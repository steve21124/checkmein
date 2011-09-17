//
//  CheckMeInViewController.h
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMIScannerController.h"

@interface HomeController : UIViewController<CMIScannerControllerDelegate> {
}
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;

- (IBAction)touched:(id)sender;

-(void) scannerController:(CMIScannerController *)scanner didFound:(NSString *)authToken;

@end
