//
//  CMIScannerController.h
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import <UIKit/UIKit.h>

#if !TARGET_IPHONE_SIMULATOR
#define MS_HAS_AVFF 1
#endif

#if MS_HAS_AVFF
#import <AVFoundation/AVFoundation.h>
#endif

#import "CMIImageDecoder.h"

@protocol CMIScannerControllerDelegate;

@interface CMIScannerController : UIViewController <CMIImageDecoderDelegate
#if MS_HAS_AVFF
, AVCaptureVideoDataOutputSampleBufferDelegate
#endif
> {
    UIView* _videoPreviewView;
#if MS_HAS_AVFF
    AVCaptureSession*           captureSession;
    AVCaptureVideoPreviewLayer* previewLayer;
#endif
    
    // Querying logic
    NSTimeInterval   _lastRequestAt;
    BOOL             _done;
    
    id<CMIScannerControllerDelegate> _delegate;
}

@property (nonatomic, retain) UIView *videoPreviewView;
#if MS_HAS_AVFF
@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
#endif
@property (nonatomic, assign) id<CMIScannerControllerDelegate> delegate;

@end

@protocol CMIScannerControllerDelegate<NSObject>
@optional

- (void)scannerController:(CMIScannerController*)scanner didFound:(NSString*)authToken;

@end
