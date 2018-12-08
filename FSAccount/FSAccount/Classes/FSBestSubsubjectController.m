//
//  FSBestSubsubjectController.m
//  myhome
//
//  Created by FudonFuchina on 2018/4/6.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestSubsubjectController.h"
#import "FSBestSubjectModel.h"
#import "FSBestAccountDetailController.h"
#import "FSBestAccountAPI.h"
#import "FSUIKit.h"
#import "FSBestBeListController.h"
#import "FSPublic.h"
#import "FSMacro.h"

@interface FSBestSubsubjectController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView                            *tableView;
@property (nonatomic,strong) NSArray                                *list;
@property (nonatomic,assign) CGFloat                                cacheSum;

@end

@implementation FSBestSubsubjectController{
    CGFloat             _delta;
    BOOL                _needRefresh;
    UISegmentedControl  *_control;
    UIBarButtonItem     *_bbi;
    BOOL                _canUpdate;
    BOOL                _showRate;
    BOOL                _hideSubject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.sum < 0.001) {
        self.sum = 0.001;
    }
    
    if (_needThisYear) {
        _control = [[UISegmentedControl alloc] initWithItems:@[@"今年",@"所有"]];
        _control.selectedSegmentIndex = 0;
        _control.frame = CGRectMake(0, 4, 100, 36);
        [_control addTarget:self action:@selector(controlEvent) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = _control;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification) name:_Notifi_DetailUpdateCacheData object:nil];
    [self subsubjectHandleDatas];
}

- (void)controlEvent{
    self.needThisYear = _control.selectedSegmentIndex == 0;
    [self subsubjectHandleDatas];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_needRefresh) {
        _needRefresh = NO;
        [self needRefreshAlert];
    }
}

- (void)needRefreshAlert{
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:@"耗时服务" message:@"如果您更改过科目，需要刷新数据；\n如果只是更改了备注，可以不刷新。" actionTitles:@[@"刷新"] styles:@[@(UIAlertActionStyleDestructive)] handler:^(UIAlertAction *action) {
        __weak typeof(self)this = self;
        [self amendData:^{
            [this subsubjectHandleDatas];
        }];
    }];
}

- (void)handleNotification{
    _needRefresh = YES;
}

- (void)subsubjectHandleDatas{
    [FSBestAccountAPI bestAccount_home_sub_thread:self.table be:self.be thisYear:self.needThisYear call:^(NSArray<FSBestAccountCacheModel *> *list) {
        NSArray *subjects = [FSBestAccountAPI subSubjectForType:self.be forTable:self.table];
        [self handleData:subjects caches:list];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self subsubjectDesignViews];
        });
    }];
}

- (void)handleData:(NSArray *)list caches:(NSArray *)caches{
    CGFloat sum = 0;
    for (FSBestSubjectModel *m in list) {
        CGFloat psum = 0;
        CGFloat msum = 0;
        for (FSBestAccountCacheModel *cache in caches) {
            if ([m.be isEqualToString:cache.be] && [m.vl isEqualToString:cache.km]) {
                CGFloat pc = [cache.p doubleValue];
                CGFloat mc = [cache.m doubleValue];
                psum += pc;
                msum += mc;
            }
        }
        CGFloat delta = psum - msum;
        sum += delta;
        m.value = [FSKit bankStyleDataThree:@(delta)];
        m.v = delta;
    }
    self.cacheSum = sum;
    
    NSComparator cmptr = ^(FSBestSubjectModel *obj1, FSBestSubjectModel *obj2){
        if (obj1.v < obj2.v) {
            return (NSComparisonResult)NSOrderedDescending;
        }else if (obj1.v > obj2.v) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    self.list = [list sortedArrayUsingComparator:cmptr];
}

- (void)subsubjectDesignViews{
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64 - 50) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
        
        CGFloat w = WIDTHFC / 2;
        for (int x = 0; x < 2; x ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.backgroundColor = FS_GreenColor;
            button.frame = CGRectMake(w * x, _tableView.bottom, w - .5 * (1 - x), 50);
            button.tag = x;
            [button setTitle:x?@"隐藏科目":@"查看占比" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(seeRate:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
        }
        
        _bbi = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(needRefresh)];
        self.navigationItem.rightBarButtonItem = _bbi;
    }else{
        [_tableView reloadData];
    }
    
    CGFloat delta = 0;
    if (_control) {
        if (_control.selectedSegmentIndex == 0) {
            delta = fabs(_cacheSum - _thisYear);
            self.all = [FSKit bankStyleDataThree:@(_thisYear)];
        }else{
            delta = fabs(_cacheSum - _sum);
            self.all = [FSKit bankStyleDataThree:@(_sum)];
        }
    }else{
        delta = fabs(_cacheSum - _sum);
    }
    _delta = delta;
    
    if (fabs(delta) > 1) {
        NSString *title = [[NSString alloc] initWithFormat:@"%.2f",delta];
        [_bbi setTitle:title];
        _bbi.tintColor = UIColor.redColor;
        _canUpdate = YES;
    }else{
        [_bbi setTitle:self.all];
        _bbi.tintColor = nil;
        _canUpdate = NO;
    }
}

