//
//  CMISetupController.h
//  CheckMeIn
//
//  Created by Antonio MENDES PINTO on 17/09/11.
//  Copyright (c) 2011 Moodstocks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"


@interface CMISetupController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    // The request to communicate with the server
    ASIHTTPRequest *_request;    
}

@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) NSURL *url;

@end
