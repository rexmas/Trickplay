


#include <cstring>
#include <cstdlib>

#include "curl/curl.h"

#include "network.h"

namespace Network
{
    
    //=========================================================================
    
    Request::Request(TPContext * context)
    :
        method("GET"),
        timeout_s(30),
        redirect(true)
    {
        gchar * ua=g_strdup_printf("Mozilla/5.0 (compatible; %s-%s) TrickPlay/%d.%d.%d (%s/%d; %s/%s)",
            context->get(TP_SYSTEM_LANGUAGE),
            context->get(TP_SYSTEM_COUNTRY),
            TP_MAJOR_VERSION,TP_MINOR_VERSION,TP_PATCH_VERSION,
            context->get(TP_APP_ID),
            context->get_int(APP_RELEASE,0),
            context->get(TP_SYSTEM_NAME),
            context->get(TP_SYSTEM_VERSION));
        
        user_agent=ua;
        
        g_free(ua);
        
        // We're going to use this later to manage cookies
        
        app_id=context->get(TP_APP_ID);
    }
    
    //=========================================================================
    
    Response::Response()
    :
        code(0),
        body(g_byte_array_new()),
        failed(false)
    {
    }
    
    Response::~Response()
    {
        g_byte_array_unref(body);
    }
    
    Response::Response(const Response & other)
    :
        code(other.code),
        headers(other.headers),
        status(other.status),
        body(other.body),
        failed(other.failed)
    {
        g_byte_array_ref(body);
    }
    
    //=========================================================================
    
    class NetworkThread
    {
    public:
            
        static void shutdown()
        {
            get(true);
        }
        
        static void perform_request_async_incremental(const Request & request,IncrementalResponseCallback callback,gpointer user)
        {
            get()->submit_request(request,callback,user);
        }

        static void perform_request_async(const Request & request,ResponseCallback callback,gpointer user)
        {
            get()->submit_request(request,callback,user);
        }
        
        static Response perform_request(const Request & request)
        {
            RequestClosure closure(request);
            
            CURL * eh=create_easy_handle(&closure);
            
            if (eh)
            {
                CURLcode c = curl_easy_perform(eh);
                
                if (c!=CURLE_OK)
                    request_failed(&closure,c);
                    
                curl_easy_cleanup(eh);
            }
            
            return closure.response;
        }

    private:
        
        //.....................................................................
        // Gets the network thread instance, creating it if it doesn't exist.
        // Or, destroys it.
        
        static NetworkThread * get(bool destroy=false)
        {
            static NetworkThread * thread=NULL;
            
            if(!destroy)
            {
                if (!thread)
                {
                    thread=new NetworkThread();
                }
            }
            else 
            {
                if (thread)
                {
                    delete thread;
                    thread=NULL;
                }
            }
            return thread;
        }
        
        //.....................................................................
        // Internal structure to hold all the things we care about
        
        struct RequestClosure
        {
            RequestClosure(const Request & req)
            :
                request(req),
                callback(NULL),
                incremental_callback(NULL),
                data(NULL),
                got_body(false),
                put_offset(0)
            {}

            RequestClosure(const Request & req,ResponseCallback cb,gpointer d)
            :
                request(req),
                callback(cb),
                incremental_callback(NULL),
                data(d),
                got_body(false),
                put_offset(0)
            {}
            
            RequestClosure(const Request & req,IncrementalResponseCallback icb,gpointer d)
            :
                request(req),
                callback(NULL),
                incremental_callback(icb),
                data(d),
                got_body(false),
                put_offset(0)
            {}

            Request                     request;
            ResponseCallback            callback;
            IncrementalResponseCallback incremental_callback;
            gpointer                    data;
            Response                    response;
            bool                        got_body;
            size_t                      put_offset;
        };
        
        //.....................................................................
        // Puts a new request closure into the queue
        
        void submit_request(const Request & request,ResponseCallback callback,gpointer user)
        {
            g_async_queue_push(queue,new RequestClosure(request,callback,user));
        }
        
