//
//  LORefresh.h
//  RefreshDemo
//
//  Created by neal on 15/6/25.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, LORefreshViewType){
    LORefreshViewTypeHeaderDefault, //Header(风火轮,标题)
    LORefreshViewTypeHeaderGif,     //Header(gif图,标题)
    LORefreshViewTypeFooterDefault  //Footer(风火轮,标题)
};

typedef NS_ENUM(NSInteger, LORefreshLayoutType){
    LORefreshLayoutTypeLeftIndicator,   //左右布局:左风火轮(或 gif),右标题    默认值
    LORefreshLayoutTypeTopIndicator,    //上下布局:上风火轮(或 gif),下标题
    LORefreshLayoutTypeRightIndicator   //左右布局:左标题,右风火轮(或 gif)
};

typedef NS_ENUM(NSInteger, LORefreshState){
    LORefreshStateNormal,       //常态下
    LORefreshStatePulling,      //松手刷新 或者 松手显示更多
    LORefreshStateRefreshing    //刷新中
};



@interface LORefresh : UIView

//设置布局样式,默认样式LORefreshLayoutTypeLeftIndicator 左右布局:左风火轮(或 gif),右标题
@property(nonatomic, assign) LORefreshLayoutType refreshLayoutType;

//正在刷新的回调,可以在里面做网络请求
@property (copy, nonatomic) void (^refreshingBlock)();

//开始刷新
- (void)beginRefreshing;

//结束刷新
- (void)endRefreshing;

//是否正在刷新
- (BOOL)isRefreshing;


//xx.gif 仅当LORefreshViewType 为 LORefreshViewTypeHeaderGif时可用
- (void)setGifName:(NSString *)gifName;


- (void)setTitle:(NSString *)title forState:(LORefreshState)state;

//构造方法.根据给定的 type 创建header 或者 footer.
+ (instancetype)refreshWithRefreshViewType:(LORefreshViewType)refreshViewType refreshingBlock:(void (^)())block;

+(CGFloat)labelFit:(NSString *)str andFont:(UIFont *)font;

@end

//为 UIScrollView及其子类添加 header 或者 footer 视图.
@interface UIScrollView (RefreshView)

//如果既要加 header 又要加 footer,调用下面的方法2次,传入不同的枚举值.
- (void)addRefreshWithRefreshViewType:(LORefreshViewType)refreshViewType refreshingBlock:(void (^)())block;


//获取默认类型的 header,如果 scrollView 没有添加 默认 header,返回 nil
- (LORefresh *)defaultHeader;

//获取gif类型的 header,如果 scrollView 没有添加 gif header,返回 nil
- (LORefresh *)gifHeader;

//获取默认类型的  footer,如果 scrollView 没有添加  footer,返回 nil
- (LORefresh *)defaultFooter;

@end



