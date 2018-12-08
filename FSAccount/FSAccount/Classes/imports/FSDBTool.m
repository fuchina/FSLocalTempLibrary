//
//  FSDBTool.m
//  Demo
//
//  Created by fudon on 2017/5/16.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSDBTool.h"
// #import "AppDelegate.h"
#import <objc/runtime.h>
#import "FATool.h"
#import "FSShare.h"
#import "FSPdf.h"
#import "FSMacro.h"
#import "FSABTwominusController.h"
#import "FSABOneminusController.h"
#import "FSCryptor.h"
#import "FSAPP.h"
#import "FSAppConfig.h"
#import "FSDate.h"
#import "FSABUpdateController.h"
#import "FSCryptorSupport.h"
#import "FSCryptor.h"
#import <FSRuntime.h>
#import "FSDate.h"
#import "FSUIKit.h"
#import "FSMobanAPI.h"

@implementation FSDBTool

+ (void)handleModel:(FSSQLEntity *)entity type:(NSString *)p je:(CGFloat)je time:(NSTimeInterval)time start:(NSTimeInterval)start thisYear:(NSInteger)thisYear thisYearSR:(CGFloat*)ts thisYearCB:(CGFloat*)tc{
    BOOL isSR = [p hasPrefix:_subject_SR];
    BOOL isCB = [p hasPrefix:_subject_CB];
    BOOL isPlus = [p hasSuffix:_ING_KEY];
    if (isSR || isCB) {
        if (time > thisYear) {
            if (isPlus) {
                if (isSR) {
                    *ts += je;
                }else{
                    *tc += je;
                }
            }else{
                if (isSR) {
                    *ts -= je;
                }else{
                    *tc -= je;
                }
            }
        }
        
        if (time < start) {
            return;
        }
    }
    NSString *type = [p substringToIndex:2];
    SEL setterSelector = [FSRuntime setterSELWithAttibuteName:type];
    if ([entity respondsToSelector:setterSelector]) {
        CGFloat value = [[FSRuntime valueForGetSelectorWithPropertyName:type object:entity] doubleValue];
        if (isPlus) {
            value += je;
        }else{
            value -= je;
        }
        
        NSString *v = [[NSString alloc] initWithFormat:@"%.6f",value];
        [entity performSelector:setterSelector onThread:[NSThread currentThread] withObject:v waitUntilDone:YES];
    }
}

+ (FSSQLEntity *)fasterEntityFromDB:(NSString *)tableName start:(NSTimeInterval)start{
    FSSQLEntity *entity = [[FSSQLEntity alloc] init];
    CGFloat debtor = 0;
    CGFloat creditor = 0;
    static NSTimeInterval theFirstSecondOfThisYear = 0;
    if (theFirstSecondOfThisYear < 10) {
        NSDateComponents *c = [FSDate componentForDate:[NSDate date]];
        theFirstSecondOfThisYear = [FSDate theFirstSecondOfYear:c.year];
    }
    CGFloat ts = 0;
    CGFloat tc = 0;
    
    NSInteger page = 0;
    NSInteger unit = 1000;
    NSString *sql = [self fastSql:unit page:page tableName:tableName];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:tableName];
    while ([list isKindOfClass:NSArray.class] && list.count) {
        for (NSDictionary *model in list) {
            CGFloat je = [model[@"je"] doubleValue];
            NSTimeInterval time = [model[@"time"] doubleValue];
            NSString *atype = model[@"atype"];
            NSString *btype = model[@"btype"];
            [self handleModel:entity type:atype je:je time:time start:start thisYear:theFirstSecondOfThisYear thisYearSR:&ts thisYearCB:&tc];
            [self handleModel:entity type:btype je:je time:time start:start thisYear:theFirstSecondOfThisYear thisYearSR:&ts thisYearCB:&tc];
            
            if ([FATool isDebtor:atype]) {
                debtor += je;
            }else{
                creditor += je;
            }
            
            if ([FATool isDebtor:btype]) {
                debtor += je;
            }else{
                creditor += je;
            }
        }
        page ++;
        sql = [self fastSql:unit page:page tableName:tableName];
        list = [master querySQL:sql tableName:tableName];
    }
    entity.ph = [[NSString alloc] initWithFormat:@"%.2f",debtor - creditor];
    entity.ts = [[NSString alloc] initWithFormat:@"%.2f",ts];
    entity.tc = [[NSString alloc] initWithFormat:@"%.2f",tc];
    return entity;
}

+ (NSString *)fastSql:(NSInteger)unit page:(NSInteger)page tableName:(NSString *)tableName{
    return [[NSString alloc] initWithFormat:@"SELECT * FROM %@ limit %@,%@;",tableName,@(page * unit),@(unit)];
}

+ (NSString *)sixNumberPwd{
    return [self sixNumberPwdFromRunWithKey:[NSDate date]];
}

+ (NSString *)sixNumberPwdFromRunWithKey:(NSDate *)date{
    NSDateComponents *dateComponents = [FSDate componentForDate:date];
    NSString *key = [[NSString alloc] initWithFormat:@"%@%@%@%@%@APP",[FSKit twoChar:dateComponents.year],[FSKit twoChar:dateComponents.month],[FSKit twoChar:dateComponents.day],[FSKit twoChar:dateComponents.hour],[FSKit twoChar:dateComponents.minute]];
    NSString *md5 = _fs_md5(key);
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:6];
    for (int x = 0; x < 6; x ++) {
        NSString *str = [md5 substringWithRange:NSMakeRange(2 + x * 5, 1)];
        NSInteger data = [str integerValue];
        [result appendFormat:@"%@",@(data)];
    }
    return result;
}

