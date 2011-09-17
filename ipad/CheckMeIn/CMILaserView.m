//
//  CMILaserView.m
//  CheckMeIn
//
//  Created by Cedric Deltheil on 17/09/11.
//  Copyright 2011 Moodstocks. All rights reserved.
//

#import "CMILaserView.h"

#import <QuartzCore/QuartzCore.h>

static const CGFloat kCMILaserViewHeight            = 60.0f; // pixels
static const CGFloat kCMILaserViewAnimationDuration = 1.5f; // seconds


@implementation CMILaserView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _maxHeight = self.frame.size.height;
        
        // Restrict the size to the gradient height to minimize the amount blended areas (i.e. are with transparent content)
        // that are expensive to compute
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                kCMILaserViewHeight);
    }
    return self;
}

+ (Class)layerClass {
	return [CAGradientLayer class];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    // Introduce a negative offset so that the scanner covers the top part of the view
    self.center = CGPointMake(self.center.x, self.center.y - kCMILaserViewHeight);
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *) self.layer;
    gradientLayer.colors =
    [NSArray arrayWithObjects:
     (id)[UIColor colorWithRed:0.918 green:0.063 blue:0.165 alpha:0.0].CGColor,
     (id)[UIColor colorWithRed:0.918 green:0.063 blue:0.165 alpha:0.6].CGColor,
     (id)[UIColor colorWithRed:0.918 green:0.063 blue:0.165 alpha:0.0].CGColor,
     nil];
    
    gradientLayer.locations  = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.98],
                                [NSNumber numberWithFloat:1.0], nil];
    
    NSUInteger opts = UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction;
    [UIView animateWithDuration:kCMILaserViewAnimationDuration
                          delay:0
                        options:opts
                     animations:^{
                         self.center = CGPointMake(self.center.x, self.center.y + _maxHeight + kCMILaserViewHeight);
                     }
                     completion:^(BOOL finished){
                         // nothing to do
                     }
     ];
}

@end
