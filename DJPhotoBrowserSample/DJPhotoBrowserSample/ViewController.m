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
@property (nonatomic, strong) NSArray *srcBigStringArray;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *allDataArray;

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
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;

    self.title = @"PhotoBrowser";
    
    // 如果想要新版本SDWebImage支持gif动画显示，需要加载GIFCoder
    [[SDWebImageCodersManager sharedInstance] addCoder:[SDWebImageGIFCoder sharedCoder]];

//    self.srcStringArray = @[
//                        @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
//                        @"http://ww2.sinaimg.cn/thumbnail/642beb18gw1ep3629gfm0g206o050b2a.gif",
//                        @"http://ww4.sinaimg.cn/thumbnail/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg",
//                        @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",
//                        @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",
//                        @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
//                        @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",
//                        @"http://ww2.sinaimg.cn/thumbnail/677febf5gw1erma104rhyj20k03dz16y.jpg",
//                        @"http://ww4.sinaimg.cn/thumbnail/677febf5gw1erma1g5xd0j20k0esa7wj.jpg"
//                        ];
    
    self.srcBigStringArray = @[
                               @"http://wx4.sinaimg.cn/mw690/aed2de97ly1fq8p8qdfs1j21vo2io4qp.jpg",
                               @"http://wx3.sinaimg.cn/mw690/aed2de97ly1fq8p8sqs9dj21w01w14qq.jpg",
                               @"http://wx1.sinaimg.cn/mw690/aed2de97ly1fq8p8r7tvgj21vm2io7wh.jpg",
                               @"http://wx2.sinaimg.cn/mw690/aed2de97ly1fq8p8pbg9wj21w01w0qv5.jpg",
                               @"http://wx4.sinaimg.cn/mw690/aed2de97ly1fq8p8xnqppj21w01w01ky.jpg",
                               @"http://wx2.sinaimg.cn/mw690/aed2de97ly1fq8p8u368aj21w01w0u0x.jpg",
                               @"http://wx4.sinaimg.cn/mw690/aed2de97ly1fq8p8zb0o7j21w01w1u0x.jpg",
                               @"http://wx4.sinaimg.cn/mw690/aed2de97ly1fq8p9108jbj21w01w0x6p.jpg",
                               @"http://wx4.sinaimg.cn/mw690/aed2de97ly1fq8p8vyh0gj21w01w17wi.jpg",
                               @"http://wx1.sinaimg.cn/mw690/005vp4nfgy1fix8ndii2cg308w06oqu1.gif",
                               @"http://wx4.sinaimg.cn/mw690/005vp4nfgy1fix8nfcy57g30bk06f1kx.gif",
                               @"http://wx4.sinaimg.cn/mw690/005vp4nfgy1fix8nidw05g306o08wx6p.gif",
                               @"http://wx1.sinaimg.cn/mw690/005vp4nfgy1fix8njllccg309q079tx7.gif",
                               @"http://wx4.sinaimg.cn/mw690/005vp4nfgy1fix8nmdrjtg306o048npd.gif",
                               @"http://wx3.sinaimg.cn/mw690/0068kg5hgy1fq6t0ov7seg308c08c1l1.gif",
                               @"http://wx1.sinaimg.cn/mw690/0068kg5hgy1fq6t0kh9idg30go09chdw.gif",
                               @"http://wx2.sinaimg.cn/mw690/0068kg5hgy1fq6t0r9c2dg308c08c1kz.gif",
                               @"http://wx1.sinaimg.cn/mw690/0068kg5hgy1fq6t0whg3yg30ak0cq1l2.gif",
                               @"http://wx1.sinaimg.cn/mw690/0068kg5hgy1fq6t11nfxeg30as0ec7wm.gif",
                               @"http://wx2.sinaimg.cn/mw690/0068kg5hgy1fq6t162e0hg30a00hs1l1.gif",
                               @"http://wx4.sinaimg.cn/mw690/0068kg5hgy1fq6t17mzvng30eh0b44qq.gif",
                               @"http://wx3.sinaimg.cn/mw690/0068kg5hgy1fq6t18vnw4g30ah09du0x.gif",
                               @"http://wx4.sinaimg.cn/mw690/0068kg5hgy1fq6t1ax8n6g30ah0dyqv6.gif"
                               ];

    self.srcStringArray = @[
                            @"http://wx4.sinaimg.cn/thumb150/aed2de97ly1fq8p8qdfs1j21vo2io4qp.jpg",
                            @"http://wx3.sinaimg.cn/thumb150/aed2de97ly1fq8p8sqs9dj21w01w14qq.jpg",
                            @"http://wx1.sinaimg.cn/thumb150/aed2de97ly1fq8p8r7tvgj21vm2io7wh.jpg",
                            @"http://wx2.sinaimg.cn/thumb150/aed2de97ly1fq8p8pbg9wj21w01w0qv5.jpg",
                            @"http://wx4.sinaimg.cn/thumb150/aed2de97ly1fq8p8xnqppj21w01w01ky.jpg",
                            @"http://wx2.sinaimg.cn/thumb150/aed2de97ly1fq8p8u368aj21w01w0u0x.jpg",
                            @"http://wx4.sinaimg.cn/thumb150/aed2de97ly1fq8p8zb0o7j21w01w1u0x.jpg",
                            @"http://wx4.sinaimg.cn/thumb150/aed2de97ly1fq8p9108jbj21w01w0x6p.jpg",
                            @"http://wx4.sinaimg.cn/thumb150/aed2de97ly1fq8p8vyh0gj21w01w17wi.jpg",
                            @"http://wx1.sinaimg.cn/thumb150/005vp4nfgy1fix8ndii2cg308w06oqu1.gif",
                            @"http://wx4.sinaimg.cn/thumb150/005vp4nfgy1fix8nfcy57g30bk06f1kx.gif",
                            @"http://wx4.sinaimg.cn/thumb150/005vp4nfgy1fix8nidw05g306o08wx6p.gif",
                            @"http://wx1.sinaimg.cn/thumb150/005vp4nfgy1fix8njllccg309q079tx7.gif",
                            @"http://wx4.sinaimg.cn/thumb150/005vp4nfgy1fix8nmdrjtg306o048npd.gif",
                            @"http://wx3.sinaimg.cn/thumb150/0068kg5hgy1fq6t0ov7seg308c08c1l1.gif",
                            @"http://wx1.sinaimg.cn/thumb150/0068kg5hgy1fq6t0kh9idg30go09chdw.gif",
                            @"http://wx2.sinaimg.cn/thumb150/0068kg5hgy1fq6t0r9c2dg308c08c1kz.gif",
                            @"http://wx1.sinaimg.cn/thumb150/0068kg5hgy1fq6t0whg3yg30ak0cq1l2.gif",
                            @"http://wx1.sinaimg.cn/thumb150/0068kg5hgy1fq6t11nfxeg30as0ec7wm.gif",
                            @"http://wx2.sinaimg.cn/thumb150/0068kg5hgy1fq6t162e0hg30a00hs1l1.gif",
                            @"http://wx4.sinaimg.cn/thumb150/0068kg5hgy1fq6t17mzvng30eh0b44qq.gif",
                            @"http://wx3.sinaimg.cn/thumb150/0068kg5hgy1fq6t18vnw4g30ah09du0x.gif",
                            @"http://wx4.sinaimg.cn/thumb150/0068kg5hgy1fq6t1ax8n6g30ah0dyqv6.gif"
                           ];
    
    self.lastScrollViewContentOffsetY = 0.0f;
    
    self.tableDataArray = [NSMutableArray arrayWithCapacity:0];
    self.cellHeightArray = [NSMutableArray arrayWithCapacity:0];
    self.allDataArray = [NSMutableArray arrayWithCapacity:0];
    
    [self.srcBigStringArray enumerateObjectsUsingBlock:^(NSString *src, NSUInteger idx, BOOL *stop) {
        DJPhotoItem *item = [[DJPhotoItem alloc] init];
        item.highQualityImage = src;
        item.thumbnailImage = self.srcStringArray[idx];
        item.width = 200.0f;
        item.height = 280.0f;
        if ([item.highQualityImage rangeOfString:@".gif"].length>0)
        {
            item.isGif = YES;
        }
        [self.allDataArray addObject:item];
    }];
    
    [self makeTableDataArray];
    
