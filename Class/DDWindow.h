//
//  DDWindow.h
//  DDDeviceUsage
//
//  Created by hzduanjiashun on 16/7/18.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDDeviceUsageView.h"

@interface DDWindow : UIWindow

@property (strong, readonly, nonatomic) DDDeviceUsageView *deviceUsageView;

@end
