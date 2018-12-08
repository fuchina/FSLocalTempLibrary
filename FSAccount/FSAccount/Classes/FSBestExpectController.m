//
//  FSBestExpectController.m
//  myhome
//
//  Created by FudonFuchina on 2018/7/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestExpectController.h"
#import "FSPublic.h"
#import "FSUIKit.h"
#import "FSDate.h"
#import "FSKit.h"
#import "FuSoft.h"
#import "FSMacro.h"

#define Key_Year_Many           5
#define Days_Holddays           365 * 5.0
#define Days_Holddays_Power     365 * 2.5
#define Days_Cashdays           365 * 1.5

@interface FSBestExpectController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray        *textSource;
@property (nonatomic,assign) CGFloat        dayMoney;

@property (nonatomic,assign) CGFloat        deltaMoney; // 每个月的增量
@property (nonatomic,assign) CGFloat        addMoney;   // 存量

@property (nonatomic,strong) UIView         *headView;
@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,strong) UILabel        *rateLabel;
@property (nonatomic,strong) UISlider       *slider;
@property (nonatomic,strong) UILabel        *startLabel;
@property (nonatomic,assign) BOOL           hasFirst;
@property (nonatomic,strong) UIButton       *selectButton;
@property (nonatomic,assign) NSTimeInterval firstTime;
@property (nonatomic,assign) CGFloat        newCost;
@property (nonatomic,assign) NSTimeInterval theEarliestTime;

@end

@implementation FSBestExpectController{
    CGFloat             _jzc;
    CGFloat             _sr;
    CGFloat             _cb;
}

- (void)actionOfChoose{
    WEAKSELF(this);
    [FSUIKit alertInput:1 controller:self title:NSLocalizedString(@"Set space", nil) message:@"可以设置过去多少月来计算期间的收入和成本，以便做出判断" ok:@"OK" handler:^(UIAlertController *bAlert, UIAlertAction *action) {
        UITextField *tf = bAlert.textFields.firstObject;
        NSString *text = tf.text;
        if (!_fs_isPureInt(text)) {
            [FSToast show:NSLocalizedString(@"Please input number", nil)];
            return;
        }
        NSInteger months = [text integerValue];
        if (months <= 0) {
            [FSToast show:NSLocalizedString(@"Please input a number > zero", nil)];
            return;
        }
        NSString *num = [[NSString alloc] initWithFormat:@"过去%@月",@(months)];
        [this.selectButton setTitle:num forState:UIControlStateNormal];
        
        CGFloat approximate = months * 30;
        if (months % 12 == 0) {
            NSInteger times = months / 12;
            approximate = 365 * times;
        }
        
        NSTimeInterval time = _fs_timeIntevalSince1970() - approximate * 24 * 3600;
        this.firstTime = MAX(this.theEarliestTime, time);
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:this.firstTime];
        this.startLabel.text = [FSDate stringWithDate:date formatter:nil];
        this.hasFirst = NO;
        [this bestExpectHandleDatas];
    } cancel:@"Cancel" handler:nil textFieldConifg:^(UITextField *textField) {
        textField.placeholder = @"过去多少月";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    } completion:nil];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = FS_GreenColor;
    [FSTrack event:_UMeng_Event_acc_expect];
    
    _fs_dispatch_global_main_queue_async(^{
        self.theEarliestTime = [FSBestAccountAPI firstTimeForTable:self.accountName];
    }, ^{
        [self initEvents];
    });
}

- (void)initEvents{
    CGFloat dayUnit = 24 * 3600;
    _firstTime = MAX(_theEarliestTime, _fs_timeIntevalSince1970() - 365 * dayUnit);
    NSInteger day = (_fs_timeIntevalSince1970() - _firstTime) / dayUnit;
    NSString *text = [[NSString alloc] initWithFormat:@"%@%@%@",NSLocalizedString(@"Pass", nil),@((NSInteger)day),NSLocalizedString(@"day", nil)];
    
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectButton.frame = CGRectMake(0, 0, 140, 44);
    [_selectButton setTitle:text forState:UIControlStateNormal];
    _selectButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [_selectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_selectButton addTarget:self action:@selector(actionOfChoose) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setTitleView:_selectButton];
    
    UIBarButtonItem *item = [FSViewManager bbiWithSystemType:UIBarButtonSystemItemAdd target:self action:@selector(bbiAction)];
    self.navigationItem.rightBarButtonItem = item;
    
    _textSource = @[NSLocalizedString(@"One years later", nil),NSLocalizedString(@"Three years later", nil),NSLocalizedString(@"Five years later", nil)];
    
    _sr = _model.yearSR;
    _cb = _model.yearCB;
    [self expectDesignViews];
}

