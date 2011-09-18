//
//  MBProgressHUDAdditions.h
//  Moodstocks
//
//  Created by Cédric DELTHEIL on 11/03/11.
//  Copyright 2011 Moodstocks SAS. All rights reserved.
//

#import "MBProgressHUD.h"

/**
 * MBProgressHUD class level extensions which provide convenient tools used to display
 * an HUD with basic configurations (text + image or activity indicator + text), default
 * settings (size, min show time, opacity, etc) and ability to switch to another state
 *
 * Use `hideHUDForView:animated:' to dismiss any HUD created with the methods below
 */
@interface MBProgressHUD (MSCategory)

+ (MBProgressHUD *)getHUDAddedTo:(UIView *)view;
+ (BOOL)hasHUDAddedTo:(UIView *)view;

+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view withImage:(UIImage*)image text:(NSString*)text;
+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view withImage:(UIImage*)image text:(NSString*)text subText:(NSString*)subText;
+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view withImage:(UIImage*)image text:(NSString*)text subText:(NSString*)subText minShowTime:(NSTimeInterval)minShowTime;

+ (MBProgressHUD *)showActivityHUDAddedTo:(UIView *)view withText:(NSString*)text;
+ (MBProgressHUD *)showActivityHUDAddedTo:(UIView *)view withText:(NSString*)text effect:(MBProgressHUDAnimation)effect;

+ (void)switchHUDAddedTo:(UIView *)view toImage:(UIImage*)image text:(NSString*)text;
+ (void)switchHUDAddedTo:(UIView *)view toImage:(UIImage*)image text:(NSString*)text subText:(NSString*)subText;

@end
