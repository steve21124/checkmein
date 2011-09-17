//
//  MSImageDecoderDelegate.h
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

@class CMIImageDecoder;

@protocol CMIImageDecoderDelegate <NSObject>
@optional
- (void)decoderWillDecode:(CMIImageDecoder *)decoder;
- (void)decoder:(CMIImageDecoder *)decoder didDecodeImage:(UIImage *)image withResult:(NSString *)uid;
- (void)decoder:(CMIImageDecoder *)decoder failedToDecodeImage:(UIImage *)image withReason:(NSString *)reason;
@end
