//
//  LORefresh.m
//  RefreshDemo
//
//  Created by neal on 15/6/25.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "LORefresh.h"
#import <ImageIO/ImageIO.h>
#pragma mark - 相关宏定义

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kHeaderHeight 65
#define kFooterHeight 65

#define LORefreshLabelAndIndicatorSpace 10

// RGB颜色
#define LOColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 文字颜色
#define LORefreshLabelTextColor LOColor(100, 100, 100)

// 字体大小
#define LORefreshLabelFont [UIFont boldSystemFontOfSize:13]

#pragma mark- 默认文字

NSString *const LORefreshHeaderStateIdleText = @"下拉可以刷新";
NSString *const LORefreshHeaderStatePullingText = @"松开立即刷新";
NSString *const LORefreshHeaderStateRefreshingText = @"正在刷新数据中...";

NSString *const LORefreshFooterStateIdleText = @"上拉加载更多";
NSString *const LORefreshFooterStatePullingText = @"松开立即加载";
NSString *const LORefreshFooterStateRefreshingText = @"正在加载更多的数据...";

#pragma mark - header 和 footer 枚举状态

typedef NS_ENUM(NSUInteger, LORefreshHeaderState){
    LORefreshHeaderStateIdle,         //闲置状态
    LORefreshHeaderStatePulling,      //松开就可以进行刷新的状态
    LORefreshHeaderStateRefreshing    //正在刷新中的状态
};

typedef NS_ENUM(NSUInteger, LORefreshFooterState){
    LORefreshFooterStateIdle,         //闲置状态
    LORefreshFooterStatePulling,      //松开就可以加载更多的状态
    LORefreshFooterStateRefreshing    //正在刷新中的状态
};

#pragma mark - LORefresh 延展

@interface LORefresh ()
{
    UIImageView *_arrowImageView;               //箭头
    UIActivityIndicatorView *_indicatorView;    //风火轮
    UILabel *_textLabel;                        //文本
    UIImageView *_gifImageView;                 //gif
    
    LORefreshViewType _refreshViewType;         //view类型
@protected
    LORefreshLayoutType _refreshLayoutType;     //布局类型
    LORefreshHeaderState _headerState;
    LORefreshFooterState _footerState;
}

@property (nonatomic, assign) UIScrollView *scrollView; //需要加载 header 或者 footer 的 scrollView
@property(nonatomic, assign) LORefreshHeaderState headerState;
@property(nonatomic, assign) LORefreshFooterState footerState;

@property (strong, nonatomic) NSMutableDictionary *stateTitles;

- (UIImageView *)gifImageView;
- (UILabel *)textLabel;
- (UIActivityIndicatorView *)indicatorView;
- (UIImageView *)arrowImageView;

@end





#pragma mark- LORefreshHeaderDefault 类



@interface LORefreshHeaderDefault : LORefresh
{
    CGFloat _edgeInsetsTop;
}

@end

@implementation LORefreshHeaderDefault


- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self addSubview:[self arrowImageView]];
        [self addSubview:[self indicatorView]];
        [self addSubview:[self textLabel]];
        self.textLabel.text = LORefreshHeaderStateIdleText;
        self.tag = 1000000;//方便 scrollView 找到这个视图
//        self.backgroundColor = [UIColor whiteColor];
        
        [self.stateTitles setObject:LORefreshHeaderStateIdleText forKey:@(LORefreshStateNormal)];
        [self.stateTitles setObject:LORefreshHeaderStatePullingText forKey:@(LORefreshStatePulling)];
        [self.stateTitles setObject:LORefreshHeaderStateRefreshingText forKey:@(LORefreshStateRefreshing)];

    }
    return self;
}

- (void)beginRefreshing
{
    self.headerState = LORefreshHeaderStateRefreshing;
}

- (BOOL)isRefreshing
{
    return _headerState == LORefreshHeaderStateRefreshing;
}