- (void)bestExpectHandleDatas{
    _fs_dispatch_global_main_queue_async(^{
        [FSBestAccountAPI srAndCbForTable:self.accountName months:12 completion:^(NSString *sr, NSString *cb,NSInteger year,NSInteger month) {
            self -> _sr = sr.doubleValue;
            self -> _cb = cb.doubleValue;
        }];
    }, ^{
        [self expectDesignViews];
    });
}

- (void)shakeEndActionFromShakeBase{
    [FSPublic shareAction:self view:_tableView];
}

- (void)doSomethingRepeatedly{
    [self expectDesignViews];
    
    __weak typeof(self) weakSelf = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf doSomethingRepeatedly];
    });
}

- (void)expectDesignViews{
    CGFloat days = (_fs_timeIntevalSince1970() - _firstTime) / 86400.0;
    CGFloat newCost = _newCost / 30.0;
    _dayMoney = (_sr - _cb - newCost) / days +  self.deltaMoney / 30;
    
    CGFloat assets = _model.ldzc + _model.fldzc;
    CGFloat debts = _model.ldfz + _model.fldfz;
    _jzc = assets - debts;
    
    CGFloat holdDays = 0;
    CGFloat holdDaysPower = 0;
    CGFloat cashHoldDays = 0;
    CGFloat cbPerday = _cb / days + newCost;
    if (_cb > 0) {
        holdDays = (assets + _addMoney - debts) / cbPerday;
        holdDaysPower = (_model.ldzc * 0.9 + _model.fldzc * 0.5 - _model.ldfz * 1.1 - _model.fldfz * 1.1) / cbPerday;
        cashHoldDays = (_model.ldzc * 0.9 + _addMoney) / cbPerday;
    }
    // 现金不需要减去负债，不然得出的值的参考意义不大
    
    NSString *holdDaysString = [self dayMonthYearForNumber:holdDays type:@(Days_Holddays * 12 / 365).stringValue];
    NSString *holdDaysPowerString = [self dayMonthYearForNumber:holdDaysPower type:@(Days_Holddays_Power * 12 / 365).stringValue];
    NSString *holdDaysCashString = [self dayMonthYearForNumber:cashHoldDays type:@(Days_Cashdays * 12 / 365).stringValue];
    
    NSString *rate = [[NSString alloc] initWithFormat:@"%.2f%%",((_sr - _cb) / MAX(_sr, 0.01)) * 100];
    NSArray *values = @[[self moneyFormat:_sr],[self moneyFormat:_cb],[self moneyFormat:_sr - _cb],rate,[self moneyFormat:_dayMoney],[self moneyFormat:_dayMoney * 30],[self moneyFormat:cbPerday],[self moneyFormat:cbPerday * 30],holdDaysString,holdDaysPowerString,holdDaysCashString];
    
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20 + 30 * values.count + 220)];
        _headView.backgroundColor = FS_GreenColor;
        NSArray *titles = @[NSLocalizedString(@"Start time", nil),NSLocalizedString(@"Current income", nil),NSLocalizedString(@"Current cost", nil),NSLocalizedString(@"Current profit", nil),NSLocalizedString(@"Profit ratio of sales", nil),NSLocalizedString(@"Profit per day", nil),NSLocalizedString(@"Profit per month", nil),NSLocalizedString(@"Cost per day", nil),NSLocalizedString(@"Cost per month", nil),NSLocalizedString(@"Asset can pay", nil),NSLocalizedString(@"Asset can pay(power)", nil),NSLocalizedString(@"Cash can pay", nil)];
        for (int x = 0; x < titles.count; x ++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10 + 30 * x, WIDTHFC, 30)];
            label.text = titles[x];
            label.textColor = [UIColor whiteColor];
            [_headView addSubview:label];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 3, label.top, self.view.bounds.size.width * 2 / 3 - 15, 30)];
            valueLabel.textAlignment = NSTextAlignmentRight;
            valueLabel.tag = TAG_LABEL + x - 1;
            valueLabel.text = (x == 0? nil:values[x - 1]);
            valueLabel.textColor = [UIColor whiteColor];
            [_headView addSubview:valueLabel];
            if (x == 0) {
                _startLabel = valueLabel;
                NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_firstTime];
                _startLabel.text = [FSDate stringWithDate:date formatter:nil];
            }
            if (x == 9) {
                valueLabel.textColor = (holdDays < Days_Holddays ? [UIColor yellowColor]:[UIColor whiteColor]);
            }
            if (x == 10) {
                valueLabel.textColor = (cashHoldDays < Days_Holddays_Power ? [UIColor yellowColor]:[UIColor whiteColor]);
            }
            if (x == 11) {
                valueLabel.textColor = (cashHoldDays < Days_Cashdays ? [UIColor yellowColor]:[UIColor whiteColor]);
            }
        }
        
        UILabel *zLabel = [FSViewManager labelWithFrame:CGRectMake(15, 20 + 30 * titles.count + FS_LineThickness, WIDTHFC - 15, 30) text:NSLocalizedString(@"Debt asset ratio change:", nil) textColor:[UIColor whiteColor] backColor:nil font:nil textAlignment:NSTextAlignmentLeft];
        [_headView addSubview:zLabel];
        _rateLabel = [FSViewManager labelWithFrame:CGRectMake(WIDTHFC - 100, zLabel.top, 85, 30) text:@"0.00%" textColor:[UIColor yellowColor] backColor:nil font:nil textAlignment:NSTextAlignmentRight];
        [_headView addSubview:_rateLabel];
        
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(10, _rateLabel.bottom + 10, WIDTHFC - 20, 36)];
        [_slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1;
        _slider.tintColor = [UIColor whiteColor];
        [_headView addSubview:_slider];
        
        NSArray *zTitles = @[NSLocalizedString(@"All assets", nil),NSLocalizedString(@"All liabilities", nil),NSLocalizedString(@"Repaying capability", nil)];
        for (int x = 0; x < 3; x ++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, _slider.bottom + 10 + 30 * x, WIDTHFC, 30)];
            label.text = zTitles[x];
            label.textColor = [UIColor whiteColor];
            [_headView addSubview:label];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, label.top, self.view.bounds.size.width - 15, 30)];
            valueLabel.textAlignment = NSTextAlignmentRight;
            valueLabel.tag = TAG_BUTTON + x;
            valueLabel.text = (x == 0?[self tenthousandForMoney:_jzc]:@"0.00");
            valueLabel.textColor = [UIColor whiteColor];
            [_headView addSubview:valueLabel];
        }
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableHeaderView = _headView;
        _tableView.tableFooterView = [UIView new];
        [self.view addSubview:_tableView];
        _tableView.showsVerticalScrollIndicator = NO;
        [self doSomethingRepeatedly];
    }else{
        for (int x = 0; x < values.count; x ++) {
            UILabel *label = [_headView viewWithTag:TAG_LABEL + x];
            label.text = values[x];
        }
        
        if (_hasFirst) {
            return;
        }else{
            _hasFirst = YES;
        }
        
        CGFloat jzc = _jzc + _addMoney;
        CGFloat debt = Key_Year_Many * 365 * _dayMoney;
        /*
         * debt不包含将要承担的利息，所以如果利率很高，就会不适用
         
         CGFloat debt = (_dayMoney / 2.0f) * DAYS_IN_A_MONTH * self.loanMonth / times - _debt;
         方法一：CGFloat debt = (_dayMoney / 2.0f) * DAYS_IN_A_MONTH * self.loanMonth / [FuData DEBXWithYearRate:self.loanRate monthes:self.loanMonth] - _debt;
         原理：在还款时限内，只一半的预期净收入用于偿还所有的债务和利息
         优点：看似留足了足够的边际
         缺点：平时不能做那么长的预测，特别是十多年。
         
         方法二：CGFloat debt = 6 * 365 * _dayMoney;
         原理：美元通胀率4.05%，人民币通胀率6%，物价每年复合上涨6.38%。
         格雷厄姆认为16倍市盈率是安全的最上边界，巴菲特打4折即6.4倍市盈率就是留有“足够的”安全边际
         优点：容易理解
         缺点：有点生硬，如果短期借款太多就会不太适用，因为把余钱全用来还债不太符合现实情况
         */
        
        UILabel *debtLabel = [_headView viewWithTag:TAG_BUTTON + 1];
        debtLabel.text = [self tenthousandForMoney:debt];
        
        CGFloat time = (debt / MAX(0.01, _dayMoney)) / 365;
        UILabel *payLabel = [_headView viewWithTag:TAG_BUTTON + 2];
        payLabel.text = [[NSString alloc] initWithFormat:@"%.2f%@",time,NSLocalizedString(@"year", nil)];
        if (time > 5.0) {
            payLabel.textColor = [UIColor yellowColor];
        }else{
            payLabel.textColor = [UIColor whiteColor];
        }
        
        UILabel *allLabel = [_headView viewWithTag:TAG_BUTTON];
        allLabel.text = [self tenthousandForMoney:jzc + debt];
        CGFloat rate = debt / MAX(0.01, (debt + jzc));
        _slider.value = rate;
        _rateLabel.text = [[NSString alloc] initWithFormat:@"%.2f%@",_slider.value * 100,@"%"];
        _rateLabel.textColor = (rate > 0.6)?[UIColor yellowColor]:[UIColor whiteColor];
        
        [_tableView reloadData];
        CGFloat rgb = 245/ 255.0;
        self.view.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1];
    }
}