+ (void)saveFileCallback:(Tuple2<NSString *,NSString *> * (^)(void))block{
    NSString *pdf = @"导出pdf文件";
    NSString *txt = @"导出txt文件";
    [FSUIKit alertOnCustomWindow:UIAlertControllerStyleActionSheet title:@"选择导出文本，可能比较耗时" message:nil actionTitles:@[pdf,txt] styles:@[@(UIAlertActionStyleDefault),@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        if (!block) {
            return;
        }
        Tuple2 *t = block();
        NSString *path = t._1;
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:path]) {
            [FSUIKit showAlertWithMessageOnCustomWindow:@"生成文件失败(无路径)"];
            return;
        }
        if ([action.title isEqualToString:txt]) {
            Tuple3 *t3 = [Tuple3 v1:t._1 v2:t._2 v3:@"txt"];
            [FSDBTool pushFileToWechatOrEmailWithPath:t3];
        }else if ([action.title isEqualToString:pdf]){
            [FSUIKit alertInputOnCustomWindow:1 title:@"pdf" message:@"您可以设置密码，也可以不设置。默认密码在[我]-[设置]中的\"导出PDF时的密码\"配置。" ok:@"OK" handler:^(UIAlertController *bAlert, UIAlertAction *action) {
                NSError *error = nil;
                NSString *txt = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
                if (error) {
                    [FSUIKit showAlertWithMessageOnCustomWindow:error.localizedDescription];
                    return;
                }
                NSString *pwd = [bAlert.textFields firstObject].text;
                NSString *pdfPath = [FSPdf pdfForString:txt pdfName:[[NSString alloc] initWithFormat:@"%@.pdf",t._2] password:[FSKit cleanString:pwd].length?pwd:nil];
                if ([manager fileExistsAtPath:pdfPath]) {
                    Tuple3 *t3 = [Tuple3 v1:pdfPath v2:t._2 v3:@"pdf"];
                    [FSDBTool pushFileToWechatOrEmailWithPath:t3];
                }
            } cancel:NSLocalizedString(@"Cancel", nil) handler:nil textFieldConifg:^(UITextField *textField) {
                textField.placeholder = @"此时文件没有设置密码";
                NSString *pwd = [FSAppConfig objectForKey:_appCfg_pdfPassword];
                if (_fs_isValidateString(pwd)) {
                    textField.text = pwd;
                }
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            } completion:nil];

        }
    }];
}

+ (void)pushFileToWechatOrEmailWithPath:(Tuple3 *)t{
    NSString *toWechat = @"微信";
    NSString *toMail = @"邮件";
    [FSUIKit alertOnCustomWindow:UIAlertControllerStyleActionSheet title:@"文件导出" message:nil actionTitles:@[toWechat,toMail] styles:@[@(UIAlertActionStyleDefault),@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
        NSString *path = t._1;
        if ([action.title isEqualToString:toWechat]) {
            [FSTrack event:_UMeng_Event_to_wechat];
            [FSShare wxFileShareActionWithPath:path fileName:t._2 extension:t._3 result:^(NSString *bResult) {
                [FSUIKit showMessage:bResult];
            }];
        }else if ([action.title isEqualToString:toMail]){
            [FSTrack event:_UMeng_Event_to_mail];
            NSString *email = [FSAppConfig objectForKey:_appCfg_receivedEmail];
            if (!_fs_isValidateString(email)) {
                [FSUIKit showMessage:@"您可以去App的[设置]中配置接收数据的邮箱"];
            }
            
            NSMutableString *body = [[NSMutableString alloc] initWithString:@"\n\t可以在邮件里转存到微云的\"QQ邮箱\"内"];
            NSString *name = [path lastPathComponent];
            NSData *myData = [NSData dataWithContentsOfFile:path];
            
            // TODO
//            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            [FSShare emailShareWithSubject:@"保存文件" on:app.window.rootViewController messageBody:body recipients:email?@[email]:nil fileData:myData fileName:name mimeType:@"db"];
        }
    }];
}

+ (NSString *)accountTypeWithIndex:(NSInteger)index{
    if (index < 0 || index >= 676) {
        return nil;
    }
    
    static NSMutableArray *alphabet = nil;
    if (!alphabet) {
        alphabet = [[NSMutableArray alloc] initWithCapacity:26];
        
        for (int x = 0; x < 26; x ++) {
            NSString *string = [[NSString alloc] initWithFormat:@"%c",'a' + x];
            [alphabet addObject:string];
        }
    }
    
    NSInteger leftIndex = index / 26;
    NSInteger rightIndex = index % 26;
    
    NSString *type = [[NSString alloc] initWithFormat:@"%@%@",alphabet[leftIndex],alphabet[rightIndex]];
    return type;
}

+ (Tuple2 *)returnErrorStringIfOccurrError:(NSArray *)handleArray{
    NSString *atype = [handleArray firstObject];
    NSString *btype = [handleArray lastObject];
    NSString *subA = [atype substringToIndex:2];
    NSString *subB = [btype substringToIndex:2];
    if ([atype isEqualToString:btype] || [subA isEqualToString:subB]) {
        return [Tuple2 v1:@(NO) v2:NSLocalizedString(@"It has to be two different subjects", nil)];
    }
    
    BOOL balance = [FATool balanceCheck:handleArray];
    NSMutableString *message = [[NSMutableString alloc] initWithFormat:@"%@,%@",[FATool noticeForType:atype],[FATool noticeForType:btype]];
    if (!balance) {
        [message insertString:@"[" atIndex:0];
        [message appendFormat:@"] %@",NSLocalizedString(@"Can't execute", nil)];
    }else{
        [message appendString:@"?"];
    }
    return [Tuple2 v1:@(balance) v2:message];
}

+ (void)handleDatas:(NSArray *)handleArray account:(NSString *)account date:(NSDate *)date je:(NSString *)je bz:(NSString *)bz controller:(UIViewController *)controller type:(NSString *)type completion:(void(^)(void))completion{
    if (handleArray.count != 2) {
        return;
    }
    Tuple2 *t2 = [self returnErrorStringIfOccurrError:handleArray];
    if (![t2._1 boolValue]) {
        [FSUIKit showAlertWithMessage:t2._2 controller:controller];
        return;
    }
    if (!_fs_isValidateString(account)) {
        return;
    }
    if (!_fs_isPureFloat(je)) {
        return;
    }
    if (!_fs_isValidateString(bz)) {
        return;
    }
    if (![date isKindOfClass:NSDate.class]) {
        return;
    }
    
    NSString *atype = [handleArray firstObject];
    NSString *btype = [handleArray lastObject];
    NSMutableString *message = [[NSMutableString alloc] initWithFormat:@"%@,%@",[FATool noticeForType:atype],[FATool noticeForType:btype]];
    
    BOOL onlyAdds = [atype hasSuffix:_ING_KEY] && [btype hasSuffix:_ING_KEY];
    if (onlyAdds) {
        NSInteger time = (NSInteger)[date timeIntervalSince1970];
        [self addEntities:time account:account handleArray:handleArray je:je bz:bz controller:controller type:type completion:completion];
    }else{
        NSString *firstMinus = nil;
        NSString *secondMinus = nil;
        for (int x = 0; x < handleArray.count; x ++) {
            NSString *subFlag = handleArray[x];
            if ([subFlag hasSuffix:_ED_KEY]) {
                if (firstMinus) {
                    secondMinus = [handleArray[x] substringWithRange:NSMakeRange(0, 2)];
                }else{
                    firstMinus = [handleArray[x] substringWithRange:NSMakeRange(0, 2)];
                }
            }
        }
        
        if (firstMinus && secondMinus) {    // 两项都是减
            FSABTwominusController *twoMinusController = [[FSABTwominusController alloc] init];
            twoMinusController.types = @[firstMinus,secondMinus];
            twoMinusController.accountName = account;
            twoMinusController.je = je;
            twoMinusController.bz = bz;
            [controller.navigationController pushViewController:twoMinusController animated:YES];
            twoMinusController.completion = ^ (FSABTwominusController *bController,NSArray *bEdArray,NSArray *bTracks){
                [self updateEntities:bEdArray tracks:bTracks date:date account:account handleArray:handleArray je:je bz:bz controller:controller type:type completion:completion];
            };
        }else{      // 一项是减
            FSABOneminusController *selectController = [[FSABOneminusController alloc] init];
            selectController.type = firstMinus;
            selectController.accountName = account;
            selectController.je = je;
            selectController.bz = bz;
            selectController.message = message;
            [controller.navigationController pushViewController:selectController animated:YES];
            selectController.selectBlock = ^ (FSABOneminusController *bController,NSArray<FSABModel *> *bEdArray,NSArray *bTracks){
                [self updateEntities:bEdArray tracks:bTracks date:date account:account handleArray:handleArray je:je bz:bz controller:controller type:type completion:completion];
            };
        }
    }
}