- (void)endRefreshing
{
    self.headerState = LORefreshHeaderStateIdle;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    [super setScrollView:scrollView];
    CGFloat width = self.scrollView.bounds.size.width;
    self.frame = CGRectMake(0, -kHeaderHeight, width, kHeaderHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    switch (_refreshLayoutType) {
        case LORefreshLayoutTypeLeftIndicator:
        {
            CGFloat width = [LORefresh labelFit:[self textLabel].text andFont:LORefreshLabelFont];
            CGFloat totalWidth = 22 + 10 + width;
            CGFloat indicatorViewX =( [UIScreen mainScreen].bounds.size.width - totalWidth)/ 2;
            
            [self indicatorView].frame = CGRectMake(indicatorViewX, kHeaderHeight-30, 22, 22);
            [self arrowImageView].center = self.indicatorView.center;
            [self textLabel].frame = CGRectMake(self.indicatorView.frame.origin.x + self.indicatorView.frame.size.width + 10, kHeaderHeight-30, width, 20);
            
            break;
        }
        case LORefreshLayoutTypeTopIndicator:
        {
            [self textLabel].frame = CGRectMake(0, kHeaderHeight-20, kScreenWidth, 20);
            CGPoint labelCenter = [self textLabel].center;
            [self indicatorView].center = CGPointMake(labelCenter.x, labelCenter.y - 30);
            [self arrowImageView].center = CGPointMake(labelCenter.x, labelCenter.y - 30);
            break;
        }
        case LORefreshLayoutTypeRightIndicator:
        {
            CGFloat height = kHeaderHeight / 2;
            CGFloat width = [LORefresh labelFit:[self textLabel].text andFont:LORefreshLabelFont];
            
            CGFloat leftWidth = (kScreenWidth - width - LORefreshLabelAndIndicatorSpace - 22) / 2;
            [self textLabel].frame = CGRectMake(leftWidth, 0, width , kHeaderHeight);
            
            [self indicatorView].center = CGPointMake((kScreenWidth - 22 / 2 - leftWidth), height);
            
            [self arrowImageView].center = CGPointMake((kScreenWidth - 15 / 2 - leftWidth), height);
            break;
        }
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //如果当前状态是 LORefreshHeaderStateRefreshing 不再做检测处理
    if (_headerState ==  LORefreshHeaderStateRefreshing) {
        return;
    }
    [self adjustStateWithContentOffset];
}

- (void)adjustStateWithContentOffset
{
    //记录 scrollView原始的上边距.  方便刷新之后,把 scrollView 的contentInset改回这个位置.
    _edgeInsetsTop = self.scrollView.contentInset.top;
    
    if (_headerState == LORefreshHeaderStateRefreshing) {
        return;
    }
    
    //当前的偏移量
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    
    //scrollView左上角 原始偏移量(默认是0),在有导航栏的情况下可能会被调整为64.
    CGFloat happenOffsetY = -self.scrollView.contentInset.top;
    
    //如果往上滑动,直接 return
    if (contentOffsetY >= happenOffsetY) return;
    
    //header 完全出现时的contentOffset.y
    CGFloat headerCompleteDisplayContentOffsetY = happenOffsetY - kHeaderHeight;
    NSLog(@"%f  %f  %f",contentOffsetY,happenOffsetY,headerCompleteDisplayContentOffsetY);
    if (self.scrollView.isDragging == YES) {//如果正在拖拽
        //如果当前状态是 LORefreshStateIdle(闲置状态或者叫正常状态) && header 已经全部显示
        if (_headerState == LORefreshHeaderStateIdle && contentOffsetY < headerCompleteDisplayContentOffsetY) {
            //将状态设置为  松开就可以进行刷新的状态
            self.headerState = LORefreshHeaderStatePulling;
            NSLog(@"下拉状态");
        }else if (_headerState == LORefreshHeaderStatePulling && contentOffsetY > headerCompleteDisplayContentOffsetY){//如果当前状态是 LORefreshStatePulling(松开就可以进行刷新的状态) && header只显示了一部分(用户往上滑动了)
            self.headerState = LORefreshHeaderStateIdle;
            NSLog(@"常态");
        }
    }else{//如果松开了手
        if (_headerState == LORefreshHeaderStatePulling) {//如果状态是1,下拉状态.让它进入刷新状态
            self.headerState = LORefreshHeaderStateRefreshing;
            NSLog(@"刷新中");
        }
    }
}



- (void)setHeaderState:(LORefreshHeaderState)state
{
    if (_headerState == state) return;
    
    LORefreshHeaderState oldState = _headerState;
    
    _headerState = state;
    [self textLabel].text = self.stateTitles[@(_headerState)];

    switch (_headerState) {
        case LORefreshHeaderStateIdle:{
            
            if (oldState == LORefreshHeaderStateRefreshing) {//如果前一个状态是 刷新状态,我们把风火轮隐藏,箭头显示出来
                [[self indicatorView] stopAnimating];
                [self indicatorView].hidden = YES;
                [self arrowImageView].hidden = NO;
                //让scrollView.contentInset变为(0,0,0,0)
                [UIView animateWithDuration:0.3 animations:^{
                    self.scrollView.contentInset = UIEdgeInsetsMake(_edgeInsetsTop, 0, 0, 0);
                }];
            }
            //让箭头朝下
            [UIView animateWithDuration:0.2 animations:^{
                [self arrowImageView].transform = CGAffineTransformMakeRotation(0);
            }];
            break;
        }
        case LORefreshHeaderStatePulling:{
            //让箭头朝上
            [UIView animateWithDuration:0.2 animations:^{
                [self arrowImageView].transform = CGAffineTransformMakeRotation(M_PI);
            }];
            
            break;
        }
        case LORefreshHeaderStateRefreshing:{
            
            //隐藏箭头
            [self arrowImageView].hidden = YES;
            //显示风火轮
            [self indicatorView].hidden = NO;
            [[self indicatorView] startAnimating];
            
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(_edgeInsetsTop + kHeaderHeight, 0, 0, 0);
            }completion:^(BOOL finished) {
                if (self.refreshingBlock) {
                    self.refreshingBlock();
                }
                //[self performSelector:@selector(endRefreshing) withObject:nil afterDelay:3];
            }];
            break;
        }
        default:
            break;
    }
    
}


