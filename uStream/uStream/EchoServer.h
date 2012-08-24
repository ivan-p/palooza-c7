#import <Foundation/Foundation.h>

@class ViewController;

@interface EchoServer : NSObject {
    ViewController *vc;
}

@property (nonatomic, assign, readonly ) NSUInteger     port;   // the actual port bound to, valid after -start

- (BOOL)start;
- (void)stop;

- (id)initWithViewController:(ViewController*)vc;

@end
