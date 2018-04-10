//
//  DJPhotoItem.m
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import "DJPhotoItem.h"

@interface DJPhotoItem ()

@property (nonatomic, assign) BOOL isGif;
@property (nonatomic, assign) BOOL isDown;

@end

@implementation DJPhotoItem

- (void)setDownLoadIsGif:(BOOL)isGif
{
    self.isDown = YES;
    self.isGif = isGif;
}

@end
