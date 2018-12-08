//
//  FSBestAccountCell.m
//  myhome
//
//  Created by FudonFuchina on 2018/4/5.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestAccountCell.h"
#import "FSTapLabel.h"
#import "FSViewManager.h"
#import <FuSoft.h>
#import "FSMacro.h"

@interface FSBestAccountCell ()

@property (nonatomic,strong) FSTapLabel *bzLabel;

@property (nonatomic,strong) UILabel    *aTypeLabel;
@property (nonatomic,strong) UILabel    *aTypeValueLabel;
@property (nonatomic,strong) UILabel    *bTypeLabel;
@property (nonatomic,strong) UILabel    *bTypeValueLabel;

@end

@implementation FSBestAccountCell{
    UILabel         *_timeLabel;
    UILabel         *_moneyLabel;

    UIImageView     *_imageV;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self selectDesignViews];
    }
    return self;
}

- (void)selectDesignViews{
    _timeLabel = [FSViewManager labelWithFrame:CGRectMake(15, 10, WIDTHFC - 15, 30) text:nil textColor:FS_TextColor_Normal backColor:nil font:FONTFC(14) textAlignment:NSTextAlignmentLeft];
    [self addSubview:_timeLabel];
    
    _moneyLabel = [FSViewManager labelWithFrame:CGRectMake(WIDTHFC / 2, 10, WIDTHFC / 2 - 15, 30) text:nil textColor:FS_TextColor_Dark backColor:nil font:FONTBOLD(17) textAlignment:NSTextAlignmentRight];
    [self addSubview:_moneyLabel];
    
    _aTypeLabel = [FSViewManager labelWithFrame:CGRectMake(15, _moneyLabel.bottom,WIDTHFC - 30, 30) text:NSLocalizedString(@"Type", nil) textColor:FS_TextColor_Normal backColor:nil font:FONTFC(14) textAlignment:NSTextAlignmentLeft];
    [self addSubview:_aTypeLabel];
    
    _aTypeValueLabel = [FSViewManager labelWithFrame:CGRectMake(WIDTHFC / 2, _moneyLabel.bottom, WIDTHFC / 2 - 15, 30) text:nil textColor:nil backColor:nil font:FONTFC(14) textAlignment:NSTextAlignmentRight];
    [self addSubview:_aTypeValueLabel];
    
    _bTypeLabel = [FSViewManager labelWithFrame:CGRectMake(15, _aTypeLabel.bottom,WIDTHFC - 30, 30) text:NSLocalizedString(@"Type", nil) textColor:FS_TextColor_Normal backColor:nil font:FONTFC(14) textAlignment:NSTextAlignmentLeft];
    [self addSubview:_bTypeLabel];
    
    _bTypeValueLabel = [FSViewManager labelWithFrame:CGRectMake(WIDTHFC / 2, _aTypeLabel.bottom, WIDTHFC / 2 - 15, 30) text:nil textColor:nil backColor:nil font:FONTFC(14) textAlignment:NSTextAlignmentRight];
    [self addSubview:_bTypeValueLabel];
    
    WEAKSELF(this);
    _bzLabel = [FSViewManager tapLabelWithFrame:CGRectMake(15, _bTypeLabel.bottom, WIDTHFC - 30, 44) text:nil textColor:FS_TextColor_Normal backColor:nil font:FONTFC(14) textAlignment:NSTextAlignmentLeft block:^(FSTapLabel *bLabel) {
        [this bzAction];
    }];
    [self addSubview:_bzLabel];
    _bzLabel.numberOfLines = 0;
    
    _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTHFC - 15 - 25, _bTypeLabel.bottom + 10, 24, 24)];
    _imageV.image = [UIImage imageNamed:@"selected_right_icon"];
    [self addSubview:_imageV];
}

- (void)bzAction{
    if (self.trackCallback) {
        NSString *name = _model.markSubject == 1?_model.aType:_model.bType;
        self.trackCallback(_model, _model.markSubject,name);
    }
}

- (void)setModel:(FSBestAccountModel *)entity{
    _model = nil;
    static Class Class_FSBestAccountModel = nil;
    if (!Class_FSBestAccountModel) {
        Class_FSBestAccountModel = FSBestAccountModel.class;
    }
    if ([entity isKindOfClass:Class_FSBestAccountModel]) {
        _model = entity;
    }
    
    _timeLabel.text = entity.readableTime;
    _moneyLabel.attributedText = entity.showJE;
    
    _aTypeLabel.text = entity.aType;
    _aTypeLabel.textColor = entity.atColor;
    _bTypeLabel.text = entity.bType;
    _bTypeLabel.textColor = entity.btColor;
    
    _aTypeValueLabel.text = entity.restA;
    _aTypeValueLabel.textColor = entity.arColor;
    _bTypeValueLabel.text = entity.restB;
    _bTypeValueLabel.textColor = entity.brColor;
    
    _bzLabel.attributedText = entity.colorBZ;
    _bzLabel.userInteractionEnabled = entity.canClick;
    
    _imageV.hidden = !entity.selected;
}

- (void)setImageHidden:(BOOL)hidden{
    _imageV.hidden = hidden;
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
