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

@interface CMIScannerController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate> {
#if MS_HAS_AVFF
    AVCaptureSession*           captureSession;
#endif    
}

#if MS_HAS_AVFF
@property (nonatomic, retain) AVCaptureSession *captureSession;
#endif

@end
