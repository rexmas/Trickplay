//
//  AppBrowserController.m
//  TrickplayController
//
//  Created by Rex Fenley on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppBrowser.h"
#import "AppBrowserViewController.h"
#import "Extensions.h"



@implementation AppInfo

@synthesize name;
@synthesize appID;

- (id)init {
    return [self initWithAppDictionary:nil];
}

- (id)initWithAppDictionary:(NSDictionary *)dictionary {
    if (!dictionary) {
        [self release];
        return nil;
    }
    
    self = [super init];
    if (self) {
        name = [(NSString *)[dictionary objectForKey:@"name"] retain];
        appID = [(NSString *)[dictionary objectForKey:@"id"] retain];
    }
    
    return self;
}

- (void)dealloc {
    [name release];
    name = nil;
    [appID release];
    appID = nil;
    
    [super dealloc];
}

@end





@implementation AppBrowser

@synthesize availableApps;
@synthesize delegate;
@synthesize currentApp;
@synthesize tvConnection;

#pragma mark -
#pragma mark Initialization

- (id)init
{
    return [self initWithConnection:nil delegate:nil];
}

- (id)initWithDelegate:(id <AppBrowserDelegate>)_delegate {
    return [self initWithConnection:nil delegate:_delegate];
}

- (id)initWithConnection:(TVConnection *)_connection delegate:(id<AppBrowserDelegate>)_delegate {
    
    self = [super init];
    if (self) {
        self.delegate = _delegate;
        self.tvConnection = _connection;
        [self.tvConnection setAppBrowser:self];

        viewControllers = [[NSMutableArray alloc] initWithCapacity:5];
        
        // Asynchronous URL connections for populating the table with
        // available apps and fetching information on the current
        // running app
        fetchAppsConnection = nil;
        currentAppInfoConnection = nil;
        
        // The data buffers for the connections
        fetchAppsData = nil;
        currentAppData = nil;
        
        availableApps = [[NSMutableArray alloc] initWithCapacity:10];
        currentApp = nil;
        
        /**
        // Can't do this automatically for now
        if (self.delegate) {
            [self refreshCurrentApp];
            [self refreshAvailableApps];
        }
        **/
    }
    
    return self;
}


#pragma mark -
#pragma Setters/Getters

- (void)setCurrentApp:(AppInfo *)_currentApp {
    @synchronized (self) {
        [_currentApp retain];
        [currentApp release];
        currentApp = _currentApp;
    }
}

- (void)setAvailableApps:(NSMutableArray *)_availableApps {
    @synchronized (self) {
        [_availableApps retain];
        [availableApps release];
        availableApps = _availableApps;
    }
}

#pragma mark -
#pragma mark AppBrowserViewController

- (AppBrowserViewController *)createAppBrowserViewController {
    AppBrowserViewController *viewController = [[AppBrowserViewController alloc] initWithNibName:@"AppBrowserViewController" bundle:nil appBrowser:self];
    
    return viewController;
}

- (void)addViewController:(AppBrowserViewController *)viewController {
    [viewControllers addObject:[NSValue valueWithPointer:viewController]];
}

- (void)invalidateViewController:(AppBrowserViewController *)viewController {
    NSUInteger i;
    for (i = 0; i < viewControllers.count; i++) {
        AppBrowserViewController *_viewController = [[viewControllers objectAtIndex:i] pointerValue];
        if (viewController == _viewController) {
            break;
        }
    }
    
    if (viewController == [[viewControllers objectAtIndex:i] pointerValue]) {
        [viewControllers removeObjectAtIndex:i];
    }
}

- (void)viewControllersRefresh {
    for (unsigned int i = 0; i < viewControllers.count; i++) {
        AppBrowserViewController *viewController = [[viewControllers objectAtIndex:i] pointerValue];
        
        [viewController.tableView reloadData];
    }
}

#pragma mark -
#pragma mark Retrieving App Info From Network

- (void)matchCurrentAppToAvailableApps {
    if (currentApp && availableApps) {
        for (AppInfo *app in availableApps) {
            if ([currentApp.name compare:app.name] == NSOrderedSame) {
                self.currentApp = app;
                break;
            }
        }
    }
}

// TODO: if either currentapp or availableApps have no match this
// could cause problems
- (void)matchAvailableAppsToCurrentApp {
    if (currentApp && availableApps) {
        NSUInteger i;
        for (i = 0; i < availableApps.count; i++) {
            AppInfo *app = [availableApps objectAtIndex:i];
            if ([currentApp.name compare:app.name] == NSOrderedSame) {
                break;
            }
        }
        
        if (currentApp.name == ((AppInfo *)[availableApps objectAtIndex:i]).name) {
            [availableApps replaceObjectAtIndex:i withObject:currentApp];
        }
    }
}

