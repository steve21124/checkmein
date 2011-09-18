//
//  CheckMeInViewController.m
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "HomeController.h"

#import "CMIScannerController.h"
#import "CMICheckInController.h"
#import "AboutController.h"
#import "CMIConstants.h"
#import "NSUserDefaults+Extensions.h"
#import "SBJson.h"

@implementation HomeController

@synthesize navItem;
@synthesize request = _request;
@synthesize tips = _tips;
@synthesize tipsTV;
@synthesize separatorView;

- (void)dealloc
{
    [_request release];    
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_small"]];
    self.navItem.titleView = imageView;   
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.jpg"]];
    self.view.backgroundColor = background;
    [background release];

    self.separatorView.alpha = 0;
    self.tipsTV.alpha = 0;
}

- (void) viewDidAppear:(BOOL)animated {
    [self loadTips];
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

#pragma mark - Actions

- (IBAction)touched:(id)sender {
    CMIScannerController *scanner = [[CMIScannerController alloc] initWithNibName:@"CMIScannerController" bundle:nil];
    
    scanner.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentModalViewController:scanner animated:YES];
}

- (IBAction)displayInfos:(id)sender {
    AboutController *ac = [[AboutController alloc] initWithNibName:@"AboutView" bundle:nil];
    ac.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:ac animated:YES];
}

#pragma Tips

- (void) loadTips {
    if (self.request != nil)
        [self.request cancel];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // Get the geoloc of the user
    //NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?query=%@&ll=%lf,%lf&client_id=%@&client_secret=%@&v=%@", [self.searchField.text urlEncode], ll.latitude, ll.longitude, kCMI4qClientId, kCMI4qClientSecret, kCMI4qVersion];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/tips?client_id=%@&client_secret=%@&v=%@&limit=5", ud.foursquareVenueId,kCMI4qClientId, kCMI4qClientSecret, kCMI4qVersion];
    
    NSURL *searchURL = [NSURL URLWithString: urlString];
    
    self.request = [ASIHTTPRequest requestWithURL:searchURL];
    [self.request setDelegate:self];
    
    [self.request startAsynchronous];
    
}

#pragma mark - ASIHTTPRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    NSDictionary *results = [responseString JSONValue];
    self.tips = [[[results valueForKey:@"response"] valueForKey:@"tips"] valueForKey:@"items"];
    
    if ([self.tips count]) {
        [UIView beginAnimations: @"Fade In" context:nil];
        
        // druation of animation
        [UIView setAnimationDuration:0.5];
        self.tipsTV.alpha = 1;
        self.separatorView.alpha = 1;
        [UIView commitAnimations];        
    }
    
    [self.tipsTV reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
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
    return [self.tips count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Tips";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[self.tips objectAtIndex:indexPath.row] valueForKey:@"text"];
    //cell.imageView = 
    
    NSString *location = [[self.tips objectAtIndex:indexPath.row] valueForKey:@"location"];
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

}

@end
