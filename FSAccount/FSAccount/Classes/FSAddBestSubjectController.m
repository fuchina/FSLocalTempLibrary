//
//  FSAddBestSubjectController.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/29.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSAddBestSubjectController.h"
#import "FSLabelTextField.h"
#import "FSHalfView.h"
#import "FSBestAccountAPI.h"
#import "FSUIKit.h"
#import "FSViewManager.h"
#import "FuSoft.h"
#import "UIViewExt.h"
#import "FSKit.h"
#import "FSMacro.h"

@interface FSAddBestSubjectController ()

@property (nonatomic,strong) FSHalfView     *halfView;
@property (nonatomic,strong) NSArray        *list;
@property (nonatomic,copy) NSString         *be;
@property (nonatomic,copy) NSString         *jd;

@end

@implementation FSAddBestSubjectController{
    FSLabelTextField    *_lf;
    BOOL                _showKeyboard;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self abscDesignViews];
}

- (void)abscDesignViews{
    self.title = @"增加科目";    
    _lf = [[FSLabelTextField alloc] initWithFrame:CGRectMake(0, 74, WIDTHFC, 44) text:@"名称" textFieldText:nil placeholder:@"请输入"];
    [self.view addSubview:_lf];
    
    self.list = [FSBestAccountAPI accountantClass];
    Tuple3 *t = [self.list objectAtIndex:_index];
    self.be = [t._2 description];
    self.jd = t._3;

    __weak typeof(self)this = self;
    FSTapCell *cell = [FSViewManager tapCellWithText:@"属性" textColor:nil font:nil detailText:t._1 detailColor:nil detailFont:nil block:^(FSTapCell *bCell) {
        [this cellAction:bCell];
    }];
    cell.backgroundColor = [UIColor whiteColor];
    cell.top = _lf.bottom + 1;
    [self.view addSubview:cell];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(15, cell.bottom + 20, WIDTHFC - 30, 44);
    button.backgroundColor = FSAPPCOLOR;
    button.layer.cornerRadius = 3;
    [button setTitle:@"增加" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)cellAction:(FSTapCell *)cell{
    [self.view endEditing:YES];
    if (!self.halfView) {
        WEAKSELF(this);
        self.halfView = [[FSHalfView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64)];
        self.halfView.dataSource = self.list;
        [self.view addSubview:self.halfView];
        [_halfView setConfigCell:^(UITableView *bTB, NSIndexPath *bIP,UITableViewCell *bCell) {
            Tuple3 *t = this.list[bIP.row];
            bCell.textLabel.text = t._1;
        }];
        [_halfView setSelectCell:^(UITableView *bTB, NSIndexPath *bIP) {
            Tuple3 *t = this.list[bIP.row];
            cell.detailTextLabel.text = t._1;
            this.be = [t._2 description];
            this.jd = t._3;
        }];
    }else{
        self.halfView.dataSource = self.list;
        [self.halfView showHalfView:YES];
    }
}

- (void)addClick{
    NSString *name = [FSKit stringDeleteNewLineAndWhiteSpace:_lf.textField.text];
    if (!_fs_isValidateString(name)) {
        [FSToast toast:@"请输入正确的科目名称"];return;
    }
    if (!self.jd) {
        [FSToast toast:@"请选择科目属性"];return;
    }
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:nil actionTitles:@[@"确定增加"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        NSString *error = [FSBestAccountAPI addSubject:name be:self.be jd:self.jd table:self.table];
        if (error) {
            [FSUIKit showAlertWithMessage:error controller:self];return;
        }
        if (self.addSubjectSuccess) {
            self.addSubjectSuccess(self);
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)tapActionBase{
    if (_showKeyboard) {
        [self.view endEditing:YES];
    }else{
        [_lf.textField becomeFirstResponder];
    }
    _showKeyboard = !_showKeyboard;
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
