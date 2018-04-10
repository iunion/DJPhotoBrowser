//
//  DJPhotoBrowser.h
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJPhotoBrowserDefine.h"

@protocol DJPhotoBrowserDataSource;
@protocol DJPhotoBrowserDelegate;
@interface DJPhotoBrowser : UIView

@property (nonatomic, weak) id<DJPhotoBrowserDataSource> dataSource;
@property (nonatomic, weak) id<DJPhotoBrowserDelegate> delegate;

@property (nonatomic, weak) UIView *sourceImagesContainerView;

@property (nonatomic, assign, readonly) NSUInteger imageCount;
@property (nonatomic, assign, readonly) NSUInteger currentImageIndex;

- (void)showWithImageCount:(NSUInteger)imageCount imageIndex:(NSUInteger)imageIndex;

- (void)reloadWithImageCount:(NSUInteger)imageCount imageIndex:(NSUInteger)imageIndex;

@end

@protocol DJPhotoBrowserDataSource <NSObject>

@required
// 预览图片
- (UIImage *)photoBrowser:(DJPhotoBrowser *)browser placeholderImageForIndex:(NSUInteger)index;

@optional
// 原图片控件映射到PhotoBrowser的坐标，需要在delegate中做convertRect
- (CGRect)photoBrowser:(DJPhotoBrowser *)browser containerViewRectAtIndex:(NSUInteger)index;

// 高清图片URL
- (NSURL *)photoBrowser:(DJPhotoBrowser *)browser highQualityImageURLForIndex:(NSUInteger)index;

@end

@protocol DJPhotoBrowserDelegate <NSObject>

@optional
// 滚动
- (void)photoBrowser:(DJPhotoBrowser *)browser didScrollToIndex:(NSUInteger)index;
// 删除图片
- (void)photoBrowser:(DJPhotoBrowser *)browser deleteImageAtIndex:(NSUInteger)index;

@end