+ (void)updateEntities:(NSArray *)array tracks:(NSArray *)tracks date:(NSDate *)date account:(NSString *)account handleArray:(NSArray *)handleArray je:(NSString *)je bz:(NSString *)bz controller:(UIViewController *)controller type:(NSString *)type completion:(void(^)(void))completion{
    if (handleArray.count != 2) {
        return;
    }
    Tuple2 *t2 = [self returnErrorStringIfOccurrError:handleArray];
    if (![t2._1 boolValue]) {
        [FSUIKit showAlertWithMessage:t2._2 controller:controller];
        return;
    }
    if (!_fs_isValidateString(account)) {
        return;
    }
    if (!_fs_isPureFloat(je)) {
        return;
    }
    if (!_fs_isValidateString(bz)) {
        return;
    }
    if ((!_fs_isValidateArray(array)) || (!_fs_isValidateArray(tracks))) {
        array = nil;
        tracks = nil;
    }
    
    BOOL canOn = [self checkAllDataIsRight:tracks je:je subjects:handleArray eds:array];
    if (!canOn) {
        [FSUIKit showAlertWithMessage:@"STOP：校验未通过！" controller:controller];
        return;
    }
    
    NSString *error = [self handleEDArray:array account:account];
    if (error) {
        [FSUIKit showAlertWithMessage:error controller:controller];
        return;
    }
    NSString *trackError = [self handleTracks:tracks];
    if (trackError) {
        [FSUIKit showAlertWithMessage:trackError controller:controller];
        return;
    }
    
    NSInteger time = (NSInteger)[date timeIntervalSince1970];
    [self addEntities:time account:account handleArray:handleArray je:je bz:bz controller:controller type:type completion:completion];
}

+ (BOOL)checkAllDataIsRight:(NSArray<FSABTrackModel *> *)tracks je:(NSString *)je subjects:(NSArray<NSString *> *)subjects eds:(NSArray<FSABModel *> *)eds{
    NSString *firstSubject = subjects.firstObject;
    NSString *lastSubject = subjects.lastObject;
    BOOL isFirstPlus = [firstSubject hasSuffix:_ING_KEY];
    BOOL isLastPlus = [lastSubject hasSuffix:_ING_KEY];
    if (isFirstPlus && isLastPlus) {
        return YES;
    }
    CGFloat jef = [je doubleValue];
    BOOL condition1 = YES;
    BOOL condition2 = YES;
    if (!isFirstPlus) {
        condition1 = [self balanceRight:tracks eds:eds je:jef subject:firstSubject];
    }
    if (!isLastPlus) {
        condition2 = [self balanceRight:tracks eds:eds je:jef subject:lastSubject];
    }
    return condition2 && condition1;
}

+ (BOOL)balanceRight:(NSArray<FSABTrackModel *> *)tracks eds:(NSArray<FSABModel *> *)eds je:(CGFloat)je subject:(NSString *)subject{
    if (!(_fs_isValidateArray(tracks) && _fs_isValidateArray(eds))) {
        return NO;
    }
    NSString *sub = [subject substringToIndex:2];
    NSString *subP = [[NSString alloc] initWithFormat:@"%@%@",sub,_ING_KEY];
    CGFloat trackSum = 0;
    CGFloat edSum = 0;
    for (FSABTrackModel *t in tracks) {
        CGFloat tje = [t.je doubleValue];
        NSString *link = t.link;
        NSString *type = t.type;
        BOOL isA = [type isEqualToString:@"a"];
        for (FSABModel *m in eds) {
            NSString *time = m.time;
            NSString *tp = isA?m.atype:m.btype;
            BOOL typeRight = [tp isEqualToString:subP];
            if (([time isEqualToString:link]) && typeRight) {
                trackSum += tje;
                CGFloat abrest = isA?[m.arest doubleValue]:[m.brest doubleValue];
                CGFloat abrst = isA?[m.arst doubleValue]:[m.brst doubleValue];
                edSum += (abrest - abrst);
            }
        }
    }
    CGFloat v1 = je - trackSum;
    CGFloat v2 = je - edSum;
    BOOL condition1 = fabs(v1) < 0.01;
    BOOL condition2 = fabs(v2) < 0.01;
    return condition1 && condition2;
}

