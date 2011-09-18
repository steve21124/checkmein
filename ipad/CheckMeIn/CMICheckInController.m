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

#import "MBProgressHUD.h"
#import "MBProgressHUDAdditions.h"

#import "SBJson.h"

#import "CheckMeInAppDelegate.h"

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

- (void)dealloc {
    [super dealloc];
    
    [_request release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_small"]];
    self.navItem.titleView = imageView;    
    //self.userAvatarView.placeholderImage = [UIImage imageNamed:@"default_userimage.png"];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.jpg"]];
    self.view.backgroundColor = background;
    [background release];
    
    checkedIn = NO;
    
    self.title.alpha = 0;
    self.description.alpha = 0;        
    
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

#pragma Loading functions

- (void) checkin {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/checkins/add?venueId=%@&client_id=%@&client_secret=%@&v=%@&oauth_token=%@", ud.foursquareVenueId, kCMI4qClientId, kCMI4qClientSecret, kCMI4qVersion, self.accessToken];
    
    NSURL *url = [NSURL URLWithString: urlString];

    self.request = [ASIHTTPRequest requestWithURL:url];
    self.request.requestMethod = @"POST";
    [self.request setDelegate:self];
    
    [self.request startAsynchronous];
}

- (void) loadUserInfos {    
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/users/self?client_id=%@&client_secret=%@&v=%@&oauth_token=%@", kCMI4qClientId, kCMI4qClientSecret, kCMI4qVersion, self.accessToken];
    
    NSURL *url = [NSURL URLWithString: urlString];
    
    self.request = [ASIHTTPRequest requestWithURL:url];
    [self.request setDelegate:self];
    
    [self.request startAsynchronous];
}

-(void) timeout {
    CheckMeInAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.viewController dismissModalViewControllerAnimated:NO];
}

#pragma mark - ASIHTTPRequest delegate

- (void)requestStarted:(ASIHTTPRequest *)request {
    if (!checkedIn) {
        [MBProgressHUD showActivityHUDAddedTo:self.view withText:@"Checking in" effect:MBProgressHUDAnimationZoom];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{    
    NSLog([request responseString]);
    
    if (!checkedIn) {
        checkedIn = YES;
        
        [self loadUserInfos];
    }
    else {        
        UIImage* image = [UIImage imageNamed:@"checkedin.png"];
        [MBProgressHUD switchHUDAddedTo:self.view toImage:image text:@"Hurray !"];        
        
        
        self.title.text = @"You're checked in.";

        NSString *responseString = [request responseString];
        
        id results = [responseString JSONValue];        
        
        
        NSString *avatarStringURL = [[[results objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"photo"];
        NSString *bigAvatarStringURL = [avatarStringURL stringByReplacingOccurrencesOfString:@"_thumbs" withString:@""];

        
        NSURL *avatarURL = [NSURL URLWithString: bigAvatarStringURL];

        
        [UIView beginAnimations: @"Fade In" context:nil];
            
        // druation of animation
        [UIView setAnimationDuration:0.5];
        self.title.alpha = 1;
        self.description.alpha = 1;
        self.userAvatarView.imageURL = avatarURL;
        [UIView commitAnimations];
        
        [self performSelector:@selector(timeout) withObject:nil afterDelay:5];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    UIImage* image = [UIImage imageNamed:@"warning.png"];
    [MBProgressHUD switchHUDAddedTo:self.view toImage:image text:@"Oops"];
    
    self.title.text = @"Checkin failed";
    self.description.text = @"An unexpected error has occured. You have not checked in.";                    
    
    [UIView beginAnimations: @"Fade In" context:nil];
        
    // druation of animation
    [UIView setAnimationDuration:0.5];
    self.title.alpha = 1;
    self.description.alpha = 1;
    self.userAvatarView.image = [UIImage imageNamed:@"4sq_sad.png"];
    [UIView commitAnimations];
    
    [self performSelector:@selector(timeout) withObject:nil afterDelay:5];    
}

@end
