//
//  FASelectController.m
//  myhome
//
//  Created by FudonFuchina on 2017/3/27.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSABOneminusController.h"
#import "FSDBSupport.h"
#import "MJRefresh.h"
#import "FATool.h"
#import "FSABListCell.h"
#import "FSABTrackModel.h"
#import "FSUIKit.h"

@interface FSABOneminusController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray         *dataSource;
@property (nonatomic,strong) NSMutableArray         *edArray;   // ed组
@property (nonatomic,strong) NSMutableArray         *memberArray;
@property (nonatomic,strong) NSMutableArray         *tracks;
@property (nonatomic,strong) UITableView            *tableView;
@property (nonatomic,assign) double                 sum;
@property (nonatomic,assign) NSInteger              page;
@property (nonatomic,assign) BOOL                   order;

@end

@implementation FSABOneminusController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self selectHandleDatas];
}

- (void)selectHandleDatas{
    NSInteger unit = 100;
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
    
    [self selectDesignViews];
}

- (void)bbiAction{
    self.order = !self.order;
    self.page = 0;
    [self selectHandleDatas];
}

- (void)selectDesignViews{
    if (_tableView) {
        [_tableView.mj_footer endRefreshing];
        [_tableView.mj_header endRefreshing];
        [_tableView reloadData];
        return;
    }
    self.title = [[NSString alloc] initWithFormat:@"%@%@%@元",[FATool hansForShort:self.type isCompany:self.isCompany],NSLocalizedString(@"Reduce", nil),self.je];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sort", nil) style:UIBarButtonItemStylePlain target:self action:@selector(bbiAction)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    [self.view addSubview:_tableView];
    WEAKSELF(this);
    _tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        this.page = 0;
        [this selectHandleDatas];
    }];
    this.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        this.page ++;
        [this selectHandleDatas];
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
    
    CGFloat trackNumber = 0;
    BOOL isPayoutOver = NO;
    if (![self.memberArray containsObject:entity.time]) {
        [self.memberArray addObject:entity.time];
        
        NSString *type = [[NSString alloc] initWithFormat:@"%@%@",self.type,_ING_KEY];
        if ([entity.atype isEqualToString:type]) {
            entity.brst = entity.brest;
            CGFloat arest = [entity.arest doubleValue];
            CGFloat rst = arest - je + _sum;
            CGFloat bridge = MAX(rst, 0);
            entity.arst =  [[NSString alloc] initWithFormat:@"%.6f",bridge];
            trackNumber = arest - bridge;
            _sum += arest;
            
            if (rst < 0) {
                isPayoutOver = YES;
            }
        }
        if ([entity.btype isEqualToString:type]) {
            entity.arst = entity.arest;
            CGFloat brest = [entity.brest doubleValue];
            CGFloat rst = brest - je + _sum;
            CGFloat bridge = MAX(rst, 0);
            entity.brst =  [[NSString alloc] initWithFormat:@"%.6f",bridge];
            trackNumber = brest - bridge;
            _sum += brest;
            
            if (rst < 0) {
                isPayoutOver = YES;
            }
        }
        
        FSABTrackModel *tModel = [[FSABTrackModel alloc] init];
        tModel.time = _time?:@(_fs_integerTimeIntevalSince1970()).stringValue;
        tModel.link = entity.time;
        tModel.type = [type isEqualToString:entity.atype]?@"a":@"b";
        tModel.je = [[NSString alloc] initWithFormat:@"%.6f",trackNumber];
        tModel.bz = isPayoutOver?[[NSString alloc] initWithFormat:@"%@ (总共：%.2f元)",self.bz,je]:self.bz;
        tModel.accname = self.accountName;
        [self.tracks addObject:tModel];
        
        [self.edArray addObject:entity];
    }else{
        [FSToast show:@"已选择过"];
    }

    CGFloat v = _sum - je;
    if (v >= 0) {
        [FSUIKit alert:UIAlertControllerStyleAlert controller:self title:NSLocalizedString(@"Confirm", nil) message:self.message actionTitles:@[NSLocalizedString(@"Confirm", nil)] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
            if (self.selectBlock) {
                NSArray *edArray = [self.edArray copy];
                NSArray *tracks = [self->_tracks copy];
                self.selectBlock(self,edArray,tracks);
            }
        } cancelTitle:NSLocalizedString(@"Cancel", nil) cancel:^(UIAlertAction *action) {
            [self backToInitStatus];
        } completion:nil];
    }else{
        NSString *rest = [[NSString alloc] initWithFormat:@"还需选择%.2f元",-v];
        [FSToast show:rest];
    }
}

- (void)backToInitStatus{
    [self.edArray removeAllObjects];
    [self.memberArray removeAllObjects];
    [self.tracks removeAllObjects];
    _sum = 0;
    [self selectHandleDatas];
    _tableView.contentOffset = CGPointZero;
}

- (NSMutableArray *)edArray{
    if (!_edArray) {
        _edArray = [[NSMutableArray alloc] init];
    }
    return _edArray;
}

- (NSMutableArray *)memberArray{
    if (!_memberArray) {
        _memberArray = [[NSMutableArray alloc] init];
    }
    return _memberArray;
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

