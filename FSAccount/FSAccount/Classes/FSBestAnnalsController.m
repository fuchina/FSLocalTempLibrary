//
//  FSBestAnnalsController.m
//  myhome
//
//  Created by FudonFuchina on 2018/6/24.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestAnnalsController.h"
#import "FSAnnalCell.h"
#import "FSBestAccountAPI.h"
#import "FSBestFlowController.h"
#import "FSBestAnnalsDetailController.h"
#import "FSPublic.h"
#import "FSKit.h"

@interface FSBestAnnalsController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView            *tableView;
@property (nonatomic,strong) NSMutableDictionary    *list;
@property (nonatomic,strong) NSMutableArray         *years;

@end

@implementation FSBestAnnalsController

- (void)viewDidLoad {
    [super viewDidLoad];
    _list = [NSMutableDictionary new];
    _years = [NSMutableArray new];
    [self bestAnnalsHandleDatas];
}

- (void)shakeEndActionFromShakeBase{
    [FSPublic shareAction:self view:_tableView];
}

- (void)bestAnnalsHandleDatas{
    _fs_dispatch_global_main_queue_async(^{
        NSArray *list = [FSBestAccountAPI annalsAndFlows:self.table];
        [self handleDatas:list];
    }, ^{
        [self bestAnnalsDesignViews];
    });
}

- (void)handleDatas:(NSArray *)list{
    if (_fs_isValidateArray(list)) {
        static NSString *be = @"be";
        static NSString *yr = @"yr";

        static NSString *sr = @"sr";
        static NSString *cb = @"cb";
        static NSString *lr = @"lr";
        static NSString *jlv = @"jlv";
        
        static NSString *p = @"p";
        static NSString *m = @"m";
        NSMutableDictionary *handles = [[NSMutableDictionary alloc] init];
        for (NSDictionary *model in list) {
            NSInteger ibe = [model[be] integerValue];
            BOOL isSR = ibe == FSBestAccountSubjectType1SR;
            BOOL isCB = ibe == FSBestAccountSubjectType2CB;
            CGFloat pv = [model[p] doubleValue];
            CGFloat mv = [model[m] doubleValue];
            CGFloat delta = pv - mv;
            
            NSString *myr = model[yr];
            if (myr == nil) {
                return;
            }
            if (![self.years containsObject:myr]) {
                [self.years addObject:myr];
            }
            
            NSMutableDictionary *values = [handles objectForKey:myr];
            if (!values) {
                values = [NSMutableDictionary new];
                if (isSR) {
                    [values setObject:@(delta).stringValue forKey:sr];
                }else if (isCB){
                    [values setObject:@(delta).stringValue forKey:cb];
                }
            }else{
                if (isSR) {
                    CGFloat s_sr = [[values objectForKey:sr] doubleValue];
                    s_sr += delta;
                    [values setObject:@(s_sr).stringValue forKey:sr];
                }else if (isCB){
                    CGFloat s_cb = [[values objectForKey:cb] doubleValue];
                    s_cb += delta;
                    [values setObject:@(s_cb).stringValue forKey:cb];
                }
            }
            [handles setObject:values forKey:myr];
        }
        
        NSArray *sortedYears = [self.years sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            NSInteger front = [obj1 integerValue];
            NSInteger back = [obj2 integerValue];
            return front < back;
        }];
        self.years = (NSMutableArray *)sortedYears;
        
        for (NSString *year in self.years) {
            NSMutableDictionary *dic = [handles objectForKey:year];
            CGFloat msr = [[dic objectForKey:sr] doubleValue];
            CGFloat mcb = [[dic objectForKey:cb] doubleValue];
            CGFloat mlr = msr - mcb;
            CGFloat mjlv = 0;
            if (msr != 0) {
                mjlv = mlr / msr;
            }
            
            static NSString *gn = @"gn";
            BOOL isGreen = mlr > 0.0;
            
            NSString *showSR = [FSKit bankStyleDataThree:@(msr)];
            NSString *showCB = [FSKit bankStyleDataThree:@(mcb)];
            NSString *showLR = [FSKit bankStyleDataThree:@(mlr)];
            NSString *showJLV = [[NSString alloc] initWithFormat:@"%.2f%%",mjlv * 100];
            
            NSDictionary *need = @{sr:showSR,cb:showCB,lr:showLR,jlv:showJLV,gn:@(isGreen)};
            [self.list setObject:need forKey:year];
        }
    }
}

- (void)bestAnnalsDesignViews{
    if (!_tableView) {
        self.title = NSLocalizedString(@"Annals", nil);        
        UIBarButtonItem *flow = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Flow", nil) style:UIBarButtonItemStylePlain target:self action:@selector(seeFlow)];
        self.navigationItem.rightBarButtonItem = flow;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.rowHeight = 140;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
        [self.view addSubview:_tableView];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    }else{
        [_tableView reloadData];
    }
}

- (void)seeFlow{
    FSBestFlowController *flow = [[FSBestFlowController alloc] init];
    flow.table = self.table;
    [self.navigationController pushViewController:flow animated:YES];
}

#pragma mark
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.years.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (FSAnnalCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    FSAnnalCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FSAnnalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSInteger section = indexPath.section;
    if (self.years.count > section) {
        NSString *year = [self.years objectAtIndex:section];
        NSDictionary *dic = [self.list objectForKey:year];
        [cell configDataBest:dic];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *year = [self.years objectAtIndex:section];
    if (_fs_isValidateString(year)) {
        return year;
    }
    return @"-";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return .1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *year = [self.years objectAtIndex:indexPath.section];
    FSBestAnnalsDetailController *annalsDetail = [[FSBestAnnalsDetailController alloc] init];
    annalsDetail.table = self.table;
    annalsDetail.year = year;
    [self.navigationController pushViewController:annalsDetail animated:YES];
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
