//
//  FSBestTwoMinusController.m
//  myhome
//
//  Created by FudonFuchina on 2018/4/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestTwoMinusController.h"
#import "FSBestAccountModel.h"
#import "FSBestAccountCell.h"
#import "FSBestCellView.h"
#import <FSUIKit.h>
#import "FSBestAccountAPI.h"
#import "FSToast.h"
#import "FuSoft.h"
#import "FSKit.h"
#import "FSKitDuty.h"

@interface FSBestTwoMinusController ()

@property (nonatomic,strong) UISegmentedControl *control;
@property (nonatomic,strong) NSMutableArray     *dataSource;

@property (nonatomic,strong) NSMutableArray     *firstArray;
@property (nonatomic,assign) BOOL               firstSelected;

@property (nonatomic,strong) NSMutableArray     *lastArray;
@property (nonatomic,assign) BOOL               lastSelected;

@property (nonatomic,copy)   NSString           *type;
@property (nonatomic,assign) BOOL               order;

@end

@implementation FSBestTwoMinusController{
    FSBestCellView      *_bestView;
}

- (void)controlAction:(UISegmentedControl *)control{
   [self reset];
}

- (void)reset{
    [FSToast show:@"重新开始"];
    [self.dataSource removeAllObjects];
    _control.selectedSegmentIndex = 0;
    [_firstArray removeAllObjects];
    _firstSelected = NO;
    [_lastArray removeAllObjects];
    _lastSelected = NO;
    [self twoHandleDatas];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self twoHandleDatas];
}

- (void)twoHandleDatas{
    FSBestSubjectModel *type = _subjects[_control.selectedSegmentIndex];
    self.type = type.vl;
    __block NSMutableArray *list = nil;
    _fs_dispatch_global_main_queue_async(^{
        list = [FSBestAccountAPI listForSubject:self.type table:self.table page:0 track:NO asc:self.order unit:500];
    }, ^{
        self.dataSource = list;
        self->_bestView.tableView.tableView.contentOffset = CGPointZero;
        [self twoDesignViews];
    });
}

- (void)orderAction{
    self.order = !self.order;
    if (_control.selectedSegmentIndex == 0) {
        _firstSelected = NO;
        [_firstArray removeAllObjects];
    }else if (_control.selectedSegmentIndex == 1){
        _lastSelected = NO;
        [_lastArray removeAllObjects];
    }
    _bestView.tableView.tableView.contentOffset = CGPointZero;
    [self twoHandleDatas];
}

- (void)twoDesignViews{
    if (_bestView) {
        _bestView.list = self.dataSource;
        return;
    }
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sort", nil) style:UIBarButtonItemStylePlain target:self action:@selector(orderAction)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    FSBestSubjectModel *aSubject = self.subjects.firstObject;
    FSBestSubjectModel *bSubject = self.subjects.lastObject;
    NSString *aName = nil;
    if ([aSubject.nm isKindOfClass:NSString.class] && aSubject.nm.length > 6) {
        aName = [aSubject.nm substringToIndex:6];
    }else{
        aName = aSubject.nm;
    }
    NSString *bName = nil;
    if ([bSubject.nm isKindOfClass:NSString.class] && bSubject.nm.length > 6) {
        bName = [bSubject.nm substringToIndex:6];
    }else{
        bName = bSubject.nm;
    }
    
    NSArray *array = @[aName?:@"",bName?:@""];
    _control = [[UISegmentedControl alloc] initWithItems:array];
    _control.selectedSegmentIndex = 0;
    _control.frame = CGRectMake(WIDTHFC / 2 - 50, 4, 100, 36);
    [_control addTarget:self action:@selector(controlAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _control;
    
    WEAKSELF(this);
    _bestView = [[FSBestCellView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64)];
    _bestView.selectMode = YES;
    [self.view addSubview:_bestView];
    _bestView.refresh_header = ^{
        [this reset];
    };
    _bestView.refresh_footer = ^{
        [FSToast show:@"没有更多数据"];
        [this endRefresh];
    };
    _bestView.clickCellEvent_selected = ^(NSArray *list) {
        [this clickEventEntity_list:list];
    };
    _bestView.list = self.dataSource;
}

- (void)endRefresh{
    [_bestView endRefresh];
}

- (void)clickEventEntity_list:(NSArray<FSBestAccountModel *> *)list{
    if (!_fs_isValidateArray(list)) {
        return;
    }
    
    CGFloat je = [self.je doubleValue];
    if (_control.selectedSegmentIndex == 0) {
        [_firstArray removeAllObjects];
        FSBestSubjectModel *subject = self.subjects.firstObject;
        NSInteger kemu = [subject.vl integerValue];
        CGFloat sum = 0;
        for (FSBestAccountModel *model in list) {
            if (model.selected) {
                [self.firstArray addObject:model];
                
                NSInteger aj = [model.aj integerValue];
                NSInteger bj = [model.bj integerValue];
                if (aj == kemu) {
                    CGFloat ar = [model.ar doubleValue];
                    sum += ar;
                }else if (bj == kemu){
                    CGFloat br = [model.br doubleValue];
                    sum += br;
                }
            }
        }
        if (sum >= je) {
            _firstSelected = YES;
            _control.selectedSegmentIndex = 1;
            [self twoHandleDatas];
        }else{
            NSString *show = [[NSString alloc] initWithFormat:@"还差%.2f元",je - sum];
            [FSToast show:show];
        }
    }else if (_control.selectedSegmentIndex == 1){
        [_lastArray removeAllObjects];
        FSBestSubjectModel *subject = self.subjects.lastObject;
        NSInteger kemu = [subject.vl integerValue];
        CGFloat sum = 0;
        for (FSBestAccountModel *model in list) {
            if (model.selected) {
                [self.lastArray addObject:model];
                
                NSInteger aj = [model.aj integerValue];
                NSInteger bj = [model.bj integerValue];
                if (aj == kemu) {
                    CGFloat ar = [model.ar doubleValue];
                    sum += ar;
                }else if (bj == kemu){
                    CGFloat br = [model.br doubleValue];
                    sum += br;
                }
            }
        }
        if (sum >= je) {
            _lastSelected = YES;
        }else{
            NSString *show = [[NSString alloc] initWithFormat:@"还差%.2f元",je - sum];
            [FSToast show:show];
        }
    }
    
    if (_firstSelected && _lastSelected) {
        if (self.completion) {
            FSBestSubjectModel *aSubject = self.subjects.firstObject;
            FSBestSubjectModel *bSubject = self.subjects.lastObject;
            NSString *addDesc = @"增加";
            NSString *minusDesc = @"减少";
            NSString *message = [[NSString alloc] initWithFormat:@"%@ %@,%@ %@?",aSubject.nm,aSubject.isp == 1?addDesc:minusDesc,bSubject.nm,bSubject.isp == 1?addDesc:minusDesc];
            
            [FSUIKit alert:UIAlertControllerStyleAlert controller:self title:@"确定?" message:message actionTitles:@[NSLocalizedString(@"Confirm", nil)] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
                NSArray *firsts = [FSKitDuty sortForResults:self.firstArray];
                NSArray *seconds = [FSKitDuty sortForResults:self.lastArray];
                self.completion(self,[Tuple2 v1:firsts v2:seconds]);
            } cancelTitle:NSLocalizedString(@"Cancel", nil) cancel:^(UIAlertAction *action) {
                [self reset];
            } completion:nil];
        }
    }
}

-(BOOL)navigationShouldPopOnBackButton{
    [FSKit popToController:@"FSBestAccountController" navigationController:self.navigationController animated:YES];
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
