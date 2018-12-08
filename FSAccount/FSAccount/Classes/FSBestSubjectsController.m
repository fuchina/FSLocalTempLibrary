//
//  FSBestSubjectsController.m
//  myhome
//
//  Created by FudonFuchina on 2018/6/16.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestSubjectsController.h"
#import "FSAddBestSubjectController.h"
#import "FSBestAccountAPI.h"
#import "FSUIKit.h"
#import "FSShopClassView.h"
#import "FSKit.h"
#import "FSMacro.h"

@interface FSBestSubjectsController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView                *tableView;
@property (nonatomic,strong) NSArray                    *all;
@property (nonatomic,strong) NSArray                    *list;
@property (nonatomic,assign) NSInteger                  index;
@property (nonatomic,assign) FSBestAccountSubjectType   type;

@end

@implementation FSBestSubjectsController{
    NSMutableArray *_sr;
    NSMutableArray *_cb;
    NSMutableArray *_ldzc;
    NSMutableArray *_fldzc;
    NSMutableArray *_ldfz;
    NSMutableArray *_fldfz;
    NSMutableArray *_syzqy;
    
    NSInteger       _count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _type = FSBestAccountSubjectType1SR;
    [self addSubjectHandleDatas];
}

- (void)addSubjectHandleDatas{
    _fs_dispatch_global_main_queue_async(^{
         NSArray *list = [FSBestAccountAPI allSubjectsForTable:self.account];
        self -> _count = list.count;
        [self makeGroup:list];
    }, ^{
        [self addSubjectDesignViews];
    });
}

- (void)makeGroup:(NSArray<FSBestSubjectModel *> *)list{
    if (_fs_isValidateArray(list)) {
        _sr = [[NSMutableArray alloc] init];
        _cb = [[NSMutableArray alloc] init];
        _ldzc = [[NSMutableArray alloc] init];
        _fldzc = [[NSMutableArray alloc] init];
        _ldfz = [[NSMutableArray alloc] init];
        _fldfz = [[NSMutableArray alloc] init];
        _syzqy = [[NSMutableArray alloc] init];
        for (FSBestSubjectModel *model in list) {
            NSInteger be = [model.be integerValue];
            if (be == FSBestAccountSubjectType1SR) {
                [_sr addObject:model];
            }else if (be == FSBestAccountSubjectType2CB){
                [_cb addObject:model];
            }else if (be == FSBestAccountSubjectType3LDZC){
                [_ldzc addObject:model];
            }else if (be == FSBestAccountSubjectType4FLDZC){
                [_fldzc addObject:model];
            }else if (be == FSBestAccountSubjectType5LDFZ){
                [_ldfz addObject:model];
            }else if (be == FSBestAccountSubjectType6FLDFZ){
                [_fldfz addObject:model];
            }else if (be == FSBestAccountSubjectType7SYZQY){
                [_syzqy addObject:model];
            }
        }
        self.all = @[_sr,_cb,_ldzc,_fldzc,_ldfz,_fldfz,_syzqy];
        self.list = _sr;
    }
}

- (void)addSubjectDesignViews{
    if (!_tableView) {
        self.title = [[NSString alloc] initWithFormat:@"科目（%@）",@(_count)];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"增加科目" style:UIBarButtonItemStylePlain target:self action:@selector(bbiClick)];
        self.navigationItem.rightBarButtonItem = bbi;
        
        CGFloat leftWidth = 110;
        FSShopClassView *shopClassView = [[FSShopClassView alloc] initWithFrame:CGRectMake(0, 64, leftWidth, 455)];
        shopClassView.dataSource = @[@"收入",@"成本",@"流动资产",@"非流动资产",@"流动负债",@"非流动负债",@"所有者本金"];
        [self.view addSubview:shopClassView];
        WEAKSELF(this);
        [shopClassView setSelectedBlock:^(FSShopClassView *bView, NSInteger bIndex) {
            this.index = bIndex;
        }];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(leftWidth, 64, self.view.bounds.size.width - leftWidth, self.view.bounds.size.height - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 45.5;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
    }else{
        self.index = self.index;
    }
}

- (void)setIndex:(NSInteger)index{
    _index = index;
    if (self.all.count > index && index >= 0) {
        self.list = self.all[index];
        [_tableView reloadData];
    }
}

