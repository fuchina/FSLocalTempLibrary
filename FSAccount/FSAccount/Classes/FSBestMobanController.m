//
//  FSBestMobanController.m
//  myhome
//
//  Created by FudonFuchina on 2018/7/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestMobanController.h"
#import <MJRefresh.h>
#import "FSAccountRecordController.h"
#import "FSUIKit.h"
#import "FSBestAccountAPI.h"
#import "FSAddBestMobanController.h"
#import "FSBestMobanModel.h"
#import "FSBestBZViewController.h"
#import "FSBestTwoMinusController.h"
#import "FSBestOneMinusController.h"
#import "FSAutoLayoutButtonsView.h"
#import "FSKit.h"
#import "FSToast.h"
#import "FSMacro.h"

@interface FSBestMobanController ()<UIScrollViewDelegate>

@property (nonatomic,assign) NSInteger                      page;
@property (nonatomic,strong) NSMutableArray                 *list;
@property (nonatomic,strong) NSDate                         *date;
@property (nonatomic,assign) BOOL                           needRefresh;
@property (nonatomic,strong) FSAutoLayoutButtonsView        *buttonsView;

@end

@implementation FSBestMobanController{
    UITextField     *_textField;
    BOOL            _hasDesignViews;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"记账";
    _needRefresh = YES;
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMoban)];
    UIBarButtonItem *bbi2 = [[UIBarButtonItem alloc] initWithTitle:@"补记" style:UIBarButtonItemStylePlain target:self action:@selector(dateAction)];
    self.navigationItem.rightBarButtonItems = @[bbi,bbi2];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_needRefresh) {
        _needRefresh = NO;
        [self mobanHandleDatas];
    }
}

- (void)addMoban{
    FSAddBestMobanController *add = [[FSAddBestMobanController alloc] init];
    add.account = self.account;
    [self.navigationController pushViewController:add animated:YES];
    __weak typeof(self)this = self;
    add.addSuccess = ^(FSAddBestMobanController *c) {
        [this mobanHandleDatas];
        [c.navigationController popViewControllerAnimated:YES];
    };
}

- (void)dateAction{
    [self.view endEditing:YES];
    WEAKSELF(this);
    FSAccountRecordController *saveViewController = [[FSAccountRecordController alloc] init];
    [this.navigationController pushViewController:saveViewController animated:YES];
    saveViewController.block = ^(FSBaseController *bVC, NSDate *date) {
        this.date = date;
        this.title = [[FSKit ymdhsByTimeInterval:[date timeIntervalSince1970]] substringToIndex:10];
        [bVC.navigationController popViewControllerAnimated:YES];
    };
}

- (void)mobanHandleDatas{
    self.vanView.status = FSLoadingStatusLoading;
    _fs_dispatch_global_main_queue_async(^{
        NSMutableArray *list = [FSBestAccountAPI allMobanForTable:self.account page:self.page];
        if (self.page) {
            [self.list addObjectsFromArray:list];
        }else{
            self.list = list;
        }
    }, ^{
        __weak typeof(self)this = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [this.vanView dismiss];
            [this mobanDesignViews];
        });
    });
}

- (void)mobanDesignViews{
    if (_hasDesignViews) {
        [self reloadData];
        [self.scrollView.mj_header endRefreshing];
        [self.scrollView.mj_footer endRefreshing];
        return;
    }
    _hasDesignViews = YES;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 20, size.width - 30, 40)];
    _textField.placeholder = NSLocalizedString(@"Enter the amount and start billing", nil);
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.layer.cornerRadius = 3;
    _textField.keyboardType = UIKeyboardTypeDecimalPad;
    _textField.textAlignment = NSTextAlignmentCenter;
    
    if (self.list.count && self.page == 0) {
        [_textField becomeFirstResponder];
    }else{
        [FSUIKit alert:UIAlertControllerStyleAlert controller:self title:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Click '+' to Add", nil) actionTitles:@[NSLocalizedString(@"Add", nil)] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
            [self addMoban];
        }];
    }
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, 80)];
    headView.backgroundColor = RGBCOLOR(18, 152, 233, 1);
    [headView addSubview:_textField];
    self.scrollView.delegate = self;
    [self.scrollView addSubview:headView];
    __weak typeof(self)this = self;
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        this.page = 0;
        [this mobanHandleDatas];
    }];
    self.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        this.page ++;
        [this mobanHandleDatas];
    }];
    
    _buttonsView = [[FSAutoLayoutButtonsView alloc] initWithFrame:CGRectMake(0, headView.bottom, size.width, size.height - 80 - 64 - FS_iPhone_X * (27 + 35))];
    [self.scrollView addSubview:_buttonsView];
    _buttonsView.click = ^(FSAutoLayoutButtonsView *v, NSInteger index) {
        [this click:index];
    };
    _buttonsView.configButton = ^(UIButton *button) {
        _fs_dispatch_main_queue_async(^{
            [this addShadowForView:button opacity:0.08];            
        });
    };
    
    [self reloadData];
}

- (void)addShadowForView:(UIView *)view opacity:(CGFloat)opacity{
    view.layer.shadowOffset = CGSizeMake(-6, 6);
    view.layer.shadowColor = [UIColor colorWithRed:0x49/255.0 green:0x50/255.0 blue:0x56/255.0 alpha:1].CGColor;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:view.bounds] CGPath];
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = UIScreen.mainScreen.scale;
    view.layer.cornerRadius = 22;
    view.layer.shadowRadius = 6;
}

