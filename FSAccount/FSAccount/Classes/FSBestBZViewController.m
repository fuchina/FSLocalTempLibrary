//
//  FSBestBZViewController.m
//  myhome
//
//  Created by FudonFuchina on 2018/7/4.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestBZViewController.h"
#import "FSBestAccountAPI.h"
#import "FSTextViewController.h"
#import "FSUIKit.h"
#import "FSAddBestMobanController.h"
#import "FSKit.h"
#import "FuSoft.h"
#import "FSToast.h"

@interface FSBestBZViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray        *list;
@property (nonatomic,strong) UITableView    *tableView;

@end

@implementation FSBestBZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bzHandleDatas];
}

- (void)bzHandleDatas{
    _fs_dispatch_global_main_queue_async(^{
        NSArray *list = [FSBestAccountAPI mobansForTable:self.table bz:self.bz];
        self.list = list;
    }, ^{
        [self bzDesignViews];
    });
}

- (void)bzDesignViews{
    if (!_tableView) {
        self.title = self.bz;
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(bbiClick)];
        self.navigationItem.rightBarButtonItem = bbi;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = 80;
        [self.view addSubview:_tableView];
    }else{
        [_tableView reloadData];
    }
}

- (void)bbiClick{
    FSAddBestMobanController *add = [[FSAddBestMobanController alloc] init];
    add.account = self.table;
    add.bz = self.bz;
    [self.navigationController pushViewController:add animated:YES];
    __weak typeof(self)this = self;
    add.addSuccess = ^(FSAddBestMobanController *c) {
        [this bzHandleDatas];
        [c.navigationController popViewControllerAnimated:YES];
    };
}

- (void)textHandle:(NSString *)title txt:(NSString *)text completion:(void (^)(FSTextViewController *bVC, NSString *bText))completion{
    FSTextViewController *txt = [[FSTextViewController alloc] init];
    txt.title = title;
    txt.text = text;
    txt.callback = completion;
    [self.navigationController pushViewController:txt animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        
        UILabel *one = [self labelCustom:NO];
        [cell addSubview:one];
        
        UILabel *two = [self labelCustom:YES];
        [cell addSubview:two];
    }
    return cell;
}

- (UILabel *)labelCustom:(BOOL)isSecond{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, isSecond * 30 + 10, WIDTHFC - 30, 30)];
    label.font = [UIFont systemFontOfSize:15];
    label.tag = 1000 + isSecond;
    return label;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    FSBestMobanModel *model = [self.list objectAtIndex:indexPath.row];
    
    UILabel *one = [cell viewWithTag:1000];
    UILabel *two = [cell viewWithTag:1001];
    one.attributedText = model.showA;
    two.attributedText = model.showB;
    cell.detailTextLabel.text = model.fq;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return _editMode;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FSBestMobanModel *model = [self.list objectAtIndex:indexPath.row];
        NSString *mTable = [FSBestAccountAPI mobanTableForTable:self.table];
        [FSBaseAPI deleteModelBusiness:model table:mTable controller:self success:^{
            [self bzHandleDatas];
            if (self.deleteEvent) {
                self.deleteEvent(self);
            }
        } fail:^(NSString *error) {
            [FSUIKit showAlertWithMessage:error controller:self];
        } cancel:^{
            tableView.editing = NO;
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FSBestMobanModel *model = [self.list objectAtIndex:indexPath.row];
    if (_editMode) {
        [self editBZ:model];
    }else{
        if (self.selectedBZ) {
            self.selectedBZ(self, model);
        }
    }
}

- (void)editBZ:(FSBestMobanModel *)model{
    [self textHandle:@"编辑备注" txt:model.bz completion:^(FSTextViewController *bVC, NSString *bText) {
        if (bText.length == 0) {
            [FSToast toast:@"请输入内容"];
            return;
        }
        [bVC.navigationController popViewControllerAnimated:YES];
        NSString *mTable = [FSBestAccountAPI mobanTableForTable:self.table];
        NSString *error = [FSBaseAPI updateTable:mTable field:@"bz" value:bText aid:model.aid];
        if (error) {
            [FSUIKit showAlertWithMessage:error controller:self];
        }else{
            [self bzHandleDatas];
        }
    }];
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
