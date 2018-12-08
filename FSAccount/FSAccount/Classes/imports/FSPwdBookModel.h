//
//  FSPwdBookModel.h
//  myhome
//
//  Created by FudonFuchina on 2017/8/13.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSPwdBookModel : NSObject

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy) NSString     *time;
@property (nonatomic,copy) NSString     *begin; // 开始生效时间点
@property (nonatomic,copy) NSString     *name;
@property (nonatomic,copy) NSString     *login;
@property (nonatomic,copy) NSString     *pwd;
@property (nonatomic,copy) NSString     *phone;
@property (nonatomic,copy) NSString     *mail;
@property (nonatomic,copy) NSString     *note;
@property (nonatomic,copy) NSString     *zone;

+ (NSArray<NSString *> *)tableFields;

@end
