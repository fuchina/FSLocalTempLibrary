//
//  FSBestAccountAPI.h
//  myhome
//
//  Created by FudonFuchina on 2018/3/29.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseAPI.h"
#import "FSBestSubjectModel.h"
#import "FSBestAccountModel.h"
#import "FSBestAccountCacheModel.h"
#import "FSBestTrackModel.h"
#import "FSBestMobanModel.h"

@interface FSBestAccountDataModel : NSObject

@property (nonatomic,assign) CGFloat sr;    // 今年收入
@property (nonatomic,assign) CGFloat cb;    // 今年成本

@property (nonatomic,assign) CGFloat allsr; // 所有收入
@property (nonatomic,assign) CGFloat allcb; // 所有成本

@property (nonatomic,assign) CGFloat yearSR; // 过去一年的收入
@property (nonatomic,assign) CGFloat yearCB; // 过去一年的成本

@property (nonatomic,assign) CGFloat ldzc;
@property (nonatomic,assign) CGFloat fldzc;
@property (nonatomic,assign) CGFloat ldfz;
@property (nonatomic,assign) CGFloat fldfz;
@property (nonatomic,assign) CGFloat syzqy;

@end

// 科目类型
typedef NS_ENUM(NSInteger, FSBestAccountSubjectType) {
    FSBestAccountSubjectTypeUnknown = 0,          // 不明
    FSBestAccountSubjectType1SR = 1,               // 收入
    FSBestAccountSubjectType2CB = 2,               // 成本
    FSBestAccountSubjectType3LDZC = 3,             // 流动资产
    FSBestAccountSubjectType4FLDZC = 4,            // 非流动资产
    FSBestAccountSubjectType5LDFZ = 5,             // 流动负债
    FSBestAccountSubjectType6FLDFZ = 6,            // 非流动负债
    FSBestAccountSubjectType7SYZQY = 7,            // 所有者权益 增加科目的地方判断be不能大于等于这个，如果有新增要同步更新
};

@interface FSBestAccountAPI : FSBaseAPI

// 获取所有属性为be的科目
+ (NSArray *)allSubjectsIsBe:(NSString *)be table:(NSString *)table;

/*
    jeSort：     1，从大到小，2，从小到大，默认为0
    timeSort:   1.从近到远，2.从远到近，默认为1
 */
+ (void)listForBe:(NSString *)be table:(NSString *)table page:(NSInteger)page jeSort:(NSInteger)jeSort timeSort:(NSInteger)timeSort isPlus:(BOOL)isPlus call:(void(^)(NSArray<FSBestAccountCacheModel *> *list))list;

+ (void)bestAccount_home_sub_thread:(NSString *)table be:(NSString *)be thisYear:(BOOL)thisYear call:(void(^)(NSArray<FSBestAccountCacheModel *> *list))list;

+ (void)bestAccount_home_sub_thread:(NSString *)table be:(NSString *)be year:(NSString *)year call:(void(^)(NSArray<FSBestAccountCacheModel *> *list))list;

// 首页全局数据
+ (void)business_global:(NSString *)table callback:(void(^)(NSArray *array,NSArray *mass,FSBestAccountDataModel *model))callback;

+ (NSMutableArray<FSBestAccountModel *> *)listForTable:(NSString *)table page:(NSInteger)page;

+ (NSString *)beNameForBe:(NSString *)be;

+ (NSArray<Tuple3 *> *)accountantClass;

// 增加科目
+ (NSString *)addSubject:(NSString *)name be:(NSString *)be jd:(NSString *)jd table:(NSString *)table;

// 获取所有的科目
+ (NSArray<FSBestSubjectModel *> *)allSubjectsForTable:(NSString *)table;

// 检查会计科目是否平衡
+ (BOOL)checkBalance:(FSBestSubjectModel *)aSubject bSubject:(FSBestSubjectModel *)bSubject table:(NSString *)table;

// 记账
+ (NSString *)versatileAddAccount:(NSString *)table je:(NSString *)je bz:(NSString *)bz date:(NSDate *)date aSubject:(FSBestSubjectModel *)aSubject bSubject:(FSBestSubjectModel *)bSubject aMinused:(NSArray<FSBestAccountModel *> *)aMinus bMinused:(NSArray<FSBestAccountModel *> *)bMinus controller:(UIViewController *)controller inBlock:(void(^)(void(^callback)(void)))b;

// 每个账本都有独立的Track表
+ (NSString *)trackTableForAccountTable:(NSString *)table;

// 获取某个表下某个科目的所有子科目
+ (NSArray<FSBestSubjectModel *> *)subSubjectForType:(NSString *)be forTable:(NSString *)table;

// 账本数据列表-科目
+ (NSMutableArray<FSBestAccountModel *> *)listForSubject:(NSString *)subject table:(NSString *)table page:(NSInteger)page track:(BOOL)track asc:(BOOL)asc unit:(NSInteger)unit;

+ (NSMutableArray<FSBestAccountModel *> *)listForSubjectOfDetail:(NSString *)subject table:(NSString *)table page:(NSInteger)page track:(BOOL)track asc:(BOOL)asc isAll:(BOOL)isAll jeSort:(NSInteger)jeSort unit:(NSInteger)unit start:(NSInteger)start end:(NSInteger)end isPlus:(BOOL)isPlus;

// 获取科目
+ (FSBestSubjectModel *)subjectForValue:(NSString *)vl table:(NSString *)table;

// 获取增减记录
+ (NSMutableArray<FSBestTrackModel *> *)tracksForModel:(FSBestAccountModel *)model markSubject:(NSInteger)markSubject table:(NSString *)table page:(NSInteger)page;

+ (BOOL)subjectCanDelete:(NSString *)subjectValue table:(NSString *)table;

+ (NSString *)editSubject:(FSBestSubjectModel *)model newName:(NSString *)newName table:(NSString *)table;

+ (NSArray<FSBestAccountModel *> *)searchAccount:(NSString *)account search:(NSString *)search;

+ (NSArray *)annalsAndFlows:(NSString *)table;

+ (NSString *)amendTable:(NSString *)table;

+ (NSString *)updateModel:(FSBestAccountModel *)model table:(NSString *)table;

+ (CGFloat)trackMinusedForTable:(NSString *)table lk:(NSString *)lk isAJ:(BOOL)isAJ;

+ (NSString *)deleteSubjectWithType:(NSString *)vl table:(NSString *)table;

+ (void)srAndCbForTable:(NSString *)table months:(NSInteger)months completion:(void(^)(NSString *sr,NSString *cb,NSInteger year,NSInteger month))completion;

+ (NSInteger)firstTimeForTable:(NSString *)table;

+ (NSMutableArray<NSString *> *)allMobanForTable:(NSString *)table page:(NSInteger)page;
+ (NSString *)mobanTableForTable:(NSString *)table;

+ (NSString *)addMobanForTable:(NSString *)table aj:(FSBestSubjectModel *)aj bj:(FSBestSubjectModel *)bj bz:(NSString *)bz;

+ (NSArray<FSBestMobanModel *> *)mobansForTable:(NSString *)table bz:(NSString *)bz;

+ (NSMutableArray<NSDictionary *> *)allFlowsForTable:(NSString *)table page:(NSInteger)page;

+ (NSMutableArray<FSBestAccountModel *> *)flowListForTable:(NSString *)table year:(NSString *)year month:(NSString *)month isSR:(BOOL)isSR;

+ (NSDictionary *)annalsForTable:(NSString *)table year:(NSInteger)year useCacheIfExist:(BOOL)useCache;

@end
