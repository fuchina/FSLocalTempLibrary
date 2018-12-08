//
//  FSBestBeListController.m
//  myhome
//
//  Created by FudonFuchina on 2018/8/25.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestBeListController.h"
#import "FSBestAccountAPI.h"
#import "FSBestCellView.h"
#import "FSUIKit.h"
#import "FSPublic.h"
#import "FSToast.h"
#import "FSKit.h"
#import "FSMacro.h"

@interface FSBestBeListController ()

@property (nonatomic,assign) NSInteger              page;
@property (nonatomic,strong) NSArray                *list;
@property (nonatomic,strong) FSBestCellView         *bestView;

@end

@implementation FSBestBeListController{
    NSInteger           _jeSort;       //  1，从大到小，2，从小到大，默认为0
    NSInteger           _timeSort;     //  1.从近到远，2.从远到近，默认为1
    UISegmentedControl  *_control;
    BOOL                _isPlus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isPlus = YES;
    [self beListHandleDatas];
}

- (void)beListHandleDatas{
    [FSBestAccountAPI listForBe:self.be table:self.table page:self.page jeSort:_jeSort timeSort:_timeSort isPlus:_isPlus call:^(NSArray<FSBestAccountCacheModel *> *list) {
        if (self.page) {
            if ([list isKindOfClass:NSArray.class] && list.count) {
                NSMutableArray *newList = self.list.mutableCopy;
                [newList addObjectsFromArray:list];
                self.list = newList;
            }else{
                [FSToast show:@"没有更多数据啦"];
            }
        }else{
            self.list = list;
        }
        [self beListDesignViews];
    }];
}

- (void)reloadData{
    _isPlus = (_control.selectedSegmentIndex == 0);
    _page = 0;
    [self beListHandleDatas];
    [UIView animateWithDuration:.3 animations:^{
        self.bestView.tableView.tableView.contentOffset = CGPointZero;
    }];
}

- (void)beListDesignViews{
    if (!_bestView) {
        _control = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Plus", nil),NSLocalizedString(@"Minus", nil)]];
        _control.selectedSegmentIndex = 0;
        _control.frame = CGRectMake(0, 4, 100, 36);
        [_control addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = _control;

        __block NSString *name = nil;
        _fs_dispatch_global_main_queue_async(^{
            name = [FSBestAccountAPI beNameForBe:self.be];
            if (name.length > 6) {
                name = [[NSString alloc] initWithFormat:@"%@...",[name substringToIndex:6]];
            }
        }, ^{
            UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:name style:UIBarButtonItemStylePlain target:self action:@selector(operateEvent)];
            self.navigationItem.rightBarButtonItem = bbi;
        });
        
        WEAKSELF(this);
        _bestView = [[FSBestCellView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64)];
        [self.view addSubview:_bestView];
        _bestView.refresh_header = ^{
            this.page = 0;
            [this beListHandleDatas];
        };
        _bestView.refresh_footer = ^{
            this.page ++;
            [this beListHandleDatas];
        };
        _bestView.clickCellEvent_no_selected = ^(FSBestAccountModel *bModel, NSIndexPath *indexPath) {
            [FSToast show:@"若要更改数据，请去科目列表"];
        };
    }
    _bestView.list = self.list;
}

- (void)operateEvent{
    NSString *jeStr = (_jeSort == 1)?@"金额从小到大":@"金额从大到小";
    NSString *timeStr = (_timeSort == 2)?@"时间从近到远":@"时间从远到近";
    NSNumber *t = @(UIAlertActionStyleDefault);
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:nil actionTitles:@[jeStr,timeStr] styles:@[t,t] handler:^(UIAlertAction *action) {
        if ([action.title isEqualToString:jeStr]) {
            self -> _timeSort = 0;
            NSInteger jeSort = self -> _jeSort;
            if (jeSort == 0) {
                self -> _jeSort = 1;
            }else if (jeSort == 1){
                self -> _jeSort = 2;
            }else if (jeSort == 2){
                self -> _jeSort = 1;
            }
            self.page = 0;
            [self beListHandleDatas];
        }else if ([action.title isEqualToString:timeStr]){
            self -> _jeSort = 0;
            NSInteger timeSort = self -> _timeSort;
            if (timeSort == 0) {
                self->_timeSort = 2;
            }else if (timeSort == 2){
                self -> _timeSort = 1;
            }else if (timeSort == 1){
                self -> _timeSort = 2;
            }
            self.page = 0;
            [self beListHandleDatas];
        }
        
        [UIView animateWithDuration:.3 animations:^{
            self.bestView.tableView.tableView.contentOffset = CGPointZero;
        }];
    }];
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
