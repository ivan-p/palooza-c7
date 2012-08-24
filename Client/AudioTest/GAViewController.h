#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AudioToolbox/AudioToolbox.h>

@interface GAViewController : UIViewController<NSStreamDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
    AVPlayer *player;
	NSTimer *playbackTimer;
    NSInputStream	*inputStream;
	NSOutputStream	*outputStream;
   	NSMutableArray	*messages;
    
    NSNetServiceBrowser *browser;
    NSMutableArray  *services;
}

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (nonatomic, retain) NSMutableArray *messages;

-(void) setupAVPlayerForURL: (NSURL*) url;

@end
