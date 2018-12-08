//
//  FSCryptor.h
//  myhome
//
//  Created by FudonFuchina on 2017/6/1.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSCryptor : NSObject

/*
    FDD:经查这是通用写法，只是
    note：aes256加解密。
    AES是设计出来用于替代3DES的一种高级加密技术。
 */
+ (NSString *)aes256EncryptString:(NSString *)str;
+ (NSString *)aes256DecryptString:(NSString *)str;
+ (NSString *)aes256EncryptString:(NSString *)content password:(NSString *)password;
+ (NSString *)aes256DecryptString:(NSString *)str password:(NSString *)password;

/**
 *  3DES加密
 *
 *  @param plainText 明文
 *  @param key       密钥
 *
 *  @return 加密结果
 */
+ (NSString *)encryptUseDES:(NSString *)plainText key:(NSString *)key;
/**
 *  3DES解密
 *
 *  @param cipherText 密文
 *  @param key        密钥
 *
 *  @return 解密结果
 */
+ (NSString *)decryptUseDES:(NSString*)cipherText key:(NSString*)key;


// 未知原因未解密成功
+ (NSString *)encryptString:(NSString *)str;
+ (NSString *)decryptString:(NSString *)str;

@end
