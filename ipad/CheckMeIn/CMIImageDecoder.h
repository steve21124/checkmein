//
//  CMIImageDecoder.h
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "CMIImageDecoderDelegate.h"

@protocol CMIImageDecoder <NSObject>

- (id<CMIImageDecoderDelegate>)delegate;
- (void)decodeImage:(UIImage*)query;
- (void)cancel;

@end

/**
 * A default implementation of CMIImageDecoder that does nothing.
 */
@interface CMIImageDecoder : NSObject <CMIImageDecoder> {
    id<CMIImageDecoderDelegate> _delegate;
}

@property(nonatomic, assign) id<CMIImageDecoderDelegate> delegate;

@end
