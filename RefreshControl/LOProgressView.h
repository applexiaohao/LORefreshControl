//
//  LOProgressView.h
//  RefreshDemo
//
//  Created by lewis on 6/30/15.
//  Copyright (c) 2015 蓝鸥科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@class LOProgressView;
@protocol LOProgressViewDelegate <NSObject>

//当进度发生变化时的代理回调函数
- (void)progressView:(LOProgressView *)sender withProgress:(CGFloat )progress;

//当进度为0时的代理回调函数
- (void)progressStartWithView:(LOProgressView *)sender;

//当进度结束时的代理回调函数
- (void)progressFinishedWithView:(LOProgressView *)sender;

@end


//当进度发生变化时的回调Block代码块
typedef void(^LOProgressChangeBlock)(LOProgressView *sender,CGFloat progress);

//当进度发生开始时的回调Block代码块
typedef void(^LOProgressStartBlock)(LOProgressView *sender);

//当进度发生结束时的回调Block代码块
typedef void(^LOProgressFinishedBlock)(LOProgressView *sender);

@interface LOProgressView : UIView

//进度显示从0..1
@property (nonatomic ,assign) CGFloat progress;

//进度视图的回调代理对象
@property (nonatomic ,assign) id<LOProgressViewDelegate> delegate;

//注册changeBlock
@property (nonatomic ,copy) LOProgressChangeBlock       changeBlock;

//注册startBlock
@property (nonatomic ,copy) LOProgressStartBlock        startBlock;

//注册finishedBlock
@property (nonatomic ,copy) LOProgressFinishedBlock     finishedBlock;

@end

@interface LOCircleProgressView : LOProgressView

//圆形进度现实的半径
@property (nonatomic ,assign) CGFloat   radius;

//是否进行填充
@property (nonatomic ,assign) BOOL      isFilled;

//填充的颜色
@property (nonatomic ,assign) UIColor   *color;

@end
