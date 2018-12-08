//
//  FSBestAccountListController.m
//  myhome
//
//  Created by FudonFuchina on 2018/4/9.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestAccountListController.h"
#import "FSDBMaster.h"
#import "FSBestCellView.h"
#import "FSBestAccountAPI.h"
#import "FSABSearchController.h"
#import "FSKit.h"
#import "FuSoft.h"
#import "FSToast.h"

//#import "FSBestUpdateController.h"

@interface FSBestAccountListController ()

@property (nonatomic,strong) FSBestCellView     *bestView;
@property (nonatomic,strong) NSMutableArray     *list;
@property (nonatomic,assign) NSInteger          page;

@end

@implementation FSBestAccountListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self listHandleDatas];
}

- (void)listHandleDatas{
    __block NSMutableArray  *list;
    _fs_dispatch_global_main_queue_async(^{
        list = [FSBestAccountAPI listForTable:self.table page:self.page];
    }, ^{
        if (self.page) {
            [self.list addObjectsFromArray:list];
        }else{
            self.list = list;
        }
        [self listDesignViews];
    });
}

- (void)listDesignViews{
    if (!_bestView) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchClick)];
        self.navigationItem.rightBarButtonItem = bbi;
        
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSInteger count = [master countForTable:self.table];
        self.title = [[NSString alloc] initWithFormat:@"列表（%@条）",@(count)];

        WEAKSELF(this);
        _bestView = [[FSBestCellView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64)];
        [self.view addSubview:_bestView];
        _bestView.refresh_header = ^{
            this.page = 0;
            [this listHandleDatas];
        };
        _bestView.refresh_footer = ^{
            this.page ++;
            [this listHandleDatas];
        };
        _bestView.clickCellEvent_no_selected = ^(FSBestAccountModel *bModel, NSIndexPath *indexPath) {
            [FSToast show:@"若要更改数据，请去科目列表"];
//            [this clickEventEntity:bModel ip:indexPath];
        };
    }
    _bestView.list = self.list;
}

//- (void)clickEventEntity:(FSBestAccountModel *)model ip:(NSIndexPath *)ip{
//    FSBestUpdateController *up = [[FSBestUpdateController alloc] init];
//    up.table = self.table;
//    up.model = model;
//    up.title = @"数据详情";
//    [self.navigationController pushViewController:up animated:YES];
//    __weak typeof(self)this = self;
//    up.updatedCallback = ^{
//        [this.navigationController popViewControllerAnimated:YES];
//        [this refreshIndexPath:ip];
//    };
//}

//- (void)refreshIndexPath:(NSIndexPath *)indexPath{
//    [_bestView reloadSection:indexPath.section];
//}

- (void)searchClick{
    FSABSearchController *search = [[FSABSearchController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
    __weak typeof(self)this = self;
    search.searchEvent = ^(FSABSearchController *vc, NSString *text) {
        if (text.length) {
            [this searchResult:text controller:vc];
        }
    };
    search.resultTableView = ^UITableView *(FSABSearchController *searchController) {
        FSBestCellView *view = (FSBestCellView *)searchController.resultView;
        return view.tableView.tableView;
    };
}

- (void)searchResult:(NSString *)text controller:(FSABSearchController *)controller{
    __block NSArray *list = nil;
    _fs_dispatch_global_main_queue_async(^{
        list = [FSBestAccountAPI searchAccount:self.table search:text];
    }, ^{
        FSBestCellView *view = (FSBestCellView *)controller.resultView;
        if (!view) {
            view = [[FSBestCellView alloc] initWithFrame:CGRectMake(0, 70, WIDTHFC, HEIGHTFC - 70)];
            controller.resultView = view;
            __weak typeof(view)weakView = view;
            view.refresh_header = ^{
                [weakView endRefresh];
            };
            view.refresh_footer = ^{
                [weakView endRefresh];
            };
        }
        view.list = list;
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
