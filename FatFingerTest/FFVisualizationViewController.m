//
//  FFVisualizationViewController.m
//  Fat Finger
//
//  Created by Evangelos Tzemis on 2/9/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFVisualizationViewController.h"
#import "FFCalibrationViewController.h"
@interface FFVisualizationViewController ()

@end

@implementation FFVisualizationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.animationView.min = self.min;
    self.animationView.max = self.max;
}



@end
