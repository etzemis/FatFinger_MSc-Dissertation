//
//  UsersCDTVC.h
//  FatFinger
//
//  Created by Evangelos Tzemis on 3/27/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface UsersCDTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
