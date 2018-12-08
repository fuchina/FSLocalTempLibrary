//
//  FSBestAddAccountController.m
//  myhome
//
//  Created by FudonFuchina on 2018/4/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestAddAccountController.h"
#import "FSHalfView.h"
#import "FSDBJeView.h"
#import "FSTuple.h"
#import "FSAccountRecordController.h"
#import "FSBestAccountAPI.h"
#import "FSBestTwoMinusController.h"
#import "FSBestOneMinusController.h"
#import "FSUIKit.h"
#import "FSAddBestSubjectController.h"
#import "UIViewController+BackButtonHandler.h"
#import "FuSoft.h"
#import "FSMacro.h"

@interface FSBestAddAccountController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) FSDBJeView                 *jeView;
@property (nonatomic,strong) FSBestSubjectModel         *aSubject;
@property (nonatomic,strong) FSBestSubjectModel         *bSubject;
@property (nonatomic,strong) NSDate                     *date;
@property (nonatomic,strong) FSHalfView                 *halfView;
@property (nonatomic,strong) UILabel                    *label;
@property (nonatomic,strong) NSArray                    *list;
@property (nonatomic,strong) NSArray                    *halfs;
@property (nonatomic,strong) UISegmentedControl         *control;

@end

@implementation FSBestAddAccountController{
    NSArray                 *_subjects;
    UITableView             *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _subjects = [FSBestAccountAPI accountantClass];
    [self companyAddDesignViews];
}

- (void)bjClick:(UIBarButtonItem *)bbi{
    [self.view endEditing:YES];
    WEAKSELF(this);
    __weak UIBarButtonItem *weakBBI = bbi;
    FSAccountRecordController *saveViewController = [[FSAccountRecordController alloc] init];
    [this.navigationController pushViewController:saveViewController animated:YES];
    saveViewController.block = ^(FSBaseController *bVC, NSDate *date) {
        this.date = date;
        weakBBI.title = [[FSKit ymdhsByTimeInterval:[date timeIntervalSince1970]] substringToIndex:10];
        [bVC.navigationController popViewControllerAnimated:YES];
    };
}

- (UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, WIDTHFC, 40)];
        _label.backgroundColor = FS_GreenColor;
        _label.font = [UIFont systemFontOfSize:14];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_label];
        
        [UIView animateWithDuration:.3 animations:^{
            self->_label.top = 64;
            self->_tableView.top = 104;
        } completion:^(BOOL finished) {
            self->_tableView.height = HEIGHTFC - 104;
        }];
    }
    return _label;
}

