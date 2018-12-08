//
//  FSFMUpdateController.m
//  myhome
//
//  Created by FudonFuchina on 2017/5/5.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSABUpdateController.h"
#import "FSHalfView.h"
#import "FATool.h"
#import "FSDBTool.h"
#import "FSABOneminusController.h"
#import <FSUIKit.h>

@interface FSABUpdateController ()

@property (nonatomic,strong) PHTextView     *bzTV;
@property (nonatomic,strong) FSHalfView     *halfView;
@property (nonatomic,strong) NSArray        *list;
@property (nonatomic,copy) NSString         *atype;
@property (nonatomic,copy) NSString         *btype;
@property (nonatomic,strong) FSTapCell      *cell;

@end

@implementation FSABUpdateController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self updateDesignViews];
}

- (void)updateDesignViews{
    [FSTrack event:_UMeng_Event_acc_change_page];
    _atype = _model.atype;
    _btype = _model.btype;
    
    UILabel *timeLabel = [FSViewManager suojinLabelWithSpace:15 frame:CGRectMake(0, 10, WIDTHFC, 44) textColor:FS_TextColor_Dark text:[FSKit ymdhsByTimeInterval:[_model.time doubleValue]]];
    timeLabel.font = FONTFC(14);
    timeLabel.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:timeLabel];
    UILabel *money = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTHFC - 10, 44)];
    money.textAlignment = NSTextAlignmentRight;
    money.font = [UIFont boldSystemFontOfSize:16];
    money.text = [[NSString alloc] initWithFormat:@"%.2f",[_model.je doubleValue]];
    [timeLabel addSubview:money];
    
    __weak typeof(self)this = self;
    _cell = [FSViewManager tapCellWithText:NSLocalizedString(@"Subject", nil) textColor:FS_TextColor_Normal font:FONTFC(15) detailText:[FATool noticeForType:_isA?_model.atype:_model.btype] detailColor:nil detailFont:FONTFC(15) block:^(FSTapCell *bCell) {
        [this showHalfView];
    }];
    _cell.backgroundColor = [UIColor whiteColor];
    _cell.top = timeLabel.bottom + 1;
    [self.scrollView addSubview:_cell];
    
    _bzTV = [FSViewManager phTextViewWithFrame:CGRectMake(10, _cell.bottom + 10, WIDTHFC - 20, 100) placeholder:@"更改备注"];
    _bzTV.contentText = _model.bz;
    [self.scrollView addSubview:_bzTV];
    
    UIButton *btn = [FSViewManager submitButtonWithTop:_bzTV.bottom + 20 tag:0 target:self selector:@selector(submitAction)];
    [self.scrollView addSubview:btn];
    [self addKeyboardNotificationWithBaseOn:btn.bottom + 30];
}

- (void)submitAction{
    if ([self.atype isEqualToString:self.model.atype] && [self.btype isEqualToString:self.model.btype] && [self.bzTV.text isEqualToString:self.model.bz]) {
        [FSToast show:NSLocalizedString(@"No change", nil)];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([FSKit cleanString:self.bzTV.text].length == 0) {
        [FSToast show:NSLocalizedString(@"Please Input Note", nil)];
        return;
    }
    
    NSArray *types = @[self.atype,self.btype];
    Tuple2 *t = [FSDBTool returnErrorStringIfOccurrError:types];
    if (![t._1 boolValue]) {
        [FSUIKit showAlertWithMessage:t._2 controller:self];
        return;
    }
    
    [FSUIKit alert:UIAlertControllerStyleAlert controller:self title:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Ensure that updates are more realistic", nil) actionTitles:@[NSLocalizedString(@"Update", nil)] styles:@[@(UIAlertActionStyleDestructive)] handler:^(UIAlertAction *action) {
        [self handleEvent:self->_isA?self.atype:self.btype];
    }];
}

