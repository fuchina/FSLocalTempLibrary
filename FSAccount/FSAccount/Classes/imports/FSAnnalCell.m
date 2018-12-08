//
//  FSAnnalCell.m
//  myhome
//
//  Created by FudonFuchina on 2018/1/17.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSAnnalCell.h"
#import "FSKitDuty.h"
#import "FSAccountConfiger.h"

@implementation FSAnnalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self flowCellDesignViews];
    }
    return self;
}

- (void)flowCellDesignViews{
    UIFont *font14 = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    CGFloat _width_ = UIScreen.mainScreen.bounds.size.width;
    NSArray *lefts = @[@"收入",@"成本",@"利润",@"净利率"];
    for (int x = 0; x < lefts.count; x ++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10 + 30 * x, 100, 30)];
        label.font = font14;
        label.text = lefts[x];
        [self addSubview:label];
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(15, 10 + 30 * x, _width_ - 30, 30)];
        content.font = font14;
        content.tag = 123 + x;
        content.textAlignment = NSTextAlignmentRight;
        [self addSubview:content];
    }
}

- (void)configData:(NSDictionary *)t{
    static NSString *lr = @"lr";
    CGFloat profit = [t[lr] doubleValue];
    CGFloat sr = [t[_subject_SR] doubleValue];
    NSString *rate = [[NSString alloc] initWithFormat:@"%.2f%%",profit * 100 / MAX(0.01, sr)];
    
    UILabel *srLabel = [self viewWithTag:123];
    UILabel *cbLabel = [self viewWithTag:124];
    UILabel *pLabel = [self viewWithTag:125];
    UILabel *rLabel = [self viewWithTag:126];
    srLabel.text = t[_subject_SR];
    cbLabel.text = t[_subject_CB];
    pLabel.text = t[lr];
    rLabel.text = rate;
    if (profit > 0.0) {
        UIColor *green = [UIColor colorWithRed:64/255.0 green:171/255.0 blue:62/255.0 alpha:1.0];
        pLabel.textColor = green;
    }else{
        pLabel.textColor = [UIColor redColor];
    }
}

- (void)configDataBest:(NSDictionary *)t{
    static NSString *lr = @"lr";
    static NSString *jlv = @"jlv";
    static NSString *green = @"gn";

    BOOL isGreen = [[t objectForKey:green] boolValue];
    UILabel *srLabel = [self viewWithTag:123];
    UILabel *cbLabel = [self viewWithTag:124];
    UILabel *pLabel = [self viewWithTag:125];
    UILabel *rLabel = [self viewWithTag:126];
    srLabel.text = t[_subject_SR];
    cbLabel.text = t[_subject_CB];
    pLabel.text = t[lr];
    rLabel.text = t[jlv];
    if (isGreen) {
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