- (void)sliderAction:(UISlider *)slider{
    if (slider.value == 1) {
        return;
    }
    CGFloat rate = slider.value;
    _rateLabel.text = [[NSString alloc] initWithFormat:@"%.2f%@",rate * 100,@"%"];
    
    CGFloat debt = _jzc * rate / (1 - rate);
    CGFloat allM = debt + _jzc;
    CGFloat payBack = debt / MAX(_dayMoney, 0.01);
    
    UIColor *yellowColor = [UIColor yellowColor];
    UIColor *whiteColor = [UIColor whiteColor];
    
    NSArray *texts = @[[[NSString alloc] initWithFormat:@"%@",[self tenthousandForMoney:allM]],[[NSString alloc] initWithFormat:@"%@",[self tenthousandForMoney:debt]],[[NSString alloc] initWithFormat:@"%@",[FSKitDuty dayMonthYearForNumber:payBack]]];
    for (int x = 0; x < 3; x ++) {
        UILabel *label = [_headView viewWithTag:TAG_BUTTON + x];
        label.text = texts[x];
        
        if (x == 2) {
            BOOL overPay = payBack > Key_Year_Many * 365;
            label.textColor = overPay?yellowColor:whiteColor;
            _rateLabel.textColor = overPay?yellowColor:whiteColor;
        }
    }
}

