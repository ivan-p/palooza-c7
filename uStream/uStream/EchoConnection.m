#import "EchoConnection.h"
#import "ViewController.h"

@implementation EchoConnection


- (void)dealloc
{
    [_inputStream release];
    [_outputStream release];
    [super dealloc];
}

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream viewController:(ViewController*)vc
{
    self = [super init];
    if (self != nil) {
        self->_inputStream = [inputStream retain];
        self->_outputStream = [outputStream retain];
        _vc = vc;
        [_vc setDelegate:self];
        
        outBuf = [[NSMutableData alloc] initWithCapacity:100*1024];
        inBuf = [[NSMutableData alloc] initWithCapacity:100*1024];
    }
    return self;
}


- (BOOL)open {
    [_inputStream  setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream  open];
    [_outputStream open];
    return YES;
}


- (void)close {
    [_inputStream  setDelegate:nil];
    [_outputStream setDelegate:nil];
    [_inputStream  close];
    [_outputStream close];
    [_inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void)tryWrite
{
    @synchronized(outBuf)
    {
        if (outBuf.length)
        {
            NSInteger actuallyWritten = [_outputStream write:[outBuf bytes] maxLength:outBuf.length];
            if (actuallyWritten > 0)
            {
                [outBuf replaceBytesInRange:NSMakeRange(0, actuallyWritten) withBytes:NULL length:0];
            }
        }
    }
}


- (void)detectIncomingFile
{
    int len = [inBuf length];
    
    if (len < 4)
        return;
    
    size_t fnameLen = 0;
    memcpy(&fnameLen, inBuf.bytes, 4);
    
    assert(fnameLen < 1024);
    
    if (len < fnameLen + 8)
        return;
    
    size_t dataLen = 0;
    memcpy(&dataLen, inBuf.bytes + 4 + fnameLen, 4);
    
    if (len < fnameLen + 4 + dataLen + 4)
        return;

    NSData *fnameData = [NSData dataWithBytes:(inBuf.bytes + 4) length:fnameLen];
    NSData *fileData = [NSData dataWithBytes:(inBuf.bytes + 4 + fnameLen + 4) length:dataLen];
    
    [inBuf replaceBytesInRange:NSMakeRange(0, fnameLen + 4 + dataLen + 4) withBytes:NULL length:0];
    
    NSString *fname = [[NSString alloc] initWithData:fnameData encoding:NSUTF8StringEncoding];
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fname];
    [fileData writeToFile:path atomically:YES];
    [_vc addFile:path];
    
}


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
   
    switch(streamEvent) {
        case NSStreamEventHasBytesAvailable: {
            uint8_t buffer[100*1024];
            NSInteger actuallyRead = [_inputStream read:(uint8_t *)buffer maxLength:sizeof(buffer)];
            if (actuallyRead > 0)
            {
                [inBuf appendBytes:buffer length:actuallyRead];
            }
            [self detectIncomingFile];
        } break;
        case NSStreamEventEndEncountered:
        case NSStreamEventErrorOccurred: {
            [self close];
        } break;
        case NSStreamEventHasSpaceAvailable: {
            [self tryWrite];
            break;
        }
        case NSStreamEventOpenCompleted:
        default: {
            // do nothing
        } break;
    }
}


- (void)onFileReadyToSend:(NSString*)path
{
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    size_t dataLen = [fileData length];
    
    NSData *data = [[path lastPathComponent] dataUsingEncoding:NSUTF8StringEncoding];
    size_t fnameLen = [data length];
    
    @synchronized(outBuf)
    {
        [outBuf appendBytes:&fnameLen length:4];
        [outBuf appendData:data];
        [outBuf appendBytes:&dataLen length:4];
        [outBuf appendData:fileData];
    }
    [self tryWrite];
}

@end

