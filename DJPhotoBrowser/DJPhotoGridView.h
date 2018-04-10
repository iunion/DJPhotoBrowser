//
//  DJPhotoGridView.h
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DJPhotoItem;
@interface DJPhotoGridView : UIView

@property (nonatomic, strong) NSArray<DJPhotoItem *> *photoItemArray;

@end
