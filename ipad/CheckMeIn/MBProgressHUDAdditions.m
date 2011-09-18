//
//  MBProgressHUDAdditions.m
//  CheckMeIn
//
//  Created by Cedric Deltheil on 18/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "MBProgressHUDAdditions.h"

static const CGFloat kMSHUDDefaultWidth    = 90;
static const CGFloat kMSHUDDefaultHeight   = 60;
static const CGFloat kMSHUDDefaultShowTime = 0.9;
static const CGFloat kMSHUDDefaultOpacity  = 0.9;

#pragma mark -
#pragma mark MBProgressHUD (Private)

@interface MBProgressHUD (Private)

+ (UIView*)viewWithImage:(UIImage*)image;
+ (UIView*)activityIndicatorView;

@end

@implementation MBProgressHUD (Private)

+ (UIView*)viewWithImage:(UIImage*)image {
    UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kMSHUDDefaultWidth, kMSHUDDefaultHeight)] autorelease];
	customView.backgroundColor = [UIColor clearColor];
    
    UIImageView* imgView = [[[UIImageView alloc] initWithImage:image] autorelease];
    imgView.frame = CGRectMake(0.5 * (customView.frame.size.width - image.size.width),
                               0.5 * (customView.frame.size.height - image.size.height),
                               image.size.width, image.size.height);
    [customView addSubview:imgView];
    
    return customView;
}

+ (UIView*)activityIndicatorView {
    UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kMSHUDDefaultWidth, kMSHUDDefaultHeight)] autorelease];
	customView.backgroundColor = [UIColor clearColor];
    
    UIActivityIndicatorView* activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    activityIndicator.frame = CGRectMake(0.5 * (customView.frame.size.width - activityIndicator.frame.size.width),
                                         0.5 * (customView.frame.size.height - activityIndicator.frame.size.height),
                                         activityIndicator.frame.size.width, activityIndicator.frame.size.height);
    [customView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    return customView;
}

@end

@implementation MBProgressHUD (MSCategory)

+ (MBProgressHUD *)getHUDAddedTo:(UIView *)view {
    UIView* candidate = nil;
	for (UIView* v in [view subviews]) {
		if ([v isKindOfClass:[MBProgressHUD class]]) {
			candidate = v;
		}
	}
    
    return (MBProgressHUD *) candidate;
}

+ (BOOL)hasHUDAddedTo:(UIView *)view {
    return !!([self getHUDAddedTo:view] != nil);
}

+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view withImage:(UIImage*)image text:(NSString*)text {
    return [self showHUDAddedTo:view withImage:image text:text subText:nil minShowTime:kMSHUDDefaultShowTime];
}

+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view withImage:(UIImage*)image text:(NSString*)text subText:(NSString*)subText {
    return [self showHUDAddedTo:view withImage:image text:text subText:subText minShowTime:kMSHUDDefaultShowTime];
}

+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view withImage:(UIImage*)image text:(NSString*)text subText:(NSString*)subText minShowTime:(NSTimeInterval)minShowTime {
    CGRect sbounds = [UIScreen mainScreen].bounds; // FIXME: support landscape mode
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithFrame:sbounds];
    
    HUD.customView = [self viewWithImage:image];
    HUD.labelText  = text;
    if (subText) {
        HUD.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
        HUD.detailsLabelText = subText;
    }
    
    [view addSubview:HUD];
    
	HUD.minShowTime   = minShowTime;
    HUD.opacity       = kMSHUDDefaultOpacity;
    HUD.mode          = MBProgressHUDModeCustomView;
	HUD.animationType = MBProgressHUDAnimationZoom;
    
    // I've observed race conditions while using `showWhileExecuting' since it calls
    // the `cleanUp' method that releases the custom view, probably because the method
    // to be executed returns instantly
    // [HUD showWhileExecuting:@selector(dummy) onTarget:self withObject:nil animated:YES];
    
    [HUD show:YES];
    [self hideHUDForView:view animated:YES]; // hide will handle the min show time setting
    
	return [HUD autorelease];
}

+ (MBProgressHUD *)showActivityHUDAddedTo:(UIView *)view withText:(NSString*)text {
    return [self showActivityHUDAddedTo:view withText:text effect:MBProgressHUDAnimationFade];
}

+ (MBProgressHUD *)showActivityHUDAddedTo:(UIView *)view withText:(NSString*)text effect:(MBProgressHUDAnimation)effect {
    CGRect sbounds = [UIScreen mainScreen].bounds; // FIXME: support landscape mode
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithFrame:sbounds];
    
    HUD.customView = [self activityIndicatorView];
    
    // The HUD will disable all input on the view (use the higest view possible in the view hierarchy)
    [view addSubview:HUD];
    
    HUD.delegate      = self;
    HUD.opacity       = kMSHUDDefaultOpacity;
    HUD.mode          = MBProgressHUDModeCustomView;
	HUD.animationType = effect;
    HUD.labelText     = text;
    
    [HUD show:YES];
    
    return [HUD autorelease];
}

+ (void)switchHUDAddedTo:(UIView *)view toImage:(UIImage*)image text:(NSString*)text {
    return [self switchHUDAddedTo:view toImage:image text:text subText:nil];
}

+ (void)switchHUDAddedTo:(UIView *)view toImage:(UIImage*)image text:(NSString*)text subText:(NSString*)subText {
    UIView *viewToSwitch = [self getHUDAddedTo:view];
    if (viewToSwitch != nil) {
        MBProgressHUD*  HUD = (MBProgressHUD *) viewToSwitch;
        [HUD setCustomView:[self viewWithImage:image]];
        [HUD setLabelText:text];
        if (subText) {
            [HUD setDetailsLabelFont:[UIFont boldSystemFontOfSize:16]];
            [HUD setDetailsLabelText:subText];
        }
        
        // This is a hack to make possible to change the HUD content without switching between two different modes
        [HUD updateIndicators];
        [HUD setNeedsLayout];
        [HUD setNeedsDisplay];
        
        // This is a trick to take benefit of the min show time feature without
        [HUD setMinShowTime:kMSHUDDefaultShowTime];
        [HUD setShowStarted:[NSDate date]];
        
        [self hideHUDForView:view animated:YES]; // hide will handle the min show time setting
	}
}

@end
