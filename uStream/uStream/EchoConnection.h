#import <Foundation/Foundation.h>

@class ViewController;

@interface EchoConnection : NSObject {
    NSInputStream *    _inputStream;
    NSOutputStream *   _outputStream;
    ViewController * _vc;
    
    NSMutableData *outBuf;
    NSMutableData *inBuf;
}

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream viewController:(ViewController*)vc;

- (BOOL)open;
- (void)close;

@end