@end



#pragma mark - LORefreshFooterDefault 类

@interface LORefreshHeaderGIF : LORefresh
{
    CGFloat _edgeInsetsTop;
}

@end

@implementation LORefreshHeaderGIF

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, -kHeaderHeight, kScreenWidth, kHeaderHeight)];
    if (self) {
        [self addSubview:self.gifImageView];
        [self addSubview:self.textLabel];
        self.textLabel.text = LORefreshHeaderStateIdleText;
        self.tag = 1000001;//方便 scrollView 找到这个视图
        //        self.backgroundColor = [UIColor whiteColor];
        
        [self.stateTitles setObject:LORefreshHeaderStateIdleText forKey:@(LORefreshStateNormal)];
        [self.stateTitles setObject:LORefreshHeaderStatePullingText forKey:@(LORefreshStatePulling)];
        [self.stateTitles setObject:LORefreshHeaderStateRefreshingText forKey:@(LORefreshStateRefreshing)];
    }
    return self;
}

- (void)beginRefreshing
{
    self.headerState = LORefreshHeaderStateRefreshing;
}

- (BOOL)isRefreshing
{
    return _headerState == LORefreshHeaderStateRefreshing;
}

- (void)endRefreshing
{
    self.headerState = LORefreshHeaderStateIdle;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    [super setScrollView:scrollView];
    CGFloat width = self.scrollView.bounds.size.width;
    self.frame = CGRectMake(0, -kHeaderHeight, width, kHeaderHeight);
}


//xx.gif 仅当LORefreshViewType 为 LORefreshViewTypeHeaderGif时可用
- (void)setGifName:(NSString *)gifName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"demo.gif" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    CGFloat duration = 0;
    NSMutableArray *mArr = [LORefreshHeaderGIF praseGIFDataToImageArray:data duration:&duration];
    [self gifImageView].animationImages = mArr;
    [self gifImageView].animationDuration = duration;
    [self gifImageView].image = [mArr objectAtIndex:0];
}

