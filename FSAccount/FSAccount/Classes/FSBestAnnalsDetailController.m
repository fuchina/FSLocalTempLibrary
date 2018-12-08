//
//  FSBestAnnalsDetailController.m
//  myhome
//
//  Created by FudonFuchina on 2018/7/8.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestAnnalsDetailController.h"
#import "FSBestAccountAPI.h"
#import "FSTitleContentView.h"
#import "FSUIKit.h"
#import "FSAnnalsSubjectsDetailController.h"
#import "FSKit.h"
#import "FSMacro.h"

@interface FSBestAnnalsDetailController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,strong) NSArray        *rests;
@property (nonatomic,strong) NSArray        *deltas;
@property (nonatomic,strong) NSArray        *heads;

@end

@implementation FSBestAnnalsDetailController{
    UIButton    *_frontButton;
    UIButton    *_nextButton;
    BOOL        _useCache;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initConfigs];
}

- (void)initConfigs{
    _fs_dispatch_global_queue_async(^{
        NSString *chk = [[NSString alloc] initWithFormat:@"accbeUpdated_chk_%@",self.table];
        NSInteger ck_time = [_fs_userDefaults_objectForKey(chk) integerValue];
        NSString *tk = [[NSString alloc] initWithFormat:@"accbeUpdated_tk_%@",self.table];
        NSInteger tk_time = [_fs_userDefaults_objectForKey(tk) integerValue];
        if (ck_time == tk_time) {
            self->_useCache = YES;
        }else{
            if (ck_time) {
                _fs_userDefaults_setObjectForKey(@(ck_time), tk);
            }
        }
        [self adHandleDatas:self.year.integerValue];
    });
}

- (void)adHandleDatas:(NSInteger)year{
    _fs_dispatch_global_main_queue_async(^{
        NSDictionary *dic = [FSBestAccountAPI annalsForTable:self.table year:year useCacheIfExist:self ->_useCache];
        if (!_fs_isValidateDictionary(dic)) {
            _fs_dispatch_main_queue_async(^{
                [FSToast show:@"无更多数据"];
            });
            return;
        }else{
            self.year = @(year).stringValue;
        }
        NSArray *heads = dic[@"1"];
        static NSString *_zero_ = @"0.00";
        static NSString *_zero_rate_ = @"0.00%";
        NSString *sr = _zero_;NSString *cb = _zero_;NSString *lr = _zero_;
        NSString *zzc = _zero_;NSString *fz = _zero_;NSString *jzc = _zero_;
        NSString *jlv = _zero_rate_;NSString *zzl = _zero_rate_;
        NSString *jzs = _zero_rate_;NSString *atr = _zero_rate_;
        if (_fs_isValidateArray(heads) && heads.count > 9) {
            sr = [FSKit bankStyleDataThree:heads[0]];
            cb = [FSKit bankStyleDataThree:heads[1]];
            lr = [FSKit bankStyleDataThree:heads[2]];
            zzc = [FSKit bankStyleDataThree:heads[4]];
            fz = [FSKit bankStyleDataThree:heads[5]];
            jzc = [FSKit bankStyleDataThree:heads[6]];

            CGFloat mjlv = [heads[3] doubleValue];
            jlv = [[NSString alloc] initWithFormat:@"%.2f%%",mjlv * 100];
            
            CGFloat mzzl = [heads[7] doubleValue];
            zzl = [[NSString alloc] initWithFormat:@"%.2f%%",mzzl * 100];
            
            CGFloat mroe = [heads[8] doubleValue];
            jzs = [[NSString alloc] initWithFormat:@"%.2f%%",mroe * 100];
            
            CGFloat mzzs = [heads[9] doubleValue];
            atr = [[NSString alloc] initWithFormat:@"%.2f%%",mzzs * 100];
        }
        self.heads = @[
                       [Tuple2 v1:@"收入" v2:sr],
                       [Tuple2 v1:@"成本" v2:cb],
                       [Tuple2 v1:@"利润" v2:lr],
                       [Tuple2 v1:@"净利率" v2:jlv],
                       [Tuple2 v1:@"总资产" v2:zzc],
                       [Tuple2 v1:@"总负债" v2:fz],
                       [Tuple2 v1:@"净资产" v2:jzc],
                       [Tuple2 v1:@"资产负债率" v2:zzl],
                       [Tuple2 v1:@"净资产收益率" v2:jzs],
                       [Tuple2 v1:@"总资产周转率" v2:atr],
                       ];
        
        NSArray *deltas = dic[@"2"];
        if (_fs_isValidateArray(deltas) && deltas.count > 4) {
            NSMutableArray *d = [[NSMutableArray alloc] init];
            UIColor *green = FS_GreenColor;
            UIColor *red = APPCOLOR;
            NSString *p = @"+";NSString *m = @"-";
            for (int x = 0; x < deltas.count; x ++) {
                NSNumber *v = deltas[x];
                BOOL isGreen = v.doubleValue > 0;
                NSString *show = [[NSString alloc] initWithFormat:@"%@%@",isGreen?p:m,[FSKit bankStyleDataThree:v]];
                Tuple3 *t = [Tuple3 v1:show v2:isGreen?green:red v3:v];
                [d addObject:t];
            }
            self.deltas = [d copy];
        }else{
            NSNumber *n_zero = @0;
            self.deltas = @[
                            [Tuple3 v1:_zero_ v2:APPCOLOR v3:n_zero],
                            [Tuple3 v1:_zero_ v2:APPCOLOR v3:n_zero],
                            [Tuple3 v1:_zero_ v2:APPCOLOR v3:n_zero],
                            [Tuple3 v1:_zero_ v2:APPCOLOR v3:n_zero],
                            [Tuple3 v1:_zero_ v2:APPCOLOR v3:n_zero],
                            ];
        }
        
        NSArray *rests = dic[@"3"];
        NSString *ldzc = _zero_;
        NSString *fldzc = _zero_;
        NSString *ldfz = _zero_;
        NSString *fldfz = _zero_;
        NSString *syzqy = _zero_;
        if (_fs_isValidateArray(rests) && rests.count > 4) {
            ldzc = [FSKit bankStyleDataThree:rests[0]];
            fldzc = [FSKit bankStyleDataThree:rests[1]];
            ldfz = [FSKit bankStyleDataThree:rests[2]];
            fldfz = [FSKit bankStyleDataThree:rests[3]];
            syzqy = [FSKit bankStyleDataThree:rests[4]];
        }
        self.rests = @[
                       [Tuple3 v1:@"流动资产" v2:ldzc v3:@(FSBestAccountSubjectType3LDZC)],
                       [Tuple3 v1:@"非流动资产" v2:fldzc v3:@(FSBestAccountSubjectType4FLDZC)],
                       [Tuple3 v1:@"流动负债" v2:ldfz v3:@(FSBestAccountSubjectType5LDFZ)],
                       [Tuple3 v1:@"非流动负债" v2:fldfz v3:@(FSBestAccountSubjectType6FLDFZ)],
                       [Tuple3 v1:@"所有者本金" v2:syzqy v3:@(FSBestAccountSubjectType7SYZQY)],
                       ];
        
    }, ^{
        [self adDesignViews];
    });
}

