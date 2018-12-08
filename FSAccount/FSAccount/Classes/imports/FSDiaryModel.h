//
//  FSDiaryModel.h
//  myhome
//
//  Created by FudonFuchina on 2017/5/28.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSAppModel.h"

@interface FSDiaryModel : FSAppModel

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy) NSString     *time;
@property (nonatomic,copy) NSString     *content;
@property (nonatomic,copy) NSString     *zone;
@property (nonatomic,copy) NSString     *saw;

+ (NSArray<NSString *> *)tableFields;

@end
