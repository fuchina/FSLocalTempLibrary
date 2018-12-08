//
//  FSABListCell.m
//  myhome
//
//  Created by FudonFuchina on 2017/5/21.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSABListCell.h"
#import "FSViewManager.h"
#import "FuSoft.h"
#import "FSMacro.h"
#import "FATool.h"
#import <YYLabel.h>

@interface FSABListCell ()

@property (nonatomic,strong) FSABModel     *model;

@end

@implementation FSABListCell{
    YYLabel         *_timeLabel;
    UILabel         *_moneyLabel;
    YYLabel         *_typeLabel;
    UILabel         *_typeValueLabel;
    YYLabel         *_restLabel;
    YYLabel         *_restValueLabel;
    FSTapLabel      *_bzLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self selectDesignViews];
    }
    return self;
}

- (void)selectDesignViews{
    UIFont *font14 = [UIFont systemFontOfSize:14];
    _timeLabel = [[YYLabel alloc] initWithFrame:CGRectMake(15, 10, WIDTHFC - 15, 30)];
    _timeLabel.textColor = FS_TextColor_Normal;
    _timeLabel.font = font14;
    [self addSubview:_timeLabel];
    
    _restValueLabel = [[YYLabel alloc] initWithFrame:CGRectMake(WIDTHFC / 2, 10, WIDTHFC / 2 -15, 30)];
    _restValueLabel.textColor = FS_TextColor_Dark;
    _restValueLabel.font = [UIFont boldSystemFontOfSize:17];
    _restValueLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_restValueLabel];
    
    _restLabel = [[YYLabel alloc] initWithFrame:CGRectMake(15, _restValueLabel.bottom, 100, 30)];
    _restLabel.text = NSLocalizedString(@"Money", nil);
    _restLabel.textColor = FS_TextColor_Normal;
    _restLabel.font = font14;
    [self addSubview:_restLabel];
    
    _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTHFC / 2, _restValueLabel.bottom, WIDTHFC / 2 - 15, 30)];
    _moneyLabel.textColor = FS_TextColor_Dark;
    _moneyLabel.font = font14;
    _moneyLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_moneyLabel];
    
    _typeLabel = [[YYLabel alloc] initWithFrame:CGRectMake(15, _moneyLabel.bottom, 100, 30)];
    _typeLabel.text = NSLocalizedString(@"Type", nil);
    _typeLabel.textColor = FS_TextColor_Normal;
    _typeLabel.font = font14;
    [self addSubview:_typeLabel];
    
    _typeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTHFC / 2, _moneyLabel.bottom, WIDTHFC / 2 - 15, 30)];
    _typeValueLabel.font = font14;
    _typeValueLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_typeValueLabel];
    
    WEAKSELF(this);
    _bzLabel = [FSViewManager tapLabelWithFrame:CGRectMake(15, _typeValueLabel.bottom, WIDTHFC - 30, 44) text:nil textColor:FS_TextColor_Normal backColor:nil font:font14 textAlignment:NSTextAlignmentLeft block:^(FSTapLabel *bLabel) {
        [this bzAction];
    }];
    [self addSubview:_bzLabel];
    _bzLabel.numberOfLines = 0;
}

- (void)bzAction{
    if (self.trackCallback) {
        self.trackCallback(_model, _model.type);
    }
}

- (void)flowConfigDataWithEntity:(FSABModel *)entity{
    _model = entity;
    
    _timeLabel.text = entity.readableTime;
    _restValueLabel.text = entity.rest;
    _typeValueLabel.attributedText = entity.typeValue;

    if (entity.bzText) {
        _bzLabel.attributedText = entity.bzText;
    }else{
        _bzLabel.text = entity.bz;
        _bzLabel.textColor = entity.bzColor;
    }
    _bzLabel.userInteractionEnabled = entity.enabled;
    _bzLabel.height = entity.contentHeight;
    
    if (entity.isMoneyRich) {
        _moneyLabel.attributedText = entity.money;
    }else{
        _moneyLabel.text = entity.money;
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
