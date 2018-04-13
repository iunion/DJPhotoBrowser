//
//  DJPhotoGridView.m
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import "DJPhotoGridView.h"
#import "DJPhotoItem.h"
#import "DJPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"

#define DJPhotoGroupImageMaxCount   9

#define DJPhotoGroupImageMargin     8.0f
#define DJPhotoGroupImageMaxWidth   280.0f
#define DJPhotoGroupImage2or4Width  100.0f
#define DJPhotoGroupImageWidth      80.0f
#define DJPhotoGroupImageHeight     80.0f

@interface DJPhotoGridView ()
<
    DJPhotoBrowserDelegate,
    DJPhotoBrowserDataSource
>

@property (nonatomic, weak) DJPhotoBrowser *photoBrowser;

@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *imageGifLabelArray;
@property (nonatomic, strong) NSMutableArray *imageBtnArray;

@property (nonatomic, strong) NSMutableArray *previewGifItemArray;
@property (nonatomic, assign) BOOL isPlayGif;
@property (nonatomic, assign) NSInteger playingGifIndex;

@property (nonatomic, strong) NSTimer *playGifTimer;

@end

@implementation DJPhotoGridView

+ (CGSize)photoGridViewSizeWith:(NSArray<DJPhotoItem *> *)photoItemArray
{
    CGSize size = CGSizeZero;
    
    CGFloat width = DJPhotoGroupImageWidth;
    CGFloat height = DJPhotoGroupImageHeight;
    
    NSUInteger imageCount = photoItemArray.count;
    NSUInteger perRowImageCount = 3;
    if (imageCount == 2 || imageCount == 4)
    {
        perRowImageCount = 2;
        width = DJPhotoGroupImage2or4Width;
        height = DJPhotoGroupImage2or4Width;
    }
    NSUInteger totalRowCount = ceil((CGFloat)imageCount/(CGFloat)perRowImageCount);
    
    if (imageCount == 1)
    {
        DJPhotoItem *item = photoItemArray[0];
        
        CGFloat w = item.width;
        CGFloat h = item.height;
        if (w <= 0)
        {
            w = DJPhotoGroupImageWidth;
        }
        if (h <= 0)
        {
            h = DJPhotoGroupImageHeight;
        }
        
        float scalex = DJPhotoGroupImageMaxWidth / w;
        float scaley = DJPhotoGroupImageMaxWidth / h;
        float scale = MAX(scalex, scaley);
        if (scale > 1.0f)
        {
            scale = 1.0f;
        }
        
        size = CGSizeMake(w*scale, h*scale);
    }
    else
    {
        CGFloat swidth = perRowImageCount * (width + DJPhotoGroupImageMargin) - DJPhotoGroupImageMargin;
        CGFloat sheight = totalRowCount * (height + DJPhotoGroupImageMargin) - DJPhotoGroupImageMargin;
        
        size = CGSizeMake(swidth, sheight);
    }
    
    return size;
}

- (instancetype)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect]))
    {
        [self commonInit];
    }
    return self;
}

// Storyboard用
- (instancetype)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.imageViewArray = [NSMutableArray arrayWithCapacity:0];
    self.imageGifLabelArray = [NSMutableArray arrayWithCapacity:0];
    self.imageBtnArray = [NSMutableArray arrayWithCapacity:0];

    self.previewGifItemArray = [NSMutableArray arrayWithCapacity:0];


    // 清除图片缓存，便于测试
    [[SDWebImageManager sharedManager].imageCache clearDiskOnCompletion:nil];
}

//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//
//    [_phaseTimer invalidate];
//    _phaseTimer = nil;
//
//    if (newSuperview)
//    {
//        _phaseTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_phaseTimerTick:) userInfo:nil repeats:YES];
//    }
//}

