#import <Foundation/Foundation.h>
#import "EchoConnection.h"

@class ViewController;

@interface Client : NSObject <NSNetServiceBrowserDelegate> {
    NSMutableArray *       services;
    NSNetServiceBrowser *  serviceBrowser;
    ViewController *vc;
    EchoConnection *connection;
}

- (id)initWithViewController:(ViewController*)vc;

@end