        //.....................................................................
        // Puts a new incremental request closure into the queue

        void submit_request(const Request & request,IncrementalResponseCallback callback,gpointer user)
        {
            g_async_queue_push(queue,new RequestClosure(request,callback,user));
        }

        //.....................................................................
        // Callback to destroy request closures that are left in the queue
        
        static void destroy_request_closure(gpointer closure)
        {
            if (closure!=GINT_TO_POINTER(1))
                delete (RequestClosure*)closure;
        }
        
        //.....................................................................
        // This method is invoked by a gsource in the main thread - it invokes
        // the user callback and deletes the request closure
        
        static gboolean response_notify(gpointer data)
        {
            RequestClosure * closure=(RequestClosure*)data;
            closure->callback(closure->response,closure->data);
            delete closure;
            return FALSE;
        }
        
        static void request_finished(RequestClosure * closure)
        {
            // If it is incremental, we invoke the callback right here and
            // delete the closure
            
            if (closure->incremental_callback)
            {
                closure->incremental_callback(closure->response,NULL,0,true,closure->data);
                delete closure;
            }
            
            // Otherwise, we post it to the main thread
            
            else
            {
                GSource * source = g_idle_source_new();
                g_source_set_callback(source,response_notify,closure,NULL);
                g_source_attach(source,g_main_context_default());
                g_source_unref(source);
            }
        }
        
        static void request_failed(RequestClosure * closure,CURLcode c)
        {
            closure->response.failed=true;
            closure->response.code=c;
            closure->response.status=curl_easy_strerror(c);
            
            g_warning("URL REQUEST FAILED '%s' : %d : %s",closure->request.url.c_str(),c,closure->response.status.c_str());
        }
        
        //=====================================================================
        // CURL calllbacks
        // The last parameter is a pointer to a RequestClosure
        
        static size_t curl_write_callback(void * ptr,size_t size,size_t nmemb,void * c)
        {
            g_assert(c);            
            size_t result=size*nmemb;
            RequestClosure * closure = (RequestClosure*) c;
            
            closure->got_body=true;

            if (closure->incremental_callback)
            {
                // If the callback returns false, we return 0 so that
                // curl will abort the request
                
                if (!closure->incremental_callback(closure->response,ptr,result,false,closure->data))
                    result = 0;                    
            }
            else
            {
                g_byte_array_append(closure->response.body,(const guint8*)ptr,result);
            }
            
            return result;
        }
        
        static size_t curl_read_callback(void * ptr,size_t size,size_t nmemb,void * c)
        {
            g_assert(c);            
            size_t result=size*nmemb;
            RequestClosure * closure = (RequestClosure*) c;
            
            if (closure->request.body.length()==0)
                return 0;
            
            size_t left=closure->request.body.length()-closure->put_offset;
            
            if (left>result)
                left=result;
                
            if (left)
            {
                memcpy(ptr,closure->request.body.c_str(),left);
            
                closure->put_offset+=left;
            }

            return left;
        }
        
        static size_t curl_header_callback(void * ptr,size_t size,size_t nmemb,void * c)
        {
            g_assert(c);            
            size_t result=size*nmemb;
            RequestClosure * closure = (RequestClosure*) c;
            
            // The last header only has two bytes
            
            if (result==2)
            {
                // do nothing
            }
            // This is to ignore trailer headers that may come after the body
            
            else if (!closure->got_body && result>2)
            {
                String header((char*)ptr,result-2);
                
                size_t sep = header.find(':');
                
                // If it doesn't have a ":", it must be the status line
                
                if (sep==std::string::npos)
                {
                    closure->response.headers.clear();
                    
                    gchar**parts=g_strsplit(header.c_str()," ",3);
                    
                    if(g_strv_length(parts)!=3)
                    {
                        g_warning("BAD HEADER LINE '%s'",header.c_str());
                    }
                    else
                    {
                        closure->response.code=atoi(parts[1]);
                        closure->response.status=parts[2];
                    }
                    g_strfreev(parts);
                }
                else
                {
                    closure->response.headers.insert(
                        std::make_pair(header.substr(0,sep),header.substr(sep+2,header.length())));
                }
            }
            
            return result;
        }

