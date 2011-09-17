//
//  Moodstocks.m
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "Moodstocks.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "SBJson.h"

static NSString * const kMSApiBaseURL                         = @"http://api.moodstocks.com/v2/";
static NSString * const kMSAPISearch                          = @"search";
static NSString * const kMSAPIEcho                            = @"echo";
static const NSTimeInterval kMSAPIPersistentConnectionTimeout = 20.0; // seconds
static const BOOL kMSAPIAcceptEncodingGzip                    = NO;   // no Accept-Encoding: gzip header
static const NSTimeInterval kMSAPITimeout                     = 30.0; // seconds
static const CGFloat kMSAPIImageQuality                       = 0.75;

NSString* const kMSApiErrorDomain                             = @"moodstocks";
NSInteger const kMSApiHTTPError                               = 100;
NSInteger const kMSApiInvalidJSONError                        = 110;

#pragma mark -
#pragma mark Moodstocks (Private)

@interface Moodstocks (Private)

- (void)openUrl:(NSString *)url
         params:(NSMutableDictionary *)params
     httpMethod:(NSString *)httpMethod
       delegate:(id<MSRequestDelegate>)delegate;

- (void)handleResponseDataForRequest:(ASIHTTPRequest*)request;

- (id)parseJsonResponse:(NSData *)data error:(NSError **)error;

- (NSString*)url:(NSString*)url byAddingQueryDictionary:(NSDictionary*)query;
@end

@implementation Moodstocks(Private)

- (void)openUrl:(NSString *)url
         params:(NSMutableDictionary *)params
     httpMethod:(NSString *)httpMethod
       delegate:(id<MSRequestDelegate>)delegate {
    [_request cancel];
    [_request release]; _request = nil;
    
    [self retain];
    
    self.delegate = delegate;
    self.params = params;
    
    if ([httpMethod isEqualToString:@"POST"] ||
        [httpMethod isEqualToString:@"PUT"]) {
        _request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]] retain];
        [_request setRequestMethod:httpMethod];
        for (id key in [_params keyEnumerator]) {
            if ([[_params valueForKey:key] isKindOfClass:[NSData class]])
                [((ASIFormDataRequest*)_request) setData:[_params valueForKey:key] forKey:key];
            else if ([[_params valueForKey:key] isKindOfClass:[NSArray class]]) {
                for (id val in [[_params valueForKey:key] objectEnumerator])
                    [((ASIFormDataRequest*)_request) addPostValue:val forKey:[key stringByAppendingString:@"[]"]];
            }
            else
                [((ASIFormDataRequest*)_request) setPostValue:[_params valueForKey:key] forKey:key];
        }
    }
    else {
        // GET, DELETE or HEAD
        NSString* urlQS = [self url:url byAddingQueryDictionary:_params];
        _request = [[ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlQS]] retain];
        [_request setRequestMethod:httpMethod];
    }
    
    [_request setAuthenticationScheme:(NSString *) kCFHTTPAuthenticationSchemeDigest];
    [_request setUsername:_key];
    [_request setPassword:_secret];
    [_request setUserInfo:_userInfo];
    [_request setDelegate:self];
    [_request setTimeOutSeconds:kMSAPITimeout];
    [_request setPersistentConnectionTimeoutSeconds:kMSAPIPersistentConnectionTimeout];
    [_request setAllowCompressedResponse:kMSAPIAcceptEncodingGzip];
    [_request startAsynchronous];
}

- (void)handleResponseDataForRequest:(ASIHTTPRequest*)request {
    NSData* data = [request responseData];
    if ([_delegate respondsToSelector:@selector(request:didLoadRawResponse:)]) {
        [_delegate request:request didLoadRawResponse:data];
    }
    
    NSError* error = nil;
    id result = [self parseJsonResponse:data error:&error];
    if (error) {
        if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            [_delegate request:request didFailWithError:error];
        }
    }
    else if ([_delegate respondsToSelector:@selector(request:didLoad:)]) {
        [_delegate request:request didLoad:(result == nil ? data : result)];
    }
}

- (id)parseJsonResponse:(NSData *)data error:(NSError **)error {
    NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    id result = [json JSONValue];
    [json release]; json = nil;
    if (!result) {
        if (error != nil) {
            *error = [NSError errorWithDomain:kMSApiErrorDomain code:kMSApiInvalidJSONError userInfo:nil];
        }
        return nil;
    }
    
    return result;
}

