//
//  ViewController.m
//  RefreshDemo
//
//  Created by neal on 15/6/25.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "ViewController.h"
#import "LORefresh.h"

@interface ViewController ()
{
    int state;
}
@property (nonatomic,retain) UIScrollView *s;
@end

@implementation ViewController



- (void)dealloc
{
    NSLog(@"dealloc");
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.s = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
    self.s.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    self.s.backgroundColor = [UIColor redColor];
    __block ViewController *weakSelf = self;
    [_s addRefreshWithRefreshViewType:LORefreshViewTypeFooterDefault refreshingBlock:nil];
    [_s addRefreshWithRefreshViewType:LORefreshViewTypeHeaderDefault refreshingBlock:^{
        [weakSelf.s.defaultHeader endRefreshing];
    }];

    [self.view addSubview:_s];
    
    //[s addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
////    NSLog(@"%g",[change[@"new"] CGPointValue].y);
//    
//    [self adjustStateWithContentOffset];
//
//}
//
//- (void)adjustStateWithContentOffset
//{
//    if (state != 100) {
//        //NSLog(@"%@",NSStringFromUIEdgeInsets(s.contentInset));
//    }
//    if (state == 100) {
//        return;
//    }
//    //当前的偏移量
//    CGFloat contentOffsetY = s.contentOffset.y;
//    
//    //scrollView左上角 原始偏移量(默认是0),在有导航栏的情况下可能会被调整为64.
//    CGFloat happenOffsetY = s.contentInset.top;
//    
//    //如果往上滑动,直接 return
//    if (contentOffsetY >= happenOffsetY) return;
//    
//    //header 完全出现时的contentOffset.y
//    CGFloat headerCompleteDisplayContentOffsetY = happenOffsetY - 54;//假定 header 的高度是54
//    
//    if (s.isDragging == YES) {//如果正在拖拽
//        //如果当前状态是 0(闲置状态或者叫正常状态) && header 已经全部显示
//        if (state == 0 && contentOffsetY < headerCompleteDisplayContentOffsetY) {
////            state = 1;//将状态设置为下拉状态
//            [self setState:1];
//            NSLog(@"下拉状态");
//        }else if (state == 1 && contentOffsetY > headerCompleteDisplayContentOffsetY){//如果当前状态是 1(下拉状态) && header只显示了一部分(用户往上滑动了)
//            //state = 0;
//            [self setState:0];
//            NSLog(@"常态");
//        }
//    }else{//如果松开了手
//        if (state == 1) {//如果状态是1,下拉状态.让它进入刷新状态
////            state = 100;
//            [self setState:100];
//            //s.contentInset = UIEdgeInsetsMake(54, 0, 0, 0);
//            NSLog(@"刷新中");
//        }
//        
//    }
//    
//}
//
//- (void)setState:(int)st
//{
//    if (state == st) return;
//    
//    int oldState = state;
//    
//    state = st;
//    
//    if (state == 0 && oldState == 100) {
//        [UIView animateWithDuration:0.3 animations:^{
//            s.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//        }];
//    }
//    if (state == 100) {
//        [UIView animateWithDuration:0.3 animations:^{
//            s.contentInset = UIEdgeInsetsMake(54, 0, 0, 0);
//        }completion:^(BOOL finished) {
//            [self performSelector:@selector(aa) withObject:nil afterDelay:3];
//        }];
//    }
//    
//}
//
//- (void)aa
//{
//    [self setState:0];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
