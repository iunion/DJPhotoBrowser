//
//  DJPhotoBrowserProtocol.h
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/11.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#ifndef DJPhotoBrowserProtocol_h
#define DJPhotoBrowserProtocol_h

@class DJPhotoBrowser;
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

#endif /* DJPhotoBrowserProtocol_h */
