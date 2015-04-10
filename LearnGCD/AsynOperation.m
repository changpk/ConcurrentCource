//
//  AsynOperation.m
//  LearnGCD
//
//  Created by changpengkai on 15/4/9.
//  Copyright (c) 2015年 com.pengkaichang. All rights reserved.
//

#import "AsynOperation.h"
#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AsynOperation ()

@end

@implementation AsynOperation {
    
    BOOL        executing; //基类中得都只为可读属性
    BOOL        finished; //基类中得都只为可读属性
}

- (instancetype)initWithImageURL:(NSString *)URL result:(resultDataBlock)result {
    
    if (self = [super init]) {
        
        dataBlock = result;
        finished = NO;
        executing = NO;
    }
    
    return self;
}

//必须 重写start方法，不能调用super,主要是setup
- (void)start {
    
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
}

//必须 覆盖isConcurrent，返回YES
- (BOOL)isConcurrent {
    
    return YES;
}

//必须 覆盖isExecuting
- (BOOL)isExecuting {
    return executing;
}

//必须 覆盖isFinished
- (BOOL)isFinished {
    return finished;
}

//可选 主要是用来执行task
- (void)main {
    @try {
        
        // Do the main work of the operation here.
        
        //在需要的地方添加取消的判断
                if (self.cancelled) {
        
                    NSLog(@"operation is 取消了");
        
                    return;
                }
        
        //模拟数据的操作
        sleep(3);
        
                if (self.cancelled) {
        
                    NSLog(@"operation is 取消了");
        
                    return;
                }
        
                [self completeOperation];
    }
    @catch(...) {
        // Do not rethrow exceptions.
    }
}

- (void)show {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        ViewController *controller = (ViewController *)keyWindow.rootViewController;
        
        controller.testView.backgroundColor = [UIColor colorWithRed:arc4random()%100 * 0.01 green:arc4random()%100 * 0.01  blue:arc4random()%100 * 0.01  alpha:1.0];
        
        NSLog(@"timer is run");
    });
}

- (void)completeOperation {
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    NSLog(@"---after current thread is %@",[NSThread currentThread]);
    
}

@end
