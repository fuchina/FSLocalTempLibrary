//
//  FSAppConfigModel.h
//  myhome
//
//  Created by Fudongdong on 2017/12/23.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSAppConfigModel : NSObject

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy)   NSString   *time;
@property (nonatomic,copy)   NSString   *type;
@property (nonatomic,copy)   NSString   *content;

+ (NSArray<NSString *> *)tableFields;

@end
