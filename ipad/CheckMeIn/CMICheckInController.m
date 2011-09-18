//
//  CheckInController.m
//  CheckMeIn
//
//  Created by Antonio MENDES PINTO on 17/09/11.
//  Copyright (c) 2011 Moodstocks. All rights reserved.
//

#import "CMICheckInController.h"

#import "CMIConstants.h"

#import "NSUserDefaults+Extensions.h"

@implementation CMICheckInController

@synthesize accessToken = _accessToken;
@synthesize request = _request;
@synthesize userAvatarView;
@synthesize title, description;
@synthesize navItem;

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

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_small"]];
    self.navItem.titleView = imageView;    

    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.jpg"]];
    self.view.backgroundColor = background;
    [background release];
    
    
    self.title.alpha = 0;
    self.description.alpha = 0;        
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.delegate = self;
        
    [self.view addSubview:HUD];
    
    [self checkin];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/checkins/add?venueId=%@&client_id=%@&client_secret=%@&v=%@&oauth_token=%@", ud.foursquareVenueId, kCMI4qClientId, kCMI4qClientSecret, kCMI4qVersion, self.accessToken];
    
    NSURL *url = [NSURL URLWithString: urlString];

    self.request = [ASIHTTPRequest requestWithURL:url];
    [self.request setDelegate:self];
    
    [self.request startAsynchronous];
    
    HUD.labelText = @"Checking in";
	
    [HUD show:YES];    
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
    
    NSLog([request responseString]);
    
    self.title.text = @"Hurray !";
    self.description.text = @"You have successfully checked in !";                    
    
    [UIView beginAnimations: @"Fade In" context:nil];
    
    // druation of animation
    [UIView setAnimationDuration:0.5];
    self.title.alpha = 1;
    self.description.alpha = 1;
    [UIView commitAnimations];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSError *error = [request error];
    [HUD removeFromSuperview];

    self.title.text = @"Oh oh ..";
    self.description.text = @"An unexpected error has occured. You have not checked in.";                    
    
    [UIView beginAnimations: @"Fade In" context:nil];
        
    // druation of animation
    [UIView setAnimationDuration:0.5];
    self.title.alpha = 1;
    self.description.alpha = 1;
    self.userAvatarView.image = [UIImage imageNamed:@"4sq_sad.png"];
    [UIView commitAnimations];
}

@end
