//
//  CheckInController.m
//  CheckMeIn
//
//  Created by Antonio MENDES PINTO on 17/09/11.
//  Copyright (c) 2011 Moodstocks. All rights reserved.
//

#import "CMICheckInController.h"

@implementation CMICheckInController

@synthesize accessToken = _accessToken;
@synthesize request = _request;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
	
    HUD.delegate = self;
    HUD.labelText = @"Loading";
    HUD.detailsLabelText = @"checking in";
	
    [HUD show:YES];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}

#pragma Loading functions

- (void) checkin {
    //NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?query=%@&ll=%lf,%lf&client_id=%@&client_secret=%@&v=%@", , , , kCMI4qClientId, kCMI4qClientSecret, kCMI4qVersion];
    
    //NSURL *url = [NSURL URLWithString: urlString];

    //self.request = [ASIHTTPRequest requestWithURL:url];
    //[self.request setDelegate:self];
    
    //[self.request startAsynchronous];    
    
    // Finished ..
    HUD.labelText = @"Loading infos";

}

- (void) loadInfos {
    //NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?query=%@&ll=%lf,%lf&client_id=%@&client_secret=%@&v=%@", , , , kCMI4qClientId, kCMI4qClientSecret, kCMI4qVersion];
    
    //NSURL *url = [NSURL URLWithString: urlString];
    
    //self.request = [ASIHTTPRequest requestWithURL:url];
    //[self.request setDelegate:self];
    
    //[self.request startAsynchronous];
}

#pragma ASIHTTPRequest delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    id results = [responseString JSONValue];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
}

@end
