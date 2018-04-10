//
//  DJPhotoBrowser.m
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import "DJPhotoBrowser.h"
#import "DJPhotoBrowserView.h"

@interface DJPhotoBrowser ()
<
    UIScrollViewDelegate
>
{
    UIWindowLevel bakWindowLevel;
    BOOL hasShowedFistView;
    
    UIActivityIndicatorView *saveIndicatorView;
}

@property (nonatomic, assign) NSUInteger imageCount;
@property (nonatomic, assign) NSUInteger currentImageIndex;

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation DJPhotoBrowser

- (void)dealloc
{
    NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = DJPhotoBrowserBackgrounColor;
    }
    return self;
}

- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex
{
    if (currentImageIndex >= self.imageCount)
    {
        if (self.imageCount != 0)
        {
            currentImageIndex = self.imageCount-1;
        }
        else
        {
            currentImageIndex = 0;
        }
    }
    
    _currentImageIndex = currentImageIndex;
    
    if (self.imageCount > 1)
    {
        self.indexLabel.hidden = NO;
        self.indexLabel.text = [NSString stringWithFormat:@"%@/%@", @(currentImageIndex+1), @(self.imageCount)];
        
        if ([self.delegate respondsToSelector:@selector(photoBrowser:didScrollToIndex:)])
        {
            if (self.scrollView)
            {
                NSUInteger index = fabs(self.scrollView.contentOffset.x) / self.scrollView.bounds.size.width;
                if (currentImageIndex == index)
                {
                    [self.delegate photoBrowser:self didScrollToIndex:currentImageIndex];
                }
            }
        }
    }
    else
    {
        self.indexLabel.hidden = YES;
    }
}

// 被addSubView时调用
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (self.superview)
    {
        [self setupScrollView];
        [self setupToolbars];
        
        [self setupDeviceOrientationChangeWithObserver];
    }
}

- (void)setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    for (NSInteger i = 0; i < self.imageCount; i++)
    {
        DJPhotoBrowserView *view = [[DJPhotoBrowserView alloc] init];
        view.imageview.tag = i;
        
        // 设置单击事件
        __weak __typeof(self)weakSelf = self;
        view.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
            [weakSelf orientationToHidePhotoBrowser:recognizer];
        };
        
        [self.scrollView addSubview:view];
    }
    
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
}

- (void)setupToolbars
{
    // 1. 序标
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    indexLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    indexLabel.center = CGPointMake(UI_SCREEN_WIDTH * 0.5, 30);
    indexLabel.layer.cornerRadius = 15;
    indexLabel.clipsToBounds = YES;
    self.indexLabel = indexLabel;
    [self addSubview:indexLabel];
    
    if (self.imageCount > 1)
    {
        indexLabel.text = [NSString stringWithFormat:@"%@/%@", @(self.currentImageIndex+1), @(self.imageCount)];
    }
    else
    {
        indexLabel.hidden = YES;
    }
    
    // 2.保存按钮
    UIButton *saveButton = [[UIButton alloc] init];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.layer.borderWidth = 0.1;
    saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    saveButton.layer.cornerRadius = 2;
    saveButton.clipsToBounds = YES;
    saveButton.exclusiveTouch = YES;
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton = saveButton;
    [self addSubview:saveButton];
}

- (void)setupDeviceOrientationChangeWithObserver
{
    [self onDeviceOrientationChange];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)])
    {
        return [self.dataSource photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)])
    {
        return [self.dataSource photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

#pragma mark -
#pragma mark actions

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSUInteger)index
{
    DJPhotoBrowserView *view = self.scrollView.subviews[index];
    if (view.progress)
    {
        return;
    }
    
    UIImage *placeholderImage = [self placeholderImageForIndex:index];
    
    if ([self highQualityImageURLForIndex:index])
    {
        [view setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:placeholderImage];
    }
    else
    {
        view.imageview.image = placeholderImage;
    }
}

#pragma mark 保存图像
- (void)saveImage
{
    DJPhotoBrowserView *currentView = self.scrollView.subviews[self.currentImageIndex];
    
    UIImageWriteToSavedPhotosAlbum(currentView.imageview.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    saveIndicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    if (saveIndicatorView.superview)
    {
        [saveIndicatorView removeFromSuperview];
        saveIndicatorView = nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.9f];
    label.layer.cornerRadius = 5.0f;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150.0f, 40.0f);
    label.center = self.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error)
    {
        label.text = @" 保存失败 ";
    }
    else
    {
        label.text = @" 保存成功 ";
    }
    
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0f];
}

