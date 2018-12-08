//
//  FSAccountRecordController.m
//  myhome
//
//  Created by FudonFuchina on 2017/4/16.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSAccountRecordController.h"
#import "FSDatePickerView.h"
#import "FSViewManager.h"
#import "FuSoft.h"
#import "FSKit.h"
#import "FSMacro.h"

@interface FSAccountRecordController ()

@property (nonatomic,strong) UILabel            *label;
@property (nonatomic,strong) UISegmentedControl *control;
@property (nonatomic,strong) NSDate             *date;
@property (nonatomic,assign) BOOL               isShowPicker;

@end

@implementation FSAccountRecordController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self recordDesignViews];
}

- (void)recordDesignViews{
    _control = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Hour", nil),NSLocalizedString(@"Minute", nil),NSLocalizedString(@"Second", nil)]];
    _control.selectedSegmentIndex = 0;
    _control.frame = CGRectMake(0, 4, 100, 36);
    self.navigationItem.titleView = _control;
    
    UIBarButtonItem *bbi = [FSViewManager bbiWithTitle:NSLocalizedString(@"Date", nil) target:self action:@selector(bbiAction)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    NSString *text = _fs_userDefaults_objectForKey(NSStringFromClass(self.class));
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.date = [formatter dateFromString:text];
    
    _label = [FSViewManager labelWithFrame:CGRectMake(20, 10, WIDTHFC - 40, 44) text:text textColor:APPCOLOR backColor:nil font:FONTFC(18) textAlignment:NSTextAlignmentCenter];
    [self.scrollView addSubview:_label];
    
    CGFloat btnWidth = (WIDTHFC - 60) / 2;
    NSArray *titles = @[@"+",@"-"];
    UIButton *button = nil;
    for (int x = 0; x < 2; x ++) {
        button = [FSViewManager buttonWithFrame:CGRectMake(x?(WIDTHFC - btnWidth - 20):20, _label.bottom + 10, btnWidth, 44) title:titles[x] titleColor:[UIColor whiteColor] backColor:FSAPPCOLOR fontInt:0 tag:TAG_BUTTON + x target:self selector:@selector(btnClick:)];
        button.layer.cornerRadius = 3;
        [self.scrollView addSubview:button];
    }
    
    UIButton *submitButton = [FSViewManager submitButtonWithTop:button.bottom + 20 tag:TAG_BUTTON + 2 target:self selector:@selector(btnClick:)];
    [self.scrollView addSubview:submitButton];
}

- (void)bbiAction{
    if (self.isShowPicker) {
        return;
    }
    self.isShowPicker = YES;
    WEAKSELF(this);
    FSDatePickerView *picker = [[FSDatePickerView alloc] initWithFrame:CGRectMake(0, 0, WIDTHFC, HEIGHTFC) date:nil];
    [self.view addSubview:picker];
    picker.cancel = ^{
        this.isShowPicker = NO;
    };
    picker.block = ^ (NSDate *bDate){
        this.isShowPicker = NO;
        this.date = bDate;
        NSString *time = [FSKit ymdhsByTimeInterval:[bDate timeIntervalSince1970]];
        _fs_userDefaults_setObjectForKey(time, NSStringFromClass(self.class));
        this.label.text = time;
    };
}

- (void)btnClick:(UIButton *)button{
    if (button.tag == (TAG_BUTTON + 2)) {
        NSString *time = [FSKit ymdhsByTimeInterval:[self.date timeIntervalSince1970]];
        _fs_userDefaults_setObjectForKey(time, NSStringFromClass(self.class));
        if (_block) {
            _block(self,self.date);
        }
        return;
    }
    NSInteger unit = 0;
    if (_control.selectedSegmentIndex == 0) {
        unit = 3600;
    }else if (_control.selectedSegmentIndex == 1){
        unit = 60;
    }else{
        unit = 1;
    }
    
    NSTimeInterval now = [self.date timeIntervalSince1970];
    if (button.tag == TAG_BUTTON) {
        now += unit;
    }else if (button.tag == (TAG_BUTTON + 1)){
        now -= unit;
    }
    self.date = [[NSDate alloc] initWithTimeIntervalSince1970:now];
    self.label.text = [FSKit ymdhsByTimeInterval:now];
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
