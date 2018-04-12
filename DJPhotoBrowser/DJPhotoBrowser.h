//
//  DJPhotoBrowser.h
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJPhotoBrowserDefine.h"
#import "DJPhotoBrowserProtocol.h"

@interface DJPhotoBrowser : UIView

@property (nonatomic, weak) id<DJPhotoBrowserDataSource> dataSource;
@property (nonatomic, weak) id<DJPhotoBrowserDelegate> delegate;

// 原图片所在View控件，用于图片弹出收回动画
@property (nonatomic, weak) UIView *sourceImagesContainerView;

// 图片个数
@property (nonatomic, assign, readonly) NSUInteger imageCount;
// 当前显示的图片index
@property (nonatomic, assign, readonly) NSUInteger currentImageIndex;
// 是否无限循环显示图片
@property (nonatomic, assign) BOOL infiniteScrollView;

- (void)showWithImageCount:(NSUInteger)imageCount imageIndex:(NSUInteger)imageIndex;

- (void)reloadWithImageCount:(NSUInteger)imageCount imageIndex:(NSUInteger)imageIndex;

@end


