//
//  FFCalibrationViewController.m
//  Fat Finger
//
//  Created by Evangelos Tzemis on 2/8/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFCalibrationViewController.h"
#import "FFWarmUpTrialViewController.h"


@implementation FFCalibrationViewController



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    if ([segue.identifier isEqualToString:@"GoToVisualization"]) {
        if ([segue.destinationViewController isKindOfClass:[FFVisualizationViewController class]]) {
            FFVisualizationViewController * visualizationVC = (FFVisualizationViewController *) segue.destinationViewController;
            self.user.minArea = self.CalibrationView.minContactSize;
            self.user.minArea = self.CalibrationView.maxContactSize;
            visualizationVC.min = self.CalibrationView.minContactSize;
            visualizationVC.max = self.CalibrationView.maxContactSize;
        }
    }
    else if ([segue.identifier isEqualToString:@"start warm up trials"]) {
        if ([segue.destinationViewController isKindOfClass:[FFWarmUpTrialViewController class]]) {
            FFWarmUpTrialViewController * tvc= (FFWarmUpTrialViewController*) segue.destinationViewController;
            self.user.minArea = self.CalibrationView.minContactSize;
            self.user.maxArea= self.CalibrationView.maxContactSize;
            tvc.user = self.user;
            
        }
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    self.CalibrationView.shouldsetDefaultValuesOnFirstTouch = YES;
    self.CalibrationView.autoresizesSubviews=YES;
    self.CalibrationView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // User has been already initialized

}

@end
