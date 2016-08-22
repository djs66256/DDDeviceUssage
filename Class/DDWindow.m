//
//  DDWindow.m
//  DDDeviceUsage
//
//  Created by hzduanjiashun on 16/7/18.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DDWindow.h"

@interface DDWindow ()


@end

@implementation DDWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _deviceUsageView = [[DDDeviceUsageView alloc] init];
        [self addSubview:_deviceUsageView];
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    [self bringSubviewToFront:_deviceUsageView];
}

@end
