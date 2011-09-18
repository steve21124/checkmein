//
//  AboutController.m
//  CheckMeIn
//
//  Created by Antonio MENDES PINTO on 18/09/11.
//  Copyright (c) 2011 Moodstocks. All rights reserved.
//

#import "AboutController.h"

#import "CMISuscribe.h"

@implementation AboutController

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_small"]];
    self.navigationItem.titleView = imageView; 
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
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

#pragma Actions

-(IBAction)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)suscribeToCMI:(id)sender {
    CMISuscribe *suscribeController = [[CMISuscribe alloc] initWithNibName:@"CMISuscribe" bundle:nil];
    
    [self.navigationController pushViewController:suscribeController animated:YES];
}

@end
