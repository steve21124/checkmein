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


@interface CMICheckInController : UIViewController {
	MBProgressHUD *HUD;
    
    ASIHTTPRequest *_request; 
    
    NSString *_accessToken;
}

@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) ASIHTTPRequest *request;

@end
