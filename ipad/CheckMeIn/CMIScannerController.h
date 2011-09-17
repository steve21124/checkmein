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

@interface CMIScannerController : UIViewController <CMIImageDecoderDelegate
#if MS_HAS_AVFF
, AVCaptureVideoDataOutputSampleBufferDelegate
#endif
> {
#if MS_HAS_AVFF
    AVCaptureSession*           captureSession;
#endif
    
    // Querying logic
    NSTimeInterval   _lastRequestAt;
}

#if MS_HAS_AVFF
@property (nonatomic, retain) AVCaptureSession *captureSession;
#endif

@end
