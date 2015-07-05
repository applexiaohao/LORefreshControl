//
//  LOProgressView.m
//  RefreshDemo
//
//  Created by lewis on 6/30/15.
//  Copyright (c) 2015 蓝鸥科技. All rights reserved.
//

#import "LOProgressView.h"

@interface LOProgressView(Hello)

@end

@implementation LOProgressView
@synthesize progress = p_progress;


- (void)setProgress:(CGFloat)progress
{
    if (progress < 0.0f) {
        progress = 0.0f;
    }
    if (progress > 1.0f) {
        progress = 1.0f;
    }
    
    p_progress = progress;
    
    [self setNeedsLayout];
}

@end


@implementation LOCircleProgressView
{
    CAShapeLayer *circle_layer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.progress = 0.0f;
        
        circle_layer = [CAShapeLayer layer];
        
        [self.layer addSublayer:circle_layer];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    circle_layer.bounds = self.bounds;
    circle_layer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    circle_layer.lineWidth = 1.0f;
    circle_layer.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
    circle_layer.fillColor = [UIColor clearColor].CGColor;
    circle_layer.strokeColor = [UIColor redColor].CGColor;
}

- (void)setProgress:(CGFloat)progress
{
    
    [super setProgress:progress];
    
    circle_layer.strokeEnd = [super progress];
}




@end