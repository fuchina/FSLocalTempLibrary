//
//  FSCryptorSupport.h
//  myhome
//
//  Created by Fudongdong on 2017/8/28.
//  Copyright © 2017年 fuhope. All rights reserved.
//

/*
    A：明文密码；
    B：明文密码的MD5；（真正使用的密码）
    C：用B加密B后的值；
    D：C的MD5，保存在数据库中
    D：用一个safe_key加密的保存在本地的密码
 */

#import <Foundation/Foundation.h>

@interface FSCryptorSupport : NSObject

// 保存密码，password为未加密的用户记得的值
+ (BOOL)savePassword:(NSString *)_A;

// 本地的密码
+ (NSString *)localUserDefaultsCorePassword;
// 保存核心密码
+ (void)userDefaultsCorePassword:(NSString *)md5;
+ (void)userDefaultsCorePasswordForA:(NSString *)_A;
+ (void)changeMemoryPassword:(NSString *)_A;

// 获取数据库中存储的核心密码
+ (NSString *)theCorePasswordInSQLite;
+ (void)insertCorePasswordIntoSQLite:(NSString *)_A;

// A->D
+ (NSString *)makeD:(NSString *)_A;
+ (NSString *)md5:(NSString *)_A;

@end
