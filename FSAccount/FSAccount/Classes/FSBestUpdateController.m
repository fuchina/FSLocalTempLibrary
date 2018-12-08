//
//  FSBestUpdateController.m
//  FSKit_Example
//
//  Created by Guazi on 2018/6/27.
//  Copyright © 2018年 topchuan. All rights reserved.
//

#import "FSBestUpdateController.h"
#import <FSTuple.h>
#import <FSUIKit.h>
#import "FSBestAccountAPI.h"
#import "FSHalfView.h"
#import "FSMacro.h"

@interface FSBestUpdateController ()

@property (nonatomic,strong) FSHalfView     *halfView;
@property (nonatomic,strong) NSArray        *halfs;

@end

@implementation FSBestUpdateController{
    CGFloat     _ar_track;
    CGFloat     _br_track;
    CGFloat     _ar_bank;
    CGFloat     _br_bank;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateHandleDatas];
}

- (void)updateHandleDatas{
    CGFloat rgb = 238 / 255.0;
    self.view.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1];

    __block NSArray *values;
    __block UIColor *arColor = FS_TextColor_Dark;
    __block UIColor *brColor = FS_TextColor_Dark;
    _fs_dispatch_global_main_queue_async(^{
        NSString *time = [FSKit ymdhsByTimeIntervalString:self ->_model.tm];
        NSString *p = @"增加";
        NSString *m = @"减少";
        NSInteger ap = [self ->_model.pa integerValue];
        if (!(ap == 1 || ap == 2)) {
            _fs_dispatch_main_queue_async(^{
                NSString *show = [[NSString alloc] initWithFormat:@"%@ 科目记账错误",self ->_model.aType];
                [FSUIKit showAlertWithMessage:show controller:self];
            });
            return;
        }
        CGFloat je_bank = self ->_model.je.doubleValue;
        self -> _ar_bank = self ->_model.ar.doubleValue;
        if (ap == 1) {
            self->_ar_track = [FSBestAccountAPI trackMinusedForTable:self.table lk:self ->_model.tm isAJ:YES];
            CGFloat delta = fabs((je_bank - self ->_ar_track) - self -> _ar_bank);
            if (delta > 1) {
                arColor = APPCOLOR;
            }
        }
        NSInteger bp = [self ->_model.pb integerValue];
        if (!(bp == 1 || bp == 2)) {
            _fs_dispatch_main_queue_async(^{
                NSString *show = [[NSString alloc] initWithFormat:@"%@ 科目记账错误",self ->_model.bType];
                [FSUIKit showAlertWithMessage:show controller:self];
            });
            return;
        }
        self->_br_bank = self ->_model.br.doubleValue;
        if (bp == 1) {
            self->_br_track = [FSBestAccountAPI trackMinusedForTable:self.table lk:self ->_model.tm isAJ:NO];
            CGFloat delta = fabs((je_bank - self->_br_track) - self->_br_bank);
            if (delta > 1) {
                brColor = APPCOLOR;
            }
        }
        
        NSString *af = ap == 1?p:m;
        NSString *bf = bp == 1?p:m;
        NSString *aShow = [[NSString alloc] initWithFormat:@"%@%@",self ->_model.aType,af];
        NSString *bShow = [[NSString alloc] initWithFormat:@"%@%@",self ->_model.bType,bf];
        UIColor *aColor = ap == 1?FS_GreenColor:APPCOLOR;
        UIColor *bColor = bp == 1?FS_GreenColor:APPCOLOR;
        
        NSAttributedString *aAttr = [FSKit attributedStringFor:aShow strings:@[af] color:aColor fontStrings:nil font:nil];
        NSAttributedString *bAttr = [FSKit attributedStringFor:bShow strings:@[bf] color:bColor fontStrings:nil font:nil];
        
        NSString *je = [[NSString alloc] initWithFormat:@"%.2f",je_bank];
        NSString *ar = [[NSString alloc] initWithFormat:@"%.2f",self -> _ar_bank];
        NSString *br = [[NSString alloc] initWithFormat:@"%.2f",self -> _br_bank];
        values = @[
                            [Tuple2 v1:time v2:je],
                            [Tuple2 v1:aAttr v2:ar],
                            [Tuple2 v1:bAttr v2:br],
                            [Tuple2 v1:@"备注" v2:self ->_model.bz],
                            ];
    }, ^{
        for (int x = 0; x < values.count; x ++) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.backgroundColor = [UIColor whiteColor];
            cell.tag = 1000 + x;
            cell.frame = CGRectMake(0, 74 + 51 * x, UIScreen.mainScreen.bounds.size.width, 50);
            cell.accessoryType = x == 0? UITableViewCellAccessoryNone: UITableViewCellAccessoryDisclosureIndicator;
            [self.view addSubview:cell];
            cell.textLabel.width = WIDTHFC - 30;
            cell.textLabel.textColor = FS_TextColor_Normal;cell.detailTextLabel.textColor = FS_TextColor_Dark;
            cell.textLabel.font = [UIFont systemFontOfSize:13];cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
            
            Tuple2 *t = values[x];
            if (x == 0 || x == 3) {
                cell.textLabel.text = t._1;cell.detailTextLabel.text = t._2;
            }else if (x == 1 || x == 2){
                cell.textLabel.attributedText = t._1;cell.detailTextLabel.text = t._2;
                if (x == 1) {
                    cell.detailTextLabel.textColor = arColor;
                }else{
                    cell.detailTextLabel.textColor = brColor;
                }
            }
            
            if (x) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
                [cell addGestureRecognizer:tap];
            }
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.backgroundColor = FSAPPCOLOR;
        button.frame = CGRectMake(10, 290, WIDTHFC - 20, 45);
        button.layer.cornerRadius = 3;
        [button setTitle:@"更改" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    });
}

