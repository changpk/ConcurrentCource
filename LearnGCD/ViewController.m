//
//  ViewController.m
//  LearnGCD
//
//  Created by changpengkai on 15/4/7.
//  Copyright (c) 2015年 com.pengkaichang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end
/**
 *  串行队列中FIFO，并发队列中的顺序是随机的；并发队列中的任务是同时开始执行的(文档说说FIFO，但debug看时间戳是同时执行的)
 */
@implementation ViewController {
    
    dispatch_queue_t _serialQueue; //串行队列
    
    dispatch_queue_t _concurrentQueue; //并发队列（IOS5之后可以创建并发队列，之前用系统预定义好的并发队列）
    
    dispatch_group_t _dispatchGroup;      //组
    
    
    
    
}

//创建一个串行队列
- (dispatch_queue_t)seriaQueue {
    
    if (!_serialQueue) {
        
        //IOS6.0以后GCD的内存管理纳入到ARC中，所以不需要dispatch_release
        _serialQueue = dispatch_queue_create("com.changpengkai.learnGCD.seriaQueue ", DISPATCH_QUEUE_SERIAL);
    }
    
    return _serialQueue;
}

//创建一个并发队列
- (dispatch_queue_t)concurrentQueue {
    
    if (! _concurrentQueue) {
        
        _concurrentQueue = dispatch_queue_create("com.changpengkai.learnGCD.concurrentQueue ", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return _concurrentQueue;
}

//创建一个分发组
- (dispatch_group_t)disaptchGroup {
    
    if (!_dispatchGroup) {
        
        _dispatchGroup = dispatch_group_create();
    }
    return _dispatchGroup;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
    //dispatch_sync 表示在阻塞当前线程执行任务，虽然是在创建的队列中，这个时候的队列作用是无效的,
    dispatch_sync([self seriaQueue], ^{
        
        NSLog(@"task 1, thread is %d",[NSThread isMainThread]);
        
    });
    */
    
//    [self excuteTaskInSeriaQueue];
    
//    [self excuteTaskInConcurrentQueue];
    
//    [self showUsageOfDispatchBarryierSymbol];
    
//    [self showDispatchGroupUsageInGCD];
    
//    [self showDispatchApplyUsageInGCD];
    
    [self showDispatchSemaphoreInGCD];
    
}

//串行队列中执行任务，但多个串行队列之间是并发的
- (void)excuteTaskInSeriaQueue {
    
    NSLog(@"mainThread is %@\n", [NSThread mainThread]);
    
    //dispatch_async 开启分线程中执行task1
    dispatch_async([self seriaQueue], ^{
        
        NSLog(@"task 1, thread is %@\n",[NSThread currentThread]);
        //task1所在线程休眠3秒
        sleep(3);
        
    });
    
    //task1线程休眠3s后，另开线程执行task2(但log现实执行仍然在task1的线程中，节省cpu吧)
    dispatch_async([self seriaQueue], ^{
        
        NSLog(@"task 2, thread is %@\n",[NSThread currentThread]);
        
        
    });
}


//并发队列中执行任务
- (void)excuteTaskInConcurrentQueue {
    
    NSLog(@"mainThread is %@\n\n", [NSThread mainThread]);
    
    //dispatch_async 表示在分线程中执行task
    dispatch_async([self concurrentQueue], ^{
        
        NSLog(@"begin task 1, thread is %@\n\n",[NSThread currentThread]);
        sleep(4);
        NSLog(@"end task 1, thread is %@\n\n",[NSThread currentThread]);

        
    });
    
    dispatch_async([self concurrentQueue], ^{
        
        NSLog(@"begin task 2, thread is %@\n\n",[NSThread currentThread]);
        sleep(2);
        NSLog(@"end task 2, thread is %@\n\n",[NSThread currentThread]);

    });
    
    dispatch_async([self concurrentQueue], ^{
        
        NSLog(@"begin task 3, thread is %@\n\n",[NSThread currentThread]);
        sleep(1);
        NSLog(@"end task 3, thread is %@\n\n",[NSThread currentThread]);

    });
    
    
}

//disptch_barrier_asyc的作用
- (void)showUsageOfDispatchBarryierSymbol
{
    dispatch_async([self concurrentQueue], ^{
        
        NSLog(@"begin task 1, thread is %@\n\n",[NSThread currentThread]);
        sleep(4);
        NSLog(@"end task 1, thread is %@\n\n",[NSThread currentThread]);
        
        
    });
    
    dispatch_async([self concurrentQueue], ^{
        
        NSLog(@"begin task 2, thread is %@\n\n",[NSThread currentThread]);
        sleep(2);
        NSLog(@"end task 2, thread is %@\n\n",[NSThread currentThread]);
        
    });
    
    //加入栅栏，则首先并发task1和task2，task1和task2全部执行完毕以后，执行barrier的task，barrier的task执行完毕后，在并发执行task3和task4
    dispatch_barrier_async([self concurrentQueue], ^{
        
        NSLog(@"栅栏保证前面的taks1和task2执行完");
        
        sleep(3);
        
        NSLog(@"正常恢复所有task执行状态");
        
    });
    
    dispatch_async([self concurrentQueue], ^{
        
        NSLog(@"begin task 3, thread is %@\n\n",[NSThread currentThread]);
        sleep(1);
        NSLog(@"end task 3, thread is %@\n\n",[NSThread currentThread]);
        
    });
    
    dispatch_async([self concurrentQueue], ^{
        
        NSLog(@"begin task 4, thread is %@\n\n",[NSThread currentThread]);
        sleep(3);
        NSLog(@"end task 4, thread is %@\n\n",[NSThread currentThread]);
        
    });
}

//dipatch_group的用法
- (void)showDispatchGroupUsageInGCD
{

    dispatch_group_async([self disaptchGroup], [self concurrentQueue], ^{
        
        NSLog(@"begin task 1, thread is %@\n\n",[NSThread currentThread]);
        sleep(4);
        NSLog(@"end task 1, thread is %@\n\n",[NSThread currentThread]);
        
    });
    
    dispatch_group_async([self disaptchGroup], [self concurrentQueue], ^{
        
        NSLog(@"begin task 2, thread is %@\n\n",[NSThread currentThread]);
        sleep(2);
        NSLog(@"end task 2, thread is %@\n\n",[NSThread currentThread]);
        
    });
    
    dispatch_group_async([self disaptchGroup], [self concurrentQueue], ^{
        
        NSLog(@"begin task 3, thread is %@\n\n",[NSThread currentThread]);
        sleep(3);
        NSLog(@"end task 3, thread is %@\n\n",[NSThread currentThread]);
        
    });
    
    
    //task1，task2，task3全部执行完毕后，执行notify的task4 保证并行队列中得一些task全部执行完毕以后执行notify的方法
    dispatch_group_notify([self disaptchGroup], [self concurrentQueue], ^{
        
        NSLog(@"begin task 4, thread is %@\n\n",[NSThread currentThread]);
        sleep(3);
        NSLog(@"end task 4, thread is %@\n\n",[NSThread currentThread]);
    });
    
}

//dispatch_apply的用法
- (void)showDispatchApplyUsageInGCD
{
    NSArray *array = [NSArray arrayWithObjects:@"/Users/chentao/Desktop/copy_res/gelato.ds",
                      @"/Users/chentao/Desktop/copy_res/jason.ds",
                      @"/Users/chentao/Desktop/copy_res/jikejunyi.ds",
                      @"/Users/chentao/Desktop/copy_res/molly.ds",
                      @"/Users/chentao/Desktop/copy_res/zhangdachuan.ds",
                      nil];
    
    dispatch_async([self concurrentQueue], ^{
        
        NSLog(@"loop outside current thread is %@",[NSThread currentThread]);
        
        //同步函数，会阻塞当前线程直到所有循环迭代执行完成 debug是顺序执行，擦！
       dispatch_apply([array count], [self concurrentQueue], ^(size_t index) {
           
           NSLog(@"arry index is %ld, thread is %@",index,[NSThread currentThread]);
           
           sleep(2);
           
       });
        
        NSLog(@"loop operation end");
        
    });
}

//dispatch_semaphore的用法
- (void)showDispatchSemaphoreInGCD {
    
    /*
     　　dispatch_semaphore_create　　　创建一个semaphore 信号量值>=0
     　　dispatch_semaphore_signal　　　发送一个信号 信号量+1
     　　dispatch_semaphore_wait　　　　等待信号 如果信号量>=1,继续执行，并进行减1；如果信号量<=0,阻塞线程，判断超时时间
        
        操作数据的时候，保证信号量=0，保证只有一个线程能够操作共享数据
     */
    
    
    //创建一个信号量，初始值大于等于0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_async([self concurrentQueue], ^{
        
        NSLog(@"thread %@ task1开始执行",[NSThread currentThread]);
        
        //发送信号量，信号量增1
        dispatch_semaphore_signal(semaphore);
        
        //配置延迟时间
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
        
        //判断信号量，如果信号量>=1,继续执行，并进行减1；如果信号量<=0,阻塞线程，判断超时时间
        dispatch_semaphore_wait(semaphore, popTime);

        sleep(3);

        //发送信号量，信号量增1
        dispatch_semaphore_signal(semaphore);
        
    });
    
    
    dispatch_async([self concurrentQueue], ^{
       
        //判断信号量，如果信号量>=1,继续执行，并进行减1；如果信号量<=0,阻塞线程，判断超时时间
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        NSLog(@"thread %@ task2开始执行",[NSThread currentThread]);
        
    });
    
    NSLog(@"主线程 执行完毕");
    
}

#pragma mark - NSOperation





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
