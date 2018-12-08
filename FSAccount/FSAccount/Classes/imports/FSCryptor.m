//
//  FSCryptor.m
//  myhome
//
//  Created by FudonFuchina on 2017/6/1.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSCryptor.h"
#import <CommonCrypto/CommonCryptor.h>
#import "RSA.h"
#import "KRAes.h"
#import "FSCryptorSupport.h"
#import "GTMBase64.h"

@implementation FSCryptor

+ (NSString *)aes256EncryptString:(NSString *)content{
    return [self aes256EncryptString:content password:[FSCryptorSupport localUserDefaultsCorePassword]];
}

+ (NSString *)aes256DecryptString:(NSString *)str{
    return [self aes256DecryptString:str password:[FSCryptorSupport localUserDefaultsCorePassword]];
}

+ (NSString *)aes256EncryptString:(NSString *)content password:(NSString *)password{
    if (!content || !password) {
        return nil;
    }
    NSData *encryptData = [KRAes encryptAES256WithData:[content dataUsingEncoding:NSUTF8StringEncoding] password:password];
    NSString *base64Stri = [encryptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return base64Stri;
}

+ (NSString *)aes256DecryptString:(NSString *)str password:(NSString *)password{
    if (!str || !password || [str isEqualToString:@"(null)"]) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *_decryptData = [KRAes decryptAES256WithData:data password:password];
    return [[NSString alloc] initWithData:_decryptData encoding:NSUTF8StringEncoding];
}

+ (NSString *)encryptUseDES:(NSString *)plainText key:(NSString *)key{
    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    Byte iv[] = {1,2,3,4,5,6,7,8};
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          textBytes,
                                          dataLength,
                                          buffer,
                                          1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
    }
    return ciphertext;
}

+ (NSString *)decryptUseDES:(NSString*)cipherText key:(NSString*)key{
    NSData* cipherData = [GTMBase64 decodeString:cipherText];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    Byte iv[] = {1,2,3,4,5,6,7,8};
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          1024,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainText;
}

+ (NSString *)encryptString:(NSString *)str{
    NSString *publicPath = [[NSBundle mainBundle] pathForResource:@"rsa_public_key" ofType:@"pem"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:publicPath];
    NSString *publicKey = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [RSA encryptString:str publicKey:publicKey];
}

+ (NSString *)decryptString:(NSString *)str{
    NSString *publicPath = [[NSBundle mainBundle] pathForResource:@"rsa_private_key" ofType:@"pem"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:publicPath];
    NSString *privateKey = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return [RSA decryptString:str privateKey:privateKey];
}


@end
