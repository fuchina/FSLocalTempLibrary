//
//  FSBestAccountDetailController.m
//  myhome
//
//  Created by FudonFuchina on 2018/4/6.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestAccountDetailController.h"
#import "FSBestCellView.h"
#import "FSBestAccountAPI.h"
#import "FSBestTrackController.h"
#import "FSUIKit.h"
#import "FSKit.h"
#import "FSBestUpdateController.h"
#import "FSPublic.h"
#import "FuSoft.h"
#import "FSMacro.h"

@interface FSBestAccountDetailController ()

@property (nonatomic,assign) NSInteger       page;
@property (nonatomic,strong) NSMutableArray  *list;

@end

@implementation FSBestAccountDetailController{
    FSBestCellView      *_bestView;
    UILabel             *_label;
    BOOL                _isAll;
    BOOL                _isASC;
    NSInteger           _jeSort;
    
    BOOL                _showAll;
    UIBarButtonItem     *_bbi;
    UISegmentedControl  *_control;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self detailHandleDatas];
}

- (void)setName:(NSString *)name{
    if (![name isKindOfClass:NSString.class]) {
        name = name.description;
    }
//    NSInteger length = [name lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
    NSInteger margin = 7;
    if (name.length > margin) {
        name = [[NSString alloc] initWithFormat:@"%@...",[name substringToIndex:margin]];
    }
    _name = name;
}

- (void)reloadData{
    self.page = 0;
    [self detailHandleDatas];
}

- (void)detailHandleDatas{
    __block NSMutableArray *list = nil;;
    BOOL isZero = _control.selectedSegmentIndex == 0;
    _fs_dispatch_global_main_queue_async(^{
        list = [FSBestAccountAPI listForSubjectOfDetail:self.subject table:self.table page:self.page track:YES asc:self ->_isASC isAll:self->_isAll jeSort:self->_jeSort unit:30 start:self.start end:self.end isPlus:isZero];
        if (self.page) {
            [self.list addObjectsFromArray:list];
        }else{
            self.list = list;
        }
    }, ^{
        [self detailDesignViews];
    });
}

- (void)detailDesignViews{
    if (self.list.count == 0) {
        if (!_showAll) {
            _showAll = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.label.text = @"本科目没有余额，即将显示所有数据...";
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self->_isAll = YES;
                    [self showLabelView];
                    [self detailHandleDatas];
                });
            });
        }
    }
    
    if (!_bestView) {
        _control = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Plus", nil),NSLocalizedString(@"Minus", nil)]];
        _control.selectedSegmentIndex = 0;
        _control.frame = CGRectMake(0, 4, 100, 36);
        [_control addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = _control;
        
        _bbi = [[UIBarButtonItem alloc] initWithTitle:self.name style:UIBarButtonItemStylePlain target:self action:@selector(operateEvent)];
        self.navigationItem.rightBarButtonItem = _bbi;
        
        WEAKSELF(this);
        _bestView = [[FSBestCellView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64)];
        [self.view addSubview:_bestView];
        _bestView.refresh_header = ^{
            this.page = 0;
            [this detailHandleDatas];
        };
        _bestView.refresh_footer = ^{
            this.page ++;
            [this detailHandleDatas];
        };
        _bestView.clickCellEvent_no_selected = ^(FSBestAccountModel *bModel,NSIndexPath *ip) {
            [this clickEventEntity:bModel ip:ip];
        };
        _bestView.trackCallback = ^(FSBestAccountModel *bModel, NSInteger markSubject,NSString *n) {
            [this pushToTrack:markSubject model:bModel subjectName:n];
        };
    }
    _bestView.list = self.list;
}

- (void)pushToTrack:(NSInteger)markSubject model:(FSBestAccountModel *)model subjectName:(NSString *)subjectName{
    FSBestTrackController *track = [[FSBestTrackController alloc] init];
    track.table = self.table;
    track.title = subjectName;
    track.model = model;
    track.markSubject = markSubject;
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    [self.navigationController pushViewController:track animated:YES];
}

