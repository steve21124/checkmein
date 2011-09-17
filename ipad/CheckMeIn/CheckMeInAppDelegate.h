//
//  CheckMeInAppDelegate.h
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckMeInViewController;

@interface CheckMeInAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet CheckMeInViewController *viewController;

@end
