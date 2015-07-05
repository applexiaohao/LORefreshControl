//
//  TableViewController.m
//  RefreshDemo
//
//  Created by neal on 15/6/26.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "TableViewController.h"
#import "LORefreshControl.h"

@interface TableViewController ()
@property (nonatomic, retain)NSMutableArray *dataArray;
@end

@implementation TableViewController

- (void)dealloc
{
    NSLog(@"---dealloc");
    [super dealloc];
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        self.dataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataArray;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    for (int i = 0; i < 20; i++) {
        NSString *str = [NSString stringWithFormat:@"%d",100 + arc4random()%100];
        [self.dataArray addObject:str];
    }
    
    __block TableViewController *weakSelf = self;
    [self.tableView addRefreshWithRefreshViewType:LORefreshViewTypeFooterDefault refreshingBlock:^{
        for (int i = 0; i < 20; i++) {
            NSString *str = [NSString stringWithFormat:@"%d",100 + arc4random()%100];
            [weakSelf.dataArray addObject:str];
        }
        
        [weakSelf.tableView reloadData];
        NSLog(@"%@",weakSelf.tableView.defaultFooter);
        
        //结束刷新
        [weakSelf.tableView.defaultFooter endRefreshing];

    }];
    
    
//    [self.tableView addRefreshWithRefreshViewType:LORefreshViewTypeHeaderDefault refreshingBlock:^{
//        [weakSelf.dataArray removeAllObjects];
//        for (int i = 0; i < 20; i++) {
//            NSString *str = [NSString stringWithFormat:@"%d",100 + arc4random()%100];
//            [weakSelf.dataArray addObject:str];
//        }
//        [weakSelf.tableView reloadData];
//        [weakSelf.tableView.defaultHeader endRefreshing];
//    }];
    
    [self.tableView addRefreshWithRefreshViewType:LORefreshViewTypeHeaderGif refreshingBlock:^{
        [weakSelf.dataArray removeAllObjects];
        for (int i = 0; i < 20; i++) {
            NSString *str = [NSString stringWithFormat:@"%d",100 + arc4random()%100];
            [weakSelf.dataArray addObject:str];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.gifHeader endRefreshing];
    }];
    [self.tableView.gifHeader setGifName:@"demo.gif"];
    
    
//    self.tableView.defaultHeader.refreshLayoutType = LORefreshLayoutTypeTopIndicator;
//    self.tableView.defaultHeader.refreshLayoutType = LORefreshLayoutTypeRightIndicator;
//    self.tableView.defaultHeader.refreshLayoutType = LORefreshLayoutTypeLeftIndicator;

//    self.tableView.gifHeader.refreshLayoutType = LORefreshLayoutTypeTopIndicator;
    self.tableView.gifHeader.refreshLayoutType = LORefreshLayoutTypeRightIndicator;
//    self.tableView.gifHeader.refreshLayoutType = LORefreshLayoutTypeLeftIndicator;
    
//    self.tableView.defaultFooter.refreshLayoutType = LORefreshLayoutTypeTopIndicator;
//    self.tableView.defaultFooter.refreshLayoutType = LORefreshLayoutTypeLeftIndicator;
    self.tableView.defaultFooter.refreshLayoutType = LORefreshLayoutTypeRightIndicator;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(loadMore) userInfo:nil repeats:YES];
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadMore
{
    for (int i = 0; i < 20; i++) {
        NSString *str = [NSString stringWithFormat:@"%d",100 + arc4random()%100];
        [self.dataArray addObject:str];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%@",self.tableView);
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
