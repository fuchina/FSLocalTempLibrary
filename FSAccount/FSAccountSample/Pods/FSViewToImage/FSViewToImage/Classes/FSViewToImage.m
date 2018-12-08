//
//  FSViewToImage.m
//  FSViewToImage
//
//  Created by FudonFuchina on 2018/11/22.
//  Copyright © 2018年 fudongdong. All rights reserved.
//

#import "FSViewToImage.h"

@implementation FSViewToImage

+ (UIImage *)imageForUIView:(nonnull UIView *)view{
    CGSize size = view.bounds.size;
    CGRect savedFrame = view.frame;
    BOOL isScrollView = [view isKindOfClass:UIScrollView.class];
    if (isScrollView) {
        UIScrollView *sView = (UIScrollView *)view;
        size = CGSizeMake(sView.frame.size.width,sView.contentSize.height + sView.contentInset.top + sView.contentInset.bottom);
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, size.width, size.height);
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:currnetContext];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (isScrollView) {
        view.frame = savedFrame;
    }
    return image;
}

+ (UIImage *)screenShot{
    UIApplication *app = [UIApplication sharedApplication];
    UIView *statusBar = [app valueForKey:@"_statusBar"];
    NSAssert(statusBar != nil, @"获取状态栏失败");
    UIImage *image1 = [self imageForUIView:statusBar];
    UIImage *image2 = [self screenShotApple];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    imageView.image = image2;
    UIImageView *sbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, statusBar.frame.size.width, statusBar.frame.size.height)];
    sbImageView.image = image1;
    [imageView addSubview:sbImageView];
    return [self imageForUIView:imageView];
}

+ (UIImage *)screenShotApple{
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            CGContextConcatCTM(context, [window transform]);
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            [[window layer] renderInContext:context];
            CGContextRestoreGState(context);
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
