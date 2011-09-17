//
//  Moodstocks.h
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "ASIHTTPRequest.h"

extern NSString* const kMSApiErrorDomain;
extern NSInteger const kMSApiHTTPError;
extern NSInteger const kMSApiInvalidJSONError;

@protocol MSRequestDelegate;


@interface Moodstocks : NSObject {
    NSString* _key;
    NSString* _secret;
    ASIHTTPRequest* _request;
    NSMutableDictionary* _params;
    NSDictionary* _userInfo;
    id<MSRequestDelegate> _delegate;
}

@property(nonatomic, copy) NSString* key;
@property(nonatomic, copy) NSString* secret;
@property(nonatomic, retain) NSMutableDictionary* params;
@property(nonatomic, retain) NSDictionary* userInfo;
@property(nonatomic, assign) id<MSRequestDelegate> delegate;

- (id)initWithKey:(NSString*)key secret:(NSString*)secret;
- (id)initWithKey:(NSString*)key secret:(NSString*)secret userInfo:(NSDictionary*)userInfo;

/**
 * General purpose methods
 */
- (void)requestWithPath:(NSString *)path
            andDelegate:(id<MSRequestDelegate>)delegate;

- (void)requestWithPath:(NSString *)path
              andParams:(NSMutableDictionary*)params
            andDelegate:(id<MSRequestDelegate>)delegate;

- (void)requestWithPath:(NSString *)path
              andParams:(NSMutableDictionary*)params
          andHttpMethod:(NSString*)httpMethod
            andDelegate:(id<MSRequestDelegate>)delegate;

/**
 * Convenient wrappers around API methods
 */
- (void)echo:(id<MSRequestDelegate>)delegate;
- (void)search:(UIImage*)query delegate:(id<MSRequestDelegate>)delegate;

+ (void)cancelAllOperations;

@end

@protocol MSRequestDelegate <NSObject>

@optional

- (void)requestLoading:(ASIHTTPRequest *)request;
- (void)request:(ASIHTTPRequest *)request didFailWithError:(NSError *)error;
- (void)didCancelRequest:(ASIHTTPRequest *)request;
- (void)request:(ASIHTTPRequest *)request didLoadRawResponse:(NSData *)data;
- (void)request:(ASIHTTPRequest *)request didLoad:(id)result;


@end
