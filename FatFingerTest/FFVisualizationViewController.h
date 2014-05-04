//
//  FFVisualizationViewController.h
//  Fat Finger
//
//  Created by Evangelos Tzemis on 2/9/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "FFAnimationView.h"
#import "FFTrialViewController.h"
#import "FFAppDelegate.h"


@interface FFVisualizationViewController : UIViewController

@property (nonatomic, strong) NSNumber* min;
@property (nonatomic, strong) NSNumber* max;
@property (nonatomic, strong) IBOutlet  FFAnimationView *animationView;



@end
