//
//  FSBestTrackModel.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/3.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBestTrackModel : NSObject

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy) NSString     *tm;

@property (nonatomic,copy) NSString     *lk;     // 哪条数据的记录，对应FSBestAccountModel.tm
@property (nonatomic,copy) NSString     *ms;     // markSubject 1.对应A科目，2对应B科目
@property (nonatomic,copy) NSString     *je;
@property (nonatomic,copy) NSString     *bz;

// 非tableFields
@property (nonatomic,assign) NSInteger height;
@property (nonatomic,assign) NSInteger bzHeight;
@property (nonatomic,copy) NSString     *time;
@property (nonatomic,copy) NSString     *jeShow;

- (void)countProperties;

+ (NSArray<NSString *> *)tableFields;

@end
