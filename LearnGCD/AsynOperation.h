//
//  AsynOperation.h
//  LearnGCD
//
//  Created by changpengkai on 15/4/9.
//  Copyright (c) 2015年 com.pengkaichang. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 异步操作的operation，外部调用start方法，异步执行
 */

typedef void(^resultDataBlock)(id data, NSError *error);

@interface AsynOperation : NSOperation {
    
    resultDataBlock dataBlock; //task结束以后的block
}

- (void)completeOperation;

- (instancetype)initWithImageURL:(NSString *)URL result:(resultDataBlock)result;

@end
