//
//  DDGraphView.m
//  DDDeviceUsage
//
//  Created by hzduanjiashun on 16/7/7.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DDGraphView.h"

@implementation DDGraphView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)super.layer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _minValue = _maxValue = 0;
        self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return self;
}

- (void)updateValues:(CGFloat *)values index:(int)index count:(int)count {
    for (int i = 0; i<count; i++) {
        if (values[i] != 0) {
            _maxValue = MAX(_maxValue, values[i]);
        }
    }
    if (fabs(_minValue-_maxValue) <= DBL_EPSILON) {
        return ;
    }
    
    CGSize size = {self.frame.size.width, self.frame.size.height-10};
    UIBezierPath *path = [UIBezierPath new];
    path.lineWidth = 1;
    for (int i = index; i<count+index; i++) {
        CGFloat value = values[i%count];
        CGPoint point = {size.width - 1*(i-index), size.height * value / (_maxValue - _minValue) + 5};
        if (i == index) {
            [path moveToPoint:point];
        }
        else {
            [path addLineToPoint:point];
        }
    }
    self.shapeLayer.path = path.CGPath;
}

@end
