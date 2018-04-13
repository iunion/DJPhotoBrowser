//
//  DJPhotoItem.m
//  DJPhotoBrowserSample
//
//  Created by DJ on 2018/4/4.
//  Copyright © 2018年 DennisDeng. All rights reserved.
//

#import "DJPhotoItem.h"

@interface DJPhotoItem ()

@end

@implementation DJPhotoItem

- (void)setGifDuration:(NSTimeInterval)gifDuration
{
//    if (!self.isGif)
//    {
//        _gifDuration = 0;
//        return;
//    }

    if (gifDuration <= 0)
    {
        gifDuration = 1.0f;
    }

    _gifDuration = gifDuration;
}

@end
