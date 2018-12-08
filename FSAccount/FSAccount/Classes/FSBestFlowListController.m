//
//  FSBestFlowListController.m
//  myhome
//
//  Created by FudonFuchina on 2018/7/8.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestFlowListController.h"
#import "FSBestCellView.h"
#import "FSBestAccountAPI.h"
#import "FSBestTrackController.h"
#import "FSBestUpdateController.h"
#import "FSKit.h"
#import "FSMacro.h"

@interface FSBestFlowListController ()

@property (nonatomic,strong) NSMutableArray     *list;
@property (nonatomic,strong) FSBestCellView     *bestView;
@property (nonatomic,assign) BOOL               isSR;

@property (nonatomic,strong) NSArray            *srList;
@property (nonatomic,strong) NSArray            *cbList;

@end

@implementation FSBestFlowListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bestFlowListHandleDatas];
}

- (void)bestFlowListHandleDatas{
    _fs_dispatch_global_main_queue_async(^{
        if (self.isSR) {
            if (!self.srList) {
                self.srList = [FSBestAccountAPI flowListForTable:self.table year:self.year month:self.month isSR:self.isSR];
                if (!_fs_isValidateArray(self.srList)) {
                    self.srList = @[];
                }
            }
            self.list = self.srList.copy;
        }else{
            if (!self.cbList) {
                self.cbList = [FSBestAccountAPI flowListForTable:self.table year:self.year month:self.month isSR:self.isSR];
                if (!_fs_isValidateArray(self.cbList)) {
                    self.cbList = @[];
                }
            }
            self.list = self.cbList.copy;
        }
    }, ^{
        [self bestFlowListDesignViews];
    });
}

- (void)bestFlowListDesignViews{
    if (!_bestView) {
        self.title = [[NSString alloc] initWithFormat:@"流水（%@/%@）",self.month,self.year];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"成本" style:UIBarButtonItemStylePlain target:self action:@selector(selectBE:)];
        self.navigationItem.rightBarButtonItem = bbi;
        
        WEAKSELF(this);
        _bestView = [[FSBestCellView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64)];
        [self.view addSubview:_bestView];
        _bestView.refresh_header = ^{
            [this.bestView endRefresh];
        };
        _bestView.refresh_footer = ^{
            [this.bestView endRefresh];
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

- (void)clickEventEntity:(FSBestAccountModel *)model ip:(NSIndexPath *)ip{
    NSInteger aj = [model.aj integerValue];
    NSInteger bj = [model.bj integerValue];
    NSInteger sub = [model.aIsFlow?model.aj:model.bj  integerValue];
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

- (void)selectBE:(UIBarButtonItem *)bbi{
    _isSR = !_isSR;
    if (_isSR) {
        [bbi setTitle:@"收入"];
    }else{
        [bbi setTitle:@"成本"];
    }
    self->_bestView.tableView.tableView.contentOffset = CGPointMake(0, 0);
    [self bestFlowListHandleDatas];
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
