//
//  FFAppDelegate.m
//  FatFingerTest
//
//  Created by Evangelos Tzemis on 2/11/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFAppDelegate.h"

@implementation FFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self openDatabase];
    return YES;
}



#pragma mark - Core Data

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */

-(void) openDatabase{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"FatFingerStats";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    //lets create or open it
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
    
    if(fileExists) {
        NSLog(@"File Exists");
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            if (!success) NSLog(@"Couldn't open document at %@", url);
        }];
    }
    else {
        NSLog(@"File does not exist");
        [self.document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) [self documentIsReady];
              if (!success) NSLog(@"Couldn't open document at %@", url);
          }];
    }
}

-(void) documentIsReady{
    if (self.document.documentState == UIDocumentStateNormal) {
        self.managedObjectContext = self.document.managedObjectContext;
        NSLog(@"Context is ready for use");
    }
}


@end
