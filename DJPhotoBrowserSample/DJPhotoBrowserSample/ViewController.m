//
//  ViewController.m
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import "ViewController.h"
#import "DJPhotoGridView.h"
#import "DJPhotoItem.h"

#import "SDWebImageCodersManager.h"
#import "SDWebImageGIFCoder.h"

@interface ViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource
>

@property (nonatomic, strong) NSArray *srcStringArray;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tableDataArray;

@property (nonatomic, strong) NSMutableArray *cellHeightArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"PhotoBrowser";
    
    // 如果想要新版本SDWebImage支持gif动画显示，需要加载GIFCoder
    [[SDWebImageCodersManager sharedInstance] addCoder:[SDWebImageGIFCoder sharedCoder]];

    self.srcStringArray = @[
                        @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
                        @"http://ww2.sinaimg.cn/thumbnail/642beb18gw1ep3629gfm0g206o050b2a.gif",
                        @"http://ww4.sinaimg.cn/thumbnail/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg",
                        @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",
                        @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",
                        @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                        @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",
                        @"http://ww2.sinaimg.cn/thumbnail/677febf5gw1erma104rhyj20k03dz16y.jpg",
                        @"http://ww4.sinaimg.cn/thumbnail/677febf5gw1erma1g5xd0j20k0esa7wj.jpg"
                        ];
    
    self.tableDataArray = [NSMutableArray arrayWithCapacity:0];
    self.cellHeightArray = [NSMutableArray arrayWithCapacity:0];
    for (NSUInteger i=0; i<20; i++)
    {
        NSMutableArray *temp = [NSMutableArray array];
        [_srcStringArray enumerateObjectsUsingBlock:^(NSString *src, NSUInteger idx, BOOL *stop) {
            DJPhotoItem *item = [[DJPhotoItem alloc] init];
            item.thumbnailImage = src;
            item.width = 200;
            item.height = 280;
            [temp addObject:item];
            NSUInteger index = i%9;
            if (idx == index)
            {
                *stop = YES;
            }
        }];
        
        [self.tableDataArray addObject:temp];
        CGSize size = [DJPhotoGridView photoGridViewSizeWith:temp];
        [self.cellHeightArray addObject:@(size.height)];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [[self.cellHeightArray objectAtIndex:indexPath.row] doubleValue] + 20;
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        DJPhotoGridView *photoGroup = [[DJPhotoGridView alloc] init];
        photoGroup.frame = CGRectMake(10, 10, 100, 100);
        photoGroup.tag = 100;
        [cell.contentView addSubview:photoGroup];
    }
    
    DJPhotoGridView *photoGroup = [cell viewWithTag:100];
    
//    NSMutableArray *temp = [NSMutableArray array];
//    [_srcStringArray enumerateObjectsUsingBlock:^(NSString *src, NSUInteger idx, BOOL *stop) {
//        DJPhotoItem *item = [[DJPhotoItem alloc] init];
//        item.thumbnailImage = src;
//        item.width = 200;
//        item.height = 280;
//        [temp addObject:item];
//        NSUInteger index=indexPath.row%9;
//        if (idx == index)
//        {
//            *stop = YES;
//        }
//    }];
//
//    photoGroup.photoItemArray = [temp copy];
    photoGroup.photoItemArray = [self.tableDataArray objectAtIndex:indexPath.row];
    return cell;
}

@end