+ (NSString *)handleEDArray:(NSArray<FSABModel *> *)array account:(NSString *)account{
    if (![array isKindOfClass:NSArray.class]) {
        return nil;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    for (int x = 0; x < array.count; x ++) {
        FSABModel *model = array[x];
        NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET arest = '%@',brest = '%@' WHERE aid = %@;",account,model.arst,model.brst,model.aid];
        NSString *error = [master updateWithSQL:sql];
        if (error) {
            return error;
        }
    }
    return nil;
}

+ (NSString *)handleTracks:(NSArray<FSABTrackModel *> *)tracks{
    if (![tracks isKindOfClass:NSArray.class]) {
        return nil;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    for (int x = 0; x < tracks.count; x ++) {
        FSABTrackModel *model = [tracks objectAtIndex:x];
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (time,link,type,je,bz,accname) VALUES ('%@','%@','%@','%@','%@','%@');",_tb_abTrack,model.time,model.link,model.type,model.je,model.bz,model.accname];
        NSString *error = [master insertSQL:sql fields:FSABTrackModel.tableFields table:_tb_abTrack];
        if (error) {
            return error;
        }
    }
    return nil;
}

+ (void)addEntities:(NSTimeInterval)time account:(NSString *)account handleArray:(NSArray *)handleArray je:(NSString *)je bz:(NSString *)bz controller:(UIViewController *)controller type:(NSString *)type completion:(void(^)(void))completion{
    if (!_fs_isValidateString(account)) {
        return;
    }
    if (handleArray.count != 2) {
        return;
    }
    Tuple2 *t2 = [self returnErrorStringIfOccurrError:handleArray];
    if (![t2._1 boolValue]) {
        [FSUIKit showAlertWithMessage:t2._2 controller:controller];
        return;
    }
    NSString *atype = [handleArray firstObject];
    if (!_fs_isValidateString(atype)) {
        return;
    }
    if (!([atype hasSuffix:_ED_KEY] || [atype hasSuffix:_ING_KEY])) {
        return;
    }
    NSString *btype = [handleArray lastObject];
    if (!_fs_isValidateString(btype)) {
        return;
    }
    if (!([btype hasSuffix:_ED_KEY] || [btype hasSuffix:_ING_KEY])) {
        return;
    }
    if (!_fs_isPureFloat(je)) {
        return;
    }
    if (!([bz isKindOfClass:NSString.class] && bz.length)) {
        return;
    }
    
    // time相当于sid，sid是一个唯一的标志一条数据的id。
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *existSQL = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE time = '%@';",account,@(time).stringValue];
    NSArray *bArray = [master querySQL:existSQL tableName:account];
    if (bArray.count) {
        [self addEntities:time + 1 account:account handleArray:handleArray je:je bz:bz controller:controller type:type completion:completion];
        return;
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (time,ctime,je,atype,btype,bz,arest,brest) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@');",account,@(time).stringValue,@(_fs_integerTimeIntevalSince1970()).stringValue,je,atype,btype,bz,[atype hasSuffix:_ING_KEY]?je:@"0.00",[btype hasSuffix:_ING_KEY]?je:@"0.00"];
    NSString *error = [master insertSQL:sql fields:FSABModel.tableFields table:account];
    if (error) {
        [FSUIKit showAlertWithMessage:[[NSString alloc] initWithFormat:@"记账存入失败，敬请反馈:(%@)",error] controller:controller];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:_Notifi_refreshAccount object:nil];
    [FSTrack event:_UMeng_Event_acc_su];
    
    NSString *changedTime = @(_fs_integerTimeIntevalSince1970()).stringValue;
    _fs_userDefaults_setObjectForKey(changedTime, [self accountChangeKey:account type:_type_account]);
    
    [self insertBZ:bz types:handleArray type:type];
    
    NSString *kJE = [[NSString alloc] initWithFormat:@"%.2f",[je doubleValue]];
    NSString *message = [[NSString alloc] initWithFormat:@"%@ : %@",bz,kJE];
    [FSAPP addMessage:message table:account];
    if (completion) {
        completion();
    }
}

+ (void)insertBZ:(NSString *)bz types:(NSArray *)handles type:(NSString *)type{
    if (!(_fs_isValidateString(bz) && ([handles isKindOfClass:NSArray.class] && handles.count == 2))) {
        return;
    }
    [FSMobanAPI addMobanWithBZ:bz atype:handles.firstObject btype:handles.lastObject type:type];
}

+ (NSString *)accountChangeKey:(NSString *)account type:(NSString *)type{
    NSAssert(type != nil, @"type不能为nil");
    return [[NSString alloc] initWithFormat:@"%@_%@_%@",_theAccountChangeTime,account,type];
}

+ (void)pushToAccountUpdateController:(UINavigationController *)navigationController entity:(FSABModel *)entity isA:(BOOL)isA account:(NSString *)accountName{
    if ((![navigationController isKindOfClass:UINavigationController.class]) ||(![entity isKindOfClass:FSABModel.class]) ||(!_fs_isValidateString(accountName))) {
        return;
    }
    FSABUpdateController *updateController = [[FSABUpdateController alloc] init];
    updateController.title = [FATool noticeForType:isA?entity.atype:entity.btype];
    updateController.model = entity;
    updateController.accountName = accountName;
    updateController.isA = isA;
    [navigationController pushViewController:updateController animated:YES];
    updateController.callBack = ^(FSBaseController *bVC, NSString *sql) {
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSString *error = [master updateWithSQL:sql];
        if (!error) {
            [FSTrack event:_UMeng_Event_acc_change_success];
            NSString *changedTime = @(_fs_integerTimeIntevalSince1970()).stringValue;
            _fs_userDefaults_setObjectForKey(changedTime, [self accountChangeKey:accountName type:_type_account]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:_Notifi_refreshAccount object:nil];
            [FSKit popToController:@"FSABOverviewController" navigationController:bVC.navigationController animated:YES];
            [FSToast show:NSLocalizedString(@"Update success", nil)];
        }else{
            [FSTrack event:_UMeng_Event_acc_change_fail];
            [FSUIKit showMessage:error];
        }
    };
}

+ (void)copyImportDatabase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *path = [docDir stringByAppendingFormat:@"/sql_ling.db"];
    
    NSFileManager *m = [NSFileManager defaultManager];
    NSString *desc = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"db"];
    
    NSError *error = nil;
    BOOL success = [m copyItemAtPath:desc toPath:path error:&error];
    if (!success) {
        NSLog(@"error:%@",error.localizedDescription);
    }
}

+ (void)sumSubject:(NSString *)subject table:(NSString *)table completion:(void(^)(CGFloat value))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!([subject isKindOfClass:NSString.class] && subject.length == 2)) {
            return;
        }
        NSString *p = [[NSString alloc] initWithFormat:@"%@%@",subject,_ING_KEY];
        NSString *m = [[NSString alloc] initWithFormat:@"%@%@",subject,_ED_KEY];
        NSInteger page = 0;
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE atype = '%@' or btype = '%@' or atype = '%@' or btype = '%@' limit %@,100;",table,p,p,m,m,@(page * 100)];
        NSArray *list = [master querySQL:sql tableName:table];
        CGFloat value = 0;
        while (list.count) {
            for (NSDictionary *dic in list) {
                CGFloat je = [dic[@"je"] doubleValue];
                NSString *atype = dic[@"atype"];
                NSString *btype = dic[@"btype"];
                if ([atype isEqualToString:p]) {
                    value += je;
                }
                if ([atype isEqualToString:m]) {
                    value = value - je;
                }
                if ([btype isEqualToString:p]) {
                    value += je;
                }
                if ([btype isEqualToString:m]) {
                    value = value - je;
                }
            }
            page ++;
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE atype = '%@' or btype = '%@' or atype = '%@' or btype = '%@' limit %@,100;",table,p,p,m,m,@(page * 100)];
            list = [master querySQL:sql tableName:table];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(value);
            }
        });
    });
}