/**
 * Returns true if the AppBrowserViewController can confirm an app is running
 * on Trickplay by asking it over the network.
 */

/*
- (BOOL)hasRunningApp {
    
    NSDictionary *currentAppInfo = [self getCurrentAppInfo];
    NSLog(@"Received JSON dictionary current app data = %@", currentAppInfo);
    if (!currentAppInfo) {
        return NO;
    }
    
    self.currentAppName = (NSString *)[currentAppInfo objectForKey:@"name"];
    
    if (currentAppName && ![currentAppName isEqualToString:@"Empty"]) {
        return YES;
    }
    
    return NO;
}
 */

/**
 * Asks Trickplay for the currently running app and any information pertaining
 * to this app assembled in a JSON string. The method takes this JSON string reply
 * and returns it as an NSDictionary or nil on error.
 *
 * TODO: be very explicit of what instance variables are used to
 * inform user of read/write locks necessary for multithreading
 */
/*
- (NSDictionary *)getCurrentAppInfo {
    NSLog(@"Getting Current App Info");
    
    if (!tvConnection || !tvConnection.hostName) {
        return nil;
    }
    
    // grab json data and put it into an array
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/current_app", tvConnection.hostName, tvConnection.http_port];
    NSLog(@"JSONString = %@", JSONString);
    
    NSURL *dataURL = [NSURL URLWithString:JSONString];
    NSData *JSONData = [NSData dataWithContentsOfURL:dataURL];
    //NSLog(@"Received JSONData = %@", [NSString stringWithCharacters:[JSONData bytes] length:[JSONData length]]);
    //NSArray *JSONArray = [JSONData yajl_JSON];
    if (!JSONData) {
        return nil;
    }
    
    return (NSDictionary *)[JSONData yajl_JSON];
}
 */

- (void)refresh {
    [self refreshAvailableApps];
    [self refreshCurrentApp];
}

- (void)informOfCurrentApp:(AppInfo *)app {
    @synchronized (self) {
        self.currentApp = app;
        if ([[self.currentApp name] isEqualToString:@"Empty"]) {
            self.currentApp = nil;
        }
        
        [self matchCurrentAppToAvailableApps];
    }
    NSLog(@"current app: %@", self.currentApp);
    [self.delegate appBrowser:self didReceiveCurrentApp:self.currentApp];
    [self viewControllersRefresh];
}

- (void)informOfAvailableApps:(NSArray *)apps {
    @synchronized (self) {
        [availableApps removeAllObjects];
        if (apps) {
            for (NSUInteger i = 0; i < apps.count; i++) {
                [availableApps addObject:[[[AppInfo alloc] initWithAppDictionary:[apps objectAtIndex:i]] autorelease]];
            }
        }
        [self matchAvailableAppsToCurrentApp];
    }
    [self.delegate appBrowser:self didReceiveAvailableApps:self.availableApps];
    [self viewControllersRefresh];
}

- (void)refreshCurrentApp {
    NSLog(@"Fetching Current App");
    
    if (!tvConnection || !tvConnection.hostName) {
        self.currentApp = nil;
        return;
    }
        
    if (currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
    }
    if (currentAppData) {
        [currentAppData release];
        currentAppData = nil;
    }
    
    // grab json data and put it into an array
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/current_app", tvConnection.hostName, tvConnection.http_port];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:JSONString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:50.0];
    currentAppInfoConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!currentAppInfoConnection) {
        [self performSelectorOnMainThread:@selector(informOfCurrentApp:) withObject:nil waitUntilDone:NO];
    }
}

/**
 * Asks Trickplay for the most up-to-date information of apps it has available.
 * Trickplay replies with a JSON string of up-to-date apps. The method then
 * composes an NSArray of NSDictioanry Objects with information on each app
 * available to the user on the TV, each individual NSDictionary Object referring
 * to one app, and returns this NSArray to the caller. The method also sets
 * appsAvailable to this NSArray which is later used to populate the TableView.
 *
 * Returns the NSArray passed to appsAvailable or nil on error.
 */
/*
- (NSArray *)getAvailableAppsInfo {
    NSLog(@"Getting Available Apps");
    
    if (!tvConnection || !tvConnection.hostName) {
        return nil;
    }
    
    //grab json data and put it into an array
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/apps", tvConnection.hostName, tvConnection.http_port];
    
    NSURL *dataURL = [NSURL URLWithString:JSONString];
    NSData *JSONData = [NSData dataWithContentsOfURL:dataURL];
    if (appsAvailable) {
        [appsAvailable release];
    }
    appsAvailable = [[JSONData yajl_JSON] retain];
    NSLog(@"Recieved JSON array app data = %@", appsAvailable);
    
    return appsAvailable;
}
 */

