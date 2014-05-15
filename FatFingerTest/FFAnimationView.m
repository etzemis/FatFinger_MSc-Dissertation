//
//  FFAnimationView.m
//  FatFingerTest
//
//  Created by Evangelos Tzemis on 2/16/14.
//  Copyright (c) 2014 Evangelos Tzemis. All rights reserved.
//

#import "FFAnimationView.h"

@interface FFAnimationView()
@property (nonatomic, strong) NSNumber *currentSize;
@end

@implementation FFAnimationView


// if it exceed min and mac value then reformat it
-(void)setCurrentSize:(NSNumber *)currentSize{
    if ([currentSize floatValue] > 360) {
        _currentSize = @360;
    }
    else if ([currentSize floatValue]<0){
        _currentSize= @0;
    }
    else{
        _currentSize = currentSize;
    }
    [self setNeedsDisplay];
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *touch = [touches allObjects];
    UITouch *index = [touch firstObject];
    NSNumber *indexval = [index valueForKey:@"_pathMajorRadius"];
    //NSLog(@"%.2f", [indexval floatValue]);
    NSNumber *pr = @(([indexval floatValue] - [_min floatValue])/ ([_max floatValue]-[_min floatValue]));
    self.currentSize = @([pr floatValue]*360);
    
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray *touch = [touches allObjects];
    UITouch *index = [touch firstObject];
    NSNumber *indexval = [index valueForKey:@"_pathMajorRadius"];
    //NSLog(@"%.2f", [indexval floatValue]);
    NSNumber *pr = @( ([indexval floatValue] - [_min floatValue])/ ([_max floatValue]-[_min floatValue]));
    self.currentSize = @([pr floatValue]*360);
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.currentSize = @(0);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    {
    
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    UIColor* color = [UIColor colorWithRed: 0.114 green: 0.114 blue: 1 alpha: 1];
    
    //// Oval Drawing
    CGRect ovalRect = CGRectMake(25.5, 125.5, 721, 721);
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    [ovalPath addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)) radius: CGRectGetWidth(ovalRect) / 2 startAngle: 0 * M_PI/180 endAngle: [self.currentSize intValue] * M_PI/180 clockwise: YES];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect))];
    [ovalPath closePath];
    
    [color setFill];
    [ovalPath fill];
    [strokeColor setStroke];
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(211.5, 306.5, 349, 359)];
    [fillColor setFill];
    [oval2Path fill];
    [strokeColor setStroke];
    oval2Path.lineWidth = 2;
    [oval2Path stroke];


    }

}


@end
