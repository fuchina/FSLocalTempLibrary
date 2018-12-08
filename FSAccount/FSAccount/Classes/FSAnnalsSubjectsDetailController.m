//
//  FSAnnalsSubjectsDetailController.m
//  myhome
//
//  Created by FudonFuchina on 2018/7/15.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSAnnalsSubjectsDetailController.h"
#import "FSBestAccountAPI.h"
#import "FSBestAccountDetailController.h"
#import "FSDate.h"
#import "FSKit.h"
#import "FSMacro.h"

@interface FSAnnalsSubjectsDetailController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray        *list;
@property (nonatomic,strong) UITableView    *tableView;

@end

@implementation FSAnnalsSubjectsDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self detailHandleDatas];
}

- (void)detailHandleDatas{
    [FSBestAccountAPI bestAccount_home_sub_thread:self.table be:self.be year:self.year call:^(NSArray<FSBestAccountCacheModel *> *list) {
        NSArray *subjects = [FSBestAccountAPI subSubjectForType:self.be forTable:self.table];
        [self handleDatas:list subjects:subjects];
        _fs_dispatch_main_queue_async(^{
            [self detailDesignViews];
        });
    }];
}

- (void)handleDatas:(NSArray<FSBestAccountCacheModel *> *)list subjects:(NSArray *)subjects{
    if (!_fs_isValidateArray(list)) {
        return;
    }
    
    UIColor *red = APPCOLOR;
    UIColor *green = FS_GreenColor;
    NSString *p = @"+";
    for (FSBestSubjectModel *m in subjects) {
        CGFloat psum = 0;
        CGFloat msum = 0;
        for (FSBestAccountCacheModel *cache in list) {
            if ([m.be isEqualToString:cache.be] && [m.vl isEqualToString:cache.km]) {
                CGFloat pc = [cache.p doubleValue];
                CGFloat mc = [cache.m doubleValue];
                psum += pc;
                msum += mc;
            }
        }
        CGFloat delta = psum - msum;
        BOOL isPositive = delta > 0;
        NSString *vs = [[NSString alloc] initWithFormat:@"%@%@",isPositive?p:@"",[FSKit bankStyleDataThree:@(delta)]];
        m.value = vs;
        m.v = delta;
        m.color = isPositive?green:red;
    }
    
    NSMutableArray *newList = subjects.mutableCopy;
    [newList sortUsingComparator:^NSComparisonResult(FSBestSubjectModel *obj1, FSBestSubjectModel *obj2) {
        CGFloat one = obj1.v;
        CGFloat two = obj2.v;
        if (one > two) {
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
    
    CGFloat sum = 0;
    for (int x = 0; x < newList.count; x ++) {
        FSBestSubjectModel *m = newList[x];
        if (x) {
            CGFloat add = sum + m.v;
            sum = add;
            m.sum = add;
            m.sumShow = [FSKit bankStyleDataThree:@(add)];
        }else{
            sum = m.v;
            m.sum = m.v;
            m.sumShow = [FSKit bankStyleDataThree:@(sum)];
        }
    }
    self.list = newList;
}

- (void)detailDesignViews{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = UIView.new;
        _tableView.backgroundColor = UIColor.clearColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.rowHeight = 50;
        [self.view addSubview:_tableView];
        
        NSString *rest = [FSKit bankStyleDataThree:self.delta];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:rest style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.rightBarButtonItem = bbi;
    }else{
        [_tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"c";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        CGFloat x = WIDTHFC * 118 / 320;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, WIDTHFC - x, 50)];
        label.font = [UIFont systemFontOfSize:15];
        label.tag = 1000;
        [cell addSubview:label];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    FSBestSubjectModel *model = self.list[indexPath.row];
    cell.textLabel.text = model.nm;
    cell.detailTextLabel.text = model.sumShow;
    
    UILabel *label = [cell viewWithTag:1000];
    label.text = model.value;
    label.textColor = model.color;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FSBestSubjectModel *model = self.list[indexPath.row];
    
    __block NSInteger start = 0;
    __block NSInteger end = 0;
    _fs_dispatch_global_main_queue_async(^{
        NSInteger year = self.year.integerValue;
        start = [FSDate theFirstSecondOfYear:year] - 1;
        end = [FSDate theLastSecondOfYear:year] + 1;
    }, ^{
        FSBestAccountDetailController *detail = [[FSBestAccountDetailController alloc] init];
        detail.subject = model.vl;
        detail.table = self.table;
        detail.name = model.nm;
        detail.start = start;
        detail.end = end;
        [self.navigationController pushViewController:detail animated:YES];
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
