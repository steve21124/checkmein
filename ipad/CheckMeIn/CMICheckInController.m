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
@synthesize imageView;
@synthesize tipsTableView;
@synthesize title, description;

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
    //NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?query=%@&ll=%lf,%lf&client_id=%@&client_secret=%@&v=%@", , , , kCMI4qClientId, kCMI4qClientSecret, kCMI4qVersion];
    
    //NSURL *url = [NSURL URLWithString: urlString];

    //self.request = [ASIHTTPRequest requestWithURL:url];
    //[self.request setDelegate:self];
    
    //[self.request startAsynchronous];    
    
    // Finished ..
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
    //return [self.venues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    /*
    cell.textLabel.text = [[self.venues objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    NSString *location = [[self.venues objectAtIndex:indexPath.row] valueForKey:@"location"];
    if (location) {
        cell.detailTextLabel.text = [location valueForKey:@"address"];
    }
    */
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