- (void)tapClick:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag - 1000;
    if (tag == 1) {
        [self handleA];
    }else if (tag == 2){
        [self handleB];
    }else if (tag == 3) {
        [self updateBZ];
    }
}

- (void)handleA{
    NSInteger ap = [_model.pa integerValue];
    if (ap == 1) {
        CGFloat je = _model.je.doubleValue;
        CGFloat delta = fabs(je - _ar_track - _ar_bank);
        if (delta > 1) {
            NSString *show = [[NSString alloc] initWithFormat:@"%@ 科目记录已减少%.2f元，与余额%.2f元比,存在%.2f元误差",_model.aType,_ar_track,_ar_bank,delta];
            [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:@"更正提示" message:show actionTitles:@[@"更正"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
                NSString *v = [[NSString alloc] initWithFormat:@"%.6f",je - self -> _ar_track];
                NSString *vs = [[NSString alloc] initWithFormat:@"%.2f",je - self -> _ar_track];
                self -> _model.ar = v;
                self -> _model.restA = vs;
                UITableViewCell *cell = [self.view viewWithTag:1000 + 1];
                cell.detailTextLabel.text = vs;cell.detailTextLabel.textColor = FS_TextColor_Dark;
                self -> _ar_bank = je - self -> _ar_track;
            }];
            return;
        }        
    }
    if (!(_isAJ == 1 || _isAJ == 3)) {
        return;
    }
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:@"可以更换同一属性下的其他科目" actionTitles:@[@"选择"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        FSBestSubjectModel *subject = [FSBestAccountAPI subjectForValue:self ->_model.aj table:self.table];
        NSArray *allBes = [FSBestAccountAPI subSubjectForType:subject.be forTable:self.table];
        __weak typeof(self)this = self;
        [self showHalfView:allBes callback:^(FSBestSubjectModel *model) {
            __strong typeof(this)self = this;
            self -> _model.aj = model.vl;
            self -> _model.aType = model.nm;
            self -> _model.atColor = APPCOLOR;
            NSInteger pa = [self -> _model.pa integerValue];
            NSString *pm = pa == 1?@"增加":@"减少";
            UIColor  *color = pa == 1?FS_GreenColor:APPCOLOR;
            NSString *aShow = [[NSString alloc] initWithFormat:@"%@%@",model.nm,pm];
            NSAttributedString *attr = [FSKit attributedStringFor:aShow strings:@[pm] color:color fontStrings:nil font:nil];
            UITableViewCell *cell = [self.view viewWithTag:1000 + 1];
            cell.textLabel.attributedText = attr;
        }];
    }];
}

