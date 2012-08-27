#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EchoServer.h"
#import "Client.h"

@protocol ViewControllerDelegate
- (void)onFileReadyToSend:(NSString*)path;
@end

@interface ViewController : UIViewController <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    
    AVCaptureConnection *audioConnection;
	AVCaptureConnection *videoConnection;
    
    UIImageView *imageView;
    int fileNum;
    
    AVAssetWriter *assetWriter;
	AVAssetWriterInput *assetWriterAudioIn;
	AVAssetWriterInput *assetWriterVideoIn;
	dispatch_queue_t movieWritingQueue;
    
    AVCaptureVideoOrientation referenceOrientation;
	AVCaptureVideoOrientation videoOrientation;
    
    
    // Only accessed on movie writing queue
    BOOL readyToRecordAudio; 
    BOOL readyToRecordVideo;
	BOOL recordingWillBeStarted;
	BOOL recordingWillBeStopped;
    
	BOOL recording;
    
    id<ViewControllerDelegate> delegate;
    
    AVPlayer *player;
    
    
    EchoServer *server;
    Client *client;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (void)addFile:(NSString*)path;
- (void)setDelegate:(id<ViewControllerDelegate>)d;

- (IBAction)onListen:(id)sender;
- (IBAction)onConnect:(id)sender;

@end
