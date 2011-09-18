//
//  CheckMeInViewController.h
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"

@interface HomeController : UIViewController {
    ASIHTTPRequest *_request;
    
    NSMutableArray *_tips;
    
    UITableView *tipsTV;
    UIView *separatorView;
}
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) NSMutableArray *tips;
@property (nonatomic, retain) IBOutlet UITableView *tipsTV;
@property (nonatomic, retain) IBOutlet UIView *separatorView;

- (IBAction)touched:(id)sender;
- (IBAction)displayInfos:(id)sender;

- (void) loadTips;

@end