- (void)setPhotoItemArray:(NSArray<DJPhotoItem *> *)photoItemArray
{
    [self.imageViewArray removeAllObjects];
    [self.imageGifLabelArray removeAllObjects];
    [self.imageBtnArray removeAllObjects];
    
    [self.previewGifItemArray removeAllObjects];
    self.playingGifIndex = -1;
    
    while (self.subviews.count > 0)
    {
        UIView *child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
    
    _photoItemArray = photoItemArray;
    [photoItemArray enumerateObjectsUsingBlock:^(DJPhotoItem *obj, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        // 让图片不变形，以适应按钮宽高，按钮中图片部分内容可能看不到
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.tag = idx;
        imageView.userInteractionEnabled = YES;
        [self.imageViewArray addObject:imageView];

        __weak DJPhotoItem *item = photoItemArray[idx];
        __weak typeof(self) weakSelf = self;
        [imageView sd_setImageWithURL:[NSURL URLWithString:obj.thumbnailImage
                                      ] placeholderImage:[UIImage imageNamed:@"whiteplaceholder"] options:SDWebImageLowPriority|SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image)
            {
                if (item.isGif)
                {
                    [[SDWebImageManager sharedManager] loadImageWithURL:[self photoBrowser:nil highQualityImageURLForIndex:idx] options:SDWebImageLowPriority|SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        if (image)
                        {
                            item.isDown = YES;
                            item.gifDuration = image.duration;
                        }
                    }];
                    
                    if (item)
                    {
                        item.index = idx;
                        [weakSelf.previewGifItemArray addObject:item];
                    }
                }
            }
        }];
        
        UIControl *btn = [[UIControl alloc] init];
        btn.exclusiveTouch = YES;
        btn.tag = idx;
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:btn];
        [self.imageBtnArray addObject:btn];
        
        UILabel *gifLabel = [[UILabel alloc] init];
        gifLabel.textAlignment = NSTextAlignmentCenter;
        gifLabel.textColor = [UIColor whiteColor];
        gifLabel.text = @"动图";
        gifLabel.font = [UIFont boldSystemFontOfSize:10.0f];
        gifLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.8f alpha:0.8f];
        gifLabel.bounds = CGRectMake(0, 0, 30, 16);
        gifLabel.layer.cornerRadius = 3.0f;
        gifLabel.clipsToBounds = YES;
        [btn addSubview:gifLabel];
        [self.imageGifLabelArray addObject:gifLabel];
        gifLabel.hidden = !item.isGif;

        [self addSubview:imageView];
    }];
    
    //[self setNeedsLayout];
}

- (BOOL)hasGif
{
    return (self.previewGifItemArray.count > 0);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = DJPhotoGroupImageWidth;
    CGFloat height = DJPhotoGroupImageHeight;
    
    NSUInteger imageCount = self.photoItemArray.count;
    NSUInteger perRowImageCount = 3;
    if (imageCount == 2 || imageCount == 4)
    {
        perRowImageCount = 2;
        width = DJPhotoGroupImage2or4Width;
        height = DJPhotoGroupImage2or4Width;
    }
    NSUInteger totalRowCount = ceil((CGFloat)imageCount/(CGFloat)perRowImageCount);
    
    if (imageCount == 1)
    {
        DJPhotoItem *item = self.photoItemArray[0];
        UIImageView *imageView = self.imageViewArray[0];
        
        CGFloat w = item.width;
        CGFloat h = item.height;
        if (w <= 0)
        {
            w = DJPhotoGroupImageWidth;
        }
        if (h <= 0)
        {
            h = DJPhotoGroupImageHeight;
        }
        
        float scalex = DJPhotoGroupImageMaxWidth / w;
        float scaley = DJPhotoGroupImageMaxWidth / h;
        float scale = MAX(scalex, scaley);
        if (scale > 1.0f)
        {
            scale = 1.0f;
        }
        imageView.frame = CGRectMake(0, 0, item.width*scale, item.height*scale);

        UIControl *btn = imageView.subviews[0];
        btn.frame = imageView.bounds;

        UILabel *label = btn.subviews[0];
        label.frame = CGRectMake(btn.frame.size.width-30, btn.frame.size.height-16, 30, 16);

        CGRect frame = self.frame;
        frame.size = CGSizeMake(w*scale, h*scale);
        self.frame = frame;
    }
    else
    {
        [self.imageViewArray enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
            NSUInteger rowIndex = idx / perRowImageCount;
            NSUInteger columnIndex = idx % perRowImageCount;
            CGFloat x = columnIndex * (width + DJPhotoGroupImageMargin);
            CGFloat y = rowIndex * (height + DJPhotoGroupImageMargin);
            imageView.frame = CGRectMake(x, y, width, height);
            UIControl *btn = imageView.subviews[0];
            btn.frame = imageView.bounds;
            
            UILabel *label = btn.subviews[0];
            label.frame = CGRectMake(btn.frame.size.width-30, btn.frame.size.height-16, 30, 16);
        }];
        
        CGFloat swidth = perRowImageCount * (width + DJPhotoGroupImageMargin) - DJPhotoGroupImageMargin;
        CGFloat sheight = totalRowCount * (height + DJPhotoGroupImageMargin) - DJPhotoGroupImageMargin;

        CGRect frame = self.frame;
        frame.size = CGSizeMake(swidth, sheight);
        self.frame = frame;
    }
}