//    for (NSUInteger i=0; i<20; i++)
//    {
//        NSMutableArray *temp = [NSMutableArray array];
//        [_srcStringArray enumerateObjectsUsingBlock:^(NSString *src, NSUInteger idx, BOOL *stop) {
//            DJPhotoItem *item = [[DJPhotoItem alloc] init];
//            item.thumbnailImage = src;
//            item.width = 200;
//            item.height = 280;
//            [temp addObject:item];
//            NSUInteger index = i%9;
//            if (idx == 1)
//            {
//                item.isGif = YES;
//            }
//            if (idx == index)
//            {
//                *stop = YES;
//            }
//        }];
//
//        [self.tableDataArray addObject:temp];
//        CGSize size = [DJPhotoGridView photoGridViewSizeWith:temp];
//        [self.cellHeightArray addObject:@(size.height)];
//    }
    
    self.lastOrCurrentPlayIndex = -1;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)makeTableDataArray
{
    @autoreleasepool {
        // 随机cell个数
        NSUInteger cellCount = (NSUInteger)(arc4random() % 20)+1;
        
        for (NSUInteger cells=0; cells<cellCount; cells++)
        {
            // 随机图片个数
            NSUInteger imageCount = (NSUInteger)(arc4random() % 9)+1;

            NSMutableArray *temp = [NSMutableArray array];
            NSMutableArray *temp1 = [NSMutableArray array];
            for (NSUInteger i=0; i<imageCount*2; i++)
            {
                NSUInteger whichItem = (NSUInteger)(arc4random() % self.allDataArray.count);
                DJPhotoItem *item = self.allDataArray[whichItem];

                NSUInteger index = [temp1 indexOfObject:item];
                if (index == NSNotFound)
                {
                    DJPhotoItem *itemcopy = [[DJPhotoItem alloc] init];
                    itemcopy.highQualityImage = item.highQualityImage;
                    itemcopy.thumbnailImage = item.thumbnailImage;
                    itemcopy.width = item.width;
                    itemcopy.height = item.height;
                    itemcopy.isGif = item.isGif;
                    
                    [temp addObject:itemcopy];
                    [temp1 addObject:item];
                    if (temp.count == imageCount)
                    {
                        break;
                    }
                }
            }
            
            [self.tableDataArray addObject:temp];
            CGSize size = [DJPhotoGridView photoGridViewSizeWith:temp];
            [self.cellHeightArray addObject:@(size.height)];
        }
    }
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.lastOrCurrentPlayIndex != -1)
    {
        [self playCellWithIndex:self.lastOrCurrentPlayIndex];
    }
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
    
    // 判断滚动方向
    if (scrollView.contentOffset.y>self.lastScrollViewContentOffsetY)
    {
        self.isScrollDownward = YES;
    }
    else
    {
        self.isScrollDownward = NO;
    }
    self.lastScrollViewContentOffsetY = scrollView.contentOffset.y;
    
    // 找出适合cell播放
    NSInteger lastOrCurrentPlayIndex = [self findCellWithScrollDirection:self.isScrollDownward];
    if (lastOrCurrentPlayIndex != self.lastOrCurrentPlayIndex)
    {
        // 停止当前播放的
        [self pauseCellWithIndex:self.lastOrCurrentPlayIndex];

        self.lastOrCurrentPlayIndex = lastOrCurrentPlayIndex;
        NSLog(@"lastOrCurrentPlayIndex: %@", @(lastOrCurrentPlayIndex));
        
        [self playCellWithIndex:self.lastOrCurrentPlayIndex];
    }
}

