//
//  FFCalibrationViewController.h
//  Fat Finger
//
//  Created by Evangelos Tzemis on 2/8/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFAppDelegate.h"
#import "User.h"
#import "FFVisualizationViewController.h"
#import "FFCalibrationView.h"

@interface FFCalibrationViewController : UIViewController
@property (nonatomic, strong) User* user;
@property (weak, nonatomic) IBOutlet FFCalibrationView *CalibrationView;



@end
