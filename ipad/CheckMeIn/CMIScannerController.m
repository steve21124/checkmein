//
//  CMIScannerController.m
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "CMIScannerController.h"

#import "CMILaserView.h"
#import "CMIConstants.h"
#import "MSAPIDecoder.h"

#import "CMICheckInController.h"

static const NSUInteger kCMIScannerTimeout = 15;  // seconds before giving up

#if MS_HAS_AVFF
/* Adapted from http://developer.apple.com/library/ios/#qa/qa1702/_index.html */
CGImageRef CMICreateImageFromSampleBuffer(CMSampleBufferRef sbuf) {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sbuf); 
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
    
    return (quartzImage);
}
#endif

#pragma mark - CMIScannerController (Private)

@interface CMIScannerController (Private)

#if MS_HAS_AVFF
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *)frontFacingCamera;
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
#endif
- (void)startCapture;
- (void)stopCapture;
- (void)enableScanning:(BOOL)enable;
- (BOOL)shouldDecodeImage;
- (void)showLaser;
- (void)hideLaser;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;

@end

@implementation CMIScannerController(Private)

#if MS_HAS_AVFF

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    
    return nil;
}

- (AVCaptureDevice *)frontFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
    for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
    
	return nil;
}
#endif

- (void)startCapture {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
#if MS_HAS_AVFF
    // Set torch and flash mode to auto
	if ([[self frontFacingCamera] hasFlash]) {
		if ([[self frontFacingCamera] lockForConfiguration:nil]) {
			if ([[self frontFacingCamera] isFlashModeSupported:AVCaptureFlashModeAuto])
                [[self frontFacingCamera] setFlashMode:AVCaptureFlashModeAuto];
			[[self frontFacingCamera] unlockForConfiguration];
		}
	}
    
	if ([[self frontFacingCamera] hasTorch]) {
		if ([[self frontFacingCamera] lockForConfiguration:nil]) {
			if ([[self frontFacingCamera] isTorchModeSupported:AVCaptureTorchModeAuto])
                [[self frontFacingCamera] setTorchMode:AVCaptureTorchModeAuto];
			[[self frontFacingCamera] unlockForConfiguration];
		}
	}
    
    // == CAPTURE SESSION SETUP
    AVCaptureDeviceInput* newVideoInput            = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:nil];
    
    AVCaptureVideoDataOutput *newCaptureOutput     = [[AVCaptureVideoDataOutput alloc] init];
    newCaptureOutput.alwaysDiscardsLateVideoFrames = YES; 
    dispatch_queue_t ms_queue = dispatch_queue_create("CMIScannerController", NULL);
    [newCaptureOutput setSampleBufferDelegate:self queue:ms_queue];
    dispatch_release(ms_queue);
    NSDictionary *outputSettings                   = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                                                 forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [newCaptureOutput setVideoSettings:outputSettings];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession release];
    
    // Medium preset gives 480x360 resolution (on iPad 2)
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetMedium])
        [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    
    if ([self.captureSession canAddInput:newVideoInput])
        [self.captureSession addInput:newVideoInput];
    
    if ([self.captureSession canAddOutput:newCaptureOutput])
        [self.captureSession addOutput:newCaptureOutput];
    
    [newVideoInput release];
    [newCaptureOutput release];
    
    // == VIDEO PREVIEW SETUP
    if (!self.previewLayer)
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    
    CALayer* viewLayer = [_videoPreviewView layer];
    [viewLayer setMasksToBounds:YES];
    
    [self.previewLayer setFrame:[_videoPreviewView bounds]];
    
    // NOTE: we force landscape right orientation (see Info.plist)
    if ([self.previewLayer isOrientationSupported])
        [self.previewLayer setOrientation:AVCaptureVideoOrientationPortrait];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];

     
    [self.captureSession startRunning];
    
    [self enableScanning:YES];
#endif
}

