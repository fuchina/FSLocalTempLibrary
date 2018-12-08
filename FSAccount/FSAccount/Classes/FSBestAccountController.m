//
//  FSBestAccountController.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/29.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestAccountController.h"
#import "FSTuple.h"
#import "FSTitleContentView.h"
#import "FSBestAddAccountController.h"
#import "FSBestAccountAPI.h"
#import "FSBestSubsubjectController.h"
#import "MJRefresh.h"
#import "FSBestAccountListController.h"
#import "FSDate.h"
#import "FSBestAnnalsController.h"
#import "UIViewController+BackButtonHandler.h"
#import "FSBestExpectController.h"
#import "FSBestSubjectsController.h"
#import "FSBestMobanController.h"
#import "FSPublic.h"
#import "FuSoft.h"
#import "FSMacro.h"

@interface FSBestAccountController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView            *tableView;
@property (nonatomic,strong) NSDictionary           *years;
@property (nonatomic,assign) BOOL                   needRefresh;
@property (nonatomic,assign) BOOL                   haveUpdated;

@end

@implementation FSBestAccountController{
    NSArray                 *_subjects;
    NSArray                 *_mass;
    FSBestAccountDataModel  *_model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bestAccountHandleDatas];
}

- (void)shakeEndActionFromShakeBase{
    [FSPublic shareAction:self view:_tableView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self bestAccountHandleDatas];
    }
}

- (void)bestAccountHandleDatas{
    [FSBestAccountAPI business_global:self.table callback:^(NSArray *array,NSArray *mass,FSBestAccountDataModel *model) {
        self->_model = model;
        self->_subjects = array;
        self->_mass = mass;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self bestAccountDesignViews];
        });
    }];
}

- (void)bestAccountDesignViews{
    if (!_tableView) {
        UIBarButtonItem *yb = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Annals", nil) style:UIBarButtonItemStylePlain target:self action:@selector(seeYears)];
        UIBarButtonItem *list = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(seeList)];
        self.navigationItem.rightBarButtonItems = @[list,yb];
        self.tableView.hidden = NO;
        
        NSArray *titles = @[@"记一笔",@"模板记",@"科目本"];
        CGFloat hw = WIDTHFC / titles.count;
        for (int x = 0; x < 3; x ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(hw * x, HEIGHTFC - 44 - FS_iPhone_X * 34, hw, 44);
            [button setTitle:titles[x] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = FSAPPCOLOR;
            button.tag = x;
            [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            if (x) {
                CALayer *layer = [CALayer layer];
                layer.backgroundColor = [UIColor whiteColor].CGColor;
                layer.frame = CGRectMake(0, 10, .6, 24);
                [button.layer addSublayer:layer];
            }
        }
    }else{
        [_tableView.mj_header endRefreshing];
        [_tableView reloadData];
        [self refreshHeaderData];
    }
}

- (void)refreshHeaderData{
    for (int x = 0; x < _mass.count; x ++) {
        NSDictionary *t = _mass[x];
        FSTitleContentView *tc = [_tableView.tableHeaderView viewWithTag:TAG_VIEW + x];
        if (!tc) {
            tc = [[FSTitleContentView alloc] initWithFrame:CGRectMake(15, 10 + x * 30, WIDTHFC - 28, 30)];
            tc.tag = TAG_VIEW + x;
            tc.label.textColor = [UIColor whiteColor];
            tc.contentLabel.textColor = [UIColor whiteColor];
            [_tableView.tableHeaderView addSubview:tc];
        }
        tc.label.text = [t objectForKey:@"1"];
        tc.contentLabel.text = [t objectForKey:@"2"];
        NSInteger color = [[t objectForKey:@"3"] integerValue];
        if (color == 1) {
            tc.contentLabel.textColor = [UIColor yellowColor];
        }else{
            tc.contentLabel.textColor = [UIColor whiteColor];
        }
    }
}

- (void)seeList{
    FSBestAccountListController *all = [[FSBestAccountListController alloc] init];
    all.table = self.table;
    [self.navigationController pushViewController:all animated:YES];
}

- (void)seeYears{
    FSBestAnnalsController *annals = [[FSBestAnnalsController alloc] init];
    annals.table = self.table;
    [self.navigationController pushViewController:annals animated:YES];
}

- (void)tapClick{
    FSBestExpectController *expect = [[FSBestExpectController alloc] init];
    expect.accountName = self.table;
    expect.model = _model;
    [self.navigationController pushViewController:expect animated:YES];
}

- (void)btnClick:(UIButton *)button{
    if (button.tag == 0) {
        FSBestAddAccountController *add = [[FSBestAddAccountController alloc] init];
        add.accountName = self.table;
        [self.navigationController pushViewController:add animated:YES];
        __weak typeof(self)this = self;
        add.addSuccess = ^(FSBestAddAccountController *c) {
            [c.navigationController popToViewController:this animated:YES];
            this.needRefresh = YES;
            this.haveUpdated = YES;
        };
    }else if (button.tag == 1){
        FSBestMobanController *moban = [[FSBestMobanController alloc] init];
        moban.account = self.table;
        [self.navigationController pushViewController:moban animated:YES];
        __weak typeof(self)this = self;
        moban.addSuccess = ^(FSBestMobanController *c) {
            [c.navigationController popToViewController:this animated:YES];
            this.needRefresh = YES;
            this.haveUpdated = YES;
        };
    }else if (button.tag == 2){
        FSBestSubjectsController *sub = [[FSBestSubjectsController alloc] init];
        sub.account = self.table;
        [self.navigationController pushViewController:sub animated:YES];
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 108 - FS_iPhone_X * 34) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.rowHeight = 54;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
        WEAKSELF(this);
        _tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [this bestAccountHandleDatas];
        }];

        UIView *h = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTHFC, _mass.count * 30 + 20)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [h addGestureRecognizer:tap];
        
        h.backgroundColor = FS_GreenColor;
        _tableView.tableHeaderView = h;
        
        [self refreshHeaderData];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _subjects.count;
}

static NSString *_key_name = @"name";
static NSString *_key_value = @"value";
static NSString *_key_show = @"show";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    NSDictionary *t = [_subjects objectAtIndex:indexPath.row];
    cell.textLabel.text = [t objectForKey:_key_name];
    cell.detailTextLabel.text = [t objectForKey:_key_show];
    return cell;
}

static NSString *_key_be = @"be";
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *t = [self->_subjects objectAtIndex:indexPath.row];
    NSString *be = [t objectForKey:_key_be];
    FSBestSubsubjectController *subController = [[FSBestSubsubjectController alloc] init];
    subController.table = self.table;
    subController.be = be;
    if (indexPath.row == 0) {
        subController.needThisYear = YES;
        subController.thisYear = _model.sr;
        subController.sum = _model.allsr;
        subController.all = [FSKit bankStyleDataThree:@(self->_model.sr)];
    }else if (indexPath.row == 1){
        subController.needThisYear = YES;
        subController.thisYear = _model.cb;
        subController.sum = _model.allcb;
        subController.all = [FSKit bankStyleDataThree:@(self->_model.cb)];
    }else{
        CGFloat value = [[t objectForKey:_key_value] doubleValue];
        subController.sum = value;
        subController.title = t[@"name"];
        subController.all = [FSKit bankStyleDataThree:t[_key_value]];
    }
    [self.navigationController pushViewController:subController animated:YES];
}

-(BOOL)navigationShouldPopOnBackButton{
    if (self.haveUpdated) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:_Notifi_sendSqlite3 object:nil];
        return NO;
    }
    return YES;
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
