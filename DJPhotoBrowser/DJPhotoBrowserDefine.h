//
//  DJPhotoBrowserDefine.h
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#ifndef DJPhotoBrowserDefine_h
#define DJPhotoBrowserDefine_h

typedef NS_ENUM(NSUInteger, DJWaitingViewMode)
{
    DJWaitingViewModeLoopDiagram,   // 环形
    DJWaitingViewModePieDiagram     // 饼型
};

#define UI_SCREEN_WIDTH     ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_HEIGHT    ([[UIScreen mainScreen] bounds].size.height)

// 图片缩放限制
#define kMinZoomScale 0.5f
#define kMaxZoomScale 3.0f

// 是否在横屏的时候直接满宽度，而不是满高度，一般是在有长图需求时设置为YES
#define kIsFullWidthForLandScape        YES

// 是否支持横屏
#define DJPhotoBrowserShouldLandscape   YES

// browser背景颜色
#define DJPhotoBrowserBackgrounColor    [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]

// browser中图片间的间隔margin
#define DJPhotoBrowserImageViewMargin   10.0f

// browser显示图片动画时长
#define DJPhotoBrowserShowImageAnimationDuration            0.35f
// browser隐藏图片动画时长
#define DJPhotoBrowserHideImageAnimationDuration            0.35f
// browser转屏图片动画时长
#define DJPhotoBrowserOrientationChangeAnimationDuration    0.35f

// 图片下载进度指示进度显示样式（DJWaitingViewModeLoopDiagram 环形，DJWaitingViewModePieDiagram 饼型）
#define DJWaitingViewProgressMode       DJWaitingViewModeLoopDiagram

// 图片下载进度指示器背景色
#define DJWaitingViewBackgroundColor    [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f]

// 图片下载进度指示器内部控件间的间距
#define DJWaitingViewItemMargin         10.0f


#endif /* DJPhotoBrowserDefine_h */