+ (NSMutableArray *)praseGIFDataToImageArray:(NSData *)data duration:(CGFloat *)duration;
{
    NSMutableArray *frames = nil;
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    if (src) {
        size_t l = CGImageSourceGetCount(src);
        frames = [NSMutableArray arrayWithCapacity:l];
        for (size_t i = 0; i < l; i++) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, i, NULL));
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            *duration += [delayTime floatValue];
            if (img) {
                [frames addObject:[UIImage imageWithCGImage:img]];
                CGImageRelease(img);
            }
        }
        CFRelease(src);
    }
    return frames;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    switch (_refreshLayoutType) {
        case LORefreshLayoutTypeLeftIndicator:
        {
            CGFloat width = [LORefresh labelFit:[self textLabel].text andFont:LORefreshLabelFont];
            CGFloat totalWidth = 40 + 10 + width;
            CGFloat indicatorViewX =(self.scrollView.bounds.size.width - totalWidth)/ 2;
            
            [self gifImageView].frame = CGRectMake(indicatorViewX, kHeaderHeight-30, 30, 30);
            [self textLabel].frame = CGRectMake(self.gifImageView.frame.origin.x + self.gifImageView.frame.size.width + 10, kHeaderHeight-30, width, 20);
            
            break;
        }
        case LORefreshLayoutTypeTopIndicator:
        {
            [self textLabel].frame = CGRectMake(0, kHeaderHeight-20, kScreenWidth, 20);
            CGPoint labelCenter = [self textLabel].center;
            [self gifImageView].center = CGPointMake(labelCenter.x, labelCenter.y - 30);
            break;
        }
        case LORefreshLayoutTypeRightIndicator:
        {
            CGFloat height = kHeaderHeight / 2;
            CGFloat width = [LORefresh labelFit:[self textLabel].text andFont:LORefreshLabelFont];
            
            CGFloat leftWidth = (kScreenWidth - width - LORefreshLabelAndIndicatorSpace - 40) / 2;
            [self textLabel].frame = CGRectMake(leftWidth, 0, width , kHeaderHeight);
            
            [self gifImageView].center = CGPointMake((kScreenWidth - 40 / 2 - leftWidth), height);
            
            break;
        }
        default:
            break;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //如果当前状态是 LORefreshHeaderStateRefreshing 不再做检测处理
    if (_headerState ==  LORefreshHeaderStateRefreshing) {
        return;
    }
    [self adjustStateWithContentOffset];
}

- (void)adjustStateWithContentOffset
{
    //记录 scrollView原始的上边距.  方便刷新之后,把 scrollView 的contentInset改回这个位置.
    _edgeInsetsTop = self.scrollView.contentInset.top;
    
    if (_headerState == LORefreshHeaderStateRefreshing) {
        return;
    }
    
    //当前的偏移量
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    
    //scrollView左上角 原始偏移量(默认是0),在有导航栏的情况下可能会被调整为64.
    CGFloat happenOffsetY = -self.scrollView.contentInset.top;
    
    //如果往上滑动,直接 return
    if (contentOffsetY >= happenOffsetY) return;
    
    //header 完全出现时的contentOffset.y
    CGFloat headerCompleteDisplayContentOffsetY = happenOffsetY - kHeaderHeight;
    NSLog(@"%f  %f  %f",contentOffsetY,happenOffsetY,headerCompleteDisplayContentOffsetY);
    if (self.scrollView.isDragging == YES) {//如果正在拖拽
        //如果当前状态是 LORefreshStateIdle(闲置状态或者叫正常状态) && header 已经全部显示
        if (_headerState == LORefreshHeaderStateIdle && contentOffsetY < headerCompleteDisplayContentOffsetY) {
            //将状态设置为  松开就可以进行刷新的状态
            self.headerState = LORefreshHeaderStatePulling;
            NSLog(@"下拉状态");
        }else if (_headerState == LORefreshHeaderStatePulling && contentOffsetY > headerCompleteDisplayContentOffsetY){//如果当前状态是 LORefreshStatePulling(松开就可以进行刷新的状态) && header只显示了一部分(用户往上滑动了)
            self.headerState = LORefreshHeaderStateIdle;
            NSLog(@"常态");
        }
    }else{//如果松开了手
        if (_headerState == LORefreshHeaderStatePulling) {//如果状态是1,下拉状态.让它进入刷新状态
            self.headerState = LORefreshHeaderStateRefreshing;
            NSLog(@"刷新中");
        }
    }
}


