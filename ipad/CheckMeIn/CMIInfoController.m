//
//  CMIInfoController.m
//  CheckMeIn
//
//  Created by Antonio MENDES PINTO on 18/09/11.
//  Copyright (c) 2011 Moodstocks. All rights reserved.
//

#import "CMIInfoController.h"

CGRect MSScreenBoundsForOrientation(UIInterfaceOrientation orientation) {
    CGRect bounds = [UIScreen mainScreen].bounds;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        CGFloat width = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = width;
    }
    return bounds;
}

@interface CMIInfoController ()

- (UIButton *)buttonWithTarget:(id)target selector:(SEL)inSelector frame:(CGRect)frame image:(UIImage*)image;
- (void)createSubviewsForOrientation:(UIInterfaceOrientation)orientation;

@end


@implementation CMIInfoController

- (void)loadView {
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];    
}

- (UIButton *)buttonWithTarget:(id)target selector:(SEL)inSelector frame:(CGRect)frame image:(UIImage*)image {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
	button.contentVerticalAlignment   = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[button setBackgroundImage:image forState:UIControlStateNormal];
	[button addTarget:target action:inSelector forControlEvents:UIControlEventTouchUpInside];
    button.showsTouchWhenHighlighted = YES;
    // In case the parent view draws with a custom color or gradient, use a transparent color
	[button setBackgroundColor:[UIColor clearColor]];
    [button autorelease];
    
    return button;
}

- (void)createSubviewsForOrientation:(UIInterfaceOrientation)orientation {
    CGRect bounds = MSScreenBoundsForOrientation(orientation);
    CGRect newRect = CGRectMake(0, 0, bounds.size.width, bounds.size.height - (20 /* status bar height*/));
    
    CGFloat bottomMargin = 40;
    
    // == LOGO
    UIImage* logoImage = [UIImage imageNamed:@"moodstocks.png"];
	CGRect buttonFrame = CGRectMake(0.5 * (newRect.size.width - logoImage.size.width),
                                    newRect.size.height - (logoImage.size.height + bottomMargin),
                                    logoImage.size.width, logoImage.size.height);
	UIButton* logoButton = [self buttonWithTarget:self selector:@selector(logoAction) frame:buttonFrame image:logoImage];    
    [self.view addSubview:logoButton];
    
    CGFloat offsetY = 15;
    
    // == POWERED BY
    UILabel* poweredBy          = [[[UILabel alloc] init] autorelease];
    poweredBy.textAlignment     = UITextAlignmentCenter;
    poweredBy.backgroundColor   = [UIColor clearColor];
    poweredBy.textColor         = [UIColor whiteColor];
    poweredBy.text              = @"Powered by";
    poweredBy.font              = [UIFont boldSystemFontOfSize:16];
    
    CGSize textSize = [poweredBy.text sizeWithFont:poweredBy.font
                                 constrainedToSize:CGSizeMake(newRect.size.width, CGFLOAT_MAX)
                                     lineBreakMode:UILineBreakModeWordWrap];
    
    poweredBy.frame = CGRectMake(0,
                                 logoButton.frame.origin.y - (textSize.height + offsetY),
                                 newRect.size.width, textSize.height);
    
    [self.view addSubview:poweredBy];
}

- (void)logoAction {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"How do you want to get in touch?", @"")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Send email", @""), NSLocalizedString(@"Visit website", @""), nil];
    actionSheet.tag = 0;
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view]; // otherwise half of the cancel button can't be clicked because of the tab bar
	[actionSheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            NSString* subject = [NSString stringWithFormat:@"More information (from app %@)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
            NSString *email = [NSString stringWithFormat:@"mailto:contact@moodstocks.com?subject=%@", subject];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
        else if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.moodstocks.com/"]];
        }
    }
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}
*/
 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // NOTE: we support landscape left only! See Info.plist
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // NOTE: this is an ugly hack used to make sure views are created at the right time (after the forced orientation has propagated)
    [self createSubviewsForOrientation:fromInterfaceOrientation];
}
*/
 
/*
- (void)dealloc {
    
    [super dealloc];
}
 */
@end