- (void)companyAddDesignViews{
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"日期" style:UIBarButtonItemStylePlain target:self action:@selector(bjClick:)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    _control = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Plus", nil),NSLocalizedString(@"Minus", nil)]];
    _control.selectedSegmentIndex = 0;
    _control.frame = CGRectMake(0, 4, 100, 36);
    [_control addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _control;
    
    _jeView = [[FSDBJeView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, 100)];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 54;
    _tableView.tableHeaderView = _jeView;
    _tableView.tableFooterView = [UIView new];
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    self.jeView.bzTF.textField.returnKeyType = UIReturnKeyDone;
    self.jeView.bzTF.textField.delegate = self;
}

- (void)reloadData{
    if (self.halfView) {
        [self.halfView showHalfView:NO];
    }
    BOOL isp = _control.selectedSegmentIndex == 0;
    NSArray *main = [FSBestAccountAPI accountantClass];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    if (self.aSubject) {
        NSInteger jd = [self.aSubject.jd integerValue];
        NSInteger fx = self.aSubject.isp;
        for (Tuple3 *t in main) {
            NSInteger jdm = [t._3 integerValue];
            if (jd == 1) {          // 资产或成本
                if (fx == 1) {      // 增加，资产或成本减少，其他增加
                    if (isp) {
                        if (jdm == 2) {
                            [list addObject:t];
                        }
                    }else{
                        if (jdm == 1) {
                            [list addObject:t];
                        }
                    }
                }else if (fx == 2){ // 减少，资产或成本增加，其他减少
                    if (isp) {
                        if (jdm == 1) {
                            [list addObject:t];
                        }
                    }else{
                        if (jdm == 2) {
                            [list addObject:t];
                        }
                    }
                }
            }else if (jd == 2){     // 负债或收入
                if (fx == 1) {      // 增加，负债或收入减少，其他增加
                    if (isp) {
                        if (jdm == 1) {
                            [list addObject:t];
                        }
                    }else{
                        if (jdm == 2) {
                            [list addObject:t];
                        }
                    }
                }else if (fx == 2){ // 减少，负债或收入增加，其他减少
                    if (isp) {
                        if (jdm == 2) {
                            [list addObject:t];
                        }
                    }else{
                        if (jdm == 1) {
                            [list addObject:t];
                        }
                    }
                }
            }
        }
    }
    
    NSArray *value = nil;
    if (!_fs_isValidateArray(list)) {
        value = main;
    }else{
        value = list;
    }
    if (value != _subjects) {
        _subjects = value;
        [_tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _subjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"c";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Tuple3 *t = _subjects[indexPath.row];
    cell.textLabel.text = t._1;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *je = self.jeView.jeTF.textField.text;
    if (!_fs_isPureFloat(je)) {
        [FSToast show:@"请输入正确的金额"];
        [self.jeView.jeTF.textField becomeFirstResponder];
        return;
    }
    CGFloat cash = [je doubleValue];
    if (cash < 0.01) {
        [FSToast show:@"金额不能小于1分"];
        [self.jeView.jeTF.textField becomeFirstResponder];
        return;
    }
    NSString *bz = [FSKit stringDeleteNewLineAndWhiteSpace:self.jeView.bzTF.textField.text];
    if (!_fs_isValidateString(bz)) {
        [FSToast show:@"请输入正确的备注"];
        [self.jeView.bzTF.textField becomeFirstResponder];
        return;
    }
    [self showHalfView:indexPath.row];
}

- (void)addSubject:(NSInteger)index{
    FSAddBestSubjectController *addSubject = [[FSAddBestSubjectController alloc] init];
    addSubject.table = self.accountName;
    addSubject.index = index;
    [self.navigationController pushViewController:addSubject animated:YES];
    __weak typeof(self)this = self;
    addSubject.addSubjectSuccess = ^(FSAddBestSubjectController *c) {
        [c.navigationController popToViewController:this animated:YES];
    };
}

- (void)showHalfView:(NSInteger)index{
    [self.view endEditing:YES];
    if (index > _subjects.count) {
        return;
    }
    // self.list每次都重新获取，这样保证self.aSubject与self.bSubject不会取到同一个model
    self.list = [FSBestAccountAPI allSubjectsForTable:self.accountName];
    
    Tuple3 *t = _subjects[index];
    NSNumber *key = t._2;
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    for (FSBestSubjectModel *m in self.list) {
        if ([key integerValue] == [m.be integerValue]) {
            [dataSource addObject:m];
        }
    }
    
    if (dataSource.count == 0) {
        NSString *show = @"该目录下还没有科目，快去增加科目吧";
        [FSUIKit alert:UIAlertControllerStyleAlert controller:self title:t._1 message:show actionTitles:@[@"增加"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
            [self addSubject:index];
        }];
        return;
    }
    self.halfs = dataSource;
    
    if (!self.halfView) {
        WEAKSELF(this);
        self.halfView = [[FSHalfView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64)];
        self.halfView.dataSource = dataSource;
        [self.view addSubview:self.halfView];
        [_halfView setConfigCell:^(UITableView *bTB, NSIndexPath *bIP,UITableViewCell *bCell) {
            FSBestSubjectModel *model = [this.halfs objectAtIndex:bIP.row];
            bCell.textLabel.text = model.nm;
        }];
        [_halfView setSelectCell:^(UITableView *bTB, NSIndexPath *bIP) {
            FSBestSubjectModel *t = [this.halfs objectAtIndex:bIP.row];
            BOOL isAdd = (this.control.selectedSegmentIndex == 0);
            if (this.aSubject) {
                this.bSubject = t;
                this.bSubject.isp = 2 - isAdd;
            }else{
                this.aSubject = t;
                this.aSubject.isp = 2 - isAdd;
                NSString *show = [[NSString alloc] initWithFormat:@"'%@' %@，还需选择一个科目",this.aSubject.nm,this.aSubject.isp == 1?@"增加":@"减少"];
                this.label.text = show;
                this.control.selectedSegmentIndex = 1;
                [this reloadData];
            }
            
            if (this.aSubject && this.bSubject) {
                [this handleAddAData];
            }
        }];
    }else{
        self.halfView.dataSource = dataSource;
        [self.halfView showHalfView:YES];
        [self.view bringSubviewToFront:self.halfView];
    }
}

- (void)handleAddAData{
    NSString *add = @"增加";
    NSString *minus = @"减少";
    NSString *message = [[NSString alloc] initWithFormat:@"%@ %@,%@ %@",self.aSubject.nm,self.aSubject.isp == 1?add:minus,self.bSubject.nm,self.bSubject.isp == 1?add:minus];
    self.label.text = message;
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:self.jeView.bzTF.textField.text message:message actionTitles:@[@"确定"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        NSInteger minusCount = 2 - (self.aSubject.isp == 1?1:0) - (self.bSubject.isp == 1?1:0);
        if (minusCount == 2) {
            FSBestTwoMinusController *two = [[FSBestTwoMinusController alloc] init];
            two.table = self.accountName;
            two.subjects = @[self.aSubject,self.bSubject];
            two.je = self.jeView.jeTF.textField.text;
            two.bz = self.jeView.bzTF.textField.text;
            [self.navigationController pushViewController:two animated:YES];
            __weak typeof(self)this = self;
            two.completion = ^(FSBestTwoMinusController *bController, Tuple2 *bEdArray) {
                [this handleReuslt:bEdArray];
            };
        }else if (minusCount == 1){
            FSBestOneMinusController *one = [[FSBestOneMinusController alloc] init];
            one.je = self.jeView.jeTF.textField.text;
            one.subject = self.aSubject.isp == 1?self.bSubject:self.aSubject;
            one.table = self.accountName;
            [self.navigationController pushViewController:one animated:YES];
            __weak typeof(self)this = self;
            one.completion = ^(FSBestOneMinusController *bController, NSArray *bEdArray) {
                [this handleReuslt:[Tuple2 v1:bEdArray v2:nil]];
            };
        }else{
            [self handleReuslt:nil];
        }
    } cancelTitle:@"取消" cancel:^(UIAlertAction *action) {
        [self reSelected];
    } completion:nil];
}

- (void)reSelected{
    self.aSubject = nil;
    self.bSubject = nil;
    self.label.text = @"重新选择2个科目";
    [self reloadData];
}

- (void)handleReuslt:(Tuple2 *)beMinused{    
    NSString *error = [FSBestAccountAPI versatileAddAccount:self.accountName je:self.jeView.jeTF.textField.text bz:self.jeView.bzTF.textField.text date:self.date aSubject:self.aSubject bSubject:self.bSubject aMinused:beMinused._1 bMinused:beMinused._2 controller:self inBlock:^(void (^callback)(void)) {
        NSString *message = @"将本次记录记入模板中，方便以后从'模板记'中快速增记本类记账";
        [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:@"记账成功!" message:message actionTitles:@[@"存入模板"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
            callback();
            [self execFinished];
        } cancelTitle:@"取消" cancel:^(UIAlertAction *action) {
            [self execFinished];
        } completion:nil];
    }];
    
    if (error) {
        [self reSelected];
        [FSUIKit showAlertWithMessage:error controller:self];
    }
}

- (void)execFinished{
    if (self.addSuccess) {
        self.addSuccess(self);
    }else{
        [FSKit popToController:@"FSBestAccountController" navigationController:self.navigationController animated:YES];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        [self.view endEditing:YES];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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
