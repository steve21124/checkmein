//
//  MSAPIDecoder.h
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "CMIImageDecoder.h"
#import "Moodstocks.h"

/**
 * Image decoder via HTTP querying on Moodstocks API
 */
@interface MSAPIDecoder : CMIImageDecoder <MSRequestDelegate> {
    ASIHTTPRequest* _loadingRequest;
    NSDate* _loadedTime;
    
    // Authentication parameters
    NSString* _key;
    NSString* _secret;
}

@property (nonatomic, copy) NSString* key;
@property (nonatomic, copy) NSString* secret;

- (id)initWithKey:(NSString*)key secret:(NSString*)secret;
- (void)decodeImage:(UIImage*)query;

@end
