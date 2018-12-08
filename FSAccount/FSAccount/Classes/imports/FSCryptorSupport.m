//
//  FSCryptorSupport.m
//  myhome
//
//  Created by Fudongdong on 2017/8/28.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSCryptorSupport.h"
#import "FSDBMaster.h"
#import <FSKit.h>
#import "FSMacro.h"
#import "FSCryptor.h"
#import "FSAPP.h"
#import "FSUIKit.h"

static NSString     *_safe_key  = @"_safe_key";
static NSString     *_corePwd = nil;
static NSString     *_you_dont_know = @"Email_System_Future";
@implementation FSCryptorSupport

+ (NSString *)soleKey{
    static NSString *soleKey = nil;
    if (nil == soleKey) {
        Class c = self.class;
        NSString *key = [[NSString alloc] initWithFormat:@"%@,%@",c,c];
        soleKey = _fs_md5(key);
    }
    return soleKey;
}

+ (BOOL)savePassword:(NSString *)password{
    if (!_fs_isValidateString(password)) {
        return NO;
    }
    NSString *md5 = [self md5:password];
    BOOL imported = [_fs_userDefaults_objectForKey(_UDKey_ImportNewDB) boolValue];
    if (imported) {
        NSString *_D = [self theCorePasswordInSQLite];
        NSString *_DNew = [self makeD:password];
        if (![_DNew isEqualToString:_D]) {
            [FSUIKit showAlertWithMessageOnCustomWindow:NSLocalizedString(@"Core password check", nil)];
            return NO;
        }
        _corePwd = md5;
        [self userDefaultsCorePassword:md5];
        _fs_userDefaults_setObjectForKey(@"0", _UDKey_ImportNewDB);
        return YES;
    }else{
        //这种是首次启动新建数据库时
        [self userDefaultsCorePassword:md5];
        [self insertCorePasswordIntoSQLite:password];
    }
    //需要用本地的密码去解析来获取，而此时本地的密码如果为空，就会解析失败返回nil;本地的密码和数据库的不一样，也会解析不出来。
    return YES;
}

+ (NSString *)theCorePasswordInSQLite{
    NSString *pwd = [FSAPP objectForKey:_you_dont_know];
    return pwd;
}

// value为已密码md5为key的aes256加密md5的值,再用md5加密保存在数据库中，及D。
+ (void)insertCorePasswordIntoSQLite:(NSString *)_A{
    NSString *_D = [self makeD:_A];
    if (_fs_isValidateString(_D)) {
        [FSAPP setObject:_D forKey:_you_dont_know];
    }
}

+ (NSString *)makeD:(NSString *)_A{
    if (!_fs_isValidateString(_A)) {
        return nil;
    }
    NSString *md5 = [self md5:_A];
    return [self makeDByB:md5];
}

// _B：及_A的MD5，真正用于加密的密码
+ (NSString *)makeDByB:(NSString *)_B{
    if (!_fs_isValidateString(_B)) {
        return nil;
    }
    NSString *value = [FSCryptor aes256EncryptString:_B password:_B];
    NSString *_D = _fs_md5(value);
    return _D;
}

+ (void)userDefaultsCorePassword:(NSString *)md5{
    NSString *saved = [FSCryptor aes256EncryptString:md5 password:_safe_key];
    _fs_userDefaults_setObjectForKey(saved, [self soleKey]);
}

+ (void)userDefaultsCorePasswordForA:(NSString *)_A{
    NSString *md5 = [self md5:_A];
    [self userDefaultsCorePassword:md5];
}

+ (NSString *)md5:(NSString *)_A{
    NSString *md5 = [_fs_md5(_A) uppercaseString];
    return md5;
}

+ (void)changeMemoryPassword:(NSString *)_A{
    NSString *md5 = [self md5:_A];
    _corePwd = md5;
}

+ (NSString *)localUserDefaultsCorePassword{
    if (!_fs_isValidateString(_corePwd)) {
        NSString *saved = _fs_userDefaults_objectForKey([self soleKey]);
        if (saved) {
            _corePwd = [FSCryptor aes256DecryptString:saved password:_safe_key];
        }
    }
    NSString *corePwd = _corePwd;
    return corePwd;
}

@end