+ (void)scanAccount:(NSString *)account wantYear:(NSInteger)year completion:(void(^)(NSDictionary *value))completion{
    if (!_fs_isValidateString(account)) {
        return;
    }
    if (year < 1) {
        return;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *maxSQL = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by cast(ctime as real) DESC limit 0,1;",account];
    NSArray *maxDatas = [master querySQL:maxSQL tableName:account];
    NSDictionary *maxValue = maxDatas.firstObject;
    NSInteger maxTime = [maxValue[@"time"] integerValue];
    NSString *upKey = [[NSString alloc] initWithFormat:@"cache%@SA",account];
    NSInteger upt = [[FSAPP objectForKey:upKey] integerValue];
    BOOL useCache = (upt == maxTime);
    if (useCache) {
        NSDictionary *dic = [self getCacheData:year account:account];
        if (_fs_isValidateDictionary(dic)) {
            if (completion) {
                completion(dic);
            }
            return;
        }
    }
    
    NSString *minSQL = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by cast(time as real) ASC limit 0,1;",account];
    NSArray *datas = [master querySQL:minSQL tableName:account];
    NSDictionary *value = datas.firstObject;
    NSInteger time = [value[@"time"] integerValue];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    NSDateComponents *com = [FSDate componentForDate:date];
    NSInteger earliest = [FSDate theFirstSecondOfYear:com.year];
    NSInteger latest = [FSDate theLastSecondOfYear:com.year];
    NSDate *maxDate = [[NSDate alloc] initWithTimeIntervalSince1970:maxTime];
    NSDateComponents *maxCom = [FSDate componentForDate:maxDate];
    if (year < com.year || year > maxCom.year) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    NSInteger page = 0;
    NSInteger unit = 1000;
    NSInteger whichYear = com.year;
    NSMutableDictionary *subjects = [[NSMutableDictionary alloc] init];
    NSString *sql = [self scanSQL:account page:page unit:unit];
    NSArray<NSDictionary *> *list = [master querySQL:sql tableName:account];
    while (_fs_isValidateArray(list)) {
        for (NSDictionary *e in list) {
            NSString *atype = e[@"atype"];
            NSString *btype = e[@"btype"];
            CGFloat je = [e[@"je"] doubleValue];
            NSInteger tm = [e[@"time"] integerValue];
            if (tm >= earliest && tm <= latest) {
            }else{ // 新的一年了
                [self storeData:account year:whichYear data:subjects firstYear:com.year];
                if (whichYear == year) {
                    if (completion) {
                        completion(subjects);
                    }
                }
                [subjects removeAllObjects];
                
                NSDate *newYear = [[NSDate alloc] initWithTimeIntervalSince1970:tm];
                NSDateComponents *c = [FSDate componentForDate:newYear];
                whichYear = c.year;
                earliest = [FSDate theFirstSecondOfYear:whichYear];
                latest = [FSDate theLastSecondOfYear:whichYear];
            }
            CGFloat av = [[subjects objectForKey:atype] doubleValue];
            av += je;
            CGFloat bv = [[subjects objectForKey:btype] doubleValue];
            bv += je;
            [subjects setObject:@(av) forKey:atype];
            [subjects setObject:@(bv) forKey:btype];
        }
        page ++;
        sql = [self scanSQL:account page:page unit:unit];
        list = [master querySQL:sql tableName:account];
    }
    [self storeData:account year:whichYear data:subjects firstYear:com.year];
    if (whichYear == year) {
        if (completion) {
            completion(subjects);
        }
    }
    [FSAPP setObject:@(maxTime).stringValue forKey:upKey];
}

+ (NSDictionary *)getCacheData:(NSInteger)year account:(NSString *)account{
    NSString *key = [self scanKeyForYear:year account:account];
    NSString *js = [FSAPP objectForKey:key];
    NSDictionary *dic = [FSKit objectFromJSonstring:js];
    return dic;
}

+ (void)storeData:(NSString *)account year:(NSInteger)whichYear data:(NSMutableDictionary *)subjects firstYear:(NSInteger)firstYear{
    if (whichYear == firstYear) {
        NSArray *keys = [subjects allKeys];
        NSMutableArray *pures = [[NSMutableArray alloc] init];
        for (NSString *k in keys) {
            if (k.length == 3) {
                NSString *subject = [k substringToIndex:2];
                if (![pures containsObject:subject]) {
                    [pures addObject:subject];
                }
            }
        }
        for (NSString *subject in pures) {
            NSString *p = [[NSString alloc] initWithFormat:@"%@%@",subject,_ING_KEY];
            NSString *m = [[NSString alloc] initWithFormat:@"%@%@",subject,_ED_KEY];
            CGFloat vp = [[subjects objectForKey:p] doubleValue];
            CGFloat vm = [[subjects objectForKey:m] doubleValue];
            CGFloat delta = vp - vm;
            [subjects setObject:@(delta) forKey:subject];
        }
    }else{
        NSInteger front = whichYear - 1;
        NSDictionary *value = [self getCacheData:front account:account];
        NSMutableArray *keys = [[NSMutableArray alloc] init];
        [keys addObjectsFromArray:[value allKeys]];
        NSArray *ks = [subjects allKeys];
        for (NSString *k in ks) {
            if (![keys containsObject:k]) {
                [keys addObject:k];
            }
        }
        NSMutableArray *pures = [[NSMutableArray alloc] init];
        for (NSString *k in keys) {
            if (k.length == 3) {
                NSString *subject = [k substringToIndex:2];
                if (![pures containsObject:subject]) {
                    [pures addObject:subject];
                }
            }
        }
        for (NSString *subject in pures) {
            if ([subject isEqualToString:_subject_SR] || [subject isEqualToString:_subject_CB]) {
                continue;
            }
            NSString *p = [[NSString alloc] initWithFormat:@"%@%@",subject,_ING_KEY];
            NSString *m = [[NSString alloc] initWithFormat:@"%@%@",subject,_ED_KEY];
            CGFloat vp = [[subjects objectForKey:p] doubleValue];
            CGFloat vm = [[subjects objectForKey:m] doubleValue];
            CGFloat delta = vp - vm;
            CGFloat v2 = [[value objectForKey:subject] doubleValue];
            [subjects setObject:@(v2 + delta) forKey:subject];
        }
    }
    NSString *key = [self scanKeyForYear:whichYear account:account];
    NSString *js = [FSKit jsonStringWithObject:subjects];
    [FSAPP setObject:js forKey:key];
}

+ (NSString *)scanSQL:(NSString *)account page:(NSInteger)page unit:(NSInteger)unit{
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by cast(time as real) limit %@,%@;",account,@(page * unit),@(unit)];
    return sql;
}

+ (NSString *)scanKeyForYear:(NSInteger)year account:(NSString *)account{
    NSString *key = [[NSString alloc] initWithFormat:@"%@%@scanAccount",@(year),account];
    return key;
}

+ (NSArray<NSDictionary *> *)yearsOfSubjectByTable:(NSString *)table year:(NSInteger)year useCacheIfExist:(BOOL)useCache{
    if (year < 1) {
        return nil;
    }
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return nil;
    }
    
    NSString *key = [[NSString alloc] initWithFormat:@"%@_%@_monthsSubject",@(year),table];
    NSString *json = [FSAPP objectForKey:key];
    NSArray *cache = [FSKit objectFromJSonstring:json];
    if (_fs_isValidateArray(cache) && useCache) {
        return cache;
    }
    NSArray *subjects = @[
                          _subject_SR,
                          _subject_CB,
//                          _subject_YS,
//                          _subject_XJ,
//                          _subject_TZ,
//                          _subject_CH,
//                          _subject_GZ,
//                          _subject_TX,
//                          _subject_FZ,
//                          _subject_PS,
//                          _subject_BJ,
//                          _subject_GB
                          ];
    NSString *_year_key = @"year";
    NSString *_month_key = @"month";
    NSString *_value_key = @"value";
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int x = 1; x < 13; x ++) {
        NSString *month = [[NSString alloc] initWithFormat:@"%@-%@-15 00:00:00",@(year),[FSKit twoChar:x]];
        NSDate *date = [FSDate dateByString:month formatter:nil];
        NSInteger start = [FSDate theFirstSecondOfMonth:date];
        NSInteger end = [FSDate theLastSecondOfMonth:date];
        NSMutableDictionary *dics = [[NSMutableDictionary alloc] init];
        for (NSString *type in subjects) {
            CGFloat value = [self sumSubject:type table:table start:start end:end];
            if (value >= 0.01) {
                [dics setObject:@(value) forKey:type];
            }
        }
        NSDictionary *dic = @{_year_key:@(year),_month_key:@(x),_value_key:dics};
        [array addObject:dic];
    }
    if (_fs_isValidateArray(array)) {
        NSString *js = [FSKit jsonStringWithObject:array];
        if (js) {
            [FSAPP setObject:js forKey:key];
        }
    }
    return array;
}

