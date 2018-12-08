//
//  FSPublic.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSPublic.h"
#import <FSKit.h>
#import "FSShare.h"
#import "FSTrackKeys.h"
#import "FSToast.h"
#import <FSUIKit.h>
#import <FSViewToImage.h>

typedef NS_ENUM(NSInteger, FSPublicActionType) {
    FSPublicActionTypeScreenShot = 0,
    FSPublicActionTypePageShot
};

@implementation FSPublic

+ (void)shareAction:(UIViewController *)controller view:(UIScrollView *)scrollView{
    NSString *screenShot = @"屏幕截图";
    NSString *pageShot = @"页面截图";
    [FSUIKit alert:UIAlertControllerStyleAlert controller:controller title:NSLocalizedString(@"Share screenshot to Wechat?", nil) message:nil actionTitles:@[pageShot,screenShot] styles:@[@(UIAlertActionStyleDefault),@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        if ([action.title isEqualToString:screenShot]) {
            [self action:0 view:scrollView controller:controller];
        }else if ([action.title isEqualToString:pageShot]){
            [self action:1 view:scrollView controller:controller];
        }
    }];
}

+ (void)action:(FSPublicActionType)actionType view:(UIView *)scrollView controller:(UIViewController *)controller{
    NSString *wechat = @"发到微信";
    NSString *album = @"存入相册";
    [FSUIKit alert:UIAlertControllerStyleAlert controller:controller title:@"分享图片" message:nil actionTitles:@[wechat,album] styles:@[@(UIAlertActionStyleDefault),@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        UIImage *image = nil;
        if (actionType == FSPublicActionTypePageShot) {
            image = [FSViewToImage imageForUIView:scrollView];
        }else if (actionType == FSPublicActionTypeScreenShot){
            image = [FSViewToImage screenShot];
        }
        
        if (![image isKindOfClass:UIImage.class]) {
            return;
        }
        if ([action.title isEqualToString:album]) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
        }else{
            [FSTrack event:_UMeng_Event_acc_picture];
            [FSShare wxImageShareActionWithImage:image controller:controller result:^(NSString *bResult) {
            }];
        }
    }];
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (!error) {
        [FSToast show:@"保存成功"];
    }
}

@end
