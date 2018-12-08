//
//  FSBestOneMinusController.m
//  myhome
//
//  Created by FudonFuchina on 2018/4/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestOneMinusController.h"
#import "FSBestAccountAPI.h"
#import "FSBestCellView.h"
#import "FSUIKit.h"
#import "UIViewController+BackButtonHandler.h"
#import "FSKitDuty.h"
#import "FSMacro.h"

@interface FSBestOneMinusController ()

@property (nonatomic,strong)    NSMutableArray     *list;
@property (nonatomic,strong)    NSMutableArray     *results;    // 将strong改成copy，results就总是不是mutable的了
@property (nonatomic,assign)    BOOL               order;

@end

@implementation FSBestOneMinusController{
    FSBestCellView      *_bestView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _results = [[NSMutableArray alloc] init];
    [self oneMinusHandleDatas];
}

- (void)oneMinusHandleDatas{
    NSAssert(_subject != nil, @"科目为Nil");
    NSAssert(_table != nil, @"表为Nil");

    __block NSMutableArray *list = nil;
    _fs_dispatch_global_main_queue_async(^{
        list = [FSBestAccountAPI listForSubject:self.subject.vl table:self.table page:0 track:NO asc:self.order unit:1000];
    }, ^{
        self.list = list;
        [self oneMinusDesignViews];
    });
}

- (void)reset{
    [_results removeAllObjects];
    [self oneMinusHandleDatas];
}

- (void)oneMinusDesignViews{
    if (!_bestView) {
        self.title = [[NSString alloc] initWithFormat:@"%@减少%.2f元",self.subject.nm,self.je.floatValue];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sort", nil) style:UIBarButtonItemStylePlain target:self action:@selector(orderActionOneMinus)];
        self.navigationItem.rightBarButtonItem = bbi;
        
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
            [this clickEventEntities_oneMinus_list:list];
        };
    }
    _bestView.list = self.list;
}

- (void)endRefresh{
    [_bestView endRefresh];
}

- (void)orderActionOneMinus{
    self.order = !self.order;
    [self oneMinusHandleDatas];
}

- (void)clickEventEntities_oneMinus_list:(NSArray<FSBestAccountModel *> *)list{
    if (!_fs_isValidateArray(list)) {
        return;
    }
    
    [_results removeAllObjects];
    NSInteger kemu = [self.subject.vl integerValue];
    NSString *sum = @"0";
    for (FSBestAccountModel *model in list) {
        if (model.selected) {
            [_results addObject:model];

            NSInteger aj = [model.aj integerValue];
            NSInteger bj = [model.bj integerValue];
            if (aj == kemu) {
                sum = _fs_highAccuracy_add(sum, model.ar);
            }else if (bj == kemu){
                sum = _fs_highAccuracy_add(sum, model.br);
            }
        }
    }
    
    NSComparisonResult compare = _fs_highAccuracy_compare(sum, self.je);
    if (compare != NSOrderedAscending) {
        [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:nil actionTitles:@[@"确定"] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
            NSArray *sortedList = [FSKitDuty sortForResults:self -> _results];
            self.completion(self,sortedList);
        } cancelTitle:@"取消" cancel:^(UIAlertAction *action) {
            [self reset];
            [UIView animateWithDuration:.3 animations:^{
                self->_bestView.tableView.tableView.contentOffset = CGPointMake(0, 0);
            }];
        } completion:nil];
    }else{
        NSString *show = [[NSString alloc] initWithFormat:@"还差%.2f元",_je.doubleValue - sum.doubleValue];
        [FSToast show:show];
    }
}

//// 排序
//- (NSArray<FSBestAccountModel *> *)sortForResults:(NSMutableArray<FSBestAccountModel *> *)list{
//    [list sortUsingComparator:^NSComparisonResult(FSBestAccountModel *obj1, FSBestAccountModel *obj2) {
//        if (obj1.selectedTime > obj2.selectedTime) {
//            return NSOrderedDescending;
//        }else{
//            return NSOrderedAscending;
//        }
//    }];
//    return list;
//}

-(BOOL)navigationShouldPopOnBackButton{
    [FSKit popToController:@"FSBestAccountController" navigationController:self.navigationController animated:YES];
    return NO;
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
