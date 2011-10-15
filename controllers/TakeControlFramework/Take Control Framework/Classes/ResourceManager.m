//
//  ResourceManager.m
//  TrickplayController_v2
//
//  Created by Rex Fenley on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResourceManager.h"


@implementation ResourceManager

- (id)initWithTVConnection:(TVConnection *)_tvConnection {
    if ((self = [super init])) {
        tvConnection = [_tvConnection retain];
        resourceNames = [[NSMutableDictionary alloc] initWithCapacity:40];
        resources = [[NSMutableDictionary alloc] initWithCapacity:40];
        loadingResources = [[NSMutableDictionary alloc] initWithCapacity:40];
    }
    return self;
}

- (void)declareResourceWithObject:(id)Object forKey:(id)resourceKey {
    [resourceNames setObject:Object forKey:resourceKey];
    if ([resources objectForKey:resourceKey]) {
        [resources removeObjectForKey:resourceKey];
    }
    
    if ([loadingResources objectForKey:resourceKey]) {
        // Use one AsyncImageView as the master which pulls the data
        NSMutableArray *dependentImages = [loadingResources objectForKey:resourceKey];
        if (dependentImages.count > 0) {
            AsyncImageView *imageView = [dependentImages objectAtIndex:0];
            [dependentImages removeObjectAtIndex:0];
            [self loadImageDataForImageView:imageView withResource:resourceKey];
        }
    }
}

- (NSMutableDictionary *)getResourceInfo:name {
    return [resourceNames objectForKey:name];
}

- (void)loadImageDataForImageView:(AsyncImageView *)imageView withResource:(NSString *)name {
    // asynchronously pull the image
    //NSLog(@" from network");
    NSURL *dataurl;
    // create the url to pull the data from
    NSString *dataURLString = [[resourceNames objectForKey:name] objectForKey:@"link"];
    fprintf(stderr, "URL String %s\n", [dataURLString UTF8String]);
    if ([dataURLString hasPrefix:@"http:"] || [dataURLString hasPrefix:@"https:"]) {
        dataurl = [NSURL URLWithString:dataURLString];
    } else {
        //Use the hostname and port to construct the url
        dataurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/%@", tvConnection.hostName, tvConnection.http_port, dataURLString]];
    }
    
    if (![loadingResources objectForKey:name]) {
        [loadingResources setObject:[NSMutableArray arrayWithCapacity:20] forKey:name];
    }
    
    // If resource hasn't been declared save image for later loading
    if (!dataURLString) {
        NSMutableArray *dependentImages = [loadingResources objectForKey:name];
        [dependentImages addObject:imageView];
        [imageView animateSpinner];
        
        return;
    }
    
    imageView.dataCacheDelegate = self;
    [imageView loadImageFromURL:dataurl resourceKey:name];
}

/**
 * Synchronous method of getting resource
 */

- (NSData *)fetchResource:(NSString *)name {
    fprintf(stderr, "Fetching resource %s", [name UTF8String]);
    NSData *tempData;
    
    if ((tempData = [resources objectForKey:name])) {
        fprintf(stderr, " from dictionary\n");
        return tempData;
    } else {    // pull resource
        fprintf(stderr, " from network\n");
        NSString *dataURLString = [[resourceNames objectForKey:name] objectForKey:@"link"];
        if ([dataURLString hasPrefix:@"http:"] || [dataURLString hasPrefix:@"https:"]) {
            tempData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dataURLString]];
        } else {
            //Use the hostname and port to construct the url
            dataURLString = [NSString stringWithFormat:@"http://%@:%d/%@", tvConnection.hostName, tvConnection.http_port, dataURLString];
            NSURL *dataurl = [NSURL URLWithString:dataURLString];
            
            tempData = [NSData dataWithContentsOfURL:dataurl];
        }
        if (tempData) {
            [resources setObject:tempData forKey:name];
        } else {
            NSLog(@"Trouble pulling resource %@ from network with url %@! Will set as nil\n", [resourceNames objectForKey:name], dataURLString);
        }
        
    }
    return tempData;
}

/**
 * Asynchronous method of getting UIImageView with resource.
 */

- (AsyncImageView *)fetchImageViewUsingResource:(NSString *)name
                                       frame:(CGRect)frame {
    AsyncImageView *imageView = [[[AsyncImageView alloc] initWithFrame:frame] autorelease];
    
    if (!name) {
        return imageView;
    }
    
    NSData *tempData;
    if ((tempData = [resources objectForKey:name])) {
        // image data already cached, set it to the view
        //imageView.image = [UIImage imageWithData:tempData];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [imageView loadImageFromData:tempData];
        });
    } else if ([loadingResources objectForKey:name]) {
        NSMutableArray *dependentImages = [loadingResources objectForKey:name];
        [dependentImages addObject:imageView];
        [imageView animateSpinner];
    } else {
        [self loadImageDataForImageView:imageView withResource:name];
    }
    
    return imageView;
}

- (void)dataReceived:(NSData *)data resourcekey:(id)resourceKey {
    if (data && resourceKey) {
        [resources setObject:data forKey:(NSString *)resourceKey];
        NSMutableArray *dependentImages = [loadingResources objectForKey:(NSString *)resourceKey];
        
        for (AsyncImageView *imageView in dependentImages) {
            [imageView loadImageFromData:data];
        }
    } else {
        NSLog(@"Could not cache data, either no key is specified or the data never arrived over the network");
        if (resourceKey) {
            NSMutableArray *dependentImages = [loadingResources objectForKey:resourceKey];
            for (AsyncImageView *imageView in dependentImages) {
                [imageView on_loadedFailed:YES];
            }
        }
    }
    
    [loadingResources removeObjectForKey:resourceKey];
}

- (void)dropResourceGroup:(NSString *)groupName {
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:40];
    for (id key in resources) {
        NSDictionary *resourceInfo = [resourceNames objectForKey:key];
        if ([resourceInfo objectForKey:@"group"] && [(NSString *)[resourceInfo objectForKey:@"group"] compare:groupName] == NSOrderedSame) {
            [keys addObject:key];
        }
    }
    for (id key in keys) {
        [resources removeObjectForKey:key];
        [resourceNames removeObjectForKey:key];
        [loadingResources removeObjectForKey:key];
    }
}

- (void)clean {
    [resourceNames removeAllObjects];
    [resources removeAllObjects];
    [loadingResources removeAllObjects];
}

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
    NSLog(@"ResourceManager dealloc");
    [self clean];

    if (tvConnection) {
        [tvConnection release];
        tvConnection = nil;
    }
    if (resourceNames) {
        [resourceNames release];
    }
    if (resources) {
        [resources release];
    }
    if (loadingResources) {
        [loadingResources release];
    }
    
    [super dealloc];
}

@end