- (void)setHeaderState:(LORefreshHeaderState)state
{
    if (_headerState == state) return;
    
    LORefreshHeaderState oldState = _headerState;
    
    _headerState = state;
    [self textLabel].text = self.stateTitles[@(_headerState)];
    
    switch (_headerState) {
        case LORefreshHeaderStateIdle:{
            
            if (oldState == LORefreshHeaderStateRefreshing) {//如果前一个状态是 刷新状态,我们把风火轮隐藏,箭头显示出来
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.scrollView.contentInset = UIEdgeInsetsMake(_edgeInsetsTop, 0, 0, 0);
                }completion:^(BOOL finished) {
                    [[self gifImageView] stopAnimating];
                }];
            }
            break;
        }
        case LORefreshHeaderStatePulling:{
            [[self gifImageView] startAnimating];

            break;
        }
        case LORefreshHeaderStateRefreshing:{
            
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(_edgeInsetsTop + kHeaderHeight, 0, 0, 0);
            }completion:^(BOOL finished) {
                if (self.refreshingBlock) {
                    self.refreshingBlock();
                }
                //[self performSelector:@selector(endRefreshing) withObject:nil afterDelay:3];
            }];
            break;
        }
        default:
            break;
    }
    
}


@end







#pragma mark - LORefreshFooterDefault 类


@interface LORefreshFooterDefault : LORefresh


@end

@implementation LORefreshFooterDefault

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kFooterHeight)];
    if (self) {
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        [self addSubview:self.arrowImageView];
        [self addSubview:self.indicatorView];
        [self addSubview:self.textLabel];
        self.textLabel.text = LORefreshFooterStateIdleText;
//        self.backgroundColor = [UIColor yellowColor];
        self.tag = 1000002;
        //设置不同状态下的标题
        [self.stateTitles setObject:LORefreshFooterStateIdleText forKey:@(LORefreshStateNormal)];
        [self.stateTitles setObject:LORefreshFooterStatePullingText forKey:@(LORefreshStatePulling)];
        [self.stateTitles setObject:LORefreshFooterStateRefreshingText forKey:@(LORefreshStateRefreshing)];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    switch (_refreshLayoutType) {
        case LORefreshLayoutTypeLeftIndicator:{
            CGFloat imageW = 15;
            CGFloat imageH = 40;
            CGFloat labelW = [LORefresh labelFit:[self textLabel].text andFont:LORefreshLabelFont];
            CGFloat imageX = (kScreenWidth - labelW - 10 - imageW) / 2;
            CGFloat imageY = (kHeaderHeight - imageH) / 2;
            CGFloat labelX = imageX + imageW + 10;
            
            CGFloat indicatorX = (kScreenWidth - labelW - 10 - 22) / 2;
            CGFloat indicatorY = (kHeaderHeight - 22) / 2;
            
            self.indicatorView.frame = CGRectMake(indicatorX, indicatorY, 22, 22);
            self.arrowImageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
            self.textLabel.frame = CGRectMake(labelX, 0, labelW, 65);
            break;
        }
        case LORefreshLayoutTypeTopIndicator:{
            [self textLabel].frame = CGRectMake(0, kHeaderHeight-20, kScreenWidth, 20);
            CGPoint labelCenter = [self textLabel].center;
            [self indicatorView].center = CGPointMake(labelCenter.x, labelCenter.y - 30);
            [self arrowImageView].center = CGPointMake(labelCenter.x, labelCenter.y - 30);
            break;
        }
        case LORefreshLayoutTypeRightIndicator:{
            CGFloat width = [LORefresh labelFit:[self textLabel].text andFont:LORefreshLabelFont];
            CGFloat totalWidth = 22 + 10 + width;
            CGFloat textLabelX =( [UIScreen mainScreen].bounds.size.width - totalWidth)/ 2;
            
            CGFloat textLabelY = (kHeaderHeight - 20 )/2;
            
            [self textLabel].frame = CGRectMake(textLabelX, textLabelY, width, 20);
            
            [self indicatorView].frame = CGRectMake(self.textLabel.frame.origin.x + width + 10 , textLabelY, 22, 22);
            [self arrowImageView].center = self.indicatorView.center;
            break;
        }
        default:
            break;
    }
    
}

