#import "Client.h"
@implementation Client


- (id)initWithViewController:(ViewController*)v
{
    self = [super init];
    
    vc = v;

    services = [NSMutableArray new];
    serviceBrowser = [NSNetServiceBrowser new];
    
    [serviceBrowser setDelegate:self];
    [serviceBrowser searchForServicesOfType:@"_music._tcp." inDomain:@"local."];
    
    return self;
}


- (EchoConnection *)connectTo:(NSNetService*)service 
{
    CFReadStreamRef     readStream = NULL;
    CFWriteStreamRef    writeStream = NULL;
    
    
    CFNetServiceRef netService = CFNetServiceCreate(
                                                    NULL, 
                                                    (CFStringRef) [service domain], 
                                                    (CFStringRef) [service type], 
                                                    (CFStringRef) [service name], 
                                                    0
                                                    );
    
    if (netService != NULL) {
        CFStreamCreatePairWithSocketToNetService(
                                                 NULL, 
                                                 netService, 
                                                 &readStream, 
                                                 &writeStream
                                                 );
        CFRelease(netService);
    }
    
    
    EchoConnection *conn = [[EchoConnection alloc] initWithInputStream:(NSInputStream*)readStream outputStream:(NSOutputStream*)writeStream viewController:vc];
    [conn open];
    
    CFRelease(readStream);
    CFRelease(writeStream);
    
    return conn;
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing 
{
    [services addObject:aNetService];
    
    if (!connection)
        connection = [self connectTo:aNetService];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing 
{
    [services removeObject:aNetService];
}

@end
