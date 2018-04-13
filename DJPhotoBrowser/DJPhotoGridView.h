//
//  DJPhotoGridView.h
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJPhotoBrowserDefine.h"

@class DJPhotoItem;
@interface DJPhotoGridView : UIView

@property (nonatomic, strong) NSArray<DJPhotoItem *> *photoItemArray;

@property (nonatomic, assign, readonly) BOOL hasGif;
@property (nonatomic, assign, readonly) BOOL isPlayGif;

+ (CGSize)photoGridViewSizeWith:(NSArray<DJPhotoItem *> *)photoItemArray;

- (void)gifPlay;
- (void)gifPause;

@end