- (void)stopCapture {
#if MS_HAS_AVFF
    [captureSession stopRunning];
    
    AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:input];
    
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*) [captureSession.outputs objectAtIndex:0];
    [captureSession removeOutput:output];
    
    [self.previewLayer removeFromSuperlayer];   
    self.previewLayer = nil;
    
    self.captureSession = nil;
    
    [self enableScanning:NO];
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)enableScanning:(BOOL)enable {
    if (enable) {
        _startedAt = [[NSDate date] timeIntervalSince1970];
        _lastRequestAt = -1.0;
        CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
            [self showLaser];
        }); 
    }
    else {
        [Moodstocks cancelAllOperations];
        CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
            [self hideLaser];
        });
    }
}

- (BOOL)shouldDecodeImage {
    BOOL decode = YES;
    if (_lastRequestAt > 0) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        if (now - _lastRequestAt < 1.0 /* second */)
            decode = NO;
    }
    
    return decode;
}

- (void)showLaser {
    CMILaserView *laserView = [[CMILaserView alloc] initWithFrame:_videoPreviewView.bounds];
    [_videoPreviewView addSubview:laserView];
    [laserView release];
}

- (void)hideLaser {
    CMILaserView* laserView = nil;
    for (UIView *v in [_videoPreviewView subviews]) {
        if ([v isKindOfClass:[CMILaserView class]])
            laserView = (CMILaserView*) v;
    }
    [laserView removeFromSuperview];
}

- (void)applicationDidEnterBackground {
    [self enableScanning:NO];
}

- (void)applicationWillEnterForeground {
    [self enableScanning:YES];
}

@end


@implementation CMIScannerController

@synthesize videoPreviewView = _videoPreviewView;
#if MS_HAS_AVFF
@synthesize captureSession;
@synthesize previewLayer;
#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _startedAt = [[NSDate date] timeIntervalSince1970];
        _lastRequestAt = -1;
        _done = NO;
    }
    return self;
}

- (void)dealloc
{
    [self stopCapture];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    _videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _videoPreviewView.backgroundColor = [UIColor blackColor];
    _videoPreviewView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _videoPreviewView.autoresizesSubviews = YES;
    [self.view addSubview:_videoPreviewView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [_videoPreviewView release];
    _videoPreviewView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startCapture];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

#if MS_HAS_AVFF
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_done)
        return;
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - _startedAt >= kCMIScannerTimeout) {
        _done = YES;
        
        CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
            [self hideLaser];
            [self dismissModalViewControllerAnimated:YES];
        });
        
        return;
    }
    
    CGImageRef imageRef = CMICreateImageFromSampleBuffer(sampleBuffer);
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    
    if ([self shouldDecodeImage]) {
        MSAPIDecoder* apiDecoder = [[MSAPIDecoder alloc] initWithKey:kCMIMoodstocksKey secret:kCMIMoodstocksSecret];
        apiDecoder.delegate = self;
        [apiDecoder decodeImage:image];
        [apiDecoder release];
    }
    
    CGImageRelease(imageRef);
    [image release];
}
#endif

#pragma - mark CMIImageDecoderDelegate

- (void)decoderWillDecode:(CMIImageDecoder *)decoder {
    _lastRequestAt = [[NSDate date] timeIntervalSince1970];
}

- (void)decoder:(CMIImageDecoder *)decoder didDecodeImage:(UIImage *)image withResult:(NSString *)uid {
    if (_done)
        return;
    
    _done = YES;
    
    [self enableScanning:NO];
    
    // Flash effect
    UIView* flashView = [[UIView alloc] initWithFrame:[_videoPreviewView frame]];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[[self view] window] addSubview:flashView];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                         [flashView release];
                     }
    ];
    
    CMICheckInController *checkInController = [[CMICheckInController alloc] initWithNibName:@"CMICheckInController" bundle:nil];
    checkInController.accessToken = uid;
    [self presentModalViewController:checkInController animated:NO];
}

@end
