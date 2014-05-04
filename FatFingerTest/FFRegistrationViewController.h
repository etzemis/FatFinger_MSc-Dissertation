//
//  FFRegistrationViewController.h
//  FatFingerTest
//
//  Created by Evangelos Tzemis on 2/11/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFCalibrationViewController.h"
#import "FFAppDelegate.h"
#import "User.h"

@interface FFRegistrationViewController : UITableViewController 

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
