//
//  CalibrationImage.m
//  Fat Finger
//
//  Created by Evangelos Tzemis on 2/8/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFCalibrationView.h"

@interface FFCalibrationView ()

@end



@implementation FFCalibrationView


-(id)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame]) {
        self.autoresizesSubviews=YES;
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

-(void)setMaxContactSize:(NSNumber *)maxContactSize
{
    _maxContactSize = maxContactSize;
    [self setNeedsDisplay];
}

-(void)setMinContactSize:(NSNumber *)minContactSize
{
    _minContactSize = minContactSize;
    [self setNeedsDisplay];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.shouldsetDefaultValuesOnFirstTouch) {
        self.maxContactSize = @0;
        self.minContactSize = @40;
        self.shouldsetDefaultValuesOnFirstTouch = NO;
    }

    NSArray *touch = [touches allObjects];
    UITouch *index = [touch firstObject];
    NSNumber *indexval = [index valueForKey:@"_pathMajorRadius"];
    //NSLog(@"%.2f", [indexval floatValue]);
    if ([indexval floatValue] > [self.maxContactSize floatValue]) {
        self.maxContactSize = indexval;
    }
    if ([indexval floatValue] < [self.minContactSize floatValue]) {
        self.minContactSize = indexval;
    }
    // NSLog(@"Now only %lu fingers our touching the screen", (unsigned long)[touch count]);

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *touch = [touches allObjects];
    UITouch *index = [touch firstObject];
    NSNumber *indexval = [index valueForKey:@"_pathMajorRadius"];
    //NSLog(@"%.2f", [indexval floatValue]);
    if ([indexval floatValue] > [self.maxContactSize floatValue]) {
        self.maxContactSize = indexval;
    }
    if ([indexval floatValue] < [self.minContactSize floatValue]) {
        self.minContactSize = indexval;
    }
   // NSLog(@"Now only %lu fingers our touching the screen", (unsigned long)[touch count]);
    
}



- (void)drawRect:(CGRect)rect
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIFont *cornerFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSAttributedString *cornerTextMin = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"CurrentMin: %4.2f", [self.minContactSize floatValue] ] attributes:@{ NSFontAttributeName : [cornerFont fontWithSize:25] , NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName: [UIColor whiteColor] }];
    NSAttributedString *cornerTextMax = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Current Max: %4.2f", [self.maxContactSize floatValue]] attributes:@{ NSFontAttributeName : [cornerFont fontWithSize:25] , NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName: [UIColor whiteColor] }];
    
    CGRect textBounds1;
    textBounds1.origin = CGPointMake(130, CGRectGetMaxY(rect) -150 );
    textBounds1.size = [cornerTextMin size];
    [cornerTextMin drawInRect:textBounds1];
    
    CGRect textBounds2;
    textBounds2.origin = CGPointMake(CGRectGetMidX(rect)+50, CGRectGetMaxY(rect) -150 );
    textBounds2.size = [cornerTextMax size];
    [cornerTextMax drawInRect:textBounds2];

    
}


@end
