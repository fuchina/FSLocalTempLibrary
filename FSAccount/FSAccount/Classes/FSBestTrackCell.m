//
//  FSBestTrackCell.m
//  myhome
//
//  Created by FudonFuchina on 2018/6/16.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestTrackCell.h"
#import "FSMacro.h"
#import <FSDate.h>
#import <FSCalculator.h>

@implementation FSBestTrackCell{
    UILabel *_timeLabel;
    UILabel *_jeLabel;
    UILabel *_bzLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _timeLabel = [FSViewManager labelWithFrame:CGRectMake(15, 5, WIDTHFC / 2, 30) text:nil textColor:FS_TextColor_Normal backColor:nil font:FONTFC(14) textAlignment:NSTextAlignmentLeft];
        [self addSubview:_timeLabel];
        
        _jeLabel = [FSViewManager labelWithFrame:CGRectMake(WIDTHFC / 2 + 15, 5, WIDTHFC / 2 - 30, 30) text:nil textColor:FS_TextColor_Dark backColor:nil font:FONTBOLD(18) textAlignment:NSTextAlignmentRight];
        [self addSubview:_jeLabel];
        
        _bzLabel = [FSViewManager labelWithFrame:CGRectMake(15, 35, WIDTHFC - 30, 30) text:nil textColor:FS_TextColor_Normal backColor:nil font:FONTFC(14) textAlignment:NSTextAlignmentLeft];
        _bzLabel.numberOfLines = 0;
        [self addSubview:_bzLabel];
    }
    return self;
}

- (void)setModel:(FSBestTrackModel *)model{
    _model = model;
    _timeLabel.text = model.time;
    _bzLabel.text = model.bz;
    _jeLabel.text = model.jeShow;
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
