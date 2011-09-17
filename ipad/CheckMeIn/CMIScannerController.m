//
//  CMIScannerController.m
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "CMIScannerController.h"

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
     
    [self.captureSession startRunning];    
#endif
}

- (void)stopCapture {
#if MS_HAS_AVFF
    [captureSession stopRunning];
    
    AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:input];
    
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*) [captureSession.outputs objectAtIndex:0];
    [captureSession removeOutput:output];
    
    self.captureSession = nil;
#endif
}

@end


@implementation CMIScannerController

#if MS_HAS_AVFF
@synthesize captureSession;
#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startCapture];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

#if MS_HAS_AVFF
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CGImageRef imageRef = CMICreateImageFromSampleBuffer(sampleBuffer);
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    
    // TODO: decode the image
    
    CGImageRelease(imageRef);
    [image release];
}
#endif

@end
