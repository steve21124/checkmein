//
//  CMIImageDecoder.m
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "CMIImageDecoder.h"


@implementation CMIImageDecoder

@synthesize delegate = _delegate;

- (id<CMIImageDecoderDelegate>)delegate {
    return _delegate;
}

- (void)decodeImage:(UIImage*)query {
    // void implementation
}

- (void)cancel {
    // void implementation
}

- (void)dealloc {
    _delegate = nil;
    
    [super dealloc];
}

@end
