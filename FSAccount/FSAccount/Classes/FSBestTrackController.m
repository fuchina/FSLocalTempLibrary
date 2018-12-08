//
//  FSBestTrackController.m
//  myhome
//
//  Created by FudonFuchina on 2018/6/16.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestTrackController.h"
#import <MJRefresh/MJRefresh.h>
#import "FSBestTrackCell.h"
#import "FSBestAccountAPI.h"
#import "FSViewManager.h"
#import "FSKit.h"
#import "FuSoft.h"
#import "FSMacro.h"

@interface FSBestTrackController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray         *datas;
@property (nonatomic,strong) UITableView            *tableView;
@property (nonatomic,strong) UIView                 *headView;

@property (nonatomic,assign) NSInteger              page;
@property (nonatomic,assign) BOOL                   first;
@property (nonatomic,strong) NSMutableDictionary    *heights;
@property (nonatomic,assign) CGFloat                sum;

@end

@implementation FSBestTrackController{
    UIBarButtonItem *_bbi;
    NSString        *_checkMessage;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    _heights = [NSMutableDictionary new];
    self.vanView.status = FSLoadingStatusLoading;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self trackHandleDatas];
}

- (void)trackHandleDatas{
    _fs_dispatch_global_main_queue_async(^{
        NSMutableArray *list = [FSBestAccountAPI tracksForModel:self.model markSubject:self.markSubject table:self.table page:self.page];
        if (self.page) {
            if (_fs_isValidateArray(list)) {
                [self.datas addObjectsFromArray:list];
            }
        }else{
            self.datas = list;
        }
    }, ^{
        [self trackDesignViews];
        [self.vanView dismiss];
    });
}

- (void)trackDesignViews{
    if (!_tableView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTHFC, 80)];
        _headView.backgroundColor = FS_GreenColor;
        NSArray *values = @[[FSKit ymdhsByTimeIntervalString:_model.tm],[[NSString alloc] initWithFormat:@"%.2f",[_model.je doubleValue]],NSLocalizedString(@"Remaining", nil),[[NSString alloc] initWithFormat:@"%.2f",[self.markSubject == 1?_model.ar:_model.br doubleValue]]];
        CGFloat width = (WIDTHFC - 30) / 2;
        for (int x = 0; x < values.count; x ++) {
            UILabel *label = [FSViewManager labelWithFrame:CGRectMake(15 + (x % 2) * width, 10 + (x / 2) * 30, width, 30) text:values[x] textColor:[UIColor whiteColor] backColor:nil font:(x == 1)?FONTBOLD(20):FONTFC(14) textAlignment:(x % 2 == 0)?NSTextAlignmentLeft:NSTextAlignmentRight];
            label.tag = TAG_LABEL + x;
            [_headView addSubview:label];
        }
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = _headView;
        [self.view addSubview:_tableView];
        __weak typeof(self)this = self;
        _tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            this.page = 0;
            [this trackHandleDatas];
        }];
        this.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            this.page ++;
            [this trackHandleDatas];
        }];
    }else{
        [_tableView reloadData];
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

- (FSBestTrackCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"c";
    FSBestTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FSBestTrackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSInteger row = indexPath.row;
    FSBestTrackModel *model = _datas[row];
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSBestTrackModel *model = _datas[indexPath.row];
    return model.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
