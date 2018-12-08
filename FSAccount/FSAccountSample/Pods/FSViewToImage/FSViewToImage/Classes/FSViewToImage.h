//
//  FSViewToImage.h
//  FSViewToImage
//
//  Created by FudonFuchina on 2018/11/22.
//  Copyright © 2018年 fudongdong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSViewToImage : NSObject

+ (UIImage *)imageForUIView:(nonnull UIView *)view;

// 屏幕截图
+ (UIImage *)screenShot;

@end

NS_ASSUME_NONNULL_END
