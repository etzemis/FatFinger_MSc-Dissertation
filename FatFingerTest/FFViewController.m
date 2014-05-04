//
//  FFViewController.m
//  FatFingerTest
//
//  Created by Evangelos Tzemis on 2/11/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFViewController.h"
#import "FFRegistrationViewController.h"
#import "FFAppDelegate.h"
#import "UsersCDTVC.h"

@interface FFViewController ()

@end

@implementation FFViewController


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Start New Experiment"]) {
        if ([segue.destinationViewController isKindOfClass:[FFRegistrationViewController class]]) {
            FFRegistrationViewController * rVC = (FFRegistrationViewController *) segue.destinationViewController;
            FFAppDelegate *delegate = (FFAppDelegate *)[[UIApplication sharedApplication] delegate];
            rVC.context = delegate.managedObjectContext;
            NSLog(@"We have the context");

        }
    }
    
    if ([segue.identifier isEqualToString:@"Show User Stats"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UsersCDTVC * tVC = [((UINavigationController *) segue.destinationViewController).viewControllers firstObject];
            FFAppDelegate *delegate = (FFAppDelegate *)[[UIApplication sharedApplication] delegate];
            tVC.managedObjectContext = delegate.managedObjectContext;
        }
    }
}

@end