- (void)onDeviceOrientationChange
{
    if (!DJPhotoBrowserShouldLandscape)
    {
        return;
    }
    
    //NSLog(@"onDeviceOrientationChange");
    
    DJPhotoBrowserView *currentView = self.scrollView.subviews[self.currentImageIndex];
    currentView.imageScale = 1.0f;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation))
    {
        [UIView animateWithDuration:DJPhotoBrowserOrientationChangeAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            //[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
            self.transform = (orientation == UIDeviceOrientationLandscapeRight) ? CGAffineTransformMakeRotation(M_PI*1.5) : CGAffineTransformMakeRotation(M_PI/2);
            self.bounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
            [self setNeedsLayout];
            //[self layoutIfNeeded];
        } completion:nil];
    }
    else if (orientation == UIDeviceOrientationPortrait)
    {
        [UIView animateWithDuration:DJPhotoBrowserOrientationChangeAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            //[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
            self.transform = (orientation == UIDeviceOrientationPortrait) ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
            self.bounds = screenBounds;
            [self setNeedsLayout];
            //[self layoutIfNeeded];
        } completion:nil];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width += DJPhotoBrowserImageViewMargin * 2;
    self.scrollView.bounds = rect;
    self.scrollView.center = CGPointMake(self.bounds.size.width *0.5, self.bounds.size.height *0.5);
    
    CGFloat y = 0;
    CGFloat width = self.scrollView.frame.size.width - DJPhotoBrowserImageViewMargin * 2;
    CGFloat height = self.scrollView.frame.size.height;
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(DJPhotoBrowserView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = DJPhotoBrowserImageViewMargin + idx * (DJPhotoBrowserImageViewMargin * 2 + width);
        obj.frame = CGRectMake(x, y, width, height);
    }];
    
    //self.scrollView.contentSize = CGSizeMake(self.scrollView.subviews.count * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(self.imageCount * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.currentImageIndex * self.scrollView.frame.size.width, 0);
    
    if (!hasShowedFistView)
    {
        [self showFirstImage];
    }
    
    self.indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    self.indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 30);
    self.saveButton.frame = CGRectMake(rect.size.width-75-DJPhotoBrowserImageViewMargin * 2, self.bounds.size.height - 50, 55, 30);
}

#pragma mark - scrollviewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSUInteger index = fabs(scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width;
    
    NSUInteger leftIndex = (index==0) ? 0 : index-1;
    NSUInteger rightIndex = (index+1>=self.imageCount) ? self.imageCount-1 : index+1;
    for (NSUInteger i = leftIndex; i < rightIndex; i++)
    {
        [self setupImageOfImageViewForIndex:i];
    }
}

// 拖拽时没有滑动动画，不会有此操作
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    NSLog(@"scrollViewDidEndDragging");
//
//    // 拖拽时没有滑动动画
//    if (!decelerate)
//    {
//        int autualIndex = scrollView.contentOffset.x  / scrollView.bounds.size.width;
//        // 设置当前下标
//        self.currentImageIndex = autualIndex;
//    }
//}

