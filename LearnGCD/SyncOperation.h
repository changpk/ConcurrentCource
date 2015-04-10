//
//  SyncOperation.h
//  LearnGCD
//
//  Created by changpengkai on 15/4/8.
//  Copyright (c) 2015年 com.pengkaichang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

/*
 同步的operation：主要是调用star方法，重写main方法，处理cancell事件
 */
@interface SyncOperation : NSOperation

@property (nonatomic, strong) NSString *imageURL;

- (instancetype)initWithURL:(NSString *)imageURL finishedBlock:(void(^)(UIImage * image, NSError *error))finishedBlock;

@end
