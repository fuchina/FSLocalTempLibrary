//
//  FSAddBestMobanController.m
//  myhome
//
//  Created by FudonFuchina on 2018/7/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSAddBestMobanController.h"
#import "FSBestSubjectModel.h"
#import "FSBestAccountAPI.h"
#import "FSUIKit.h"
#import "FSBestSubjectsController.h"
#import "FSKit.h"
#import "UIViewExt.h"
#import "FSMacro.h"

@interface FSAddBestMobanController ()

@property (nonatomic,strong) FSBestSubjectModel *aSubject;
@property (nonatomic,strong) FSBestSubjectModel *bSubject;

@end

@implementation FSAddBestMobanController{
    UIButton                    *_aButton;
    UIButton                    *_bButton;
    UITextField                 *_textField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"增加模板";
    [self addBMDesignViews];
}

- (void)addBMDesignViews{
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"重选" style:UIBarButtonItemStylePlain target:self action:@selector(bbiClick)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 80, width - 20, 44)];
    _textField.placeholder = @"请输入备注";
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_textField];
    if (_fs_isValidateString(_bz)) {
        _textField.text = _bz;
    }
    
    for (int x = 0; x < 3; x ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(10, _textField.bottom + 20 + 60 * x, UIScreen.mainScreen.bounds.size.width - 20, 44);
        [button setTitle:(x < 2)?@"请选择科目":@"提交" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = (x == 2)?FSAPPCOLOR:APPCOLOR;
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        if (x == 0) {
            _aButton = button;
        }else if (x == 1){
            _bButton = button;
        }
    }
}

- (void)bbiClick{
    self.aSubject = nil;
    self.bSubject = nil;
    NSString *txt = @"请选择科目";
    [_aButton setTitle:txt forState:UIControlStateNormal];
    [_bButton setTitle:txt forState:UIControlStateNormal];
    _aButton.backgroundColor = APPCOLOR;
    _bButton.backgroundColor = APPCOLOR;
}

- (void)btnClick:(UIButton *)button{
    if (button == _aButton) {
        [self getSubjectA];
    }else if (button == _bButton){
        [self getSubjectB];
    }else{
        [self commitEvent];
    }
}

- (void)getSubjectA{
    if (self.aSubject) {
        [FSToast toast:@"本科目已选择完成"];
    }else{
        [self getSubject:^(FSBestSubjectModel *subject) {
            self.aSubject = subject;
            NSString *show = [[NSString alloc] initWithFormat:@"%@_%@_%@",subject.bn,subject.nm,subject.isp == 1?@"增加":@"减少"];
            [self ->_aButton setTitle:show forState:UIControlStateNormal];
            self -> _aButton.backgroundColor = FSAPPCOLOR;
        }];
    }
}

- (void)getSubjectB{
    if (!self.aSubject) {
        [FSToast toast:@"请先选择前面科目"];
        return;
    }
    
    if (self.bSubject) {
        [FSToast toast:@"本科目已选择完成"];
    }else{
        [self getSubject:^(FSBestSubjectModel *subject) {
            self.bSubject = subject;
            NSString *show = [[NSString alloc] initWithFormat:@"%@_%@_%@",subject.bn,subject.nm,subject.isp == 1?@"增加":@"减少"];
            [self ->_bButton setTitle:show forState:UIControlStateNormal];
            self -> _bButton.backgroundColor = FSAPPCOLOR;
        }];
    }
}

- (void)getSubject:(void(^)(FSBestSubjectModel *subject))callback{
    FSBestSubjectsController *sub = [[FSBestSubjectsController alloc] init];
    sub.account = self.account;
    sub.selectedMode = YES;
    sub.model = self.aSubject;
    [self.navigationController pushViewController:sub animated:YES];
    sub.selectSubject = ^(FSBestSubjectsController *c, FSBestSubjectModel *model) {
        [c.navigationController popViewControllerAnimated:YES];
        if (callback) {
            callback(model);
        }
    };
}

- (void)commitEvent{
    NSString *bz = _textField.text;
    if (!_fs_isValidateString(bz)) {
        [_textField becomeFirstResponder];
        [FSToast toast:@"请输入备注"];
        return;
    }
    if (!self.aSubject) {
        [FSToast toast:@"请选择科目，让科目按钮变为蓝色"];
        return;
    }
    if (!self.bSubject) {
        [FSToast toast:@"请选择科目，让科目按钮变为蓝色"];
        return;
    }
    BOOL balance = [FSBestAccountAPI checkBalance:self.aSubject bSubject:self.bSubject table:self.account];
    if (!balance) {
        [FSToast toast:@"两个科目不平衡"];
        return;
    }
    
    __block NSString *error = nil;
    _fs_dispatch_global_main_queue_async(^{
        error = [FSBestAccountAPI addMobanForTable:self.account aj:self.aSubject bj:self.bSubject bz:bz];
    }, ^{
        if (error) {
            [FSUIKit showAlertWithMessage:error controller:self];
        }else{
            if (self.addSuccess) {
                self.addSuccess(self);
            }
        }
    });
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