+ (CGFloat)sumSubject:(NSString *)subject table:(NSString *)table start:(NSInteger)start end:(NSInteger)end{
    if (!([subject isKindOfClass:NSString.class] && subject.length == 2)) {
        return 0;
    }
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return 0;
    }
        NSString *p = [[NSString alloc] initWithFormat:@"%@%@",subject,_ING_KEY];
        NSString *m = [[NSString alloc] initWithFormat:@"%@%@",subject,_ED_KEY];
        NSInteger page = 0;
        NSInteger unit = 500;
        NSNumber *nUnit = @(unit);
        NSNumber *nStart = @(start);
        NSNumber *nEnd = @(end);
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSString *sql = [self sqlForSubjectP:p m:m table:table start:nStart end:nEnd page:page unit:unit nUnit:nUnit];
        NSArray *list = [master querySQL:sql tableName:table];
        CGFloat value = 0;
        while (list.count) {
            for (NSDictionary *dic in list) {
                CGFloat je = [dic[@"je"] doubleValue];
                NSString *atype = dic[@"atype"];
                NSString *btype = dic[@"btype"];
                if ([atype isEqualToString:p]) {
                    value += je;
                }
                if ([atype isEqualToString:m]) {
                    value = value - je;
                }
                if ([btype isEqualToString:p]) {
                    value += je;
                }
                if ([btype isEqualToString:m]) {
                    value = value - je;
                }
            }
            page ++;
            sql = [self sqlForSubjectP:p m:m table:table start:nStart end:nEnd page:page unit:unit nUnit:nUnit];
            list = [master querySQL:sql tableName:table];
        }
    return value;
}

+ (NSString *)sqlForSubjectP:(NSString *)p m:(NSString *)m table:(NSString *)table start:(NSNumber *)start end:(NSNumber *)end page:(NSInteger)page unit:(NSInteger)unit nUnit:(NSNumber *)nUnit{
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (atype = '%@' or btype = '%@' or atype = '%@' or btype = '%@') and (time BETWEEN %@ AND %@) limit %@,%@;",table,p,p,m,m,start,end,@(page * unit),nUnit];
    return sql;
}

+ (void)throughTheAccount:(NSString *)tableName{
    NSInteger page = 0;
    NSInteger unit = 500;
    NSString *sql = [self fastSql:unit page:page tableName:tableName];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:tableName];
    while ([list isKindOfClass:NSArray.class] && list.count) {
        for (NSDictionary *model in list) {
            CGFloat je = [model[@"je"] doubleValue];
            NSString *atype = model[@"atype"];
            NSString *btype = model[@"btype"];
            NSInteger time = [model[@"time"] integerValue];
            [self cacheEntity:model table:tableName atype:atype btype:btype je:je time:time];
        }
        page ++;
        sql = [self fastSql:unit page:page tableName:tableName];
        list = [master querySQL:sql tableName:tableName];
    }
}

+ (void)cacheEntity:(NSDictionary *)model table:(NSString *)table atype:(NSString *)atype btype:(NSString *)btype je:(CGFloat)je time:(NSInteger)time{
    static NSMutableDictionary *cache = nil;
    static NSString *_year_key = @"y";
    static NSString *_month_key = @"m";
    static NSString *_value_key = @"v";
    static NSInteger _min_second = 0;
    static NSInteger _max_second = 0;
    if (!cache) {
        cache = [[NSMutableDictionary alloc] init];
    }
    NSString *aSubject = [atype substringToIndex:2];
    NSString *bSubject = [btype substringToIndex:2];
    BOOL isAP = [atype hasSuffix:_ING_KEY];
    BOOL isBP = [btype hasSuffix:_ING_KEY];
    NSMutableDictionary *v = [cache objectForKey:_value_key];
    if (![v isKindOfClass:NSDictionary.class]) {
        v = [NSMutableDictionary new];
    }
    CGFloat aSum = [v[aSubject] doubleValue];
    CGFloat bSum = [v[bSubject] doubleValue];
    BOOL needClear = NO;
    if (cache.count) {
        if (time >= _min_second && time <= _max_second) {
        }else{
            needClear = YES;
        }
    }else{
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:time];
        NSDateComponents *c = [FSDate componentForDate:date];
        [cache setObject:@(c.year) forKey:_year_key];
        [cache setObject:@(c.month) forKey:_month_key];
        _min_second = [FSDate theFirstSecondOfMonth:date];
        _max_second = [FSDate theLastSecondOfMonth:date];
    }
    if (isAP) {
        aSum += je;
    }else{
        aSum -= je;
    }
    if (isBP) {
        bSum += je;
    }else{
        bSum -= je;
    }
    [v setObject:@(aSum) forKey:aSubject];
    [v setObject:@(bSum) forKey:bSubject];
    [cache setObject:v forKey:_value_key];
    
    if (needClear) {
        NSInteger year = [cache[_year_key] integerValue];
        NSInteger month = [cache[_month_key] integerValue];
        NSString *json = [FSKit jsonStringWithObject:cache];
        NSString *key = [self soleCacheKey:table year:year month:month];
        [FSAPP setObject:json forKey:key];
        [cache removeAllObjects];
    }
}