        //=====================================================================
        // Set-up an easy handle

        #define cc(f) if(CURLcode c=f) throw c
        
        static CURL * create_easy_handle(RequestClosure * closure)
        {
            CURL * eh=curl_easy_init();
            g_assert(eh);
            
            try
            {
                // Limit to http and https - nothing else
                cc(curl_easy_setopt(eh,CURLOPT_PROTOCOLS,CURLPROTO_HTTP|CURLPROTO_HTTPS));
                
                cc(curl_easy_setopt(eh,CURLOPT_PRIVATE,closure));
                
                cc(curl_easy_setopt(eh,CURLOPT_NOPROGRESS,1));
                cc(curl_easy_setopt(eh,CURLOPT_NOSIGNAL,1));
                cc(curl_easy_setopt(eh,CURLOPT_WRITEFUNCTION,curl_write_callback));
                cc(curl_easy_setopt(eh,CURLOPT_WRITEDATA,closure));
                cc(curl_easy_setopt(eh,CURLOPT_READFUNCTION,curl_read_callback));
                cc(curl_easy_setopt(eh,CURLOPT_READDATA,closure));
                cc(curl_easy_setopt(eh,CURLOPT_HEADERFUNCTION,curl_header_callback));
                cc(curl_easy_setopt(eh,CURLOPT_HEADERDATA,closure));
                // TODO: SSL CTX function
                cc(curl_easy_setopt(eh,CURLOPT_URL,closure->request.url.c_str()));
                // TODO: proxy
                cc(curl_easy_setopt(eh,CURLOPT_FOLLOWLOCATION,closure->request.redirect?1:0));
                cc(curl_easy_setopt(eh,CURLOPT_USERAGENT,closure->request.user_agent.c_str()));
                
                struct curl_slist * headers=NULL;
                for(StringMap::const_iterator it=closure->request.headers.begin();it!=closure->request.headers.end();++it)
                    curl_slist_append(headers,std::string(it->first+":"+it->second).c_str());
                
                cc(curl_easy_setopt(eh,CURLOPT_HTTPHEADER,headers));
                // TODO: do we free the slist?
                
                if (closure->request.method=="PUT")
                {
                    cc(curl_easy_setopt(eh,CURLOPT_UPLOAD,1));
                    cc(curl_easy_setopt(eh,CURLOPT_INFILESIZE,closure->request.body.size()));
                }
                else if (closure->request.method=="POST")
                {
                    cc(curl_easy_setopt(eh,CURLOPT_POST,1));
                    cc(curl_easy_setopt(eh,CURLOPT_POSTFIELDSIZE,1));
                }
                else if (closure->request.method!="GET")
                {
                    cc(curl_easy_setopt(eh,CURLOPT_CUSTOMREQUEST,closure->request.method.c_str()));
                }
                
                cc(curl_easy_setopt(eh,CURLOPT_TIMEOUT_MS,closure->request.timeout_s*1000));
                
                //cc(curl_easy_setopt(eh,CURLOPT_VERBOSE,1));
                
                //cc(curl_easy_setopt(eh,CURLOPT_COOKIEFILE,""));
                //cc(curl_easy_setopt(eh,CURLOPT_COOKIEJAR,"/home/pablo/build/cookies"));
                
            }
            catch(CURLcode c)
            {
                curl_easy_cleanup(eh);
                eh=NULL;
                request_failed(closure,c);
            }
            
            return eh;
        }

#undef cc

        //=====================================================================
        // The thread function. It gets new requests from the queue and processes
        // existing requests.
        
