//
//  FSContactModel.h
//  myhome
//
//  Created by FudonFuchina on 2017/5/26.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSContactModel : NSObject

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy) NSString     *time;
@property (nonatomic,copy) NSString     *name;
@property (nonatomic,copy) NSString     *phone;
@property (nonatomic,copy) NSString     *type;  // 工作手机、家庭手机等

+ (NSArray<NSString *> *)tableFields;

@end
