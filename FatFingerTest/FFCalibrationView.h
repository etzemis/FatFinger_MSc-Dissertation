//
//  CalibrationImage.h
//  Fat Finger
//
//  Created by Evangelos Tzemis on 2/8/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FFCalibrationView : UIView
@property (nonatomic, strong) NSNumber *maxContactSize;
@property (nonatomic, strong) NSNumber *minContactSize;
@property BOOL shouldsetDefaultValuesOnFirstTouch;
@end