- (void)bbiClick{
    FSAddBestSubjectController *absc = [[FSAddBestSubjectController alloc] init];
    absc.table = self.account;
    absc.index = _index;
    [self.navigationController pushViewController:absc animated:YES];
    __weak typeof(self)this = self;
    absc.addSubjectSuccess = ^(FSAddBestSubjectController *c) {
        [c.navigationController popToViewController:this animated:YES];
        [this addSubjectHandleDatas];
    };
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *i = @"c";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:i];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    FSBestSubjectModel *model = [_list objectAtIndex:indexPath.row];
    cell.textLabel.text = model.nm;
#if DEBUG
    cell.detailTextLabel.text = model.vl;
#endif
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FSBestSubjectModel *model = [_list objectAtIndex:indexPath.row];
    if (self.selectedMode) {
        if (self.selectSubject) {
            [self getPlusOrMinus:model];
        }
    }else{
        [self clickModel:model];
    }
}

- (void)getPlusOrMinus:(FSBestSubjectModel *)model{
    if (self.model) {
        NSInteger isp = 0;
        NSInteger aJD = [self.model.jd integerValue];
        NSInteger bJD = [model.jd integerValue];
        if (aJD == bJD) {   // 同属性科目，比如资产与成本
            if (self.model.isp == 1) {
                isp = 2;
            }else if (self.model.isp == 2){
                isp = 1;
            }
        }else{      // 不同属性科目，比如资产与负债
            isp = self.model.isp;
        }
        if (isp == 1 || isp == 2) {
            model.isp = isp;
            NSString *bn = [self subjectTypeOfIndex];
            model.bn = bn;
            self.selectSubject(self, model);
        }
    }else{
        NSString *p = @"增加";
        NSString *m = @"减少";
        NSNumber *type = @(UIAlertActionStyleDefault);
        [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:nil actionTitles:@[p,m] styles:@[type,type] handler:^(UIAlertAction *action) {
            if ([action.title isEqualToString:p]) {
                model.isp = 1;
            }else if ([action.title isEqualToString:m]){
                model.isp = 2;
            }
            NSString *bn = [self subjectTypeOfIndex];
            model.bn = bn;
            self.selectSubject(self, model);
        }];
    }
}

- (void)clickModel:(FSBestSubjectModel *)model{
    BOOL canDelete = [FSBestAccountAPI subjectCanDelete:model.vl table:self.account];
    NSArray *titles = nil;
    NSArray *styles = nil;
    NSString *edit = @"修改";
    NSString *dele = @"删除";
    if (canDelete) {
        titles = @[edit,dele];
        styles = @[@(UIAlertActionStyleDefault),@(UIAlertActionStyleDestructive)];
    }else{
        [self changeSubject:model];
    }
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:nil actionTitles:titles styles:styles handler:^(UIAlertAction *action) {
        if ([action.title isEqualToString:edit]) {
            [self changeSubject:model];
        }else if ([action.title isEqualToString:dele]){
            NSString *error = [FSBestAccountAPI deleteSubjectWithType:model.vl table:self.account];
            if (error) {
                [FSUIKit showAlertWithMessage:error controller:self];
                return;
            }
            [self addSubjectHandleDatas];
        }
    }];
}

- (void)changeSubject:(FSBestSubjectModel *)model{
    __weak typeof(self)this = self;
    [FSUIKit alertInput:1 controller:self title:model.nm message:nil ok:@"修改" handler:^(UIAlertController *bAlert, UIAlertAction *action) {
        UITextField *tf = bAlert.textFields.firstObject;
        NSString *text = tf.text;
        if (!_fs_isValidateString(text)) {
            [FSUIKit showAlertWithMessage:@"请输入内容" controller:this];
            return;
        }
        if ([text isEqualToString:model.nm]) {
            NSString *show = [[NSString alloc] initWithFormat:@"已经是'%@'",text];
            [FSToast show:show];
            return;
        }
        NSString *error = [FSBestAccountAPI editSubject:model newName:text  table:self.account];
        if (error) {
            [FSUIKit showAlertWithMessage:error controller:self];
            return;
        }
        [this addSubjectHandleDatas];
    } cancel:@"取消" handler:nil textFieldConifg:^(UITextField *textField) {
        textField.placeholder = @"改成新名称，不超过20个字符";
    } completion:nil];
}

- (NSString *)subjectTypeOfIndex{
    NSInteger index = _index;
    if (index == 0) {
        return @"收入";
    }else if (index == 1){
        return @"成本";
    }else if (index == 2){
        return @"流动资产";
    }else if (index == 3){
        return @"非流动资产";
    }else if (index == 4){
        return @"流动负债";
    }else if (index == 5){
        return @"非流动负债";
    }else if (index == 6){
        return @"所有者本金";
    }
    return nil;
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
