//
//  FSBestMobanModel.h
//  myhome
//
//  Created by FudonFuchina on 2018/7/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBestMobanModel : NSObject

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy) NSString     *tm;

@property (nonatomic,copy) NSString     *aj;
@property (nonatomic,copy) NSString     *ap;    // 1or2
@property (nonatomic,copy) NSString     *an;    // 科目名称，如 现金
@property (nonatomic,copy) NSString     *abe;    // 科目属性，如收入为 1
@property (nonatomic,copy) NSString     *abn;    // 属性名称，如'成本'

@property (nonatomic,copy) NSString     *bj;
@property (nonatomic,copy) NSString     *bp;    // 1or2
@property (nonatomic,copy) NSString     *bn;    //
@property (nonatomic,copy) NSString     *bbe;    //
@property (nonatomic,copy) NSString     *bbn;    //

@property (nonatomic,copy) NSString     *fq;    // 频数
@property (nonatomic,copy) NSString     *bz;    // 备注

// 非field
@property (nonatomic,copy) NSAttributedString     *showA;
@property (nonatomic,copy) NSAttributedString     *showB;

+ (NSArray<NSString *> *)tableFields;

@end
