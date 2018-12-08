//
//  FSBestCellView.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/5.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestCellView.h"
#import "FSReuseTableView.h"
#import "FSBestAccountModel.h"

@interface FSBestCellView : UIView

@property (nonatomic,assign) BOOL               selectMode;

@property (nonatomic,strong) FSReuseTableView   *tableView;

@property (nonatomic,strong) NSArray<FSBestAccountModel *> *list;

@property (nonatomic,copy) void (^refresh_header)(void);
@property (nonatomic,copy) void (^refresh_footer)(void);

@property (nonatomic,copy) void (^clickCellEvent_selected)(NSArray<FSBestAccountModel *> *list);
@property (nonatomic,copy) void (^clickCellEvent_no_selected)(FSBestAccountModel *bModel,NSIndexPath *indexPath);
@property (nonatomic,copy) void (^trackCallback)(FSBestAccountModel *bModel,NSInteger markSubject,NSString *name); // markSubject 1为第一个科目，2为第二个科目

- (void)endRefresh;

- (void)reloadSection:(NSInteger)section;

@end
