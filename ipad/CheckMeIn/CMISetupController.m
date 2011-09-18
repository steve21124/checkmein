//
//  CMISetupController.m
//  CheckMeIn
//
//  Created by Antonio MENDES PINTO on 17/09/11.
//  Copyright (c) 2011 Moodstocks. All rights reserved.
//

#import "CMISetupController.h"
#import "SBJson.h"

#import "NSString+URLEncode.h"
#import "NSUserDefaults+Extensions.h"

#import "CMIConstants.h"

@implementation CMISetupController

@synthesize request = _request;
@synthesize searchField = _searchField;
@synthesize locMgr = _locMgr;
@synthesize venues = _venues;
@synthesize resultsTV;
@synthesize delegate = _delegate;
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

- (void) dealloc {
    [super dealloc];
    
    [_request release];
    [_locMgr release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.jpg"]];
    self.view.backgroundColor = background;
    [background release];

    
    self.resultsTV.alpha = 0;
    
    self.locMgr = [[CLLocationManager alloc] init];
    self.locMgr.delegate = self;
    self.locMgr.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locMgr.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [self.locMgr startUpdatingLocation];
    
    if (!self.delegate) {
        // initial configuration
        self.navItem.rightBarButtonItem = nil;
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.venues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[self.venues objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    NSString *location = [[self.venues objectAtIndex:indexPath.row] valueForKey:@"location"];
    if (location) {
        cell.detailTextLabel.text = [location valueForKey:@"address"];
    }
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedVenue = [self.venues objectAtIndex:indexPath.row];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:[selectedVenue valueForKey:@"name"]
                                                      message:@"Is this really your place ?"  
                                                     delegate:nil  
                                            cancelButtonTitle:@"No"  
                                            otherButtonTitles:@"Yes !", nil];  
    
    message.delegate = self;
    
    [message show];  
    
    [message release]; 
}

#pragma mark - Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex  
{  
    if (buttonIndex == 1) {        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        ud.foursquareVenueId = [selectedVenue valueForKey:@"id"];
        [ud synchronize];
        
        if (self.delegate) {
            [self.delegate setupDidSelectVenue];
        }
        
        [self dismissModalViewControllerAnimated:YES];
    }
} 

#pragma mark - Actions

-(IBAction)search:(id)sender;
{    
    if (self.request != nil)
        [self.request cancel];

    // TODO : CHANGE THAT :
    // Get the geoloc of the user
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?query=%@&ll=%lf,%lf&client_id=%@&client_secret=%@&v=%@", [self.searchField.text urlEncode], ll.latitude, ll.longitude, kCMI4qClientId, kCMI4qClientSecret, kCMI4qVersion];

    //NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?query=%@&ll=%lf,%lf&client_id=%@&client_secret=%@&v=%@", [self.searchField.text urlEncode], 48.869449359999997, 2.3415347299999998, kCMI4qClientId, kCMI4qClientSecret, kCMI4qVersion];
    
    NSURL *searchURL = [NSURL URLWithString: urlString];
    
    self.request = [ASIHTTPRequest requestWithURL:searchURL];
    [self.request setDelegate:self];
    
    [self.request startAsynchronous];
}

-(IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ASIHTTPRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    NSDictionary *results = [responseString JSONValue];
    self.venues = [[results valueForKey:@"response"] valueForKey:@"venues"];
    
    if ([self.venues count] > 0) {
        [UIView beginAnimations: @"Fade In" context:nil];
        
        // druation of animation
        [UIView setAnimationDuration:0.5];
        self.resultsTV.alpha = 1;
        [UIView commitAnimations];
    }
    
    [self.resultsTV reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
}

#pragma mark - Core Location delegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{    
    ll = [newLocation coordinate];
}

- (void)locationError:(NSError *)error 
{
	//locLabel.text = [error description];
}

@end