        static gpointer process(gpointer q)
        {
            g_debug("STARTED NETWORK THREAD");
            
            // Get the queue and hold on to it
            
            GAsyncQueue * queue=(GAsyncQueue*)q;            
            g_async_queue_ref(queue);
            
            // Initialize the multi handle
            
            CURLM * multi=curl_multi_init();
            g_assert(multi);
            
            // Variables pulled out of the loop
            
            GTimeVal tv;
            long timeout;
            glong pop_wait;
            gpointer new_request;
            int running_handles=0;
            
            while(true)
            {
                if (running_handles)
                {
                    // If there are running requests, we won't wait for new ones
                    // to arrive
                
                    pop_wait=0;
                }
                else
                {
                    // Otherwise, we use the curl multi timeout as guidance. This
                    // number is sometimes completely out of whack.
                    
                    timeout=0;
                    curl_multi_timeout(multi,&timeout);
                    
                    pop_wait = (timeout<0 || timeout>1000) ? G_USEC_PER_SEC : timeout * 1000;                    
                }
                
                if (pop_wait)
                {
                    // Wait for a new request
                    
                    g_get_current_time(&tv);
                    g_time_val_add(&tv,pop_wait);
                
                    new_request=g_async_queue_timed_pop(queue,&tv);
                }
                else
                {
                    // See if there is a new request but don't wait
                    
                    new_request=g_async_queue_try_pop(queue);
                }
                
                // A 1 means we should exit
                
                if (new_request==GINT_TO_POINTER(1))
                    break;
                            
                if (new_request)
                {
                    // Initialize the new request
                    
                    RequestClosure * closure=(RequestClosure*)new_request;
                    
                    // Create the easy handle for it
                    
                    CURL * eh=create_easy_handle(closure);
                    
                    if (!eh)
                        request_finished(closure);
                    else
                        curl_multi_add_handle(multi,eh);
                }
                
                // Perform all the requests
                
                while(true)
                {
                    CURLMcode result=curl_multi_perform(multi,&running_handles);
                    
                    if (result!=CURLM_CALL_MULTI_PERFORM)
                        break;
                }
                
                // Check for requests that are finished, whether completed or
                // failed
                
                int msgs_in_queue;
                
                while(true)
                {
                    CURLMsg * msg = curl_multi_info_read(multi,&msgs_in_queue);
                    
                    if(!msg)
                        break;
                    
                    if(msg->msg==CURLMSG_DONE)
                    {
                        RequestClosure * closure=NULL;
                        
                        curl_easy_getinfo(msg->easy_handle,CURLINFO_PRIVATE,&closure);
                        g_assert(closure);
                        
                        if(msg->data.result!=CURLE_OK)
                            request_failed(closure,msg->data.result);
                            
                        request_finished(closure);
                                            
                        curl_easy_cleanup(msg->easy_handle);
                    }
                }
            }
            
            curl_multi_cleanup(multi);
            
            g_async_queue_unref(queue);
            
            g_debug("NETWORK THREAD TERMINATING");
            
            return NULL;
        }
        
        NetworkThread()
        {
            queue = g_async_queue_new_full(destroy_request_closure);
            g_assert(queue);
            
            thread = g_thread_create(process,queue,TRUE,NULL);
            g_assert(thread);
        }
        
        ~NetworkThread()
        {
            g_async_queue_push(queue,GINT_TO_POINTER(1));
            g_thread_join(thread);
            g_async_queue_unref(queue);
        }
        
        GAsyncQueue * queue;
        GThread *     thread;
    };

    //=========================================================================
    
    void shutdown()
    {
        NetworkThread::shutdown();
    }
    
    void perform_request_async_incremental(const Request & request,IncrementalResponseCallback callback,gpointer user)
    {
        NetworkThread::perform_request_async_incremental(request,callback,user);    
    }
    
    void perform_request_async(const Request & request,ResponseCallback callback,gpointer user)
    {
        NetworkThread::perform_request_async(request,callback,user);
    }
    
    Response perform_request(const Request & request)
    {
        return NetworkThread::perform_request(request);
    }    
};