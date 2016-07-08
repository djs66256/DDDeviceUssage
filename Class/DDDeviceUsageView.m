//
//  DDDeviceUsageView.m
//  DDDeviceUsage
//
//  Created by hzduanjiashun on 16/7/7.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

#import "DDDeviceUsageView.h"
#import "DDGraphView.h"

#define kMaxValueCount 256
#define kGraphCount 4

@implementation DDDeviceUsageView {
    CGFloat *_fpsValues;
    CGFloat *_memUsageValues;
    CGFloat *_memLeftValues;
    CGFloat *_cpuValues;
    int _cursor;
    CADisplayLink *_displayLink;
    
    NSArray<DDGraphView *> *_graphViews;
    NSArray<UILabel *> *_graphLabels;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        NSMutableArray *graphViews = [NSMutableArray arrayWithCapacity:kGraphCount];
        DDGraphView *preGraphView = nil;
        for (int i = 0; i<kGraphCount; i++) {
            DDGraphView *graphView = [[DDGraphView alloc] initWithFrame:self.bounds];
            graphView.layer.borderColor = [UIColor blackColor].CGColor;
            graphView.layer.borderWidth = 1;
            if (i==1 || i==2) {
                graphView.autoRange = YES;
            }
            else {
                graphView.maxValue = 100;
            }
            graphView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:graphView];
            [graphViews addObject:graphView];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:graphView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:kMaxValueCount]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:graphView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
            
            if (preGraphView) {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:graphView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:preGraphView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
                
                [self addConstraint:[NSLayoutConstraint constraintWithItem:graphView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:preGraphView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
            }
            else {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:graphView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            }
            if (i == kGraphCount-1) {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:graphView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            }
            preGraphView = graphView;
        }
        _graphViews = graphViews.copy;
        
        
        _fpsValues = (CGFloat *)malloc(sizeof(CGFloat)*kMaxValueCount);
        memset(_fpsValues, 0, kMaxValueCount);
        _memUsageValues = (CGFloat *)malloc(sizeof(CGFloat)*kMaxValueCount);
        memset(_memUsageValues, 0, kMaxValueCount);
        _memLeftValues = (CGFloat *)malloc(sizeof(CGFloat)*kMaxValueCount);
        memset(_memLeftValues, 0, kMaxValueCount);
        _cpuValues = (CGFloat *)malloc(sizeof(CGFloat)*kMaxValueCount);
        memset(_cpuValues, 0, kMaxValueCount);
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLink:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}
                        
                        
- (void)displayLink:(CADisplayLink *)link {
    _fpsValues[_cursor] = 1/link.duration;
    _memUsageValues[_cursor] = [self usedMemory];
    _memLeftValues[_cursor] = [self availableMemory];
    _cpuValues[_cursor] = [self cpuUsage];
    
    [_graphViews[0] updateValues:_fpsValues index:_cursor count:kMaxValueCount];
    [_graphViews[1] updateValues:_memUsageValues index:_cursor count:kMaxValueCount];
    [_graphViews[2] updateValues:_memLeftValues index:_cursor count:kMaxValueCount];
    [_graphViews[3] updateValues:_cpuValues index:_cursor count:kMaxValueCount];
    
    _cursor ++;
    _cursor %= kMaxValueCount;
}


// 获取当前设备可用内存(单位：MB）

- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return 0;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}


// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return 0;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}


- (float)cpuUsage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

@end