// scrollview结束滚动调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
    NSUInteger index = fabs(scrollView.contentOffset.x) / scrollView.bounds.size.width;
    
    // 设置当前下标
    self.currentImageIndex = index;
    
    // 将不是当前imageview的缩放全部还原
    NSUInteger leftIndex = (index==0) ? 0 : index-1;
    NSUInteger rightIndex = (index+1>=self.imageCount) ? self.imageCount-1 : index+1;
    if (leftIndex != index)
    {
        DJPhotoBrowserView *view = scrollView.subviews[leftIndex];
        view.imageScale = 1.0f;
    }
    if (rightIndex != index)
    {
        DJPhotoBrowserView *view = scrollView.subviews[rightIndex];
        view.imageScale = 1.0f;
    }
}

- (void)showFirstImage
{
    CGRect rect = CGRectZero;
    
    if ([self.dataSource respondsToSelector:@selector(photoBrowser:containerViewRectAtIndex:)])
    {
        rect = [self.dataSource photoBrowser:self containerViewRectAtIndex:self.currentImageIndex];
    }
    else if (self.sourceImagesContainerView)
    {
        UIView *sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
        rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
        //NSLog(@"%@", NSStringFromCGRect(rect));
    }
    
    if (CGRectIsEmpty(rect) || CGRectEqualToRect(rect, CGRectZero))
    {
        hasShowedFistView = YES;
        
        self.scrollView.hidden = NO;
        self.indexLabel.hidden = NO;
        self.saveButton.hidden = NO;
        
        return;
    }
    
    UIImage *placeholderImage = [self placeholderImageForIndex:self.currentImageIndex];
    UIImageView *tempView = [[UIImageView alloc] initWithFrame:rect];
    tempView.image = placeholderImage;
    [self addSubview:tempView];
    tempView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat placeImageSizeW = placeholderImage.size.width;
    CGFloat placeImageSizeH = placeholderImage.size.height;
    
    if (placeImageSizeW == 0)
    {
        hasShowedFistView = YES;
        
        self.scrollView.hidden = NO;
        self.indexLabel.hidden = NO;
        self.saveButton.hidden = NO;
        
        return;
    }

    CGRect targetTempRect = CGRectZero;
    CGFloat placeHolderH = (placeImageSizeH * UI_SCREEN_WIDTH)/placeImageSizeW;
    if (placeHolderH <= UI_SCREEN_HEIGHT)
    {
        targetTempRect = CGRectMake(0, (UI_SCREEN_HEIGHT - placeHolderH) * 0.5 , UI_SCREEN_WIDTH, placeHolderH);
    }
    else
    {
        // 图片高度>屏幕高度
        targetTempRect = CGRectMake(0, 0, UI_SCREEN_WIDTH, placeHolderH);
    }
    
    // 先隐藏scrollview
    self.scrollView.hidden = YES;
    self.indexLabel.hidden = YES;
    self.saveButton.hidden = YES;
    
    [UIView animateWithDuration:DJPhotoBrowserShowImageAnimationDuration animations:^{
        // 将点击的临时imageview动画放大到和目标imageview一样大
        tempView.frame = targetTempRect;
    } completion:^(BOOL finished) {
        // 动画完成后，删除临时imageview，让目标imageview显示
        if (tempView.superview)
        {
            [tempView removeFromSuperview];
        }
        
        self.scrollView.hidden = NO;
        self.indexLabel.hidden = NO;
        self.saveButton.hidden = NO;
        
        hasShowedFistView = YES;
    }];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didScrollToIndex:)])
    {
        [self.delegate photoBrowser:self didScrollToIndex:self.currentImageIndex];
    }
}

- (void)showWithImageCount:(NSUInteger)imageCount imageIndex:(NSUInteger)imageIndex
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window)
    {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    // 遮挡状态栏
    bakWindowLevel = window.windowLevel;
    window.windowLevel = UIWindowLevelStatusBar+10.0f;
    
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = DJPhotoBrowserBackgrounColor;
    contentView.center = window.center;
    contentView.bounds = window.bounds;
    
    self.center = CGPointMake(contentView.bounds.size.width * 0.5, contentView.bounds.size.height * 0.5);
    self.bounds = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height);
    
    self.imageCount = imageCount;
    self.currentImageIndex = imageIndex;
    
    [contentView addSubview:self];
    [window addSubview:contentView];
    self.contentView = contentView;
}