- (void)bbiAction{
    WEAKSELF(this);
    [FSUIKit alertInput:3 controller:self title:NSLocalizedString(@"Increase and stock", nil) message:NSLocalizedString(@"Unit:ten thousand", nil) ok:@"OK" handler:^(UIAlertController *bAlert, UIAlertAction *action) {
        UITextField *textField = bAlert.textFields.firstObject;
        UITextField *addTF = bAlert.textFields[1];
        UITextField *costTF = bAlert.textFields[2];
        this.deltaMoney = [textField.text doubleValue] * 10000;
        this.addMoney = [addTF.text doubleValue] * 10000;
        this.newCost = [costTF.text doubleValue] * 10000;
        this.hasFirst = NO;
        [this expectDesignViews];
    } cancel:NSLocalizedString(@"Cancel", nil) handler:nil textFieldConifg:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        if (textField.tag == 1) {
            textField.placeholder = NSLocalizedString(@"Stock(unit:ten thousand)", nil);
        }else if (textField.tag == 0){
            textField.placeholder = NSLocalizedString(@"Increase pey month(unit:ten thousand)", nil);
        }else if (textField.tag == 2){
            textField.placeholder = @"每个月的成本增量（单位：万）";
        }
    } completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.textSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.textLabel.text = _textSource[indexPath.row];
    if (indexPath.row <= 2) {
        NSInteger number = 365 * (1 + indexPath.row * 2);
        cell.detailTextLabel.text = [self tenthousandForMoney:_addMoney + _jzc + number * _dayMoney];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tenthousandForMoney:(CGFloat)money{
    if (money < 10000) {
        return [[NSString alloc] initWithFormat:@"%.2f",money];
    }else{
        return [[NSString alloc] initWithFormat:@"%.2f万",money / 10000.0];
    }
}

- (NSString *)moneyFormat:(CGFloat)je{
    return [FSKit bankStyleDataThree:@(je)];
}

- (NSString *)dayMonthYearForNumber:(CGFloat)number type:(NSString *)insert{
    if (number > 365) {
        return [[NSString alloc] initWithFormat:@"%.2f%@%@",number / 365.0,insert,NSLocalizedString(@"year", nil)];
    }else if (number > 30){
        return [[NSString alloc] initWithFormat:@"%.2f%@%@",number / 30,insert,NSLocalizedString(@"month", nil)];
    }else{
        return [[NSString alloc] initWithFormat:@"%.2f%@%@",number,insert,NSLocalizedString(@"day", nil)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
