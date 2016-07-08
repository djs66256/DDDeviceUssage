//
//  ViewController.m
//  DDDeviceUsage
//
//  Created by hzduanjiashun on 16/7/7.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "ViewController.h"
#import "DDDeviceUsageView.h"

@interface ViewController ()

@property (strong, nonatomic) DDDeviceUsageView *usageView;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    _usageView = [[DDDeviceUsageView alloc] initWithFrame:CGRectMake(10, 10, 256, 300)];
    _usageView.autoresizingMask = UIViewAutoresizingNone;
//    _usageView.frame = self.view.bounds;
//    _usageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_usageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