- (NSString*)url:(NSString*)url byAddingQueryDictionary:(NSDictionary*)query {
    // This method prepares a query string and supports encoding array parameters
    NSString* u = [NSString stringWithString:url];
    NSMutableArray* queryStrings = [NSMutableArray array];
    
    for (NSString* key in [query keyEnumerator]) {
        if ([[query valueForKey:key] isKindOfClass:[NSArray class]]) {
            NSArray* ary = [query valueForKey:key];
            NSMutableArray* pairs = [NSMutableArray array];
            for (NSString* value in [ary objectEnumerator]) {
                NSString* val = [value stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                [pairs addObject:[[key stringByAppendingString:@"%5B%5D="] stringByAppendingString:val]];
            }
            
            [queryStrings addObject:[pairs componentsJoinedByString:@"&"]];
        }
        else {
            // We assume we have a string...
            NSString* val = [query valueForKey:key];
            val = [val stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
            val = [val stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
            [queryStrings addObject:[NSString stringWithFormat:@"%@=%@", key, val]];
        }
    }
    
    if ([queryStrings count] > 0) {
        NSString* qs = [queryStrings componentsJoinedByString:@"&"];
        if ([u rangeOfString:@"?"].location == NSNotFound) {
            u = [u stringByAppendingFormat:@"?%@", qs];
        } else {
            u = [u stringByAppendingFormat:@"&%@", qs];
        }
    }
    
    return u;
}

@end

@implementation Moodstocks

@synthesize key = _key;
@synthesize secret = _secret;
@synthesize params = _params;
@synthesize userInfo = _userInfo;
@synthesize delegate = _delegate;

- (id)initWithKey:(NSString*)key secret:(NSString*)secret {
    if ((self = [self initWithKey:key secret:secret userInfo:nil])) {
        // nothing to do
    }
    return self;
}

- (id)initWithKey:(NSString*)key secret:(NSString*)secret userInfo:(NSDictionary*)userInfo {
    if ((self = [super init])) {
        self.key = key;
        self.secret = secret;
        self.userInfo = userInfo;
    }
    return self;
}

- (void)dealloc {
    [_key release];
    [_secret release];
    [_request cancel];
    [_request release];
    [_params release];
    [_userInfo release];
    
    [super dealloc];
}

- (void)requestWithPath:(NSString *)path
            andDelegate:(id<MSRequestDelegate>)delegate {
    [self requestWithPath:path
                andParams:[NSMutableDictionary dictionary]
            andHttpMethod:@"GET"
              andDelegate:delegate];
}

- (void)requestWithPath:(NSString *)path
              andParams:(NSMutableDictionary*)params
            andDelegate:(id<MSRequestDelegate>)delegate {
    [self requestWithPath:path
                andParams:params
            andHttpMethod:@"GET"
              andDelegate:delegate];
}

- (void)requestWithPath:(NSString *)path
              andParams:(NSMutableDictionary*)params
          andHttpMethod:(NSString*)httpMethod
            andDelegate:(id<MSRequestDelegate>)delegate {
    NSString * fullURL = [kMSApiBaseURL stringByAppendingString:path];
    [self openUrl:fullURL params:params httpMethod:httpMethod delegate:delegate];
}

- (void)echo:(id<MSRequestDelegate>)delegate {
    NSString * fullURL = [kMSApiBaseURL stringByAppendingString:kMSAPIEcho];
    [self openUrl:fullURL params:[NSMutableDictionary dictionary] httpMethod:@"POST" delegate:delegate];
}

- (void)search:(UIImage*)query delegate:(id<MSRequestDelegate>)delegate {
    NSString * fullURL = [kMSApiBaseURL stringByAppendingString:kMSAPISearch];
    NSData *imageBlob = UIImageJPEGRepresentation(query, kMSAPIImageQuality);
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObject:imageBlob forKey:@"image_file"]; 
    [self openUrl:fullURL params:params httpMethod:@"POST" delegate:delegate];
}

+ (void)cancelAllOperations {
    [[ASIHTTPRequest sharedQueue] cancelAllOperations];
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request {
    if ([_delegate respondsToSelector:@selector(requestLoading:)]) {
        [_delegate requestLoading:request];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if ([request responseStatusCode] == 200) {
        [self handleResponseDataForRequest:request];
    }
    else {
        NSError* error = [NSError errorWithDomain:kMSApiErrorDomain
                                             code:kMSApiHTTPError
                                         userInfo:nil];
        
        if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            [_delegate request:request didFailWithError:error];
        }
    }
    
    [self autorelease];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if ([[request error] code] == ASIRequestCancelledErrorType) {
        if ([_delegate respondsToSelector:@selector(didCancelRequest:)]) {
            [_delegate didCancelRequest:request];
        }
    }
    else {
        if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            [_delegate request:request didFailWithError:[request error]];
        }
    }
    
    [self autorelease];
}

@end
