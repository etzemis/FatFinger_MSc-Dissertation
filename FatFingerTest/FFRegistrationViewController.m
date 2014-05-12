//
//  FFRegistrationViewController.m
//  FatFingerTest
//
//  Created by Evangelos Tzemis on 2/11/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFRegistrationViewController.h"

@interface FFRegistrationViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userID;
@end

@implementation FFRegistrationViewController 

#pragma mark - UitextField Delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.userID){
        [self.userID resignFirstResponder];
    }
    return YES;
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
// Un-comment that to force Field Check!
    
    if ([identifier isEqualToString:@"startCalibration"]) {
        return [self checkFieldsComplete];
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"startCalibration"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            FFCalibrationViewController *calibrationVC = [((UINavigationController *) segue.destinationViewController).viewControllers firstObject];
            calibrationVC.user = [self createUser];
            
        }
    }
}


#pragma mark - Validation

-(BOOL) checkFieldsComplete{
    if ([self.userID.text isEqualToString:@""]) {
        [self alert:@"All fields should be completed before you proceed"];
        return NO;
    }
    else{       //Check if User ID Exists
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        if ([nf numberFromString:self.userID.text]) {  // is Decimal
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            request.predicate = nil;        //all
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"userID"
                                                                      ascending:YES
                                                                       selector:@selector(compare:)]];
            NSError *error;
            NSArray * users = [self.context executeFetchRequest:request error:&error];
            int lastID = [((User *)[users lastObject]).userID intValue];
            if ([self.userID.text intValue] <= lastID) {
                [self alert:[NSString stringWithFormat:@"User Id should be greater than %d", lastID]];
                return NO;
            }
            else{
                return YES;
            }
        }
        else {
            [self alert:@"User ID should contain only numbers"];
            return NO;
        }
       
    };
}


-(User*)createUser{
    User* user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                               inManagedObjectContext:self.context];
    user.userID = @([self.userID.text integerValue]);
    [self.context save:nil];
    return user;
}

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"User Registration"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}


@end
