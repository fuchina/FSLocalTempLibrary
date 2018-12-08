//
//  FATwoMinusController.m
//  myhome
//
//  Created by FudonFuchina on 2017/3/27.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSABTwominusController.h"
#import "FSDBSupport.h"
#import "MJRefresh.h"
#import "FATool.h"
#import "FSABModel.h"
#import "FSABListCell.h"
#import "FSABTrackModel.h"
#import "UIViewController+BackButtonHandler.h"
#import <FSUIKit.h>

@interface FSABTwominusController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UISegmentedControl *control;
@property (nonatomic,strong) NSMutableArray     *dataSource;

@property (nonatomic,strong) NSMutableArray     *firstArray;
@property (nonatomic,strong) NSMutableArray     *firstMember;
@property (nonatomic,assign) CGFloat            firstSum;
@property (nonatomic,assign) BOOL               firstSelected;
@property (nonatomic,strong) NSMutableArray     *lastArray;
@property (nonatomic,strong) NSMutableArray     *lastMember;
@property (nonatomic,assign) CGFloat            lastSum;
@property (nonatomic,assign) BOOL               lastSelected;
@property (nonatomic,assign) NSInteger          page;
@property (nonatomic,strong) UITableView        *tableView;
@property (nonatomic,copy)   NSString           *type;
@property (nonatomic,strong) NSMutableArray     *tracks;
@property (nonatomic,assign) BOOL               order;

@end

@implementation FSABTwominusController

- (void)controlAction:(UISegmentedControl *)control{
    self.page = 0;
    [self twoHandleDatas];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self twoHandleDatas];
}

- (void)twoHandleDatas{
    NSInteger unit = 30;
    self.type = _types[_control.selectedSegmentIndex];
    NSString *condition = [[NSString alloc] initWithFormat:@"%@%@",self.type,_ING_KEY];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE ((atype = '%@' AND cast(arest as REAL) > 0) OR (btype = '%@' AND cast(brest as REAL) > 0)) order by cast(time as REAL) %@ limit %@,%@;",_accountName,condition,condition,self.order?@"DESC":@"ASC",@(self.page * unit),@(unit)];
    NSMutableArray *bArray = [FSDBSupport querySQL:sql class:FSABModel.class tableName:_accountName];
    for (FSABModel *model in bArray) {
        [model processPropertiesWithType:condition canSeeTrack:NO search:nil isCompany:self.isCompany];
    }
    
    if (self.page) {
        [self.dataSource addObjectsFromArray:bArray];
    }else{
        self.dataSource = bArray;
        self.tableView.contentOffset = CGPointZero;
    }
    [self twoDesignViews];
}

- (void)orderAction{
    self.order = !self.order;
    self.page = 0;
    [self twoHandleDatas];
}

