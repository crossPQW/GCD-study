//
//  ViewController.m
//  GCD study
//
//  Created by 黄少华 on 16/1/17.
//  Copyright © 2016年 黄少华. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self dispatchCreatDemo];
//    [self dispatchBarrierDemo];
//    [self testBackDownload];
//    [self dispatchApplyDemo];
    [self dispatchApplyDemo2:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dispatchCreatDemo
{
    
//    dispatch_get_main_queue(),主队列,主线程唯一队列,串行
//    dispatch_get_global_queue(<#long identifier#>, <#unsigned long flags#>) //并行全局队列
    
    //自定义队列
    dispatch_queue_t serialQueue = dispatch_queue_create("com.start.gcddemo", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t firstQueue = dispatch_queue_create("com.start.firstqueue", DISPATCH_QUEUE_SERIAL);//串行队列
    dispatch_queue_t secondQueue = dispatch_queue_create("com.start.secondQueue", DISPATCH_QUEUE_CONCURRENT);//并行队列
    dispatch_queue_t thridQueue = dispatch_queue_create("thridQueue", DISPATCH_QUEUE_CONCURRENT);//并行队列
    dispatch_queue_t firthQueue = dispatch_queue_create("firthQueue", DISPATCH_QUEUE_CONCURRENT);//并行队列

    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_set_target_queue(firstQueue, serialQueue);
    dispatch_set_target_queue(secondQueue, serialQueue);
    
    dispatch_async(firstQueue, ^{
        NSLog(@"1");
        [NSThread sleepForTimeInterval:3];
    });
    
    dispatch_async(secondQueue, ^{
        NSLog(@"2");
        [NSThread sleepForTimeInterval:3];
    });
    
    dispatch_async(secondQueue, ^{
        NSLog(@"3");
        [NSThread sleepForTimeInterval:3];
    });
    
//    dispatch_async(thridQueue, ^{
//        NSLog(@"4");
//        [NSThread sleepForTimeInterval:3];
//    });
//    
//    dispatch_async(firthQueue, ^{
//        NSLog(@"5");
//        [NSThread sleepForTimeInterval:3];
//    });
    
    
    
}

- (void)dispatchBarrierDemo
{
    //防止读写冲突,可以创建一个串行队列,操作都在这个队列,没有更新数据用并行,写入用串行
    dispatch_queue_t dataQueue = dispatch_queue_create("com.dispatchDataQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"read data 1");
    });
    
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"read data 2");
    });
    
    //前面的都执行完毕,再执行后面的操作
    dispatch_barrier_async(dataQueue, ^{
        NSLog(@"start write data 1");
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"end write data 1");
    });
    
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"read data 3");
    });
    
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"read data 4");
    });

}

- (void)testBackDownload{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{//将工作从主线程迁移到全局队列中,异步调用保证线程会执行下去,不会阻塞主线程
        //耗时操作
        NSLog(@"start");
        [NSThread sleepForTimeInterval:5];
        dispatch_async(dispatch_get_main_queue(), ^{//回到主线程更新UI
            NSLog(@"UI已经更新啦");
        });
        
    });

}

- (void)dispatchApplyDemo{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.starming.gcddemo.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_apply(100000, concurrentQueue, ^(size_t i) {
//        NSLog(@"%zu",i);
//    });
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_apply(10000, concurrentQueue, ^(size_t i) {
            NSLog(@"%zu",i);
        });
    });
    NSLog(@"end");
    //dispatch_apply会阻塞主线程,但是用异步线程包着就好了
}

- (void)dispatchApplyDemo2:(BOOL)export{
    dispatch_queue_t applyQueue = dispatch_queue_create("dispatchApplyDemo2", DISPATCH_QUEUE_CONCURRENT);
    if (export) {
        //这样可能造成死锁
        for (int i = 0; i< 100; i++) {
            dispatch_async(applyQueue, ^{
                NSLog(@"wrong:%d",i);
            });
        }
    }else{
        dispatch_apply(100, applyQueue, ^(size_t i) {
            NSLog(@"right: %zu",i);
        });
    }
}

#warning TODO 106行
@end
