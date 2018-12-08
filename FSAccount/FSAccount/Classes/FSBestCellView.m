//
//  FSBestCellView.m
//  myhome
//
//  Created by FudonFuchina on 2018/4/5.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestCellView.h"
#import "FSBestAccountCell.h"
#import "FSKit.h"

@implementation FSBestCellView

- (void)setList:(NSArray<FSBestAccountModel *> *)list{
    _list = list;
    if (![list isKindOfClass:NSArray.class]) {
        _list = nil;
    }
    [self bestCellDesignViews];
}

- (void)bestCellDesignViews{
    if (!_tableView) {
        _tableView = [[FSReuseTableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self addSubview:_tableView];
        __weak typeof(self)this = self;
        _tableView.refresh_header = self.refresh_header;
        _tableView.refresh_footer = self.refresh_footer;
        
        _tableView.numberOfSections = ^NSInteger(UITableView *tableView) {
            return this.list.count;
        };
        _tableView.numberOfRowsInSection = ^NSInteger(UITableView *tableView, NSInteger section) {
            return 1;
        };
        _tableView.cellForRowAtIndexPath = ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *identifier = @"c";
            FSBestAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[FSBestAccountCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
                cell.trackCallback = this.trackCallback;
            }
            return cell;
        };
        _tableView.willDisplayCell = ^(UITableViewCell *cell, NSIndexPath *indexPath) {
            FSBestAccountCell *customCell = (FSBestAccountCell *)cell;
            FSBestAccountModel *entity = this.list[indexPath.section];
            customCell.model = entity;
        };
        
        _tableView.heightForRowAtIndexPath = ^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            FSBestAccountModel *entity = this.list[indexPath.section];
            return entity.cellHeight;
        };
        _tableView.heightForHeaderInSection = ^CGFloat(UITableView *tableView, NSInteger section) {
            return section == 0?10:.1;
        };
        _tableView.heightForFooterInSection = ^CGFloat(UITableView *tableView, NSInteger section) {
            return 5;
        };
        _tableView.didSelectRowAtIndexPath = ^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            FSBestAccountModel *entity = this.list[indexPath.section];
            if (this.clickCellEvent_selected) {
                entity.selectedTime = _fs_timeIntevalSince1970();
                entity.selected = !entity.selected;
                this.clickCellEvent_selected(this.list);
            }
            if (this.clickCellEvent_no_selected) {
                this.clickCellEvent_no_selected(entity,indexPath);
            }
            if (this.selectMode) {
                FSBestAccountCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                [cell setImageHidden:!entity.selected];
            }
        };
    }else{
        [_tableView endRefresh];
        [_tableView.tableView reloadData];
    }
}

- (void)endRefresh{
    [_tableView endRefresh];
}

- (void)reloadSection:(NSInteger)section{
    NSIndexSet *is = [NSIndexSet indexSetWithIndex:section];
    [_tableView.tableView reloadSections:is withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