- (void)beginRefreshing
{
    self.footerState = LORefreshFooterStateRefreshing;
}

- (BOOL)isRefreshing
{
    return _footerState == LORefreshFooterStateRefreshing;
}

- (void)endRefreshing
{
    self.footerState = LORefreshFooterStateIdle;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    [super setScrollView:scrollView];
    
    //在上拉加载更多的时候,scrollView(及其子类) 的contentSize.height 会变大.我们需要改变 footer 的 frame,确保它显示在最下方
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGFloat width = self.scrollView.bounds.size.width;
        CGFloat y = self.scrollView.contentSize.height;
        NSLog(@"%g",y);
        self.frame = CGRectMake(0, y, width, kFooterHeight);
    }
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self adjustStateWithContentOffset];
    }
}

-  (void)adjustStateWithContentOffset
{
    //当前的偏移量
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    
    //contentsize的 height
    CGFloat contentSizeHeight = self.scrollView.contentSize.height;
    
    //contentOffsetY 与 scrollView height 的和
    CGFloat maxOffsetY = contentOffsetY + self.scrollView.bounds.size.height;
    
    //如果没滑动到最底部,什么都不做
    if (maxOffsetY < contentSizeHeight)return;
    
    //footer完全显示时的 y 值
    CGFloat footerCompleteDisplayY = contentSizeHeight + kFooterHeight;
//    NSLog(@"%f %f %f",footerCompleteDisplayY,contentSizeHeight,maxOffsetY);
    //footer 完全显示之后,还在往上拉
    if (self.scrollView.dragging) {
        if(maxOffsetY > footerCompleteDisplayY && _footerState == LORefreshFooterStateIdle){
            self.footerState = LORefreshFooterStatePulling;
            NSLog(@"上拉");
        }else if(_footerState == LORefreshFooterStatePulling && maxOffsetY < footerCompleteDisplayY){
            self.footerState = LORefreshFooterStateIdle;
            NSLog(@"正常");
        }
    }else{
        if(_footerState == LORefreshFooterStatePulling){
            self.footerState = LORefreshFooterStateRefreshing;
            NSLog(@"加载更多");
        }
    }
}

- (void)setFooterState:(LORefreshFooterState)footerState
{
    if (_footerState == footerState) return;
    LORefreshFooterState oldState = _footerState;
    _footerState = footerState;
    [self textLabel].text = self.stateTitles[@(_footerState)];
    
    switch (_footerState) {
        case LORefreshFooterStateIdle:{
            if (oldState == LORefreshFooterStateRefreshing) {//如果前一个状态是 刷新(加载更多)状态,我们隐藏风火轮,显示箭头
                [[self indicatorView] stopAnimating];
                [self indicatorView].hidden = YES;
                [self arrowImageView].hidden = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    UIEdgeInsets insets = self.scrollView.contentInset;
                    insets.bottom = 0;
                    self.scrollView.contentInset = insets;
                }];
            }
            //让箭头朝上
            [UIView animateWithDuration:0.2 animations:^{
                [self arrowImageView].transform = CGAffineTransformMakeRotation(M_PI);
            }];
            break;
        }
        case LORefreshFooterStatePulling:{
            //让箭头朝下
            [UIView animateWithDuration:0.2 animations:^{
                [self arrowImageView].transform = CGAffineTransformMakeRotation(0);
            }];
            break;
        }
        case LORefreshFooterStateRefreshing:{
            //隐藏箭头
            [self arrowImageView].hidden = YES;
            //显示风火轮
            [self indicatorView].hidden = NO;
            [[self indicatorView] startAnimating];

            [UIView animateWithDuration:0.3 animations:^{
                UIEdgeInsets insets = self.scrollView.contentInset;
                insets.bottom = kFooterHeight;
                self.scrollView.contentInset = insets;
            }completion:^(BOOL finished) {
                if (self.refreshingBlock) {
                    self.refreshingBlock();
                }
            }];
            break;

        }
        default:
            break;
    }
}

@end





#pragma mark - LORefresh 实现部分