- (void)reloadData{
    _buttonsView.texts = self.list;
    _buttonsView.height = _buttonsView.selfHeight;
    self.scrollView.contentSize = CGSizeMake(WIDTHFC, _buttonsView.bottom + 20);
}

- (void)click:(NSInteger)index{
    [self.view endEditing:YES];
    if (self.list.count <= index) {
        return;
    }
    BOOL isJZ = _fs_isPureFloat(_textField.text);
    if (!isJZ) {
        [FSToast show:@"输入金额才是记账哦"];
    }
    
    NSString *model = [self.list objectAtIndex:index];
    FSBestBZViewController *bz = [[FSBestBZViewController alloc] init];
    bz.table = self.account;
    bz.bz = model;
    bz.editMode = !isJZ;
    [self.navigationController pushViewController:bz animated:YES];
    __weak typeof(self)this = self;
    bz.selectedBZ = ^(FSBestBZViewController *c, FSBestMobanModel *m) {
        [c.navigationController popViewControllerAnimated:YES];
        [this nextStep:m];
    };
    bz.deleteEvent = ^(FSBestBZViewController *c) {
        this.needRefresh = YES;
    };
}

- (void)nextStep:(FSBestMobanModel *)model{
    NSString *ap = [model.ap integerValue] == 1?@"增加":@"减少";
    NSString *bp = [model.bp integerValue] == 1?@"增加":@"减少";
    NSString *message = [[NSString alloc] initWithFormat:@"%@（%@）%@\n%@（%@）%@",model.an,model.abn,ap,model.bn,model.bbn,bp];
    NSString *title = [[NSString alloc] initWithFormat:@"%@，%@元",model.bz,_textField.text];
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:title message:message actionTitles:@[@"确定"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        [self addAccountHandle:model];
    }];
}

- (void)addAccountHandle:(FSBestMobanModel *)model{
    if (!_fs_isPureFloat(_textField.text)) {
        [FSToast toast:@"请输入正确的金额"];
        return;
    }
    if (!_fs_isValidateString(model.bz)) {
        [FSToast toast:@"备注不能为空"];
        return;
    }
    FSBestSubjectModel *aSubject = [FSBestAccountAPI subjectForValue:model.aj table:self.account];
    if (!aSubject) {
        NSString *show = [[NSString alloc] initWithFormat:@"'%@'科目不存在",model.an];
        [FSToast toast:show];
        return;
    }
    FSBestSubjectModel *bSubject = [FSBestAccountAPI subjectForValue:model.bj table:self.account];
    if (!bSubject) {
        NSString *show = [[NSString alloc] initWithFormat:@"'%@'科目不存在",model.bn];
        [FSToast toast:show];
        return;
    }
    NSInteger ap = [model.ap integerValue];aSubject.isp = ap;
    NSInteger bp = [model.bp integerValue];bSubject.isp = bp;
    NSInteger minusCount = 2 - (ap == 1?1:0) - (bp == 1?1:0);
    if (minusCount == 2) {
        FSBestTwoMinusController *two = [[FSBestTwoMinusController alloc] init];
        two.table = self.account;
        two.subjects = @[aSubject,bSubject];
        two.je = _textField.text;
        two.bz = model.bz;
        [self.navigationController pushViewController:two animated:YES];
        __weak typeof(self)this = self;
        two.completion = ^(FSBestTwoMinusController *bController, Tuple2 *bEdArray) {
            [this handleReuslt:bEdArray bz:model a:aSubject b:bSubject];
        };
    }else if (minusCount == 1){
        FSBestOneMinusController *one = [[FSBestOneMinusController alloc] init];
        one.je = _textField.text;
        one.subject = aSubject.isp == 1?bSubject:aSubject;
        one.table = self.account;
        [self.navigationController pushViewController:one animated:YES];
        __weak typeof(self)this = self;
        one.completion = ^(FSBestOneMinusController *bController, NSArray *bEdArray) {
            [this handleReuslt:[Tuple2 v1:bEdArray v2:nil] bz:model a:aSubject b:bSubject];
        };
    }else{
        [self handleReuslt:nil bz:model a:aSubject b:bSubject];
    }
}

- (void)handleReuslt:(Tuple2 *)beMinused bz:(FSBestMobanModel *)model a:(FSBestSubjectModel *)aSubject b:(FSBestSubjectModel *)bSubject{
    NSString *error = [FSBestAccountAPI versatileAddAccount:self.account je:_textField.text bz:model.bz date:self.date aSubject:aSubject bSubject:bSubject aMinused:beMinused._1 bMinused:beMinused._2 controller:self inBlock:^(void (^callback)(void)) {
        callback();
    }];
    
    if (error) {
        [FSUIKit showAlertWithMessage:error controller:self];
    }else{
        if (self.addSuccess) {
            self.addSuccess(self);
        }else{
            [FSKit popToController:@"FSBestAccountController" navigationController:self.navigationController animated:YES];
        }
        
        NSString *mobanTable = [FSBestAccountAPI mobanTableForTable:self.account];
        [FSBaseAPI addFreq:mobanTable field:@"fq" model:model];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        [self.view endEditing:YES];
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
