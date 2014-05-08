//
//  FFRegistrationViewController.m
//  FatFingerTest
//
//  Created by Evangelos Tzemis on 2/11/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFRegistrationViewController.h"

@interface FFRegistrationViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *surname;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isLeftHanded;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hasPreviousiPadExperience;
@end

@implementation FFRegistrationViewController 

#pragma mark - UitextField Delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.name){
        [self.name resignFirstResponder];
        [self.surname becomeFirstResponder];
    }
    if(textField == self.surname){
        [self.surname resignFirstResponder];
        [self.email becomeFirstResponder];
    }
    if(textField == self.email){
        [self.email resignFirstResponder];
        [self.age becomeFirstResponder];
    }
    if(textField == self.age){
        [self.age resignFirstResponder];
    }
    
    return YES;
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
// Un-comment that to force Field Check!
    
//    if ([identifier isEqualToString:@"startCalibration"]) {
//        return [self checkFieldsComplete];
//    }
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
    if ([self.name.text isEqualToString:@""] || [self.surname.text isEqualToString:@""] || [self.email.text isEqualToString:@""] ||  [self.age.text isEqualToString:@""]) {
        
        [self alert:@"All fields should be completed before you proceed"];

        return NO;
    } else {
        return [self validateEmail];
    }
}

-(BOOL) validateEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; //  return 0;
    if ([emailTest evaluateWithObject:_email.text]) {
        //check age field
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        if ([nf numberFromString:self.age.text]) {  // is Decimal
            return YES;
        }
        else {
            [self alert:@"Age Field should contain only numbers"];
            return NO;
        }
    }
    else{
        [self alert:@"You need to enter a valid e-mail address"];
        return NO;
    }
}

-(User*)createUser{
    User* user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                               inManagedObjectContext:self.context];
    user.name = self.name.text;
    user.surname = self.surname.text;
    user.email = self.email.text;
    user.age = @([self.age.text integerValue]);
    user.gender = @(self.gender.selectedSegmentIndex == 0);  // true if male
    user.lefthanded = @(self.isLeftHanded.selectedSegmentIndex == 0);  // true if leftHanded
    user.experience = @(self.hasPreviousiPadExperience.selectedSegmentIndex == 0);  //true if he has
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
