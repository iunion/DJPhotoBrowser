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

// 记录偏移值,用于判断上滑还是下滑
@property (nonatomic, assign) CGFloat lastScrollViewContentOffsetY;
// Yes-往下滑,NO-往上滑
@property (nonatomic, assign) BOOL isScrollDownward;

@property (nonatomic, assign) NSInteger lastOrCurrentPlayIndex;

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
    
    self.lastScrollViewContentOffsetY = 0.0f;
    
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
            if (idx == 1)
            {
                item.isGif = YES;
            }
            if (idx == index)
            {
                *stop = YES;
            }
        }];
        
        [self.tableDataArray addObject:temp];
        CGSize size = [DJPhotoGridView photoGridViewSizeWith:temp];
        [self.cellHeightArray addObject:@(size.height)];
    }
    
    self.lastOrCurrentPlayIndex = -1;
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self pauseCellWithIndex:self.lastOrCurrentPlayIndex];
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
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:16.0f];
        label.tag = 200;
        [cell.contentView addSubview:label];
    }
    
    DJPhotoGridView *photoGroup = [cell viewWithTag:100];
    UILabel *label = [cell viewWithTag:200];
    label.text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll");
    
    //判断滚动方向
    if (scrollView.contentOffset.y>self.lastScrollViewContentOffsetY)
    {
        self.isScrollDownward = YES;
    }
    else
    {
        self.isScrollDownward = NO;
    }
    self.lastScrollViewContentOffsetY = scrollView.contentOffset.y;
    
    // 停止当前播放的
    //[self stopCurrentPlayingCell];
    
    // 找出适合播放的并点亮
    NSInteger lastOrCurrentPlayIndex = [self findCellWithScrollDirection:self.isScrollDownward];
    if (lastOrCurrentPlayIndex != self.lastOrCurrentPlayIndex)
    {
        [self pauseCellWithIndex:self.lastOrCurrentPlayIndex];

        self.lastOrCurrentPlayIndex = lastOrCurrentPlayIndex;
        NSLog(@"lastOrCurrentPlayIndex: %@", @(lastOrCurrentPlayIndex));
        
        [self playCellWithIndex:self.lastOrCurrentPlayIndex];
    }
}

- (NSInteger)findCellWithScrollDirection:(BOOL)isScrollDownward
{
    __block NSInteger lastOrCurrentPlayIndex = self.lastOrCurrentPlayIndex;
    //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastOrCurrentPlayIndex inSection:0]];
    
    if (self.tableView.contentOffset.y <= 0)
    {
        // 顶部
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        DJPhotoGridView *photoGroup = [cell viewWithTag:100];
        if (photoGroup.hasGif)
        {
            //[self shouldLightCellWithShouldLightIndex:0];
            lastOrCurrentPlayIndex = 0;
            return lastOrCurrentPlayIndex;
        }
    }
    else if (self.tableView.contentOffset.y+self.tableView.frame.size.height >= self.tableView.contentSize.height)
    {
        // 底部
        // 其他的已经暂停播放
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.tableDataArray.count-1 inSection:0]];
        DJPhotoGridView *photoGroup = [cell viewWithTag:100];
        if (photoGroup.hasGif)
        {
            //[self shouldLightCellWithShouldLightIndex:self.dataArray.count-1];
            lastOrCurrentPlayIndex = self.tableDataArray.count-1;
            return lastOrCurrentPlayIndex;
        }
    }
    
    NSArray *cellsArray = [self.tableView visibleCells];
    
    NSArray *newArray = nil;
    if (!isScrollDownward)
    {
        newArray = [cellsArray reverseObjectEnumerator].allObjects;
    }
    else
    {
        newArray = cellsArray;
    }
    
    [newArray enumerateObjectsUsingBlock:^(UITableViewCell *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        //NSLog(@"%ld",(long)cell.row);
        
        DJPhotoGridView *photoGroup = [cell viewWithTag:100];
        if (photoGroup.hasGif)
        {
            CGRect rect = [photoGroup convertRect:photoGroup.bounds toView:self.view];
            CGFloat topSpacing = rect.origin.y;
            CGFloat bottomSpacing = self.view.frame.size.height-rect.origin.y-rect.size.height;
            if ((topSpacing >= -rect.size.height/3) && (bottomSpacing >= -rect.size.height/3))
            {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                if (indexPath)
                {
                    lastOrCurrentPlayIndex = indexPath.row;
                    *stop = YES;
                }
            }
        }
    }];
    //[self shouldLightCellWithShouldLightIndex:self.lastOrCurrentLightIndex];
    
    //NSLog(@"lastOrCurrentPlayIndex: %@", @(lastOrCurrentPlayIndex));
    
    return lastOrCurrentPlayIndex;
}

- (void)pauseCellWithIndex:(NSInteger)index
{
    if (index >= 0 && index < self.tableDataArray.count)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        DJPhotoGridView *photoGroup = [cell viewWithTag:100];
        [photoGroup gifPause];
    }
}

- (void)playCellWithIndex:(NSInteger)index
{
    if (index >= 0 && index < self.tableDataArray.count)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        DJPhotoGridView *photoGroup = [cell viewWithTag:100];
        [photoGroup gifPlay];
    }
}


@end
