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

@implementation HomeController

@synthesize navItem;

- (void)dealloc
{
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

@end
