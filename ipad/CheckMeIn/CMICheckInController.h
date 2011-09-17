//
//  CheckInController.h
//  CheckMeIn
//
//  Created by Antonio MENDES PINTO on 17/09/11.
//  Copyright (c) 2011 Moodstocks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"


@interface CMICheckInController : UIViewController<MBProgressHUDDelegate, ASIHTTPRequestDelegate> {
	MBProgressHUD *HUD;
    
    ASIHTTPRequest *_request; 
    
    NSString *_accessToken;
    
    NSDictionary *infos;
    NSMutableArray *tips;
    NSMutableArray *coupons;
}

@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) ASIHTTPRequest *request;

- (void) checkin;
- (void) loadInfos;

@end