- (void)seeRate:(UIButton *)button{
    if (button.tag == 0) {
        _showRate = !_showRate;
        [button setTitle:_showRate?@"隐藏占比":@"查看占比" forState:UIControlStateNormal];
    }else if (button.tag == 1){
        _hideSubject = !_hideSubject;
        [button setTitle:_hideSubject?@"显示科目":@"隐藏科目" forState:UIControlStateNormal];
    }
    [_tableView reloadData];
}

- (void)needRefresh{
    if (!_canUpdate) {
        FSBestBeListController *beList = [[FSBestBeListController alloc] init];
        beList.table = self.table;
        beList.be = self.be;
        [self.navigationController pushViewController:beList animated:YES];
        return;
    }
    NSString *title = [[NSString alloc] initWithFormat:@"误差为%.2f元，更正误差?",_delta];
    NSString *change = @"更正（耗时操作）";
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:title actionTitles:@[change] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        WEAKSELF(this);
        [self amendData:^{
            [this subsubjectHandleDatas];
        }];
    }];
}

- (void)amendData:(void(^)(void))completion{
    BOOL isMain = NSThread.isMainThread;
    if (isMain) {
        [self showWaitView:YES];
    }
    _fs_dispatch_global_queue_async(^{
        NSString *error = [FSBestAccountAPI amendTable:self.table];
        _fs_dispatch_main_queue_async(^{
            if (error) {
                [FSUIKit showAlertWithMessage:error controller:self];
            }else{
                [self showWaitView:NO];
                [FSToast show:@"更正完成"];
                if (completion) {
                    completion();
                }
            }
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"c";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    FSBestSubjectModel *model = [self.list objectAtIndex:indexPath.row];
    if (_hideSubject) {
        cell.textLabel.text = @"* * * * *";
    }else{
        cell.textLabel.text = model.nm;
    }
    if (_showRate) {
        NSString *rate = [[NSString alloc] initWithFormat:@"%.2f%%",model.v / self.sum * 100];
        NSString *all = [[NSString alloc] initWithFormat:@"%@・%@",model.value,rate];
        NSAttributedString *attr = [FSKit attributedStringFor:all strings:@[rate] color:FS_GreenColor fontStrings:@[rate] font:[UIFont boldSystemFontOfSize:12]];
        cell.detailTextLabel.attributedText = attr;
    }else{
        cell.detailTextLabel.text = model.value;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FSBestSubjectModel *model = [self.list objectAtIndex:indexPath.row];
    FSBestAccountDetailController *detail = [[FSBestAccountDetailController alloc] init];
    detail.subject = model.vl;
    detail.table = self.table;
    detail.name = model.nm;
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)shakeEndActionFromShakeBase{
    [FSPublic shareAction:self view:_tableView];
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