- (void)refreshAvailableApps {
    NSLog(@"Fetching Available Apps");
    
    if (!tvConnection || !tvConnection.hostName) {
        [availableApps removeAllObjects];
        return;
    }
        
    if (fetchAppsConnection) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
    }
    if (fetchAppsData) {
        [fetchAppsData release];
        fetchAppsData = nil;
    }
    
    // grab json data and put it into an array
    NSString *JSONString = [NSString stringWithFormat:@"http://%@:%d/api/apps", tvConnection.hostName, tvConnection.http_port];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:JSONString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:50.0];
    fetchAppsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!fetchAppsConnection) {
        [self performSelectorOnMainThread:@selector(informOfAvailableApps:) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark -
#pragma mark NSURLConnection Handling

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData {
    if (connection == fetchAppsConnection) {
        if (!fetchAppsData) {
            fetchAppsData = [[NSMutableData alloc] initWithCapacity:10000];
        }
        
        [fetchAppsData appendData:incrementalData];
    } else if (connection == currentAppInfoConnection) {
        if (!currentAppData) {
            currentAppData = [[NSMutableData alloc] initWithCapacity:10000];
        }
        
        [currentAppData appendData:incrementalData];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == fetchAppsConnection) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
        
        NSMutableArray *apps = [fetchAppsData yajl_JSON];
        NSLog(@"Received JSON array available apps = %@", apps);
        
        [self informOfAvailableApps:apps];
    } else if (connection == currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
        
        NSLog(@"Current app: %@", [currentAppData yajl_JSON]);
        AppInfo *app = [[[AppInfo alloc] initWithAppDictionary:[currentAppData yajl_JSON]] autorelease];
                
        [self informOfCurrentApp:app];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == fetchAppsConnection) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
        
        if (error) {
            NSLog(@"Did fail fetching available apps with error: %@", error);
        }
        [self informOfAvailableApps:nil];
    } else if (connection == currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
        
        if (error) {
            NSLog(@"Did fail fetching current app with error: %@", error);
        }
        [self informOfCurrentApp:nil];
    }
}

#pragma mark -
#pragma mark Launching App

/**
 * Tells Trickplay to launch a selected app and sets this app as the current
 * app.
 */
- (void)launchApp:(AppInfo *)app {
    if (!tvConnection || !tvConnection.hostName || !app || ![app isKindOfClass:[AppBrowser class]]) {
        return;
    }
    
    NSString *launchString = [NSString stringWithFormat:@"http://%@:%d/api/launch?id=%@", tvConnection.hostName, tvConnection.http_port, app.appID];
    dispatch_queue_t launchApp_queue = dispatch_queue_create("launchAppQueue", NULL);
    dispatch_async(launchApp_queue, ^(void){
        
        NSLog(@"Launching app via url '%@'", launchString);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:launchString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        NSHTTPURLResponse *response;
        NSData *launchData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
        NSLog(@"launch data = %@", launchData);
        
        // Failure to launch
        if (response.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self.delegate appBrowser:self newAppLaunched:app successfully:NO];
                [self viewControllersRefresh];
            });
        } else {  // Successful launch
            self.currentApp = app;
        
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self.delegate appBrowser:self newAppLaunched:app successfully:YES];
                [self viewControllersRefresh];
            });
        }
    });
    dispatch_release(launchApp_queue);
}

#pragma mark -
#pragma mark Deallocation

- (void)cancelRefresh {
    if (fetchAppsConnection) {
        [fetchAppsConnection cancel];
        [fetchAppsConnection release];
        fetchAppsConnection = nil;
    }
    if (currentAppInfoConnection) {
        [currentAppInfoConnection cancel];
        [currentAppInfoConnection release];
        currentAppInfoConnection = nil;
    }
    if (fetchAppsData) {
        [fetchAppsData release];
        fetchAppsData = nil;
    }
    if (currentAppData) {
        [currentAppData release];
        currentAppData = nil;
    }
}

- (void)dealloc {
    NSLog(@"AppBrowser Dealloc");
    
    self.delegate = nil;
    [self.tvConnection setAppBrowser:nil];
    self.tvConnection = nil;
    
    [self cancelRefresh];
    
    [viewControllers release];
    
    self.currentApp = nil;
    self.availableApps = nil;
        
    [super dealloc];
}

@end