+ (NSString *)soleCacheKey:(NSString *)table year:(NSInteger)year month:(NSInteger)month{
    NSString *key = [[NSString alloc] initWithFormat:@"%@%@%@a",table,@(year),@(month)];
    return key;
}

// 因为没有区分表，导致这个数据错误
+ (CGFloat)woodpeckerTrack:(NSString *)subj account:(NSString *)account{
    NSString *tableName = @"accounttrack";
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSInteger page = 0;
    NSInteger unit = 500;
    NSString *sql = [self birdSQLForTrack:unit page:page tableName:tableName forTable:account];
    NSArray *list = [master querySQL:sql tableName:tableName];
    CGFloat all = 0;
    while ([list isKindOfClass:NSArray.class] && list.count) {
        for (NSDictionary *model in list) {
            CGFloat je = [model[@"je"] doubleValue];
            NSString *link = model[@"link"];
            NSString *ns = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where aid = %@;",account,@([link integerValue])];
            NSArray *li = [master querySQL:ns tableName:account];
            NSDictionary *al = li.firstObject;
            if (al) {
                NSString *type = model[@"type"];
                NSString *subject = nil;
                if ([type isEqualToString:@"b"]) {
                    subject = al[@"btype"];
                }else{
                    subject = al[@"atype"];
                }
                NSString *sub = [subject substringToIndex:2];
                if ([sub isEqualToString:subj]) {
                    all += je;
                }
            }else{
                [FSUIKit showAlertWithMessageOnCustomWindow:@"发现：这条记录绑定的数据不存在" handler:nil];
                return 0;
            }
        }
        page ++;
        sql = [self birdSQLForTrack:unit page:page tableName:tableName forTable:account];
        list = [master querySQL:sql tableName:tableName];
    }
    return all;
}

