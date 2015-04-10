//
//  ViewController.m
//  LearnGCD
//
//  Created by changpengkai on 15/4/7.
//  Copyright (c) 2015年 com.pengkaichang. All rights reserved.
//

#import "ViewController.h"

#import "SyncOperation.h"
#import "AsynOperation.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;

- (IBAction)controlOperation:(UIButton *)sender;
@end
/**
 *  串行队列中FIFO，并发队列中的顺序是随机的；并发队列中的任务是同时开始执行的(文档说说FIFO，但debug看时间戳是同时执行的)
 */
@implementation ViewController {
    
    dispatch_queue_t _serialQueue; //串行队列
    
    dispatch_queue_t _concurrentQueue; //并发队列（IOS5之后可以创建并发队列，之前用系统预定义好的并发队列）
    
    dispatch_group_t _dispatchGroup;      //组
    
    
    NSOperationQueue *_operationQueue; //操作队列，类似disaptch_queue,但不是FIFO，可以设置依赖和优先级
    
    AsynOperation *_asynop;
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
    
    //    [self showDispatchSemaphoreInGCD];
    
    //    [self showNSBlockOperationInQueue];
    
    //    [self showDependencyOperationInQueue];
    
    //    [self addBlockConcurrentNum];
    
    //    [self showNSInvocationOperation];
    
//    [self showSynOperation];
    
//    [self showAsynOperation];
    
}

- (void)didReceiveMemoryWarning {
    
    NSLog(@"内存警告");
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

//创建一个操作队列 IOS4.0之后的操作队列底层使用GCD实现的
- (NSOperationQueue *)operationQueue {
    
    if (!_operationQueue) {
        
        _operationQueue = [[NSOperationQueue alloc]init];
        
        //给队列加名称
        _operationQueue.name = @"com.changpengkai.myQueue";
        
        //并发operation不是Block的最大数目，默认为-1，没有限制；如果为1，则是串行队列
        _operationQueue.maxConcurrentOperationCount = 2;
        
        /*
         ios8.0中的新特性
         线程这个概念已经在苹果的框架中被系统性的忽略。这对于开发者而言是件好事。
         
         沿着这个趋势，NSOperation中新的qualityOfService的属性取代了原来的threadPriority。通过它可以推迟那些不重要的任务，从而让用户体验更加流畅。
         
         NSQualityOfService枚举定义了以下值：
         
         UserInteractive：和图形处理相关的任务，比如滚动和动画。
         UserInitiated：用户请求的任务，但是不需要精确到毫秒级。例如，如果用户请求打开电子邮件App来查看邮件。
         Utility：周期性的用户请求任务。比如，电子邮件App可能被设置成每五分钟自动检查新邮件。但是在系统资源极度匮乏的时候，将这个周期性的任务推迟几分钟也没有大碍。
         Background：后台任务，用户可能并不会察觉对这些任务。比如，电子邮件App对邮件进行引索以方便搜索。
         */
        _operationQueue.qualityOfService = NSQualityOfServiceDefault;
        
        //调用属性访问的时候，队列中需要执行的任务数，不同时刻不一样，利用KVO进行监听
        NSLog(@"-- 创建队列时的操作数目 %uld\n\n",_operationQueue.operationCount);
        
        //调用属性访问的时候，队列中需要执行执行的任务数。不同时刻不一样，利用KVO进行监听
        NSLog(@"-- 创建队列时的操作数 %@\n\n",_operationQueue.operations);
    }
    
    return _operationQueue;
    
}

//NSBlockOperation的用法
- (void)showNSBlockOperationInQueue {
    
    self.pauseBtn.hidden = NO;
    
    //便利构造方法
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"--operation is -- %@",blockOperation);
        NSLog(@"--- task1 thread is %@",[NSThread currentThread]);
        //数据操作
        sleep(1);
        NSLog(@"--- task1 数据操作结束");
        
    }];
    
    __weak NSBlockOperation *weakBlockOpe = blockOperation;
    
    //添加任务的block
    [blockOperation addExecutionBlock:^{
        
        NSLog(@"--operation is -- %@",weakBlockOpe);
        NSLog(@"--- task2 thread is %@",[NSThread currentThread]);
        //数据操作
        sleep(1);
        NSLog(@"--- task2 数据操作结束");
        
    }];
    
    //添加任务的block
    [blockOperation addExecutionBlock:^{
        
        NSLog(@"--operation is -- %@",weakBlockOpe);
        NSLog(@"--- task3 thread is %@",[NSThread currentThread]);
        //数据操作
        sleep(5);
        NSLog(@"--- task3 数据操作结束");
        
    }];
    
    
    //添加操作到队列，开始依次执行FIFO
    //    [[self operationQueue] addOperation:blockOperation];
    
    //如果为NO，阻塞当前线程就是调用方法所在的线程；如果为YES，等效于上面方法的操作，直接返回
    [[self operationQueue] addOperations:@[blockOperation] waitUntilFinished:NO];
    
    //设置队列为阻塞状态，添加新的操作，操作将被挂起
    [self operationQueue].suspended = YES;
    
    [[self operationQueue] addOperationWithBlock:^{
        
        NSLog(@"--- task4 thread is %@",[NSThread currentThread]);
        //数据操作
        sleep(5);
        NSLog(@"--- task4 数据操作结束");
        
    }];
    
    //调用属性访问的时候，队列中正在执行的任务数，不同时刻不一样，利用KVO进行监听
    NSLog(@"-- 队列时的操作数目 %uld\n\n",[self operationQueue].operationCount);
    
    //调用属性访问的时候，队列中正在执行的操作。不同时刻不一样，利用KVO进行监听
    NSLog(@"-- 队列时的操作数 %@\n\n",[self operationQueue].operations);
    NSLog(@"主线程继续执行");
    
}

