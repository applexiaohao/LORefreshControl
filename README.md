# LORefreshControl
LORefreshControl
* 最方便快捷的下拉刷新代码：一行代码搞定



> 为ScrollView添加默认下拉刷新代码
 
    //LORefreshViewTypeFooterDefault指定使用默认的刷新样式

    [self.scrollView addRefreshWithRefreshViewType:LORefreshViewTypeFooterDefault refreshingBlock:^{
    //...开始刷新状态时会立即执行Block代码块.
    }];

> 为ScrollView添加GIF图片下拉刷新代码

    //LORefreshViewTypeHeaderGif指定使用GIF图片的刷新样式

    [self.scrollView addRefreshWithRefreshViewType:LORefreshViewTypeHeaderGif refreshingBlock:^{
          //...开始刷新状态时会立即执行Block代码块.
    }];

    //设置GIF图片的资源
    [self.scrollView.gifHeader setGifName:@"xxx.gif"];

> 修改ScrollView下拉刷新视图的布局样式

    //左右布局:左风火轮(或 gif),右标题    默认值
    self.scrollView.defaultHeader.refreshLayoutType = LORefreshLayoutTypeTopIndicator;
    左右布局:左标题,右风火轮(或 gif)
    self.scrollView.defaultHeader.refreshLayoutType = LORefreshLayoutTypeRightIndicator;
    上下布局:上风火轮(或 gif),下标题
    self.scrollView.defaultHeader.refreshLayoutType = LORefreshLayoutTypeLeftIndicator;

> 修改ScrollView下拉刷新视图不同状态的显示文字

    //获取当前滚动视图的刷新提醒视图
    LORefresh *refresh = self.scrollView.defaultHeader;
    //修改正在刷新状态时的提醒文字
    [refresh setTitle:@"正在快快的刷新哦..." forState:LORefreshStateRefreshing];
    //修改正在下拉状态下的提醒文字
    [refresh setTitle:@"松手就可以刷新了哦..." forState:LORefreshStatePulling];
    //修改正常状态下的提醒文字
    [refresh setTitle:@"还用刷新功能吗？..." forState:LORefreshStateNormal];

## 注意
* 工程使用非ARC环境下编译运行,支持iOS版本 > 5.0

## 谢谢
* 如果在使用的时候有遇到新的问题bug，麻烦Issue或者邮件通知我，我们一定会在最快的时间内修复bug