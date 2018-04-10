//
//  DJPhotoBrowserView.m
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import "DJPhotoBrowserView.h"
#import "DJWaitingView.h"
#import "UIImageView+WebCache.h"

@interface DJPhotoBrowserView ()
<
    UIScrollViewDelegate
>
{
    BOOL hasLoadedImage;
}

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIImageView *imageview;

@property (nonatomic,strong) DJWaitingView *waitingView;
@property (nonatomic, strong) UIButton *reloadButton;

@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) UIImage *placeHolderImage;

@property (nonatomic,strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic,strong) UITapGestureRecognizer *singleTap;

@end

@implementation DJPhotoBrowserView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupScrollview];
        [self setupImageview];
        [self setupReloadButton];
        [self setupWaitingView];

        [self setupTapGestureRecognizer];
    }
    
    return self;
}
    
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.scrollview.frame = self.bounds;
    
    self.reloadButton.center = self.scrollview.center;
    self.waitingView.center = self.scrollview.center;
}

- (void)setupScrollview
{
    UIScrollView *scrollview = [[UIScrollView alloc] init];
    scrollview.backgroundColor = [UIColor clearColor];
    scrollview.frame = self.bounds;
    scrollview.delegate = self;
    scrollview.clipsToBounds = YES;
    
    [self addSubview:scrollview];
    self.scrollview = scrollview;
}

- (void)setupImageview
{
    UIImageView *imageview = [[UIImageView alloc] init];
    imageview.frame = self.bounds;
    imageview.userInteractionEnabled = YES;
    
    [self.scrollview addSubview:imageview];
    self.imageview = imageview;
}

- (void)setupReloadButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 2;
    button.clipsToBounds = YES;
    button.bounds = CGRectMake(0, 0, 200.0f, 40.0f);
    button.center = self.scrollview.center;
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    button.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    [button setTitle:@"原图加载失败，点击重新加载" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(reloadImage) forControlEvents:UIControlEventTouchUpInside];
    button.hidden = YES;
    
    [self addSubview:button];
    self.reloadButton = button;
}

- (void)setupWaitingView
{
    DJWaitingView *waitingView = [[DJWaitingView alloc] init];
    waitingView.center = self.scrollview.center;
    
    [self addSubview:waitingView];
    self.waitingView = waitingView;
}

- (void)setupTapGestureRecognizer
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delaysTouchesBegan = YES;
    // 只能有一个手势存在
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self addGestureRecognizer:doubleTap];
    [self addGestureRecognizer:singleTap];
    
    self.doubleTap = doubleTap;
    self.singleTap = singleTap;
    
    self.exclusiveTouch = YES;
}

- (CGFloat)imageScale
{
    return self.scrollview.zoomScale;
}

- (void)setImageScale:(CGFloat)imageScale
{
    self.scrollview.zoomScale = imageScale;
}

- (void)setProgress:(CGFloat)progress
{
    if (progress > 1.0f)
    {
        progress = 1.0f;
    }
    _progress = progress;
    
    self.waitingView.progress = progress;
}


#pragma mark -
#pragma mark actions

- (void)reloadImage
{
    [self setImageWithURL:self.imageUrl placeholderImage:self.placeHolderImage];
}

// 单击
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.singleTapBlock)
        {
            self.singleTapBlock(recognizer);
        }
    }
}

// 双击
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // 图片加载完之后才能响应双击放大
        if (self.progress != 1.0f)
        {
            return;
        }
        
        CGPoint touchPoint = [recognizer locationInView:self];
        if (self.scrollview.zoomScale <= 1.0f)
        {
            // 需要放大的图片的X点
            CGFloat scaleX = touchPoint.x + self.scrollview.contentOffset.x;
            // 需要放大的图片的Y点
            CGFloat sacleY = touchPoint.y + self.scrollview.contentOffset.y;
            [self.scrollview zoomToRect:CGRectMake(scaleX, sacleY, 10.0f, 10.0f) animated:YES];
        }
        else
        {
            // 还原
            [self.scrollview setZoomScale:1.0 animated:YES];
        }
    }
}


#pragma mark -
#pragma mark layoutSubviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollview.frame = self.bounds;
    
    [self adjustFrame];
}

- (void)adjustFrame
{
    CGRect frame = self.scrollview.frame;
    if (self.imageview.image)
    {
        // 获得图片的size
        CGSize imageSize = self.imageview.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        // 图片宽度始终==屏幕宽度(新浪微博就是这种效果)
        if (kIsFullWidthForLandScape)
        {
            CGFloat ratio = frame.size.width/imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height*ratio;
            imageFrame.size.width = frame.size.width;
        }
        else
        {
            if (frame.size.width <= frame.size.height)
            {
                // 竖屏时候
                CGFloat ratio = frame.size.width/imageFrame.size.width;
                imageFrame.size.height = imageFrame.size.height*ratio;
                imageFrame.size.width = frame.size.width;
            }
            else
            {
                // 横屏的时候
                CGFloat ratio = frame.size.height/imageFrame.size.height;
                imageFrame.size.width = imageFrame.size.width*ratio;
                imageFrame.size.height = frame.size.height;
            }
        }
        
        self.imageview.frame = imageFrame;
//        NSLog(@"%@",NSStringFromCGRect(_scrollview.frame));
//        NSLog(@"imageview.frame: %@",NSStringFromCGRect(self.imageview.frame));
        self.scrollview.contentSize = self.imageview.frame.size;
        self.imageview.center = [self centerOfScrollViewContent:self.scrollview];
        
        // 根据图片大小找到最大缩放等级，保证最大缩放时候，不会有黑边
        CGFloat maxScale = frame.size.height/imageFrame.size.height;
        maxScale = frame.size.width/imageFrame.size.width>maxScale ? frame.size.width/imageFrame.size.width : maxScale;
        // 超过了设置的最大的才算数
        maxScale = maxScale>kMaxZoomScale ? maxScale : kMaxZoomScale;
        
        // 初始化
        self.scrollview.minimumZoomScale = kMinZoomScale;
        self.scrollview.maximumZoomScale = maxScale;
        self.scrollview.zoomScale = 1.0f;
    }
    else
    {
        frame.origin = CGPointZero;
        self.imageview.frame = frame;
        // 重置内容大小
        self.scrollview.contentSize = self.imageview.frame.size;
    }
    
    self.scrollview.contentOffset = CGPointZero;
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    
    return actualCenter;
}

- (void)setImageWithURLString:(nonnull NSString *)urlString placeholderImage:(nullable UIImage *)placeholder
{
    NSURL *url = [NSURL URLWithString:urlString];
    if (url)
    {
        [self setImageWithURL:url placeholderImage:placeholder];
    }
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    self.reloadButton.hidden = YES;
    self.waitingView.hidden = NO;
    
    self.imageUrl = url;
    self.placeHolderImage = placeholder;
    
    // 加载图片
    __weak __typeof(self)weakSelf = self;
    [self.imageview sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageLowPriority|SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
        if (expectedSize>0)
        {
            weakSelf.progress = (CGFloat)receivedSize / expectedSize;
        }
        else
        {
            weakSelf.progress = 0.0f;
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakSelf setNeedsLayout];
        weakSelf.waitingView.hidden = YES;
        
        if (error)
        {
            // 图片加载失败的处理，此处可以自定义各种操作（...）
            weakSelf.reloadButton.hidden = NO;
            return;
        }
        
        weakSelf.progress = 1.0f;
    }];
    
    [self setNeedsLayout];
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // 这里是缩放进行时调整
    self.imageview.center = [self centerOfScrollViewContent:scrollView];
}

@end