- (void)clickEventEntity:(FSBestAccountModel *)model ip:(NSIndexPath *)ip{
    NSInteger aj = [model.aj integerValue];
    NSInteger bj = [model.bj integerValue];
    NSInteger sub = [self.subject integerValue];
    NSInteger isAJ = 0;
    if (aj == sub && bj != sub) {
        isAJ = 1;
    }else if (aj != sub && bj == sub){
        isAJ = 2;
    }else if (aj == sub && bj == sub){
        isAJ = 3;
    }
    
    FSBestUpdateController *up = [[FSBestUpdateController alloc] init];
    up.table = self.table;
    up.isAJ = isAJ;
    up.model = model;
    up.title = @"数据详情";
    [self.navigationController pushViewController:up animated:YES];
    __weak typeof(self)this = self;
    up.updatedCallback = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:_Notifi_DetailUpdateCacheData object:nil];
        [this.navigationController popViewControllerAnimated:YES];
        [this refreshIndexPath:ip];
    };
}

- (void)refreshIndexPath:(NSIndexPath *)ip{
    [_bestView reloadSection:ip.section];
}

- (void)operateEvent{
    NSString *all = nil;
    NSString *rest = nil;
    NSString *allData = nil;
    
    BOOL needAll = _control.selectedSegmentIndex == 0;
    if (needAll) {
        if (_isAll) {
            rest = @"余额为正";
            all = rest;
        }else{
            allData = @"所有数据";
            all = allData;
        }
    }
    
    NSString *timeSort = nil;
    NSString *timeSort_a = nil;
    NSString *timeSort_b = nil;
    if (_isASC) {
        timeSort_a = @"时间从近到远";
        timeSort = timeSort_a;
    }else{
        timeSort_b = @"时间从远到近";
        timeSort = timeSort_b;
    }
    
    NSString *jeSort = nil;
    NSString *jeSort_a = nil;
    NSString *jeSort_b = nil;
    if (_jeSort == 2){
        jeSort_b = @"金额从小到大";
        jeSort = jeSort_b;
    }else{
        jeSort_a = @"金额从大到小";
        jeSort = jeSort_a;
    }
    
    NSArray *titles = nil;
    NSArray *types = nil;
    NSNumber *type = @(UIAlertActionStyleDefault);
    if (needAll) {
        titles = @[all,timeSort,jeSort];
        types = @[type,type,type];
    }else{
        titles = @[timeSort,jeSort];
        types = @[type,type];
    }
    
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:nil actionTitles:titles styles:types handler:^(UIAlertAction *action) {
        if ([action.title isEqualToString:rest]) {
            self->_isAll = NO;
        }else if ([action.title isEqualToString:allData]){
            self->_isAll = YES;
        }
        
        if ([action.title isEqualToString:timeSort_a]) {
            self->_isASC = NO;
        }else if ([action.title isEqualToString:timeSort_b]){
            self -> _isASC = YES;
        }
        
        if ([action.title isEqualToString:jeSort_a]) {
            self -> _jeSort = 2;
        }else if ([action.title isEqualToString:jeSort_b]){
            self -> _jeSort = 1;
        }else{
            self -> _jeSort = 0;
        }
        
        [self showLabelView];
        self.page = 0;
        [UIView animateWithDuration:.3 animations:^{
            self->_bestView.tableView.tableView.contentOffset = CGPointZero;            
        }];
        [self detailHandleDatas];
    }];
}

- (void)showLabelView{
    NSString *show = nil;
    if (_jeSort == 1) {
        show = @"金额从小到大";
    }else if (_jeSort == 2){
        show = @"金额从大到小";
    }else{
        NSMutableString *newString = [NSMutableString new];
        BOOL needAll = _control.selectedSegmentIndex == 0;
        if (needAll) {
            if (_isAll) {
                [newString appendString:@"所有数据 + "];
            }else{
                [newString appendString:@"余额为正 + "];
            }
        }
        
        if (_isASC) {
            [newString appendString:@"时间从远到近"];
        }else{
            [newString appendString:@"时间从近到远"];
        }
        show = [newString copy];
    }
    self.label.text = show;
}

- (UILabel *)label{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, WIDTHFC, 26)];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = FSAPPCOLOR;
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:12];
        [self.view addSubview:_label];
        
        [UIView animateWithDuration:.3 animations:^{
            self -> _label.top = 64;
        } completion:^(BOOL finished) {
            self ->_bestView.top = self ->_label.bottom;
            self ->_bestView.height = HEIGHTFC - self ->_label.bottom;
            self ->_bestView.tableView.tableView.height = self ->_bestView.height;
        }];
    }
    return _label;
}

- (void)shakeEndActionFromShakeBase{
    [FSPublic shareAction:self view:_bestView.tableView.tableView];
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
