//
//  DJPhotoBrowserView.h
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJPhotoBrowserDefine.h"

typedef void (^photoViewSingleTapBlock)(UITapGestureRecognizer * _Nonnull recognizer);

@interface DJPhotoBrowserView : UIView

@property (nonnull, nonatomic, strong, readonly) UIImageView *imageview;

// 下载进度
@property (nonatomic, assign) CGFloat progress;
// 图片缩放比例
@property (nonatomic, assign) CGFloat imageScale;

// 单击回调
@property (nullable, nonatomic, copy) photoViewSingleTapBlock singleTapBlock;

- (void)setImageWithURL:(nonnull NSURL *)url placeholderImage:(nullable UIImage *)placeholder;
- (void)setImageWithURLString:(nonnull NSString *)urlString placeholderImage:(nullable UIImage *)placeholder;

@end
