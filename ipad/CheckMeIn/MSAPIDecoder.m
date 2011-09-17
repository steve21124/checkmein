//
//  MSAPIDecoder.m
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "MSAPIDecoder.h"

#import "ASIFormDataRequest.h"

@implementation MSAPIDecoder

@synthesize key = _key;
@synthesize secret = _secret;

- (id)initWithKey:(NSString*)key secret:(NSString*)secret {
    self = [super init];
    if (self) {
        self.key = key;
        self.secret = secret;
    }
    
    return self;
}

- (void)dealloc {
    [_loadingRequest cancel];
    [_loadingRequest release]; _loadingRequest = nil; 
    [_loadedTime release];     _loadedTime = nil;
    [_key release];            _key = nil;
    [_secret release];         _secret = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark CMIImageDecoder

- (void)decodeImage:(UIImage*)query {
    [self retain];
    
    if ([_delegate respondsToSelector:@selector(decoderWillDecode:)])
        [_delegate decoderWillDecode:self];
    
    Moodstocks* ms = [[Moodstocks alloc] initWithKey:_key secret:_secret];
    [ms search:query delegate:self];
    [ms release];
}

- (void)cancel {
    [_loadingRequest cancel];
}

#pragma mark -
#pragma mark MSRequestDelegate

- (void)requestLoading:(ASIHTTPRequest *)request {
    [_loadingRequest release];
    _loadingRequest = [request retain];
}

- (void)request:(ASIHTTPRequest *)request didFailWithError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(decoder:failedToDecodeImage:withReason:)]) {
        NSString* reason = @"Unknown"; 
        switch ([error code]) {
            case ASIConnectionFailureErrorType: {
                reason = @"No connection";
                break;
            }
            case ASIAuthenticationErrorType: {
                reason = @"Invalid credentials";
                break;
            }
            default: {
                break;
            }
        }
        
        // Retrieve the image by decoding the JPEG blob
        ASIFormDataRequest* req = (ASIFormDataRequest*) _loadingRequest;
        NSData* jpeg = [(NSDictionary*) [[req fileData] objectAtIndex:0] objectForKey:@"data"];
        [_delegate decoder:self failedToDecodeImage:[UIImage imageWithData:jpeg] withReason:reason];
    }
    
    [_loadingRequest release]; _loadingRequest = nil;
    
    [self autorelease];
}

- (void)didCancelRequest:(ASIHTTPRequest *)request {
    [_loadingRequest release]; _loadingRequest = nil;
    
    [self autorelease];
}

- (void)request:(ASIHTTPRequest *)request didLoad:(id)result {
    [_loadedTime release];
    _loadedTime = [[NSDate date] retain];
    
    NSDictionary* json = (NSDictionary*) result;
    BOOL found = [[json objectForKey:@"found"] boolValue];
    if (found) {
        if ([_delegate respondsToSelector:@selector(decoder:didDecodeImage:withResult:)]) {
            NSString* uid = (NSString*) [json objectForKey:@"id"];
            
            // Retrieve the image by decoding the JPEG blob
            ASIFormDataRequest* req = (ASIFormDataRequest*) _loadingRequest;
            NSData* jpeg = [(NSDictionary*) [[req fileData] objectAtIndex:0] objectForKey:@"data"];
            [_delegate decoder:self didDecodeImage:[UIImage imageWithData:jpeg] withResult:uid];
        }
    }
    
    [_loadingRequest release]; _loadingRequest = nil;
    
    [self autorelease];
}

@end