@implementation LORefresh
@synthesize scrollView = _scrollView;

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_arrowImageView release];
    [_indicatorView release];
    [_textLabel release];
    [_gifImageView release];
    Block_release(_refreshingBlock);
    [super dealloc];
}

#pragma mark - init methods

//采用类簇的方式,根据 type 创建不同类型的 RefreshView
+ (instancetype)refreshWithRefreshViewType:(LORefreshViewType)refreshViewType refreshingBlock:(void (^)())block
{
    //目前 LORefresh 只支持3种类型的 RefreshView(与LORefresh.h 文件中的 LORefreshViewType一一对应)
    NSArray *classNames = @[@"LORefreshHeaderDefault",@"LORefreshHeaderGIF",@"LORefreshFooterDefault"];
    
    //下面的判断是一个容错处理(refreshViewType超出了范围返回 nil)
    //如果 其他 开发者要扩展 LORefresh 类,可以增加枚举值,增加 LORefresh 的子类
    if (refreshViewType < [classNames count]) {
        Class className = NSClassFromString(classNames[refreshViewType]);
        LORefresh *refresh = [[className alloc] init];
        refresh.refreshingBlock = block;
        
        return [refresh autorelease];
    }else{
        return nil;
    }
}


#pragma mark - Custom Getter
- (UIImageView *)arrowImageView
{
    if (_arrowImageView == nil) {
        //箭头的size设置为(15,40),子类里会在 layoutSubviews 里面更改它的(x,y)值
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 40)];
        _arrowImageView.image = [UIImage imageNamed:@"arrow"];
    }
    return _arrowImageView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        //风火轮的size设置为(22,22),子类里会在 layoutSubviews 里面更改它的(x,y)值
        _indicatorView.frame = CGRectMake(0, 0, 22, 22);
    }
    return _indicatorView;
}

- (UILabel *)textLabel
{
    if (_textLabel == nil) {
        //_textLabel的frame设置为(0,0,0,0),子类里会在 layoutSubviews 里面更改它的frame值
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.textColor = LORefreshLabelTextColor;
        _textLabel.font = LORefreshLabelFont;
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}

- (UIImageView *)gifImageView
{
    if (_gifImageView == nil) {
        //imageView的size设置为(40,40),子类里会在 layoutSubviews 里面更改它的(x,y)值
        _gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    }
    return _gifImageView;
}



#pragma mark -
-  (void)setRefreshLayoutType:(LORefreshLayoutType)refreshLayoutType
{
    _refreshLayoutType = refreshLayoutType;
    [self setNeedsDisplay];
}

- (LORefreshLayoutType)refreshLayoutType
{
    return _refreshLayoutType;
}


- (void)beginRefreshing
{
}

- (BOOL)isRefreshing
{
    return NO;
}

- (void)endRefreshing
{
}


- (void)setTitle:(NSString *)title forState:(LORefreshState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    
    // 刷新当前状态的文字
    self.textLabel.text = self.stateTitles[@(state)];
    [self setNeedsDisplay];
}

- (NSMutableDictionary *)stateTitles
{
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

- (void)setGifName:(NSString *)gifName
{
    
}


+(CGFloat)labelFit:(NSString *)str andFont:(UIFont *)font
{
    NSDictionary  *dic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    CGSize actualsize = [str boundingRectWithSize:CGSizeMake(300.f, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    return actualsize.width;
}

@end












#pragma mark - UIScrollView(RefreshView)


//为 UIScrollView及其子类添加 header 或者 footer 视图.
@implementation UIScrollView (RefreshView)

- (void)addRefreshWithRefreshViewType:(LORefreshViewType)refreshViewType refreshingBlock:(void (^)())block
{
    LORefresh *refresh = [LORefresh refreshWithRefreshViewType:refreshViewType refreshingBlock:block];
    refresh.scrollView = self;
    
    [self addObserver:refresh forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self addSubview:refresh];
}


- (LORefresh *)defaultHeader
{
    return (LORefresh *)[self viewWithTag:1000000];
}

- (LORefresh *)gifHeader
{
    return (LORefresh *)[self viewWithTag:1000001];
}

- (LORefresh *)defaultFooter
{
    return (LORefresh *)[self viewWithTag:1000002];
}

@end