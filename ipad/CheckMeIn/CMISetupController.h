//
//  CMISetupController.h
//  CheckMeIn
//
//  Created by Antonio MENDES PINTO on 17/09/11.
//  Copyright (c) 2011 Moodstocks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import <CoreLocation/CoreLocation.h>

@interface CMISetupController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, CLLocationManagerDelegate> {
    // The request to communicate with the server
    ASIHTTPRequest *_request; 
        
    // User Location
    CLLocationManager *_locMgr;
    CLLocationCoordinate2D ll;
    
    id selectedVenue;
    
    NSMutableArray *_venues;
    
    UITableView *resultsTV;    
}

-(IBAction)search:(id)sender;

@property (nonatomic, retain) ASIHTTPRequest *request;

@property (nonatomic, retain) IBOutlet UITextField *searchField;
@property (nonatomic, retain) IBOutlet UITableView *resultsTV;

@property (nonatomic, retain) CLLocationManager *locMgr;

@property (nonatomic, retain) NSMutableArray *venues;

@end