//控制队列任务的开始或者暂停
- (IBAction)controlOperation:(UIButton *)sender {
    
    //如果队列中由挂起的操作，则执行判断
    if ([self operationQueue].operationCount == 0) {
        
        NSLog(@"没有操作");
        return;
    }
    
    BOOL suspend = [self operationQueue].isSuspended;
    
    if (!suspend) {
        
        NSLog(@"开始");
        [sender setTitle:@"开始" forState:UIControlStateNormal];
        [self operationQueue].suspended = YES;
        
    }else {
        
        NSLog(@"暂停");
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        
        //重新开始队列中的挂起的操作
        [self operationQueue].suspended = NO;
        
    }
    
}

//控制操作之间的依赖关系，等价于并发数目为1，顺序执行
- (void)showDependencyOperationInQueue {
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        
        sleep(2);
        NSLog(@"正在下载苍老师全集 。。。 %@", [NSThread currentThread]);
        
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        
        sleep(2);
        NSLog(@"正在解压缩苍老师全集。。。 %@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        
        sleep(2);
        NSLog(@"正在保存到磁盘 。。。 %@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        
        sleep(2);
        NSLog(@"下载完成 。 %@", [NSThread currentThread]);
    }];
    
    // 指定操作之间的”依赖“关系，某一个操作的执行，必须等待另一个操作完成才会开始
    // 依赖关系是可以跨队列指定的
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    [op4 addDependency:op3];
    // *** 添加依赖的时候，注意不要出现循环依赖
    //    [op3 addDependency:op4];
    
    [[self operationQueue] addOperation:op1];
    [[self operationQueue]  addOperation:op2];
    [[self operationQueue]  addOperation:op3];
    
    // 主队列更新UI
    [[NSOperationQueue mainQueue] addOperation:op4];
}

//这样的话，每个Block就相当于一个NSOperation，会受到queue最大并发数的限制
- (void)addBlockConcurrentNum {
    
    [[self operationQueue] addOperationWithBlock:^{
        
        NSLog(@"--- task1 thread is %@",[NSThread currentThread]);
        //数据操作
        sleep(5);
        NSLog(@"--- task1 数据操作结束");
        
    }];
    
    [[self operationQueue] addOperationWithBlock:^{
        
        NSLog(@"--- task2 thread is %@",[NSThread currentThread]);
        //数据操作
        sleep(5);
        NSLog(@"--- task2 数据操作结束");
        
    }];
    
    [[self operationQueue] addOperationWithBlock:^{
        
        NSLog(@"--- task3 thread is %@",[NSThread currentThread]);
        //数据操作
        sleep(5);
        NSLog(@"--- task3 数据操作结束");
        
    }];
    
}

//NSInvocationOperation的用法
- (void)showNSInvocationOperation {
    
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadData:) object:@"http://www.baidu.com"];
    
    //直接启动，在主线程操作
    //    [op1 start];
    
    //加入队列中，开启分线程操作
    [[self operationQueue] addOperation:op1];
    
    
}

//这个方法会再指定的queue里面执行
- (void)loadData:(NSString *)url {
    
    NSLog(@"--- url is %@ task3 thread is %@",url,[NSThread currentThread]);
    //数据操作
    sleep(5);
    NSLog(@"--- task3 数据操作结束");
    
}

//展示自定义同步的操作
- (void)showSynOperation {
    
    SyncOperation *syncOp = [[SyncOperation alloc]initWithURL:@"http://images.cnitblog.com/i/450136/201406/262237525398083.png" finishedBlock:^(UIImage *image, NSError *error) {
        
        NSLog(@"--- %@", NSStringFromCGSize(image.size));
    }];
    
    [syncOp start];
    
    //下面的方法不能调用，否则自动会在分线程中执行
    //        [[self operationQueue] addOperation:syncOp];
    
    NSLog(@"syncOp is concurrent %d",syncOp.concurrent);
}

//展示自定义并发的operaiton
- (void)showAsynOperation {
    
    _asynop = [[AsynOperation alloc]initWithImageURL:@"http://www.baidu.com" result:nil];
    [_asynop start];
    sleep(2);
    [_asynop cancel];
    
    [_asynop addObserver:self forKeyPath:@"isExecuting" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

//监听状态 KVO是同步执行的，会阻塞caller所在的线程
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    sleep(3);
    NSLog(@"change is %@",change);
}

@end