+ (NSString *)birdSQLForTrack:(NSInteger)unit page:(NSInteger)page tableName:(NSString *)tableName forTable:(NSString *)table{
    return [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where accname = '%@' limit %@,%@;",tableName,table,@(page * unit),@(unit)];
}

+ (CGFloat)woodpeckerPlus:(NSString *)subject account:(NSString *)account{
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSInteger page = 0;
    NSInteger unit = 500;
    NSString *sql = [self birdSQL:unit page:page tableName:account];
    NSArray *list = [master querySQL:sql tableName:account];
    CGFloat plus = 0;
    NSString *subP = [[NSString alloc] initWithFormat:@"%@p",subject];
    while ([list isKindOfClass:NSArray.class] && list.count) {
        for (NSDictionary *model in list) {
            CGFloat je = [model[@"je"] doubleValue];
            NSString *atype = model[@"atype"];
            NSString *btype = model[@"btype"];
            if ([atype isEqualToString:subP] || [btype isEqualToString:subP]) {
                plus += je;
            }
        }
        page ++;
        sql = [self birdSQL:unit page:page tableName:account];
        list = [master querySQL:sql tableName:account];
    }
    return plus;
}

+ (CGFloat)woodpeckerMinus:(NSString *)subject account:(NSString *)account{
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSInteger page = 0;
    NSInteger unit = 500;
    NSString *sql = [self birdSQL:unit page:page tableName:account];
    NSArray *list = [master querySQL:sql tableName:account];
    CGFloat minus = 0;
    NSString *subM = [[NSString alloc] initWithFormat:@"%@m",subject];
    while ([list isKindOfClass:NSArray.class] && list.count) {
        for (NSDictionary *model in list) {
            CGFloat je = [model[@"je"] doubleValue];
            NSString *atype = model[@"atype"];
            NSString *btype = model[@"btype"];
            if ([atype isEqualToString:subM] || [btype isEqualToString:subM]) {
                minus += je;
            }
        }
        page ++;
        sql = [self birdSQL:unit page:page tableName:account];
        list = [master querySQL:sql tableName:account];
    }
    return minus;
}

+ (CGFloat)woodpeckerRest:(NSString *)subject account:(NSString *)account{
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSInteger page = 0;
    NSInteger unit = 500;
    NSString *sql = [self birdSQL:unit page:page tableName:account];
    NSArray *list = [master querySQL:sql tableName:account];
    CGFloat rest = 0;
    NSString *subP = [[NSString alloc] initWithFormat:@"%@p",subject];
    while ([list isKindOfClass:NSArray.class] && list.count) {
        for (NSDictionary *model in list) {
            NSString *atype = model[@"atype"];
            NSString *btype = model[@"btype"];
            if ([atype isEqualToString:subP]) {
                CGFloat v = [model[@"arest"] doubleValue];
                rest += v;
            }
            if ([btype isEqualToString:subP]) {
                CGFloat v = [model[@"brest"] doubleValue];
                rest += v;
            }
        }
        page ++;
        sql = [self birdSQL:unit page:page tableName:account];
        list = [master querySQL:sql tableName:account];
    }
    return rest;
}

+ (NSString *)birdSQL:(NSInteger)unit page:(NSInteger)page tableName:(NSString *)tableName{
    return [[NSString alloc] initWithFormat:@"SELECT * FROM %@ limit %@,%@;",tableName,@(page * unit),@(unit)];
}

+ (void)findErrorTrackForSubject:(NSString *)subject table:(NSString *)account controller:(UIViewController *)controller{
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSInteger page = 0;
    NSInteger unit = 500;
    NSString *sql = [self fastSql:unit page:page tableName:account];
    NSArray *list = [master querySQL:sql tableName:account];
    
    NSString *trackSQL = @"SELECT * FROM accounttrack";
    NSArray *tracks = [master querySQL:trackSQL tableName:@"accounttrack"];
    while ([list isKindOfClass:NSArray.class] && list.count) {
        for (NSDictionary *model in list) {
            NSString *atype = model[@"atype"];
            NSString *btype = model[@"btype"];
            CGFloat arest = [model[@"arest"] doubleValue];
            CGFloat brest = [model[@"brest"] doubleValue];
            CGFloat JE = [model[@"je"] doubleValue];
            CGFloat aAll = 0;
            CGFloat bAll = 0;
            BOOL aIS = [atype hasSuffix:_ING_KEY];
            BOOL bIS = [btype hasSuffix:_ING_KEY];
            if (aIS == NO && bIS == NO) {
                continue;
            }
            NSInteger aid = [model[@"aid"] integerValue];
            for (NSDictionary *t in tracks) {
                NSString *accname = t[@"accname"];
                if (![accname isEqualToString:account]) {
                    continue;
                }
                NSInteger link = [t[@"link"] integerValue];
                NSString *tp = t[@"type"];

                if (link == aid) {
                    CGFloat je = [t[@"je"] doubleValue];
                    
                    if (aIS && [tp isEqualToString:@"a"]) {
                        aAll += je;
                        if ([atype containsString:subject]) {
                            NSString *time = [FSKit ymdhsByTimeIntervalString:model[@"time"]];
                            NSLog(@"%@-%@",time,@(je));
                        }
                    }
                    if (bIS && [tp isEqualToString:@"b"]) {
                        bAll += je;
                        if ([btype containsString:subject]) {
                            NSString *time = [FSKit ymdhsByTimeIntervalString:model[@"time"]];
                            NSLog(@"%@-%@",time,@(je));
                        }
                    }
                }
            }
            
            if (aIS) {
                CGFloat aCheck = (JE - aAll - arest);
                if (fabs(aCheck) > 0.1) {
                    NSString *show = [[NSString alloc] initWithFormat:@"aid-a:%@",@(aid)];
                    [FSUIKit showAlertWithMessage:show controller:controller];
                    return;
                }
            }
            if (bIS) {
                CGFloat bCheck = (JE - bAll - brest);
                if (fabs(bCheck) > 0.1) {
                    NSString *show = [[NSString alloc] initWithFormat:@"aid-b:%@",@(aid)];
                    [FSUIKit showAlertWithMessage:show controller:controller];
                    return;
                }
            }
        }
        page ++;
        sql = [self fastSql:unit page:page tableName:account];
        list = [master querySQL:sql tableName:account];
    }
}

+ (NSString *)makeTrackRightSQL:(NSInteger)unit page:(NSInteger)page tableName:(NSString *)tableName{
    return [[NSString alloc] initWithFormat:@"SELECT * FROM %@ limit %@,%@;",tableName,@(page * unit),@(unit)];
}

/*
    数据对不上的原因：
    1.“还清京东白条”，并不在“科目减少”数集中，减少科目也不是本金，但link了本金的一条数据，造成了余额减少，导致“超减”；
    2.“给XX结婚红包”，link到本金的数据，但减少的科目也不是本金，与上同。
    总结：都是Link到数据，但科目没对上。
 
    解决办法：
        遍历科目“type为增加，余额不等于金额”的每条数据，找出减记的track数据，检查track数据的type（a或b）和link去找出减记的科目，如果科目不一致就是有问题。
 */
+ (void)checkOverMinus:(NSString *)subject account:(NSString *)account controller:(UIViewController *)controller{
    NSString *subP = [[NSString alloc] initWithFormat:@"%@p",subject];
    NSString *subM = [[NSString alloc] initWithFormat:@"%@m",subject];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE atype = '%@' OR btype = '%@';",account,subP,subP];
    NSArray *bases = [master querySQL:sql tableName:account];
    NSString *mSql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE atype = '%@' OR btype = '%@';",account,subM,subM];
    NSArray *mBases = [master querySQL:mSql tableName:account];

    NSString *trackSQL = @"SELECT * FROM accounttrack";
    NSArray *tracks = [master querySQL:trackSQL tableName:@"accounttrack"];
    
    for (NSDictionary *model in bases) {
        CGFloat je = [model[@"je"] doubleValue];
        NSInteger aid = [model[@"aid"] integerValue];
        NSString *atype = model[@"atype"];
        if ([atype hasSuffix:_ING_KEY]) {
            CGFloat arest = [model[@"arest"] doubleValue];
            if (fabs(je - arest) > 0.1) {
                CGFloat mje = 0;
                for (NSDictionary *t in tracks) {
                    NSInteger link = [t[@"link"] integerValue];
                    NSString *tp = t[@"type"];
                    CGFloat tje = [t[@"je"] doubleValue];
                    NSString *tbz = t[@"bz"];
                    if (link == aid) {
                        BOOL isA = [tp isEqualToString:@"a"];
                        if (isA) {
                            mje += tje;
                        }
                        BOOL contain = NO;
                        for (NSDictionary *m in mBases) {
                            NSString *mbz = m[@"bz"];
                            if ([mbz isEqualToString:tbz]) {
                                contain = YES;
                                break;
                            }
                        }
                        if (!contain) {
                            NSString *show = [[NSString alloc] initWithFormat:@"aid-A:%@ - tbz:%@",@(aid),tbz];
                            [FSUIKit showAlertWithMessage:show controller:controller];
                            return;
                        }
                    }
                }
                CGFloat delta = je - arest - mje;
                if (fabs(delta) > 0.1) {
                    NSString *show = [[NSString alloc] initWithFormat:@"aid-A:%@",@(aid)];
                    [FSUIKit showAlertWithMessage:show controller:controller];
                    return;
                }
            }
        }
        
        NSString *btype = model[@"btype"];
        if ([btype hasSuffix:_ING_KEY]) {
            CGFloat brest = [model[@"brest"] doubleValue];
            if (fabs(je - brest) > 0.1) {
                CGFloat mje = 0;
                for (NSDictionary *t in tracks) {
                    NSInteger link = [t[@"link"] integerValue];
                    NSString *tp = t[@"type"];
                    CGFloat tje = [t[@"je"] doubleValue];
                    NSString *tbz = t[@"bz"];
                    if (link == aid) {
                        BOOL isB = [tp isEqualToString:@"b"];
                        if (isB) {
                            mje += tje;
                        }
                        BOOL contain = NO;
                        for (NSDictionary *m in mBases) {
                            NSString *mbz = m[@"bz"];
                            if ([mbz isEqualToString:tbz]) {
                                contain = YES;
                                break;
                            }
                        }
                        if (!contain) {
                            NSString *show = [[NSString alloc] initWithFormat:@"aid-B:%@ - tbz:%@",@(aid),tbz];
                            [FSUIKit showAlertWithMessage:show controller:controller];
                            return;
                        }
                    }
                }
                CGFloat delta = je - brest - mje;
                if (fabs(delta) > 0.1) {
                    if (aid == 65) {
                        continue;
                    }
                    NSString *show = [[NSString alloc] initWithFormat:@"aid-B:%@",@(aid)];
                    [FSUIKit showAlertWithMessage:show controller:controller];
                    return;
                }
            }
        }
    }
    [FSUIKit showAlertWithMessage:@"检查完毕，没有问题" controller:controller];
}

+ (NSString *)execSQL:(NSString *)sql{
    FSDBMaster *m = [FSDBMaster sharedInstance];
    NSString *error = [m execSQL:sql type:nil];
    return error;
}

@end