- (void)handleB{
    NSInteger bp = [_model.pb integerValue];
    if (bp == 1) {
        CGFloat je = _model.je.doubleValue;
        CGFloat delta = fabs(je - _br_track - _br_bank);
        if (delta > 1) {
            NSString *show = [[NSString alloc] initWithFormat:@"%@ 科目记录已减少%.2f元，与余额%.2f元比,存在%.2f元误差",_model.bType,_br_track,_br_bank,delta];
            [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:@"更正提示" message:show actionTitles:@[@"更正"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
                NSString *v = [[NSString alloc] initWithFormat:@"%.6f",je - self -> _br_track];
                NSString *vs = [[NSString alloc] initWithFormat:@"%.2f",je - self -> _br_track];
                self -> _model.br = v;
                self -> _model.restB = vs;
                UITableViewCell *cell = [self.view viewWithTag:1000 + 2];
                cell.detailTextLabel.text = vs;cell.detailTextLabel.textColor = FS_TextColor_Dark;
                self -> _br_bank = je - self -> _br_track;
            }];
            return;
        }
    }
    if (!(_isAJ == 2 || _isAJ == 3)) {
        return;
    }
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:@"可以更换同一属性下的其他科目" actionTitles:@[@"选择"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        FSBestSubjectModel *subject = [FSBestAccountAPI subjectForValue:self ->_model.bj table:self.table];
        NSArray *allBes = [FSBestAccountAPI subSubjectForType:subject.be forTable:self.table];
        __weak typeof(self)this = self;
        [self showHalfView:allBes callback:^(FSBestSubjectModel *model) {
            __strong typeof(this)self = this;
            self -> _model.bj = model.vl;
            self -> _model.bType = model.nm;
            self -> _model.btColor = APPCOLOR;
            NSInteger pb = [self -> _model.pb integerValue];
            NSString *pm = pb == 1?@"增加":@"减少";
            UIColor  *color = pb == 1?FS_GreenColor:APPCOLOR;
            NSString *aShow = [[NSString alloc] initWithFormat:@"%@%@",model.nm,pm];
            NSAttributedString *attr = [FSKit attributedStringFor:aShow strings:@[pm] color:color fontStrings:nil font:nil];
            UITableViewCell *cell = [self.view viewWithTag:1000 + 2];
            cell.textLabel.attributedText = attr;
        }];
    }];
}

- (void)showHalfView:(NSArray *)bes callback:(void (^)(FSBestSubjectModel *model))callback{
    self.halfs = bes;
    
    WEAKSELF(this);
    if (!self.halfView) {
        self.halfView = [[FSHalfView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64)];
        self.halfView.dataSource = bes;
        [self.view addSubview:self.halfView];
        [_halfView setConfigCell:^(UITableView *bTB, NSIndexPath *bIP,UITableViewCell *bCell) {
            FSBestSubjectModel *model = [this.halfs objectAtIndex:bIP.row];
            bCell.textLabel.text = model.nm;
        }];
    }else{
        self.halfView.dataSource = bes;
        [self.halfView showHalfView:YES];
        [self.view bringSubviewToFront:self.halfView];
    }
    [_halfView setSelectCell:^(UITableView *bTB, NSIndexPath *bIP) {
        FSBestSubjectModel *t = [this.halfs objectAtIndex:bIP.row];
        if (callback) {
            callback(t);
        }
    }];
}

- (void)updateBZ{
    __weak typeof(self)this = self;
    [FSUIKit alertInput:1 controller:self title:@"更改备注" message:_model.bz ok:@"更改" handler:^(UIAlertController *bAlert, UIAlertAction *action) {
        UITextField *tf = bAlert.textFields.firstObject;
        NSString *text = tf.text;
        if (!_fs_isValidateString(text)) {
            [FSToast show:@"请输入内容"];
            return;
        }
        __strong typeof(this)self = this;
        self->_model.bz = text;
        self -> _model.colorBZ = [FSKit attributedStringFor:text strings:@[text] color:FS_TextColor_Normal fontStrings:nil font:nil];
        UITableViewCell *cell = [self.view viewWithTag:1000 + 3];
        cell.detailTextLabel.text = text;
    } cancel:@"取消" handler:nil textFieldConifg:^(UITextField *textField) {
        textField.placeholder = @"请输入新的备注";
    } completion:nil];
}

- (void)buttonClick{
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:nil actionTitles:@[@"确定修改"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        NSString *error = [FSBestAccountAPI updateModel:self->_model table:self.table];
        if (error) {
            [FSUIKit showAlertWithMessage:error controller:self];
        }else{
            if (self.updatedCallback) {
                self.updatedCallback();
            }
        }
    }];
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