- (void)handleEvent:(NSString *)toType{
    BOOL same = [self sameMoney];
    if (same && [toType hasSuffix:_ED_KEY] && [_isA?_model.atype:_model.btype hasSuffix:_ING_KEY]) {
        NSString *subject = [toType substringToIndex:2];
        [FSDBTool sumSubject:subject table:self.accountName completion:^(CGFloat value) {
            CGFloat je = [self->_model.je doubleValue];
            if (value >= je) {
                NSMutableString *message = [[NSMutableString alloc] initWithFormat:@"%@,%@",[FATool noticeForType:toType],[FATool noticeForType:self->_isA?self->_model.btype:self->_model.atype]];
                FSABOneminusController *selectController = [[FSABOneminusController alloc] init];
                selectController.accountName = self.accountName;
                selectController.je = self->_model.je;
                selectController.bz = self->_model.bz;
                selectController.time = self->_model.time;
                selectController.message = message;
                selectController.type = subject;
                [self.navigationController pushViewController:selectController animated:YES];
                __weak typeof(self)this = self;
                selectController.selectBlock = ^ (FSABOneminusController *bController,NSArray<FSABModel *> *bEdArray,NSArray *bTracks){
                    NSString *error = [FSDBTool handleEDArray:bEdArray account:this.accountName];
                    if (error) {
                        [FSUIKit showAlertWithMessage:error controller:self];
                        return;
                    }
                    NSString *trackErr = [FSDBTool handleTracks:bTracks];
                    if (trackErr) {
                        [FSUIKit showAlertWithMessage:trackErr controller:self];
                        return;
                    }
                    NSString *sql = nil;
                    if (self->_isA) {
                        sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET atype = '%@',arest = '0.00',bz = '%@' WHERE aid = %@;",self->_accountName,toType,self.bzTV.text,self.model.aid];
                    }else{
                        sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET btype = '%@',brest = '0.00',bz = '%@' WHERE aid = %@;",self->_accountName,toType,self.bzTV.text,self.model.aid];
                    }
                    if (self.callBack) {
                        NSAssert(sql != nil, @"ddd");
                        self.callBack(self, sql);
                    }
                };
            }else{
                [FSUIKit showAlertWithMessage:NSLocalizedString(@"There is not enough money to be reduced", nil) controller:self];
            }
        }];
    }else{
        NSString *sql = nil;
        if (_isA) {
            sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET atype = '%@',bz = '%@' WHERE aid = %@;",_accountName,toType,self.bzTV.text,self.model.aid];
        }else{
            sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET btype = '%@',bz = '%@' WHERE aid = %@;",_accountName,toType,self.bzTV.text,self.model.aid];
        }
        if (self.callBack) {
            NSAssert(sql != nil, @"ddd");
            self.callBack(self, sql);
        }
    }
}

/*
 账本修改逻辑:
     1.被修改科目是减少，说明肯定减少过其他数据，就不能改成增加，只能继续改成其他科目的减少；
         // 原来减少的是现金，现在改成减少应收，那么应收还得减少，而原来减少的现金又无法补回，所以有逻辑矛盾，不能执行
 
     2.被修改科目是增加：【只有这种情况可以修改】
         没有被减少过，可以改成其他科目的增加，也可以改成其他科目的减少；
 
         被减少过，可以改成其他科目的增加；
             // 会导致被改科目为负值
 */
- (void)showHalfView{
    [self.view endEditing:YES];
    BOOL same = [self sameMoney];
    if (!same) {
        [FSUIKit showAlertWithMessage:NSLocalizedString(@"Modification without support", nil) controller:self];
        return;
    }

    if (!self.list) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[FATool debtors]];
        [array addObjectsFromArray:[FATool creditors]];
        NSMutableArray *needs = [[NSMutableArray alloc] init];
        for (NSString *subject in array) {
            Tuple2 *t = [FSDBTool returnErrorStringIfOccurrError:@[subject,_isA?_model.btype:_model.atype]];
            BOOL can = [t._1 boolValue];
            if (can) {
                [needs addObject:subject];
            }
        }
        self.list = needs;
        
//        //.科目是减少的情况
//        NSString *subject = _isA?_model.atype:_model.btype;
//        if ([subject hasSuffix:_ED_KEY]) {
//            NSMutableArray *reduces = [[NSMutableArray alloc] init];
//            for (NSString *sub in needs) {
//                if ([sub hasSuffix:_ED_KEY]) {
//                    [reduces addObject:sub];
//                }
//            }
//            self.list = reduces;
//        }else if ([subject hasSuffix:_ING_KEY]){    // 科目是增加的情况
//            BOOL same = [self sameMoney];
//            if (same) {       // 没减少过
//                self.list = needs;
//            }else{            // 被减少过
//                NSMutableArray *adds = [[NSMutableArray alloc] init];
//                for (NSString *sub in needs) {
//                    if ([sub hasSuffix:_ING_KEY]) {
//                        [adds addObject:sub];
//                    }
//                }
//                self.list = adds;
//            }
//        }
    }
    
    if (!self.halfView) {
        WEAKSELF(this);
        self.halfView = [[FSHalfView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64)];
        self.halfView.dataSource = self.list;
        [self.view addSubview:self.halfView];
        [_halfView setConfigCell:^(UITableView *bTB, NSIndexPath *bIP,UITableViewCell *bCell) {
            bCell.textLabel.text = [FATool noticeForType:this.list[bIP.row]];
        }];
        [_halfView setSelectCell:^(UITableView *bTB, NSIndexPath *bIP) {
            NSString *str = this.list[bIP.row];
            this.cell.detailTextLabel.text = [FATool noticeForType:str];
            if (this.isA) {
                this.atype = str;
            }else{
                this.btype = str;
            }
        }];
    }else{
        self.halfView.dataSource = self.list;
        [self.halfView showHalfView:YES];
    }
}

- (BOOL)sameMoney{
    NSString *rest = nil;
    if (_isA) {
        rest = [[NSString alloc] initWithFormat:@"%.2f",[_model.arest doubleValue]];
    }else{
        rest = [[NSString alloc] initWithFormat:@"%.2f",[_model.brest doubleValue]];
    }
    NSString *je = [[NSString alloc] initWithFormat:@"%.2f",[_model.je doubleValue]];
    BOOL same = [rest isEqualToString:je];
    return same;
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
