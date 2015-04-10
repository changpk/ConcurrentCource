//
//  RunLoopObj.h
//  LearnGCD
//
//  Created by changpengkai on 15/4/9.
//  Copyright (c) 2015年 com.pengkaichang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunLoopObj : NSObject

+ (void)displayMainRunLoopInfo;

- (void)displayRunLoopInSepreteThread;

- (void)displayNSTimerInSepreteThread;

@end