- (NSInteger)findCellWithScrollDirection:(BOOL)isScrollDownward
{
    __block NSInteger lastOrCurrentPlayIndex = self.lastOrCurrentPlayIndex;
    
    if (self.tableView.contentOffset.y <= 0)
    {
        // 顶部
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        DJPhotoGridView *photoGroup = [cell viewWithTag:100];
        if (photoGroup.hasGif)
        {
            lastOrCurrentPlayIndex = 0;
            return lastOrCurrentPlayIndex;
        }
    }
    else if (self.tableView.contentOffset.y+self.tableView.frame.size.height >= self.tableView.contentSize.height)
    {
        // 底部
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.tableDataArray.count-1 inSection:0]];
        DJPhotoGridView *photoGroup = [cell viewWithTag:100];
        if (photoGroup.hasGif)
        {
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
        DJPhotoGridView *photoGroup = [cell viewWithTag:100];
        if (photoGroup.hasGif)
        {
            CGRect rect = [photoGroup convertRect:photoGroup.bounds toView:self.view];

            // 顶部间隔
            CGFloat topSpacing = rect.origin.y;
            // 底部间隔
            CGFloat bottomSpacing = self.view.frame.size.height-rect.origin.y-rect.size.height;

            BOOL find = NO;
            if (isScrollDownward)
            {
                if ((topSpacing >= -rect.size.height/5) && (bottomSpacing >= -rect.size.height/3))
                {
                    find = YES;
                }
            }
            else
            {
                if ((topSpacing >= -rect.size.height/3) && (bottomSpacing >= -rect.size.height/5))
                {
                    find = YES;
                }
            }

            if (find)
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