- (void)twoDesignViews{
    if (_tableView) {
        [_tableView.mj_footer endRefreshing];
        [_tableView.mj_header endRefreshing];
        [_tableView reloadData];
        return;
    }
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sort", nil) style:UIBarButtonItemStylePlain target:self action:@selector(orderAction)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    NSArray *array = @[[FATool hansForShort:_types[0] isCompany:self.isCompany],[FATool hansForShort:_types[1] isCompany:self.isCompany]];
    _control = [[UISegmentedControl alloc] initWithItems:array];
    _control.selectedSegmentIndex = 0;
    _control.frame = CGRectMake(WIDTHFC / 2 - 50, 4, 100, 36);
    [_control addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _control;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:_tableView];
    WEAKSELF(this);
    _tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        this.page = 0;
        [this twoHandleDatas];
    }];
    this.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        this.page ++;
        [this twoHandleDatas];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (FSABListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    FSABListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[FSABListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.index = indexPath.section;
    
    FSABModel *entity = _dataSource[indexPath.section];
    [cell flowConfigDataWithEntity:entity];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSABModel *entity = _dataSource[indexPath.section];
    return entity.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0?10:.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FSABModel *entity = _dataSource[indexPath.section];
    CGFloat je = [self.je doubleValue];
    
    if (_control.selectedSegmentIndex == 0) {
        if (!_firstSelected) {
            if (![self.firstMember containsObject:entity.aid]) {
                [self.firstMember addObject:entity.aid];
                
                CGFloat trackNumber = 0;
                BOOL changedA = YES;
                BOOL isPayoutOver = NO;
                NSString *type = [[NSString alloc] initWithFormat:@"%@%@",self.type,_ING_KEY];
                if ([entity.atype isEqualToString:type]) {
                    entity.brst = entity.brest;
                    CGFloat arest = [entity.arest doubleValue];
                    CGFloat rst = arest - je + _firstSum;
                    CGFloat bridge = MAX(rst, 0);
                    entity.arst =  [[NSString alloc] initWithFormat:@"%.6f",bridge];
                    trackNumber = arest - bridge;
                    _firstSum += arest;
                    
                    if (rst < 0) {
                        isPayoutOver = YES;
                    }
                }
                if ([entity.btype isEqualToString:type]) {
                    entity.arst = entity.arest;
                    changedA = NO;
                    CGFloat brest = [entity.brest doubleValue];
                    CGFloat rst = brest - je + _firstSum;
                    CGFloat bridge = MAX(rst, 0);
                    entity.brst =  [[NSString alloc] initWithFormat:@"%.6f",bridge];
                    trackNumber = brest - bridge;
                    _firstSum += brest;
                    
                    if (rst < 0) {
                        isPayoutOver = YES;
                    }
                }
                
                FSABTrackModel *tModel = [[FSABTrackModel alloc] init];
                tModel.time = @(_fs_integerTimeIntevalSince1970()).stringValue;
                tModel.link = entity.time;
                tModel.type = [type isEqualToString:entity.atype]?@"a":@"b";
                tModel.je = [[NSString alloc] initWithFormat:@"%.6f",trackNumber];
                tModel.bz = isPayoutOver?[[NSString alloc] initWithFormat:@"%@ (总共：%.2f元)",self.bz,je]:self.bz;
                tModel.accname = self.accountName;
                [self.tracks addObject:tModel];

                [self.firstArray addObject:entity];
            }else{
                [FSToast show:@"已选择"];
            }
            
            if ((_firstSum - je) >= 0) {
                _firstSelected = YES;
                self.page = 0;
                _control.selectedSegmentIndex = 1;
                [self twoHandleDatas];
            }else{
                NSString *rest = [[NSString alloc] initWithFormat:@"还需选择%.2f元",(je - _firstSum)];
                [FSToast show:rest];
            }
        }
    }else{
        if (!_lastSelected) {
            if (![self.lastMember containsObject:entity.aid]) {
                [self.lastMember addObject:entity.aid];
                
                BOOL hasSelected = [self.firstMember containsObject:entity.aid];
                CGFloat trackNumber = 0;
                BOOL isPayoutOver = NO;
                NSString *type = [[NSString alloc] initWithFormat:@"%@%@",self.type,_ING_KEY];
                if ([entity.atype isEqualToString:type]) {
                    if (hasSelected) {
                        for (FSABModel *m in self.firstArray) {
                            if ([m.aid integerValue] == [entity.aid integerValue]) {
                                entity.brst = m.brst;break;
                            }
                        }
                    }else{
                        entity.brst = entity.brest;
                    }
                    CGFloat arest = [entity.arest doubleValue];
                    CGFloat rst = arest - je + _lastSum;
                    CGFloat newRest = MAX(rst, 0);
                    entity.arst =  [[NSString alloc] initWithFormat:@"%.6f",newRest];
                    trackNumber = arest - newRest;
                    _lastSum += arest;
                    
                    if (rst < 0) {
                        isPayoutOver = YES;
                    }
                }
                
                if ([entity.btype isEqualToString:type]) {
                    if (hasSelected) {
                        for (FSABModel *m in self.firstArray) {
                            if ([m.aid integerValue] == [entity.aid integerValue]) {
                                entity.arst = m.arst;break;
                            }
                        }
                    }else{
                        entity.arst = entity.arest;
                    }
                    CGFloat brest = [entity.brest doubleValue];
                    CGFloat rst = brest - je + _lastSum;
                    CGFloat newRest = MAX(rst, 0);
                    entity.brst =  [[NSString alloc] initWithFormat:@"%.6f",newRest];
                    trackNumber = brest - newRest;
                    _lastSum += brest;
                    
                    if (rst < 0) {
                        isPayoutOver = YES;
                    }
                }
                
                FSABTrackModel *tModel = [[FSABTrackModel alloc] init];
                tModel.time = @(_fs_integerTimeIntevalSince1970()).stringValue;
                tModel.link = entity.time;
                tModel.type = [type isEqualToString:entity.atype]?@"a":@"b";
                tModel.je = [[NSString alloc] initWithFormat:@"%.6f",trackNumber];
                tModel.bz = isPayoutOver?[[NSString alloc] initWithFormat:@"%@ (总共：%.2f元)",self.bz,je]:self.bz;
                tModel.accname = self.accountName;
                [self.tracks addObject:tModel];
                
                [self.lastArray addObject:entity];
            }else{
                [FSToast show:@"已选择过"];
            }
            
            if ((_lastSum - je) >= 0) {
                _lastSelected = YES;
            }else{
                NSString *rest = [[NSString alloc] initWithFormat:@"还需选择%.2f元",(je - _lastSum)];
                [FSToast show:rest];
            }
        }
    }
    
    if (_firstSelected && _lastSelected) {
        if (self.completion) {
            NSString *message = [[NSString alloc] initWithFormat:@"%@ %@,%@ %@?",[FATool hansForShort:self.types[0] isCompany:self.isCompany],NSLocalizedString(@"Reduce", nil),[FATool hansForShort:self.types[1] isCompany:self.isCompany],NSLocalizedString(@"Reduce", nil)];
            
            [FSUIKit alert:UIAlertControllerStyleAlert controller:self title:@"确定?" message:message actionTitles:@[NSLocalizedString(@"Confirm", nil)] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
                NSMutableArray *allEDs = [[NSMutableArray alloc] initWithArray:self.firstArray];
                [allEDs addObjectsFromArray:self.lastArray];
                
                // 如果同一条数据被加在里面，一条改变了arest，一条改变了brest，后一条数据会干扰前一条数据；
                NSMutableArray *theSames = [[NSMutableArray alloc] init];
                NSMutableArray *datas = [[NSMutableArray alloc] init];
                for (int x = 0; x < allEDs.count; x ++) {
                    FSABModel *model = allEDs[x];
                    if (![datas containsObject:model.aid]) {
                        [datas addObject:model.aid];
                    }else{
                        [theSames addObject:model];
                    }
                }

                for (int y = 0; y < theSames.count; y ++) {
                    FSABModel *model = [theSames objectAtIndex:y];
                    for (int x = 0; x < allEDs.count; x ++) {
                        FSABModel *abModel = allEDs[x];
                        if ([abModel.aid  integerValue] != [model.aid integerValue]) {
                            continue;
                        }else{
                            CGFloat arest = [model.arst doubleValue];
                            CGFloat brest = [model.brst doubleValue];
                            CGFloat mArest = [abModel.arst doubleValue];
                            CGFloat mBrest = [abModel.brst doubleValue];

                            CGFloat newA = MIN(mArest, arest);
                            CGFloat newB = MIN(mBrest, brest);

                            abModel.arst = [[NSString alloc] initWithFormat:@"%.6f",newA];
                            abModel.brst = [[NSString alloc] initWithFormat:@"%.6f",newB];
                            model.arst = abModel.arst;
                            model.brst = abModel.brst;
                        }
                    }
                }

                [allEDs removeObjectsInArray:theSames];
                
                self.completion(self,allEDs,[self.tracks copy]);
            } cancelTitle:NSLocalizedString(@"Cancel", nil) cancel:^(UIAlertAction *action) {
                [FSKit popToController:@"FSABOverviewController" navigationController:self.navigationController animated:YES];
            } completion:nil];
        }
    }
}

-(BOOL)navigationShouldPopOnBackButton{
    [FSKit popToController:@"FSABOverviewController" navigationController:self.navigationController animated:YES];
    return NO;
}

- (NSMutableArray *)firstArray{
    if (!_firstArray) {
        _firstArray = [[NSMutableArray alloc] init];
    }
    return _firstArray;
}

- (NSMutableArray *)lastArray{
    if (!_lastArray) {
        _lastArray = [[NSMutableArray alloc] init];
    }
    return _lastArray;
}

- (NSMutableArray *)firstMember{
    if (!_firstMember) {
        _firstMember = [[NSMutableArray alloc] init];
    }
    return _firstMember;
}

- (NSMutableArray *)lastMember{
    if (!_lastMember) {
        _lastMember = [[NSMutableArray alloc] init];
    }
    return _lastMember;
}

- (NSMutableArray *)tracks{
    if (!_tracks) {
        _tracks = [[NSMutableArray alloc] init];
    }
    return _tracks;
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

