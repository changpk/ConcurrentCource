//
//  SyncOperation.m
//  LearnGCD
//
//  Created by changpengkai on 15/4/8.
//  Copyright (c) 2015年 com.pengkaichang. All rights reserved.
//

#import "SyncOperation.h"
#import <UIKit/UIKit.h>

@implementation SyncOperation {
    
    void(^block)(UIImage * image, NSError *error); //获取到得数据，传递到外部
    
    
}

- (instancetype)initWithURL:(NSString *)imageURL finishedBlock:(void(^)(UIImage * image, NSError *error))finishedBlock {
    
    if (self = [super init]) {
        
        _imageURL = imageURL;
        block = finishedBlock;
        
    }
    
    return self;
}

//main方法主要是用来执行task，此方法会在阻塞caller的线程
- (void)main {
    
    NSLog(@"thread is %@",[NSThread currentThread]);
    NSLog(@"concurrent is %d",self.concurrent);
    
    BOOL done = NO; //耗时的操作，保证线程是阻塞状态
    
    while (!self.cancelled && !done) {
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]];
        
        UIImage *loadImage = [UIImage imageWithData:imageData];
        
        done = YES;
        
        block (loadImage,nil);
    }

}

@end