- (void)adDesignViews{
    self.title = self.year;
    if (!_tableView) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(bbiClick)];
        self.navigationItem.rightBarButtonItem = bbi;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 110) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = UIColor.clearColor;
        [self.view addSubview:_tableView];
        
        CGFloat w = WIDTHFC / 2;
        for (int x = 0; x < 2; x ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake((w + 1) * x, HEIGHTFC - 46 - FS_iPhone_X * 34, w, 46);
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            button.backgroundColor = FSAPPCOLOR;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            if (x) {
                _nextButton = button;
            }else{
                _frontButton = button;
            }
        }
    }else{
        [_tableView reloadData];
    }
    
    NSInteger front = self.year.integerValue - 1;
    [_frontButton setTitle:@(front).stringValue forState:UIControlStateNormal];
    NSInteger back = self.year.integerValue + 1;
    [_nextButton setTitle:@(back).stringValue forState:UIControlStateNormal];
    [self configTableHead];
}

- (void)buttonClick:(UIButton *)button{
    NSInteger year = self.year.integerValue;
    if (button == _frontButton) {
        [self adHandleDatas:year - 1];
    }else if (button == _nextButton){
        [self adHandleDatas:year + 1];
    }
}

- (void)configTableHead{
    UIView *head = _tableView.tableHeaderView;
    if (!head) {
        head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTHFC, 0)];
        head.backgroundColor = FS_GreenColor;
    }
    
    for (int x = 0; x < self.heads.count; x ++) {
        Tuple2 *t = self.heads[x];
        FSTitleContentView *tc = [_tableView.tableHeaderView viewWithTag:TAG_VIEW + x];
        if (!tc) {
            tc = [[FSTitleContentView alloc] initWithFrame:CGRectMake(15, 10 + x * 30, WIDTHFC - 28, 30)];
            tc.tag = TAG_VIEW + x;
            tc.label.textColor = [UIColor whiteColor];
            tc.contentLabel.textColor = [UIColor whiteColor];
            [head addSubview:tc];
        }
        tc.label.text = t._1;
        tc.contentLabel.text = t._2;
    }
    head.height = self.heads.count * 30 + 20;
    _tableView.tableHeaderView = head;
}

- (void)bbiClick{
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:@"提示" message:@"如果觉得数据不对，可以点击刷新" actionTitles:@[@"刷新"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        self -> _useCache = NO;
        [self adHandleDatas:self.year.integerValue];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.rests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"c";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.detailTextLabel.textColor = UIColor.blackColor;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(WIDTHFC * 118 / 320, 0, WIDTHFC - 130, 60)];
        label.tag = 1000;
        label.font = [UIFont boldSystemFontOfSize:12];
        [cell addSubview:label];
    }
    Tuple3 *txt = self.rests[indexPath.row];
    cell.textLabel.text = txt._1;
    cell.detailTextLabel.text = txt._2;
    
    UILabel *label = [cell viewWithTag:1000];
    if (self.deltas.count > indexPath.row) {
        Tuple3 *t = self.deltas[indexPath.row];
        label.text = t._1;
        label.textColor = t._2;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tuple3 *txt = self.rests[indexPath.row];
    Tuple3 *de = self.deltas[indexPath.row];
    FSAnnalsSubjectsDetailController *detail = [[FSAnnalsSubjectsDetailController alloc] init];
    detail.year = self.year;
    detail.table = self.table;
    detail.be = txt._3;
    detail.delta = de._3;
    detail.title = txt._1;
    [self.navigationController pushViewController:detail animated:YES];
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
