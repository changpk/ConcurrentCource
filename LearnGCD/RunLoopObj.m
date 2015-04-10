//
//  RunLoopObj.m
//  LearnGCD
//
//  Created by changpengkai on 15/4/9.
//  Copyright (c) 2015年 com.pengkaichang. All rights reserved.
//

#import "RunLoopObj.h"

@interface RunLoopObj ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@end

@implementation RunLoopObj {
    
    NSThread *_thread1;
    NSThread *_thread2;
    
    BOOL finished;
}

+ (void)displayMainRunLoopInfo {
    
    NSLog(@"主队列的 runloop is %@\n\n*************\n\n",[NSRunLoop mainRunLoop].description);
    
}

- (void)displayRunLoopInSepreteThread {
    
    _thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(runThread1) object:nil];
    _thread1.name = @"com.changpengkai.testThread1";
    [_thread1 start];
}

- (void)runThread1 {
    
    NSLog(@"当前线程是%@\n主队列的 runloop is %@\n\n*************\n\n", [NSThread currentThread],[NSRunLoop mainRunLoop].description);
    
}

- (void)displayNSTimerInSepreteThread {
    
    _thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(runThread2) object:nil];
    _thread2.name = @"com.changpengkai.testThread2";
    [_thread2 start];
}

- (void)runThread2 {
    
    NSLog(@"线程开始\n\n");
    
//    [self configNetWorkSource];
    
        [self configTimerSource];

    NSLog(@"线程结束");
}

#pragma mark - 定时器在分线程中

//测试Timer
- (void)configTimerSource {
    
    NSLog(@"阻塞开始，执行timer");
    
    //NSTimer会自动加入当前的runLoop，模式为NSDefaultRunLoopMode
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
    //启动runLoop，模式要匹配
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    
    //如下的情况只是在NSTimer的情况下
    //方法1获得当前的RunLoop，配置NSDefaultRunLoopMode,运行5s中（也就是阻塞线程5s）
    //        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    /*
     //这样相当于 方法1 中的beforeDate的参数为NSDate disfuture，线程会永远阻塞。
     [[NSRunLoop currentRunLoop]run];
     
     //相当于 方法1 中的Mode为NSDefaultRunLoopMode
     [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
     */
}

- (void)timerRun:(NSTimer *)timer {
    
    static int timerCount = 1;
    NSLog(@"timer 运行了 %d 次",timerCount);
    timerCount ++;
    
    //任务完成，finished状态改变
    if (timerCount == 5) {
        
        finished = YES;
        
        if ([timer isValid]) {
            
            //把timer从当前的RunLoop中移除，这个时候，线程会自动退出，因为没有了source
            [timer invalidate];
            //最好置为nil
            timer = nil;
            NSLog(@"阻塞结束，移除timer\n\n");
        }
    }
}

#pragma mark - 测试网络链接在分线程中

//测试网络模式，NSRunloop不需要开启，蛋疼了好久才测出来
- (void)configNetWorkSource {
    
    NSURL *sourceURL = [NSURL URLWithString:@"http://b.hiphotos.baidu.com/baike/w%3D268/sign=8426ac93d2c8a786be2a4d085f08c9c7/38dbb6fd5266d016a81d9241942bd40735fa3556.jpg"];
    //默认把链接加入到当前的RunLoop，模式为NSDefaultRunLoopMode,不用开启，当需要保持线程一直存在
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:sourceURL] delegate:self];
    NSLog(@"网络请求中不会阻塞，执行请求");
    
    //循环开启runloop 保证线程一直存在（里面这句话这样写是没作用的，我认为，while就有阻塞线程的作用了）
        while (!finished) {
    
            static int count = 1;
            NSLog(@"执行次数%d",count);
            BOOL result = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            //这句代码在NSTimer中是不会执行的，但对于网络请求是会执行的，蛋疼了我好久才测试出来
            count ++;
            NSLog(@"result is %d",result);
        }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"data length is %uld",data.length);
}

//请求结束，设置finished的状态，结束循环，结束线程
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"finishLoading ");
    NSLog(@"结束请求");
    finished = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"请求失败");
    
}

@end
