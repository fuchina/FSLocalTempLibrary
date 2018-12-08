//
//  FSBestFlowCell.m
//  myhome
//
//  Created by FudonFuchina on 2018/7/5.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestFlowCell.h"
#import <FSKit.h>

@implementation FSBestFlowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self flowDesignViews];
    }
    return self;
}

- (void)flowDesignViews{
    CGFloat _width_ = UIScreen.mainScreen.bounds.size.width;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_width_ / 2 - 60, 35, 100, 70)];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.tag = 123;
    CGFloat rgb = 238 / 255.0;
    label.textColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1];
    [self addSubview:label];
    
    UIFont *font14 = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    NSArray *lefts = @[@"收入",@"成本",@"利润",@"净利率"];
    for (int x = 0; x < lefts.count; x ++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10 + 30 * x, 100, 30)];
        label.font = font14;
        label.text = lefts[x];
        [self addSubview:label];
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(15, 10 + 30 * x, _width_ - 30, 30)];
        content.font = font14;
        content.tag = 124 + x;
        content.textAlignment = NSTextAlignmentRight;
        [self addSubview:content];
    }
}

- (void)configData:(NSDictionary *)t{
    static NSString *p = @"ps";
    static NSString *m = @"ms";
    static NSString *r = @"rs";
    static NSString *n = @"n";
    static NSString *jlv = @"jlv";
    static NSString *c = @"c";

    UILabel *rLabel = [self viewWithTag:123];
    UILabel *srLabel = [self viewWithTag:124];
    UILabel *cbLabel = [self viewWithTag:125];
    UILabel *pLabel = [self viewWithTag:126];
    UILabel *jLabel = [self viewWithTag:127];
    srLabel.text = t[p];
    cbLabel.text = t[m];
    pLabel.text = t[r];
    rLabel.text = t[n];
    jLabel.text = t[jlv];
    BOOL hasProfit = [t[c] boolValue];
    if (hasProfit) {
        UIColor *green = [UIColor colorWithRed:64/255.0 green:171/255.0 blue:62/255.0 alpha:1.0];
        pLabel.textColor = green;
    }else{
        pLabel.textColor = UIColor.redColor;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
