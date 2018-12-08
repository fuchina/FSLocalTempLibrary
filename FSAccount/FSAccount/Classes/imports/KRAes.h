//
//  KRAES.h
//  KRAES
//
//  Created by Kalvar on 2014/6/19.
//  Copyright (c) 2014年 Kalvar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRAes : NSObject

+ (NSData *)encryptAES256WithData:(NSData *)data password:(NSString *)key;
+ (NSData *)decryptAES256WithData:(NSData *)data password:(NSString *)key;

@end
