//
//  DJPhotoItem.h
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJPhotoItem : NSObject

@property (nonnull, nonatomic, strong) NSString *thumbnailImage;
@property (nullable, nonatomic, strong) NSString *highQualityImage;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign, readonly) BOOL isGif;
@property (nonatomic, assign, readonly) BOOL isDown;

- (void)setDownLoadIsGif:(BOOL)isGif;

@end
