//
//  DDGraphView.h
//  DDDeviceUsage
//
//  Created by hzduanjiashun on 16/7/7.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDGraphView : UIView

@property (assign, nonatomic) BOOL autoRange;
@property (assign, nonatomic) CGFloat minValue;
@property (assign, nonatomic) CGFloat maxValue;

- (void)updateValues:(CGFloat *)values index:(int)index count:(int)count;

@end