- (void)reloadWithImageCount:(NSUInteger)imageCount imageIndex:(NSUInteger)imageIndex
{
    if (!self.superview)
    {
        return;
    }
    
    if (self.scrollView.superview)
    {
        [self.scrollView removeFromSuperview];
        self.scrollView = nil;
    }
    
    self.imageCount = imageCount;
    self.currentImageIndex = imageIndex;
    
    [self setupScrollView];
}

#pragma mark 单击

- (void)orientationToHidePhotoBrowser:(UITapGestureRecognizer *)recognizer
{
    DJPhotoBrowserView *currentView = self.scrollView.subviews[self.currentImageIndex];
    
    currentView.imageScale = 1.0f;
    
    self.indexLabel.hidden = YES;
    self.saveButton.hidden = YES;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if (UIDeviceOrientationIsLandscape(orientation))
    {
        [UIView animateWithDuration:DJPhotoBrowserOrientationChangeAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            //[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)UIDeviceOrientationPortrait];
            self.transform = CGAffineTransformIdentity;
            self.bounds = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
            [self setNeedsLayout];
            //[self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self hidePhotoBrowser:recognizer];
        }];
    }
    else
    {
        [self hidePhotoBrowser:recognizer];
    }
}

- (void)hidePhotoBrowser:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"hidePhotoBrowser");
    
    DJPhotoBrowserView *view = (DJPhotoBrowserView *)recognizer.view;
    NSUInteger currentIndex = view.imageview.tag;
    
    CGRect rect = CGRectZero;
    if ([self.dataSource respondsToSelector:@selector(photoBrowser:containerViewRectAtIndex:)])
    {
        rect = [self.dataSource photoBrowser:self containerViewRectAtIndex:currentIndex];
    }
    else if (self.sourceImagesContainerView)
    {
        UIView *sourceView = self.sourceImagesContainerView.subviews[currentIndex];
        rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
        //NSLog(@"%@", NSStringFromCGRect(rect));
    }
    
    if (CGRectIsEmpty(rect) || CGRectEqualToRect(rect, CGRectZero))
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.window.windowLevel = bakWindowLevel;
        
        if (self.superview)
        {
            [self removeFromSuperview];
        }
        if (self.contentView.superview)
        {
            [self.contentView removeFromSuperview];
        }
        
        return;
    }
    
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.image = view.imageview.image;
    
    CGFloat tempImageSizeH = tempImageView.image.size.height;
    CGFloat tempImageSizeW = tempImageView.image.size.width;
    CGFloat tempImageViewH = (tempImageSizeH * UI_SCREEN_WIDTH)/tempImageSizeW;
    
    CGRect targetTempRect;
    if (tempImageViewH < UI_SCREEN_HEIGHT)
    {
        // 图片高度<屏幕高度
        targetTempRect = CGRectMake(0, (UI_SCREEN_HEIGHT - tempImageViewH)*0.5, UI_SCREEN_WIDTH, tempImageViewH);
    }
    else
    {
        targetTempRect = CGRectMake(0, 0, UI_SCREEN_WIDTH, tempImageViewH);
    }
    tempImageView.frame = targetTempRect;
    [self addSubview:tempImageView];
    
    self.saveButton.hidden = YES;
    self.indexLabel.hidden = YES;
    self.scrollView.hidden = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.window.windowLevel = bakWindowLevel;
    
    [UIView animateWithDuration:DJPhotoBrowserHideImageAnimationDuration animations:^{
        tempImageView.frame = rect;
    } completion:^(BOOL finished) {
        if (self.superview)
        {
            [self removeFromSuperview];
        }
        if (self.contentView.superview)
        {
            [self.contentView removeFromSuperview];
        }
        if (tempImageView.subviews)
        {
            [tempImageView removeFromSuperview];
        }
    }];
}

@end