- (void)buttonClick:(UIControl *)button
{
    // 启动图片浏览器
    DJPhotoBrowser *browser = [[DJPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self; // 原图的父控件
    browser.dataSource = self;
    browser.delegate = self;
    browser.infiniteScrollView = YES;
    [browser showWithImageCount:self.photoItemArray.count imageIndex:button.tag];
    self.photoBrowser = browser;
}

- (void)gifPlay
{
    if (!self.hasGif)
    {
        return;
    }
    
    if (self.playGifTimer)
    {
        [self.playGifTimer invalidate];
        self.playGifTimer = nil;
    }
    
    [self gifPause];
    
    self.playingGifIndex = (self.playingGifIndex+1) % self.previewGifItemArray.count;
    DJPhotoItem *item = self.previewGifItemArray[self.playingGifIndex];

    self.isPlayGif = YES;
    UIImageView *imageView = self.imageViewArray[item.index];
    [imageView sd_setImageWithURL:[self photoBrowser:nil highQualityImageURLForIndex:item.index] placeholderImage:[UIImage imageNamed:@"whiteplaceholder"] options:SDWebImageLowPriority|SDWebImageRetryFailed];
    UILabel *label = self.imageGifLabelArray[item.index];
    label.hidden = YES;

    NSTimer *playGifTimer = [NSTimer timerWithTimeInterval:item.gifDuration target:self selector:@selector(gifPlay) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:playGifTimer forMode:NSRunLoopCommonModes];
    self.playGifTimer = playGifTimer;
}

- (void)gifPause
{
    if (!self.isPlayGif)
    {
        return;
    }

    self.isPlayGif = NO;
    if (self.playGifTimer)
    {
        [self.playGifTimer invalidate];
        self.playGifTimer = nil;
    }

    if (self.playingGifIndex >= self.previewGifItemArray.count)
    {
        return;
    }
    
    DJPhotoItem *item = self.previewGifItemArray[self.playingGifIndex];
    UIImageView *imageView = self.imageViewArray[item.index];
    [imageView sd_setImageWithURL:[NSURL URLWithString:item.thumbnailImage] placeholderImage:[UIImage imageNamed:@"whiteplaceholder"] options:SDWebImageLowPriority|SDWebImageRetryFailed];
    UILabel *label = self.imageGifLabelArray[item.index];
    label.hidden = NO;
}


#pragma mark -
#pragma mark DJPhotoBrowserDataSource

// 预览图片
- (UIImage *)photoBrowser:(DJPhotoBrowser *)browser placeholderImageForIndex:(NSUInteger)index
{
    UIImageView *imageView = self.subviews[index];
    return imageView.image;
}

// 原图片控件映射到PhotoBrowser的坐标
- (CGRect)photoBrowser:(DJPhotoBrowser *)browser containerViewRectAtIndex:(NSUInteger)index
{
    UIView *view = self.subviews[index];
    CGRect rect = [self convertRect:view.frame toView:browser];
    return rect;
}

// 高清图片URL
- (NSURL *)photoBrowser:(DJPhotoBrowser *)browser highQualityImageURLForIndex:(NSUInteger)index
{
    DJPhotoItem *item = self.photoItemArray[index];
    NSString *urlStr = item.highQualityImage;
    if (!urlStr)
    {
        urlStr = [[self.photoItemArray[index] thumbnailImage] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    }
    return [NSURL URLWithString:urlStr];
}


#pragma mark -
#pragma mark DJPhotoBrowserDelegate

// 滚动
- (void)photoBrowser:(DJPhotoBrowser *)browser didScrollToIndex:(NSUInteger)index
{
    NSLog(@"didScrollToIndex: %@", @(index));
}

// 删除图片
- (void)photoBrowser:(DJPhotoBrowser *)browser deleteImageAtIndex:(NSUInteger)index
{
    
}


@end
