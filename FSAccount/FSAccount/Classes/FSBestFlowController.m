//
//  FSBestFlowController.m
//  myhome
//
//  Created by FudonFuchina on 2018/7/5.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestFlowController.h"
#import "FSBestAccountAPI.h"
#import "FSBestFlowCell.h"
#import "FSBestFlowListController.h"
#import "FSPublic.h"
#import "FSKit.h"
#import "FuSoft.h"
#import "FSToast.h"

@interface FSBestFlowController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,strong) NSMutableArray *years;
@property (nonatomic,assign) NSInteger      page;

@end

@implementation FSBestFlowController

- (void)viewDidLoad {
    [super viewDidLoad];
    _years = [[NSMutableArray alloc] init];
    [self flowHandleDatas];
}

- (void)shakeEndActionFromShakeBase{
    [FSPublic shareAction:self view:_tableView];
}

- (void)flowHandleDatas{
    _fs_dispatch_global_main_queue_async(^{
        NSMutableArray *list = [FSBestAccountAPI allFlowsForTable:self.table page:self.page];
        if (self.page) {
            if (_fs_isValidateArray(list)) {
                [self.years addObjectsFromArray:list];
            }else{
                _fs_dispatch_main_queue_async(^{
                    self.page --;
                    [FSToast show:@"没有更多数据了"];return;
                });
            }
        }else{
            self.years = list;
        }
    }, ^{
        if (_fs_isValidateArray(self.years)) {
            if (self.years.count == 1) {
                NSDictionary *one = self.years.firstObject;
                self.title = [[NSString alloc] initWithFormat:@"流水（%@）",one[@"year"]];;
            }else{
                NSDictionary *first = self.years.firstObject;
                NSDictionary *last = self.years.lastObject;
                self.title = [[NSString alloc] initWithFormat:@"流水(%@-%@)",last[@"year"],first[@"year"]];
            }
        }else{
            self.title = @"流水";
        }
        [self flowDesignViews];
    });
}

- (void)flowDesignViews{
    if (!_tableView) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Dates back", nil) style:UIBarButtonItemStylePlain target:self action:@selector(bbiAction)];
        self.navigationItem.rightBarButtonItem = bbi;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 140;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
        [self.view addSubview:_tableView];
    }else{
        [_tableView reloadData];
    }
}

- (void)bbiAction{
    self.page ++;
    [self flowHandleDatas];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.years.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic = self.years[section];
    NSArray *array = [dic objectForKey:@"list"];
    if (_fs_isValidateArray(array)) {
        return array.count;
    }
    return 0;
}

- (FSBestFlowCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"c";
    FSBestFlowCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FSBestFlowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(FSBestFlowCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.years[indexPath.section];
    NSArray *array = [dic objectForKey:@"list"];
    NSDictionary *value = [array objectAtIndex:indexPath.row];
    [cell configData:value];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *dic = self.years[section];
    return dic[@"year"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return .1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.years[indexPath.section];
    NSArray *array = [dic objectForKey:@"list"];
    NSDictionary *value = [array objectAtIndex:indexPath.row];

    FSBestFlowListController *list = [[FSBestFlowListController alloc] init];
    list.table = self.table;
    list.year = dic[@"year"];
    list.month = [value objectForKey:@"mn"];
    [self.navigationController pushViewController:list animated:YES];
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
