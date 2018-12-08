//
//  FSDBTool.h
//  Demo
//
//  Created by fudon on 2017/5/16.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSSQLEntity.h"
#import "FSTuple.h"
#import <FSFile.h>
#import "FSDBSupport.h"
#import "FSABModel.h"
#import "FSABTrackModel.h"

@interface FSDBTool : NSObject

+ (FSSQLEntity *)fasterEntityFromDB:(NSString *)tableName start:(NSTimeInterval)start;

+ (NSString *)sixNumberPwd;
+ (NSString *)sixNumberPwdFromRunWithKey:(NSDate *)date;

// block返回Tuple2: _1：文件路径; _2：文件名字(不带扩展名)
+ (void)saveFileCallback:(Tuple2<NSString *,NSString *> * (^)(void))block;
+ (void)pushFileToWechatOrEmailWithPath:(Tuple3 *)path;

// 生成会计科目类型，最多26 * 26个
+ (NSString *)accountTypeWithIndex:(NSInteger)index;

// Tuple2: 第一个是bool值，第二个是message
+ (Tuple2 *)returnErrorStringIfOccurrError:(NSArray *)handleArray;

+ (void)handleDatas:(NSArray *)handleArray account:(NSString *)account date:(NSDate *)date je:(NSString *)je bz:(NSString *)bz controller:(UIViewController *)controller type:(NSString *)type completion:(void(^)(void))completion;
// 处理rest有减少的数据
+ (NSString *)handleEDArray:(NSArray<FSABModel *> *)array account:(NSString *)account;
// 存入账本跟踪数据
+ (NSString *)handleTracks:(NSArray<FSABTrackModel *> *)tracks;

// 账本修改的时间的key
+ (NSString *)accountChangeKey:(NSString *)account type:(NSString *)type;

+ (void)pushToAccountUpdateController:(UINavigationController *)navigationController entity:(FSABModel *)entity isA:(BOOL)isA account:(NSString *)accountName;

// 将外来的数据库拷贝入本工程继续使用，该数据库放到工程中，命名为 test.db
+ (void)copyImportDatabase;

+ (void)sumSubject:(NSString *)subject table:(NSString *)table completion:(void(^)(CGFloat value))completion;

// 获取year的某科目的每月数据
+ (NSArray<NSDictionary *> *)yearsOfSubjectByTable:(NSString *)table year:(NSInteger)year useCacheIfExist:(BOOL)useCache;
+ (CGFloat)sumSubject:(NSString *)subject table:(NSString *)table start:(NSInteger)start end:(NSInteger)end;

+ (void)scanAccount:(NSString *)account wantYear:(NSInteger)year completion:(void(^)(NSDictionary *value))completion;

// 遍历账本，将数据以月度为单位缓存
+ (void)throughTheAccount:(NSString *)tableName;
+ (NSString *)soleCacheKey:(NSString *)table year:(NSInteger)year month:(NSInteger)month;

+ (CGFloat)woodpeckerTrack:(NSString *)subj account:(NSString *)account;
+ (CGFloat)woodpeckerPlus:(NSString *)subject account:(NSString *)account;
+ (CGFloat)woodpeckerMinus:(NSString *)subject account:(NSString *)account;
+ (CGFloat)woodpeckerRest:(NSString *)subject account:(NSString *)account;

+ (void)findErrorTrackForSubject:(NSString *)subject table:(NSString *)account controller:(UIViewController *)controller;
+ (void)checkOverMinus:(NSString *)subject account:(NSString *)account controller:(UIViewController *)controller;

// 执行SQL语句
+ (NSString *)execSQL:(NSString *)sql;

@end
