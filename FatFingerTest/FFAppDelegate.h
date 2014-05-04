//
//  FFAppDelegate.h
//  FatFingerTest
//
//  Created by Evangelos Tzemis on 2/11/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>

@interface FFAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

// added to support CoreData
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIManagedDocument *document;



- (void)openDatabase;

@end
