//
//  ViewController.m
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import "ViewController.h"
#import "Table.h"
#import "Plist.h"
#import "Param.h"
#import "TestAction.h"
#import "MKTimer.h"
#import "AppDelegate.h"
#import "Folder.h"
#import "GetTimeDay.h"
#import "FileCSV.h"
#import "visa.h"
#import "SerialPort.h"
#import "Common.h"
#import "AFNetworking/AFNetworking.h"
#import "MK_FileTXT.h"
#import "MK_FileFolder.h"
#import "GetTimeDay.h"
#import "FileTXT.h"
@interface ViewController ()<NSXMLParserDelegate>
@property (nonatomic, strong) AFNetworkReachabilityManager *manager;

@end

//文件名称
NSString * param_Name = @"Param";

@interface ViewController()<NSTextFieldDelegate>
{
    Table * tab1;
    NSString *nestID;
    Folder   * fold;
    FileCSV  * csvFile;
    FileTXT  * file_txt;
    Plist * plist;
    Param * param;
    SerialPort *   serialport;        //控制板类
    SerialPort *   humiturePort;      //温湿度控制类
    NSArray    *   itemArr1;
    NSArray    *   itemArr2;
    
    TestAction * action1;
    TestAction * action2;
    TestAction * action3;
    TestAction * action4;
    
    //定时器相关
     MKTimer * mkTimer;
     int      ct_cnt;                  //记录cycle time定时器中断的次数
    
    //Add For SFC===============
    
    __weak IBOutlet NSTextField *netState_TF;
    IBOutlet NSTextField *hadUpload_TF;
    IBOutlet NSTextField *underUpload_TF;
    IBOutlet NSTextField *reUpload_TF;
    IBOutlet NSTextField *totalToUpload_TF;
    
    
    
    
    IBOutlet NSTextField *NS_TF1;                     //产品1输入框
    IBOutlet NSTextField *NS_TF2;                     //产品2输入框
    IBOutlet NSTextField *NS_TF3;                     //产品3输入框
    
    IBOutlet NSTextField *NS_TF4;                     //产品4输入框
    
    
    IBOutlet NSTextView *Log_View;                    //Log日志
    
    IBOutlet NSTextField *  Status_TF;                //显示状态栏
    IBOutlet NSTextField *  testFieldTimes;           //时间显示输入框
    IBOutlet NSTextField *  humiture_TF;              //温湿度显示lable
    IBOutlet NSTextField *  TestCount_TF;             //测试的次数
    IBOutlet NSButton    *  IsUploadPDCA_Button;      //上传PDCA的按钮
    IBOutlet NSButton    *  IsUploadSFC_Button;       //上传SFC的按钮
    IBOutlet NSPopUpButton *product_Type;             //产品的类型
    IBOutlet NSTextField *  Version_TF;               //软件版本
    
    
    __weak IBOutlet NSButton *cancelUnlimit;
    __weak IBOutlet NSButton *singleTest;
    __weak IBOutlet NSButton *singleTest_1;
    __weak IBOutlet NSButton *singleTest_2;
    __weak IBOutlet NSButton *singleTest_3;
    __weak IBOutlet NSButton *singleTest_4;
    
    IBOutlet NSTextView *A_LOG_TF;
    IBOutlet NSTextView *B_LOG_TF;
    IBOutlet NSTextView *C_LOG_TF;
    IBOutlet NSTextView *D_LOG_TF;
    
    IBOutlet NSTextView *A_FailItem;
    IBOutlet NSTextView *B_FailItem;
    IBOutlet NSTextView *C_FailItem;
    IBOutlet NSTextView *D_FailItem;
    
    
    __weak IBOutlet NSPopUpButton *SN_Length;
    
    
    
    IBOutlet NSPopUpButton *NestID_Change;
    IBOutlet NSTextField   *product_Config;
    IBOutlet NSButton      *config_change;
    IBOutlet NSPopUpButton *Vender;
    IBOutlet NSTextField   *loopTest_Label;
    IBOutlet NSTextField   *Operator_TF;
    IBOutlet NSButton      *nulltest_button;
    IBOutlet NSButton      *startbutton;
    
    //定义对应的布尔变量 判断index=101-104是否均执行
    BOOL isFix_A_Done;
    BOOL isFix_B_Done;
    BOOL isFix_C_Done;
    BOOL isFix_D_Done;
    BOOL isFinish;
    
    NSString * noticeStr_A;
    NSString * noticeStr_B;
    NSString * noticeStr_C;
    NSString * noticeStr_D;
    
    
    int index;
    //创建相关的属性
    NSString * foldDir;
    NSString *foldD;
    AppDelegate  * app;
    
    //温湿度相关属性
    NSString             * humitureString;
    NSString             * temptureString;
    
    //测试结束通知中返回的对象===数据中含有P代表成功，含有F代表失败
    NSString             * notiString;
    NSMutableString      * notiAppendingString;//拼接的字符串
    
    //产品通过的的次数和测试的总数
    int                   passNum;     //通过的测试次数
    int                   totalNum;    //通过的测试总数
    int                   fix_A_num;
    int                   fix_B_num;
    int                   fix_C_num;
    int                   fix_D_num;

    NSMutableDictionary        * config_Dic;  //相关的配置参数属性
   
    //增加无限循环限制设定
    BOOL  unLimitTest;                               //无限循环设定
    NSString *sw_org;
    NSString *foldDir_tmp;
    
    NSString *day_T;
    NSInteger controlLog;
    
    
    //Add For SFC
    NSInteger hadUploadCount;
    NSInteger underUploadCount;
    NSInteger totalUploadCount;

    BOOL isUpLoadLocalData;
    BOOL isBreakUploadLocalData;
    NSInteger reUpload;
    NSString *sn_Upload;
    BOOL isUploadSuccess;
    NSInteger intervalTimes;
    NSInteger SFCRequestCount;
    NSInteger reqTimeOutCount;
    BOOL isLocalDataUploading;
    
    NSMutableArray *webBodyArrM;
    NSInteger isNetOK;
    NSInteger testCount;
}

@end

@implementation ViewController


//软件测试整个流程  //door close--->SN---->config-->监测start--->下压气缸---->抛出SN-->直接运行


- (void)viewDidLoad {
    [super viewDidLoad];
    
    testCount=0;
    file_txt=[[FileTXT alloc]init];
    webBodyArrM=[[NSMutableArray alloc]initWithCapacity:10];
    day_T=[[GetTimeDay shareInstance] getCurrentDay];
    intervalTimes=0;
    reqTimeOutCount=0;
    SFCRequestCount=0;
    unLimitTest=NO;
    controlLog=0;
    isFix_A_Done=NO;
    isFix_B_Done=NO;
    isFix_C_Done=NO;
    isFix_D_Done=NO;
    isFinish=NO;
    
    noticeStr_A=[[NSString alloc]init];
    noticeStr_B=[[NSString alloc]init];
    noticeStr_C=[[NSString alloc]init];
    noticeStr_D=[[NSString alloc]init];
    
    
    //整型变量定义区
    index    = 0;
    passNum  = 0;
    totalNum = 0;
    
    fix_A_num = 0;
    fix_B_num = 0;
    fix_C_num = 0;
    fix_D_num = 0;
    
    
    config_Dic = [[NSMutableDictionary alloc]initWithCapacity:10];
    plist = [Plist shareInstance];
    param = [[Param alloc]init];
    [param ParamRead:param_Name];
    
    [config_Dic setValue:param.sw_ver forKey:kSoftwareVersion];
    [Version_TF setStringValue:param.sw_ver];
    sw_org=param.sw_ver;
    foldDir_tmp=param.foldDir;
    //第一响应
    [NS_TF1 acceptsFirstResponder];
    //加载界面
    if ([NestID_Change.title containsString:@"BC"])
    {
        itemArr1 = [plist PlistRead:@"Station_Cr_1_Humid_BC" Key:@"AllItems"];
    }
    else
    {
        itemArr1 = [plist PlistRead:@"Station_Cr_1_Humid_BC" Key:@"AllItems"];
    }
    tab1 = [[Table  alloc]init:Tab1_View DisplayData:itemArr1];
    
    //初始化温湿度和主控板
     humiturePort = [[SerialPort alloc]init];
    [humiturePort setTimeout:1 WriteTimeout:1];
     serialport   = [[SerialPort alloc]init];
    [serialport setTimeout:1 WriteTimeout:1];
    
     notiAppendingString = [[NSMutableString alloc]init];
    
    
    
    //开启定时器
    mkTimer = [[MKTimer alloc]init];
    //获取测试Fail的全局变量
    app = [NSApplication sharedApplication].delegate;
    
    //创建总文件
    fold    = [[Folder alloc]init];
    csvFile = [[FileCSV alloc]init];
    
    
    
    //监听测试结束，重新等待SN
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectSnChangeNoti:) name:@"SNChangeNotice" object:nil];
    //监听空测试
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectNullTestNotiM:) name:@"NULLTEST" object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCA_SFC_LimitNoti:) name:@"PDCAButtonLimit_Notification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReceiveWebBodyStrNoti:) name:@"ReturnWebBodyStrNotice" object:nil];

    
    

    //将参数传入TestAction中，开启线程
    [self reloadPlist];
    
    
    
    //开启线程，扫描SN，和 获取温湿度消息
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^(void){
        
         [self Working];
        
    });

    dispatch_async(dispatch_get_global_queue(0,0), ^(void){
        
        [self judgeNet];
        
    });
    

    // Do any additional setup after loading the view.
}





#pragma mark=======================改变测试条件



- (IBAction)product_config:(NSButton *)sender
{
    if (!sender.state)
    {
        product_Config.editable=NO;

        if (index < 6)
        {
            
            
            [self creat_TotalFile];
            
            [action1 setFoldDir:foldDir];
            [action2 setFoldDir:foldDir];
            [action3 setFoldDir:foldDir];
            [action4 setFoldDir:foldDir];
            
            
            [config_Dic setValue: product_Config.stringValue forKey:kConfig_pro];

        }
    }
    else
    {
        product_Config.editable=YES;
    }

}
- (IBAction)NestID_Change:(NSPopUpButton *)sender
{

    [config_Dic setValue: NestID_Change.titleOfSelectedItem forKey:kProductNestID];
}

-(void)reloadPlist
{
    action1 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix1 withFileDir:foldDir withType:1];
    action1.resultTF = DUT_Result1_TF;//显示结果的lable
    action1.Log_View  = A_LOG_TF;
    action1.Fail_View = A_FailItem;
    action1.dutTF    = NS_TF1;
    action1.isCancel=NO;
    [action1 setFoldDir:foldDir];
    [action1 setCsvTitle:plist.titile];
    [action1 setSw_ver:param.sw_ver];
    [action1 setSw_name:param.sw_name];

    
    
    action2 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix2 withFileDir:foldDir withType:2];
    action2.resultTF = DUT_Result2_TF;//显示结果的lable
    action2.Log_View = B_LOG_TF;
    action2.Fail_View =B_FailItem;
    action2.dutTF    = NS_TF2;
    action2.isCancel=NO;
    [action2 setFoldDir:foldDir];
    [action2 setCsvTitle:plist.titile];
    [action2 setSw_ver:param.sw_ver];
    [action2 setSw_name:param.sw_name];
    
    
    action3 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix3 withFileDir:foldDir withType:3];
    action3.resultTF = DUT_Result3_TF;//显示结果的lable
    action3.Log_View = C_LOG_TF;
    action3.Fail_View =C_FailItem;
    action3.dutTF    = NS_TF3;
    action3.isCancel=NO;
    [action3 setFoldDir:foldDir];
    [action3 setCsvTitle:plist.titile];
    [action3 setSw_ver:param.sw_ver];
    [action3 setSw_name:param.sw_name];
    
    action4 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix4 withFileDir:foldDir withType:4];
    action4.resultTF = DUT_Result4_TF;//显示结果的lable
    action4.Log_View = D_LOG_TF;
    action4.Fail_View =D_FailItem;
    action4.dutTF    = NS_TF4;
    action4.isCancel=NO;
    [action4 setFoldDir:foldDir];
    [action4 setCsvTitle:plist.titile];
    [action4 setSw_ver:param.sw_ver];
    [action4 setSw_name:param.sw_name];

}

-(void)reloadAction
{
    [self creat_TotalFile];

    action1 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix1 withFileDir:foldDir withType:1];
    [action1 setFoldDir:foldDir];
    [action1 setSw_ver:sw_org];
    [action1 setCsvTitle:plist.titile];
    action1.resultTF = DUT_Result1_TF;//显示结果的lable

    
    action2 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix2 withFileDir:foldDir withType:2];
    [action2 setFoldDir:foldDir];
    [action2 setSw_ver:sw_org];
    [action2 setCsvTitle:plist.titile];
    action2.resultTF = DUT_Result2_TF;//显示结果的lable
    
    action3 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix3 withFileDir:foldDir withType:3];
    [action3 setFoldDir:foldDir];
    [action3 setSw_ver:sw_org];
    [action3 setCsvTitle:plist.titile];
    action3.resultTF = DUT_Result3_TF;//显示结果的lable
    
    action4 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix4 withFileDir:foldDir withType:4];
    [action4 setFoldDir:foldDir];
    [action4 setSw_ver:sw_org];
    [action4 setCsvTitle:plist.titile];
    action4.resultTF = DUT_Result4_TF;//显示结果的lable
    
}

- (IBAction)change_Station_Button:(id)sender {
    
    if (index > 4)
    {
        return;
    }
    if ([sender isEqual:product_Type]) {
        
        [self creat_TotalFile];
        
        [action1 setFoldDir:foldDir];
        [action2 setFoldDir:foldDir];
        [action3 setFoldDir:foldDir];
        [action4 setFoldDir:foldDir];
        

        [config_Dic setValue: product_Type.titleOfSelectedItem forKey:kProduct_type];
        
    }
    if ([sender isEqual:Vender]) {
        
    }
    
}


#pragma mark=======================设置配置文件的状态
-(void)setConfigStation
{
    [config_Dic setValue: NestID_Change.titleOfSelectedItem forKey:kProductNestID];
    [config_Dic setValue: [product_Config.stringValue length]>0?product_Config.stringValue:@"" forKey:kConfig_pro];
    [config_Dic setValue:  product_Type.titleOfSelectedItem forKey:kProduct_type];
    [config_Dic setValue: [Operator_TF.stringValue length]>0?Operator_TF.stringValue:@"" forKey:kOperator_ID];
    
}


- (IBAction)start_Action:(id)sender {//发送通知开始测试
    
    startbutton.enabled = NO;
    
}
- (IBAction)cancelUnlimit:(NSButton *)sender
{
    unLimitTest=NO;
    sender.hidden=YES;
}

- (IBAction)singleTest:(NSButton *)sender
{

    if (sender.state)
    {
        singleTest_1.enabled=YES;
        singleTest_2.enabled=YES;
        singleTest_3.enabled=YES;
        singleTest_4.enabled=YES;
    }
    else
    {
        singleTest_1.enabled=NO;
        singleTest_2.enabled=NO;
        singleTest_3.enabled=NO;
        singleTest_4.enabled=NO;
    }
}

- (IBAction)singleTest_1:(NSButton *)sender
{
    if (sender.state == 0)
    {
         action1.isCancel=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCurrentThread" object:@""];

    }
    else
    {
        //将参数传入TestAction中，开启线程
        action1 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix1 withFileDir:foldDir withType:1];
        action1.resultTF = DUT_Result1_TF;//显示结果的lable
        action1.Log_View  = A_LOG_TF;
        action1.Fail_View = A_FailItem;
        action1.dutTF    = NS_TF1;
        action1.isCancel=NO;
        [action1 setFoldDir:foldDir];
        [action1 setCsvTitle:plist.titile];
        [action1 setSw_ver:param.sw_ver];
        [action1 setSw_name:param.sw_name];
        action1.dut_sn=NS_TF1.stringValue;
    }

}
- (IBAction)singleTest_2:(NSButton *)sender
{

    if (!sender.state)
    {
        action2.isCancel=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCurrentThread" object:@""];

    }
    else
    {
        action2 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix2 withFileDir:foldDir withType:2];
        action2.resultTF = DUT_Result2_TF;//显示结果的lable
        action2.Log_View = B_LOG_TF;
        action2.Fail_View =B_FailItem;
        action2.dutTF    = NS_TF2;
        action2.isCancel=NO;
        [action2 setFoldDir:foldDir];
        [action2 setCsvTitle:plist.titile];
        [action2 setSw_ver:param.sw_ver];
        [action2 setSw_name:param.sw_name];
        action2.dut_sn=NS_TF2.stringValue;
    }

}
- (IBAction)singleTest_3:(NSButton *)sender
{

    if (!sender.state)
    {
        action3.isCancel=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCurrentThread" object:@""];

    }
    else
    {
        action3 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix3 withFileDir:foldDir withType:3];
        action3.resultTF = DUT_Result3_TF;//显示结果的lable
        action3.Log_View = C_LOG_TF;
        action3.Fail_View =C_FailItem;
        action3.dutTF    = NS_TF3;
        action3.isCancel=NO;
        [action3 setFoldDir:foldDir];
        [action3 setCsvTitle:plist.titile];
        [action3 setSw_ver:param.sw_ver];
        [action3 setSw_name:param.sw_name];
        action3.dut_sn=NS_TF3.stringValue;

    }

}
- (IBAction)singleTest_4:(NSButton *)sender
{

    if (!sender.state)
    {
        action4.isCancel=YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCurrentThread" object:@""];

    }
    else
    {
        action4 = [[TestAction alloc]initWithTable:tab1 withFixDic:param.Fix4 withFileDir:foldDir withType:4];
        action4.resultTF = DUT_Result4_TF;//显示结果的lable
        action4.Log_View = D_LOG_TF;
        action4.Fail_View =D_FailItem;
        action4.dutTF    = NS_TF4;
        action4.isCancel=NO;
        [action4 setFoldDir:foldDir];
        [action4 setCsvTitle:plist.titile];
        [action4 setSw_ver:param.sw_ver];
        [action4 setSw_name:param.sw_name];
        action4.dut_sn=NS_TF4.stringValue;
    }

}



#pragma mark=======================通知
//=============================================
-(void)selectSnChangeNoti:(NSNotification *)noti
{
     notiString = noti.object;
     totalNum++;
    
    if ([noti.object containsString:@"1"]) {
        
        fix_A_num = 101;
        noticeStr_A=noti.object;
        [notiAppendingString appendString:noti.object];
    }
    if ([noti.object containsString:@"2"]) {
        
        fix_B_num = 102;
        noticeStr_B=noti.object;
        [notiAppendingString appendString:noti.object];

    }
    if ([noti.object containsString:@"3"]) {
        
        fix_C_num = 103;
        noticeStr_C=noti.object;
        [notiAppendingString appendString:noti.object];

    }
    if ([noti.object containsString:@"4"]) {
        
        fix_D_num = 104;
        noticeStr_D=noti.object;
        [notiAppendingString appendString:noti.object];

    }
    
    //软件测试结束
    if (([notiAppendingString containsString:@"1"] || singleTest_1.state==0)&&([notiAppendingString containsString:@"2"] || singleTest_2.state==0)&&([notiAppendingString containsString:@"3"] || singleTest_3.state==0)&&([notiAppendingString containsString:@"4"] || singleTest_4.state==0)) {
        index = 105;
        [notiAppendingString setString:@""];
    }
    

}




//去掉回显
-(NSString *)backtringCut:(NSString *)backStr
{
    NSString *str;
    NSArray *arr=[backStr componentsSeparatedByString:@"\r\n"];
    if (arr.count>1) {
        
         str=arr[1];
    }
    else
    {
        str=@"";
    }
    return str;
}



-(void)selectPDCA_SFC_LimitNoti:(NSNotification *)noti
{
    unLimitTest=YES;
    cancelUnlimit.hidden=NO;
    IsUploadSFC_Button.enabled=YES;
    IsUploadPDCA_Button.enabled=YES;
    SN_Length.enabled=YES;
}

-(void)selectNullTestNotiM:(NSNotification *)noti
{
    [self creat_TotalFile];
    //空测试的时候，隐藏相关的按钮
    nulltest_button.hidden = NO;
    param.sw_ver=[NSString stringWithFormat:@"%@_N",param.sw_ver];
    [self reloadPlist];
    itemArr1 = [plist PlistRead:@"Station_Cr_1_Humid_BC" Key:@"AllItems"];
    tab1 = [tab1 init:Tab1_View DisplayData:itemArr1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NTNotification" object:@""];


}




-(void)ReceiveWebBodyStrNoti:(NSNotification *)noti
{
    [webBodyArrM addObject:noti.object];
    testCount++;
    
}

//发送通知，监听SN
- (IBAction)change_SFC_State:(id)sender {
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoticeSFCSTATE" object:IsUploadSFC_Button.state?@"YES":@"NO"];
    
    
}

//=============================================


-(void)Working
{
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
        
#pragma mark-------------//index = 0,初始化控制板串口
        if (index == 0) {
            
            [NSThread sleepForTimeInterval:0.2];
            
            BOOL  isOpen = [serialport Open:param.contollerBoard];
            if (!isOpen)
            {
                isOpen = [serialport Open:param.contollerBoard_e];
                param.contollerBoard=param.contollerBoard_e;
            }

            
            if (param.isDebug)
            {
                
                 [self UpdateTextView:@"index = 0,模拟控制板初始化" andClear:NO andTextView:Log_View];
                 index = 1;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index = 0,模拟控制板初始化"];
                });
                [NSThread sleepForTimeInterval:1];
            }
            else if(isOpen)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index = 0,控制板连接成功"];
                });
                
                [self UpdateTextView:@"index = 0,控制板连接成功" andClear:NO andTextView:Log_View];
                
                index = 1;

            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index = 0,控制板打开失败"];
                });
                [self UpdateTextView:@"index = 0,控制板打开失败" andClear:NO andTextView:Log_View];
                
            }
        }
#pragma mark-------------//index=1,初始化温湿度板子
        if (index == 1) {
            
            [NSThread sleepForTimeInterval:0.2];
            if (param.isDebug) {
                
                [self UpdateTextView:@"index = 1,debug 模式中,模拟温湿度板子初始化" andClear:NO andTextView:Log_View];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index = 1,debug 模式中,模拟温湿度板子初始化"];
                });
                index = 2;
                [NSThread sleepForTimeInterval:1];

            }
            else if (!humiturePort.IsOpen)
            {
                 BOOL  isOpen = [humiturePort Open:param.humiture_uart_port_name];
                if (!isOpen)
                {
                    isOpen = [humiturePort Open:param.humiture_uart_port_name_e];
                    param.humiture_uart_port_name=param.humiture_uart_port_name_e;
                }
                 if (isOpen)
                 {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Status_TF setStringValue:@"index=1,温湿度连接成功！"];
                    });
                    //获取温湿度的值
                    [NSThread sleepForTimeInterval:1];
                    [humiturePort WriteLine:@"Read"];
                    [NSThread sleepForTimeInterval:1];
                    NSString  * back_humitureStr = [humiturePort ReadExisting];
                     
                     action1.tem_humit=back_humitureStr;
                     action2.tem_humit=back_humitureStr;
                     action3.tem_humit=back_humitureStr;
                     action4.tem_humit=back_humitureStr;
                     
                    //显示温湿度
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [humiture_TF setStringValue:back_humitureStr];
                    });
                     
                    [self UpdateTextView:@"index = 1,温湿度连接成功" andClear:NO andTextView:Log_View];
                    index = 2;
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Status_TF setStringValue:@"index=1,温湿度连接失败！"];
                    });
                }
            }
            else
            {
                
                
                //获取温湿度的值
                [NSThread sleepForTimeInterval:0.3];
                [humiturePort WriteLine:@"Read"];
                [NSThread sleepForTimeInterval:0.8];
                NSString  * back_humitureStr = [humiturePort ReadExisting];
                
                
                
                action1.tem_humit=back_humitureStr;
                action2.tem_humit=back_humitureStr;
                action3.tem_humit=back_humitureStr;
                action4.tem_humit=back_humitureStr;

                //显示温湿度
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [humiture_TF setStringValue:back_humitureStr];
                });
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"index=1,温湿度更新成功!"];
                });
                
                index = 2;
            }

        
        }
        
#pragma mark-------------//index=2,检测门是否关闭
        if ( index == 2) {
            
            index=3;
        }
 #pragma mark-------------//index=3,请输入SN的值
        if (index == 3) {
            
            [NSThread sleepForTimeInterval:0.5];
            dispatch_async(dispatch_get_main_queue(), ^{
                [Status_TF setStringValue:@"index=3,请输入SN"];
            });

            if (controlLog==0)
            {
                [self UpdateTextView:@"index=3,请输入SN" andClear:NO andTextView:Log_View];
            }
            controlLog=1;
             dispatch_sync(dispatch_get_main_queue(), ^{
                if (([NS_TF1.stringValue length]==17 ||[NS_TF1.stringValue length]==21 || singleTest_1.state==0)&&([NS_TF2.stringValue length]==17 ||[NS_TF2.stringValue length]==21 || singleTest_2.state==0)&&([NS_TF3.stringValue length]==17 ||[NS_TF3.stringValue length]==21 || singleTest_3.state==0)&&([NS_TF4.stringValue length]==17 ||[NS_TF4.stringValue length]==21 || singleTest_4.state==0) && !(singleTest_1.state==0 && singleTest_2.state==0 && singleTest_3.state==0 && singleTest_4.state==0))
                {
                    [serialport ReadExisting];
                    index = 4;
                }
                
            });
        }
        
        
        
#pragma mark-------------//index=4,判断当前配置文件和changeID等配置
        
        if (index == 4) { //判断当前配置文件和changeID等配置
            [NSThread sleepForTimeInterval:0.3];
            [self setConfigStation];
            
            if (config_change.state) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"请确认产品 Config!"];
                });
            }
            else
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Status_TF setStringValue:@"等待 SN!"];
                });
            }
            
            
            if (!config_change.state) {
                
                //配置好了，将相关参数传送
                action1.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
                action2.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
                action3.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
                action4.Config_Dic = [NSDictionary dictionaryWithDictionary:config_Dic];
                nestID=NestID_Change.title;
                [self UpdateTextView:@"index=4,参数已经配置好" andClear:NO andTextView:Log_View];
                
                
                index = 5;
                
            }
        }
        
#pragma mark-------------//index=5,双击启动/点击界面start按钮---》气缸动作---->start ok
        if (index == 5) {
            
            [NSThread sleepForTimeInterval:0.5];
            NSString *backString=[serialport ReadExisting];
            
            if ([[backString uppercaseString] containsString:@"START OK*_*\r\n"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index=5,启动检测OK"];
                    action1.dut_sn = [NS_TF1 stringValue];
                    action2.dut_sn = [NS_TF2 stringValue];
                    action3.dut_sn = [NS_TF3 stringValue];
                    action4.dut_sn = [NS_TF4 stringValue];
                });
                index = 6;
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index=5,请重新双击启动"];
                });
            }
            if (param.isDebug)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Status_TF setStringValue:@"index=5,启动检测OK"];
                    action1.dut_sn = [NS_TF1 stringValue];
                    action2.dut_sn = [NS_TF2 stringValue];
                    action3.dut_sn = [NS_TF3 stringValue];
                    action4.dut_sn = [NS_TF4 stringValue];
                });
                index = 6;
            }
            
        }
        

 #pragma mark-------------//index=6,抛出开始测试信号
        if (index == 6)
        {
            [NSThread sleepForTimeInterval:0.2];
            [self UpdateTextView:@"" andClear:YES andTextView:Log_View];
            dispatch_async(dispatch_get_main_queue(), ^{
                [Status_TF setStringValue:@"index=6,测试中..."];
                if (!unLimitTest)
                {
                    nestID=NestID_Change.title;
                    [NS_TF1 setStringValue:@""];
                    [NS_TF2 setStringValue:@""];
                    [NS_TF3 setStringValue:@""];
                    [NS_TF4 setStringValue:@""];
                    
                    [NS_TF1 becomeFirstResponder];
                    [webBodyArrM removeAllObjects];
                }
                
                [self creat_TotalFile];
                [action1 setFoldDir:foldDir];
                [action2 setFoldDir:foldDir];
                [action3 setFoldDir:foldDir];
                [action4 setFoldDir:foldDir];
                
                
                [config_Dic setValue: product_Config.stringValue forKey:kConfig_pro];
                
            });
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NSThreadStart_Notification" object:@""];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [tab1 ClearTable];
            });

            [testFieldTimes setStringValue:@"0"];
            [mkTimer setTimer:0.1];
            [mkTimer startTimerWithTextField:testFieldTimes];
            ct_cnt = 1;
            index = 1000;
            
        }
    
        
#pragma mark-------------//index=101,A治具测试结束，发送指令信号灯
        if (fix_A_num == 101) {
            [NSThread sleepForTimeInterval:0.1];
            isFix_A_Done=YES;

            if (param.isDebug) {
                
                if ([noticeStr_A containsString:@"P"]) {
                    
                    passNum++;
                    [serialport WriteLine:@"FIX_A pass"];
                    
                    
                }
                
                
            }
            else
            {
                if ([noticeStr_A containsString:@"P"]) {
                    
                    passNum++;
                    [serialport WriteLine:@"FIX_A pass"];
                    
                    
                    
                }
                
                if ([noticeStr_A containsString:@"F"]) {
                    
                    [serialport WriteLine:@"FIX_A fail"];
                    
                }
            
            }
            
            fix_A_num = 0;
            noticeStr_A=@"";
            [self UpdateTextView:@"index=101,FIX-A测试完毕！\n" andClear:NO andTextView:Log_View];
        }
        
        
#pragma mark-------------//index=102,B治具测试结束，发送指令信号灯
        if (fix_B_num == 102) {
            [NSThread sleepForTimeInterval:0.1];
            isFix_B_Done=YES;
            if (param.isDebug) {

                if ([noticeStr_B containsString:@"P"]) {
                    
                    passNum++;
                    [serialport WriteLine:@"FIX_B pass"];
                    
                    
                }

            }
            else
            {
            
                if ([noticeStr_B containsString:@"P"]) {
                    
                    passNum++;
                    
                    [serialport WriteLine:@"FIX_B pass"];
                    
                    
                    
                }
                
                if ([noticeStr_B containsString:@"F"]) {
                    
                    [serialport WriteLine:@"FIX_B fail"];
                    
                }
            }
            
            fix_B_num =0;
            noticeStr_B=@"";
            [self UpdateTextView:@"index=102,FIX-B测试完毕！\n" andClear:NO andTextView:Log_View];
        }
        
#pragma mark-------------//index=103,C治具测试结束，发送指令信号灯
        if (fix_C_num == 103) {
            [NSThread sleepForTimeInterval:0.1];
            isFix_C_Done=YES;
            
            if (param.isDebug) {
                

                if ([noticeStr_C containsString:@"P"]) {
                    
                    passNum++;
                    [serialport WriteLine:@"FIX_C pass"];
                    
                    
                    
                }

            }
            else
            {
            
                if ([noticeStr_C containsString:@"P"]) {
                    
                    passNum++;
                    
                    [serialport WriteLine:@"FIX_C pass"];
                    
                   
                    
                }
                
                if ([noticeStr_C containsString:@"F"]) {
                    
                    [serialport WriteLine:@"FIX_C fail"];
                    
                }
            }
            [self UpdateTextView:@"index=103,FIX-C测试完毕！\n" andClear:NO andTextView:Log_View];
            fix_C_num = 0;
            noticeStr_C=@"";
            
        }
        
        
#pragma mark-------------//index=103,C治具测试结束，发送指令信号灯
        if (fix_D_num == 104) { //扫描SN
            [NSThread sleepForTimeInterval:0.1];
            isFix_D_Done=YES;
            if (param.isDebug) {

                if ([noticeStr_D containsString:@"P"]) {
                    
                    passNum++;
                    [serialport WriteLine:@"FIX_D pass"];
                    
                   
                    
                }

                
            }
            else
            {
                if ([noticeStr_D containsString:@"P"]) {
                    
                    passNum++;
                    
                    [serialport WriteLine:@"FIX_D pass"];
                    
                    
                    
                }
                
                if ([noticeStr_D containsString:@"F"]) {
                    
                    [serialport WriteLine:@"FIX_D fail"];
                    
                }
           }
            
            fix_D_num = 0;
            noticeStr_D=@"";
            [self UpdateTextView:@"index=104,FIX-D测试完毕！\n" andClear:NO andTextView:Log_View];
        }
  
#pragma mark-------------//index=105,所有软件测试结束
        if (index == 105 || isFinish)
        {
            [NSThread sleepForTimeInterval:0.2];
            controlLog=0;
            if (!isFix_A_Done && singleTest_1.state==1)
            {
                index=101;
                isFinish=YES;
            }
            else if (!isFix_B_Done && singleTest_2.state==1)
            {
                index=102;
                isFinish=YES;
            }
            else if (!isFix_C_Done && singleTest_3.state==1)
            {
                index=103;
                isFinish=YES;
            }
            else if (!isFix_D_Done && singleTest_4.state==1)
            {
                index=104;
                isFinish=YES;
            }
            else
            {
                [self UpdateTextView:@"index=105,所有线程测试完毕！\n" andClear:NO andTextView:Log_View];
                testCount=0;
                if (IsUploadSFC_Button.state)
                {
                    [self stoping];
                    NSArray *webBodyArr=[NSArray arrayWithArray:webBodyArrM];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if ((isNetOK&& SFCRequestCount < 2) || intervalTimes%1000==200)
                        {
                            sn_Upload=@"";
                            isUploadSuccess=YES;
                            NSInteger i=webBodyArr.count;
                            while (i > 0)
                            {
                                if ([sn_Upload isEqualToString:@""])
                                {
                                    if ([webBodyArr[i-1] containsString:@"<SN>FGR"])
                                    {
                                        if (isUploadSuccess)
                                        {
                                            intervalTimes=0;
                                            [self upLoadToSFCWithWebBodyString:webBodyArr[i-1]];
                                            i--;
                                        }
                                    }
                                    else
                                    {
                                        i--;
                                    }
                                    
                                    if (SFCRequestCount != 0 )
                                    {
                                        isUploadSuccess=NO;
                                        break;
                                    }
                                    
                                }
                            }
                        }
                        
                        if (!isNetOK || !isUploadSuccess)
                        {
                            if (isNetOK)
                            {
                                [netState_TF setPlaceholderString:@"服务器异常！"];
                                [netState_TF setTextColor:[NSColor whiteColor]];
                                [netState_TF setBackgroundColor:[NSColor yellowColor]];
                            }
                            else
                            {
                                [netState_TF setPlaceholderString:@"网络异常！"];
                                [netState_TF setTextColor:[NSColor whiteColor]];
                                [netState_TF setBackgroundColor:[NSColor yellowColor]];
                            }
                            
                            
                            NSInteger i=webBodyArr.count;
                            while (i > 0)
                            {
                                if ([webBodyArr[i-1] containsString:@"<SN>FGR"])
                                {
                                    [self saveSFCDataWithString:webBodyArr[i-1]];
                                    i--;
                                    underUploadCount++;
                                    intervalTimes++;
                                }
                                else
                                {
                                    i--;
                                }
                                [underUpload_TF setPlaceholderString:[NSString stringWithFormat:@"%ld",(long)underUploadCount]];

                            }
                            
                        }

                        
                    });
                    

                }

                    isFix_A_Done=NO;
                    isFix_B_Done=NO;
                    isFix_C_Done=NO;
                    isFix_D_Done=NO;
                    isFinish    =NO;
                    [NSThread sleepForTimeInterval:0.2];
                
                    if (unLimitTest && [product_Config.stringValue containsString:@"LPT"] && ![product_Config.stringValue containsString:@"-CRB"])
                    {
                        [NSThread sleepForTimeInterval:1];
                        
                    }
                    else
                    {
                        //发送reset，让气缸复位
                        [serialport WriteLine:@"reset"];
                        [self UpdateTextView:@"index=105,向串口发送reset指令！\n" andClear:NO andTextView:Log_View];
                        
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //更新测试的次数
                        [TestCount_TF setStringValue:[NSString stringWithFormat:@"%d/%d",passNum,totalNum]];
                        //========定时器结束========
                        [mkTimer endTimer];
                        [self UpdateTextView:@"计时器停止计时！\n" andClear:NO andTextView:Log_View];
                        ct_cnt = 0;
                        singleTest.enabled=YES;
                        
                        
                    });
                
                
                index = 1; //重新获取温湿度
            }
           
            [NSThread sleepForTimeInterval:0.2];
            
        }
        
        

        
        
#pragma mark-------------//index=1000,测试结束
        if (index == 1000)
        { //等待测试结束，并返回测试的结果
            [NSThread sleepForTimeInterval:0.2];
        }

   
    }
    
    
}






//创建A,B,C,D治具对应的文件ABCD
-(void)creat_TotalFile
{
    
    action1.Product_type=product_Type.title;
    action2.Product_type=product_Type.title;
    action3.Product_type=product_Type.title;
    action4.Product_type=product_Type.title;

    action1.Product_config=product_Config.stringValue;
    action2.Product_config=product_Config.stringValue;
    action3.Product_config=product_Config.stringValue;
    action4.Product_config=product_Config.stringValue;

    
    NSString  *  day = [[GetTimeDay shareInstance] getCurrentDay];
    
    foldDir = [NSString stringWithFormat:@"%@/%@/%@_%@",foldDir_tmp,day,param.sw_name,param.sw_ver];
 
    foldD=foldDir;
    foldDir = [foldDir stringByAppendingFormat:@"/Config_%@",product_Config.stringValue];
 
    
    action1.foldDir2=foldD;
    action2.foldDir2=foldD;
    action3.foldDir2=foldD;
    action4.foldDir2=foldD;

    if (![day isEqualToString:day_T])
    {
        [action1 setFoldDir:foldDir];
        [action2 setFoldDir:foldDir];
        [action3 setFoldDir:foldDir];
        [action4 setFoldDir:foldDir];

        
    }
    
    
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@.csv",foldD,day]];
    
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_%@.csv",foldDir,day,product_Config.stringValue]];

    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_A.csv",foldDir,day]];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_B.csv",foldDir,day]];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_C.csv",foldDir,day]];
    [self createFileWithstr:[NSString stringWithFormat:@"%@/%@_D.csv",foldDir,day]];
    
   
    
}


/**
 *  生成文件
 *
 *  @param fileString 文件的地址
 */
-(void)createFileWithstr:(NSString *)fileString
{
    while (YES) {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileString]) {
            break;
        }
        else
        {
            
            [fold Folder_Creat:foldDir];
            [csvFile CSV_Open:fileString];
            [csvFile CSV_Write:plist.titile];
        }
        
    }

}

#pragma mark====================按钮相关
//将空测试出来的值写到plist文件中去
- (IBAction)NullTestDone_Button:(id)sender {
    
  [[NSNotificationCenter defaultCenter] postNotificationName:@"WriteNullValue" object:nil];
    
}


- (IBAction)reset_fixture:(id)sender {
    
    
}




#pragma mark 控制光标 成为第一响应者

-(void)controlTextDidChange:(NSNotification *)obj{
    
    NSTextField *tf = (NSTextField *)obj.object;
    
    if (tf.tag == 4) {
        
        [tf setEditable:YES];
    }
    
    if (tf.stringValue.length == [SN_Length.title integerValue]) {
        
        NSTextField *nextTF = [self.view viewWithTag:tf.tag+1];
        
        if (nextTF) {
            
            
            if (nextTF.tag == 4) {
                
                [nextTF setEditable:YES];
                
            }
            [tf resignFirstResponder];
            [nextTF becomeFirstResponder];
            
        }
        if (tf.tag == 4 ) {
            
            [tf setEditable:NO];
            
        }
    }
}






//更新upodateView
-(void)UpdateTextView:(NSString*)strMsg andClear:(BOOL)flagClearContent andTextView:(NSTextView *)textView
{
    if (flagClearContent)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [textView setString:@""];
                       });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           if ([[textView string]length]>0)
                           {
                               NSString * messageString = [NSString stringWithFormat:@"%@: %@\n",[[GetTimeDay shareInstance] getFileTime],strMsg];
                               NSRange range = NSMakeRange([textView.textStorage.string length] , messageString.length);
                               [textView insertText:messageString replacementRange:range];
                               
                           }
                           else
                           {
                                NSString * messageString = [NSString stringWithFormat:@"%@: %@\n",[[GetTimeDay shareInstance] getFileTime],strMsg];
                               [textView setString:[NSString stringWithFormat:@"%@\n",messageString]];
                           }
                           
                               [textView setTextColor:[NSColor redColor]];
                           
                       });
    }
}









-(void)viewWillDisappear
{
    if (action1 != nil) {
        
        [action1 threadEnd];
        action1 = nil;
    }
    if (action2 != nil) {
        
        [action2 threadEnd];
        action2 = nil;
    }
    if (action3 != nil) {
        
        [action3 threadEnd];
        action3 = nil;
    }
    if (action4 != nil) {
        
        [action4 threadEnd];
        action4 = nil;
    }
    
    [serialport Close];
    [humiturePort Close];
    [config_Dic removeAllObjects];
    exit(0);
}

-(void)viewDidDisappear
{
    exit(0);
}

//==================================ADD For SFC============================

- (void)judgeNet
{
    self.manager = [AFNetworkReachabilityManager sharedManager];
    [self.manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: {
                NSLog(@"网络不可用");
                [netState_TF setPlaceholderString:@"网络异常！"];
                [netState_TF setTextColor:[NSColor whiteColor]];
                [netState_TF setBackgroundColor:[NSColor yellowColor]];
                
                isNetOK=NO;
                NSInteger i=0;
                NSString *SFC_CacheStr=[[MK_FileTXT shareInstance] TXT_ReadFromPath:@"/vault/BCM_Caches/Caches_SFC.txt"];
                
                NSArray *webBodyArr=[SFC_CacheStr componentsSeparatedByString:@"==="];
                i = webBodyArr.count;
                underUploadCount=webBodyArr.count;
                if (SFC_CacheStr.length == 0)
                {
                    underUploadCount = 0;
                }
                [underUpload_TF setPlaceholderString:[NSString stringWithFormat:@"%ld",(long)underUploadCount]];
                [underUpload_TF setTextColor:[NSColor redColor]];
                
                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                NSLog(@"网络已连接");
                [netState_TF setPlaceholderString:@"缓存数据上传中..."];
                [netState_TF setBackgroundColor:[NSColor greenColor]];
                dispatch_async(dispatch_get_global_queue(0,0), ^(void){
                    isNetOK=YES;
                    isUpLoadLocalData=YES;
                    [self uploadLocalData];
                    
                });

                
                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                NSLog(@"你现在使用的流量");
                [netState_TF setPlaceholderString:@"缓存数据上传中..."];
                [netState_TF setBackgroundColor:[NSColor yellowColor]];
                
                dispatch_async(dispatch_get_global_queue(0,0), ^(void){
                    isNetOK=YES;

                    [self uploadLocalData];
                    
                });

                break;
            }
                
            case AFNetworkReachabilityStatusUnknown: {
                NSLog(@"你现在使用的未知网络");
                [netState_TF setPlaceholderString:@"缓存数据上传中..."];
                [netState_TF setBackgroundColor:[NSColor yellowColor]];
                
                dispatch_async(dispatch_get_global_queue(0,0), ^(void){
                    isNetOK=YES;
                    
                    [self uploadLocalData];
                    
                });


                break;
            }
                
            default:
                break;
        }
    }];
    [self.manager startMonitoring];
}


-(void)uploadLocalData
{
    isLocalDataUploading=YES;
    NSInteger i=0;
    NSString *SFC_CacheStr=[[MK_FileTXT shareInstance] TXT_ReadFromPath:@"/vault/BCM_Caches/Caches_SFC.txt"];
    
    NSArray *webBodyArr=[SFC_CacheStr componentsSeparatedByString:@"==="];
    i = webBodyArr.count;
    underUploadCount=webBodyArr.count;
    if (SFC_CacheStr.length == 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            underUploadCount = 0;
            [netState_TF setPlaceholderString:@"网络已连接"];
            [netState_TF setTextColor:[NSColor whiteColor]];
            [netState_TF setBackgroundColor:[NSColor greenColor]];
            
        });
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [underUpload_TF setPlaceholderString:[NSString stringWithFormat:@"%ld",(long)underUploadCount]];
        
    });
    while (i > 0 && SFC_CacheStr.length > 0)
    {
        if (isUpLoadLocalData)
        {
            [self upLoadLocalDataWithwebBodyString:webBodyArr[i-1]];
            i--;
        }
        
        if (isBreakUploadLocalData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [netState_TF setPlaceholderString:@"服务器异常！"];
                [netState_TF setTextColor:[NSColor whiteColor]];
                [netState_TF setBackgroundColor:[NSColor yellowColor]];
            });
            break;
        }
        
        if (i == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [netState_TF setPlaceholderString:@"网络已连接"];
                [netState_TF setTextColor:[NSColor whiteColor]];
                [netState_TF setBackgroundColor:[NSColor greenColor]];
                [self removeFolderWithPath:@"/vault/BCM_Caches/Caches_SFC.txt"];
                underUploadCount=0;
            });
            
        }
        [NSThread sleepForTimeInterval:0.2];

    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
            
        isLocalDataUploading=NO;
        [underUpload_TF setPlaceholderString:[NSString stringWithFormat:@"%ld",(long)underUploadCount]];

    });
    
}

-(void)removeFolderWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDeleteSucces=[fileManager removeItemAtPath:path error:nil];
    if (isDeleteSucces)
    {
        NSLog(@"本地缓存数据清除成功！");
    }
    else
    {
        NSLog(@"缓存文件路径不存在！");
    }
}

-(void)upLoadLocalDataWithwebBodyString:(NSString *)webBodyString
{
    NSRange range=[webBodyString rangeOfString:@"FGR"];
    range.length=21;
    sn_Upload=[webBodyString substringWithRange:range];
    if ([sn_Upload containsString:@"<"])
    {
        range.length=17;
        sn_Upload=[webBodyString substringWithRange:range];
    }
    isUpLoadLocalData=NO;
    NSString *webServiceStr = [NSString stringWithFormat:
                               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                               "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                               "<soap:Body>\n"
                               "%@\n"
                               "</soap:Body>\n"
                               "</soap:Envelope>",
                               webBodyString];//webService头
    
    NSString *path = @"http://10.3.6.19:8080/MesWcfF6Upload.svc";
    NSURL *url = [NSURL URLWithString:path];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%ld", webServiceStr.length];
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-type"];
    [theRequest addValue: @"http://tempuri.org/IMesWcfF6Upload/UploadResistanceData" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[webServiceStr dataUsingEncoding:NSUTF8StringEncoding]];
    theRequest.timeoutInterval=10;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                              {
                                  NSString *newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                  [self UpdateTextView:[NSString stringWithFormat:@"Return String===%@",newStr] andClear:NO andTextView:Log_View];
                                  if ([newStr containsString:@"<UploadResistanceDataResult>OK</UploadResistanceDataResult>"])
                                  {
                                      [self saveSFCLogWithString:[NSString stringWithFormat:@"SN %@ 上传成功！",sn_Upload] FileName:@"SFC_LOG"];
                                      [self saveSFCLogWithString:[NSString stringWithFormat:@"SN %@ 上传成功！",sn_Upload] FileName:[NSString stringWithFormat:@"%@SFC_LOG",[[GetTimeDay shareInstance] getCurrentMonth]]];
                                      isUpLoadLocalData=YES;
                                      if (underUploadCount != 0)
                                      {
                                          underUploadCount--;
                                      }
                                      reqTimeOutCount=0;
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [underUpload_TF setPlaceholderString:[NSString stringWithFormat:@"%ld",(long)underUploadCount]];
                                          
                                      });
                                      
                                      isUploadSuccess=YES;
                                      
                                      
                                  }
                                  else
                                  {
                                      [self saveSFCLogWithString:[NSString stringWithFormat:@"SN %@ 上传失败！%@\n",sn_Upload,error] FileName:@"SFC_LOG"];
                                      [self saveSFCLogWithString:[NSString stringWithFormat:@"SN %@ 上传失败！%@\n",sn_Upload,error] FileName:[NSString stringWithFormat:@"%@SFC_LOG",[[GetTimeDay shareInstance] getCurrentMonth]]];
                                      isBreakUploadLocalData=YES;
                                      reqTimeOutCount++;
                                      isUploadSuccess=NO;
                                      
                                  }
                                  
                              }];
    
    [task resume];
    
}

-(void)saveSFCDataWithString:(NSString *)dataString
{
    NSString * SFCCachesPath=@"/vault/BCM_Caches";
    [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:SFCCachesPath];
    
    [[MK_FileTXT shareInstance] createOrFlowTXTFileWithFolderPath:SFCCachesPath FileName:@"Caches_SFC" Content:dataString];
}

-(void)saveSFCLogWithString:(NSString *)SFCLog FileName:(NSString *)fileName
{
    NSString * SFCLogPath=@"/vault/BCM_SFC_LOG";
    [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:SFCLogPath];
    
    [[MK_FileTXT shareInstance] createOrFlowTXTFileWithFolderPath:SFCLogPath FileName:fileName Content:SFCLog];
}


-(void)saveSFCuploadCount:(NSInteger)uploadCount TotalCount:(NSInteger)totalCount ReUploadCount:(NSInteger)reUploadCount IsDay:(BOOL)isDay
{
    NSString * SFCCount=@"/vault/BCM_SFC_Count";
    NSInteger isday;
    if (isDay)
    {
        isday=1;
    }
    else
    {
        isday=0;
    }
    [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:SFCCount];
    [[MK_FileTXT shareInstance] createOrFlowTXTFileWithFolderPath:SFCCount FileName:@"Count_SFC" Content:[NSString stringWithFormat:@"%ld,%ld,%ld,%ld",uploadCount,totalCount,reUploadCount,isday]];
    
}

-(void)confirmReUploadSN
{
    
    NSString *infoLog=[[MK_FileTXT shareInstance] TXT_ReadFromPath:@"/vault/BCM_SFC_LOG/SFC_LOG.txt"];
    if ([infoLog containsString:[NSString stringWithFormat:@"%@ 上传成功",sn_Upload]])
    {
        reUpload++;
        [reUpload_TF setPlaceholderString:[NSString stringWithFormat:@"%ld",(long)reUpload]];
    }
}


-(void)upLoadToSFCWithWebBodyString:(NSString *)webBodyString
{
    NSRange range=[webBodyString rangeOfString:@"FGR"];
    range.length=21;
    sn_Upload=[webBodyString substringWithRange:range];
    if ([sn_Upload containsString:@"<"])
    {
        range.length=17;
        sn_Upload=[webBodyString substringWithRange:range];
        
    }
    NSString *webServiceStr = [NSString stringWithFormat:
                               @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                               "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                               "<soap:Body>\n"
                               "%@\n"
                               "</soap:Body>\n"
                               "</soap:Envelope>",
                               webBodyString];//webService头
    
    NSString *path = @"http://10.3.6.19:8080/MesWcfF6Upload.svc";
    NSURL *url = [NSURL URLWithString:path];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%ld", webServiceStr.length];
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-type"];
    [theRequest addValue: @"http://tempuri.org/IMesWcfF6Upload/UploadResistanceData" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[webServiceStr dataUsingEncoding:NSUTF8StringEncoding]];
    theRequest.timeoutInterval=10;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                              {
                                  
                                  NSString *newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                  [self UpdateTextView:[NSString stringWithFormat:@"Return String===%@",newStr] andClear:NO andTextView:Log_View];
                                  if ([newStr containsString:@"<UploadResistanceDataResult>OK</UploadResistanceDataResult>"])
                                  {
                                      
                                      [self saveSFCLogWithString:[NSString stringWithFormat:@"SN %@ 上传成功！",sn_Upload] FileName:@"SFC_LOG"];
                                      [self saveSFCLogWithString:[NSString stringWithFormat:@"SN %@ 上传成功！",sn_Upload] FileName:[NSString stringWithFormat:@"%@SFC_LOG",[[GetTimeDay shareInstance] getCurrentMonth]]];
                                      isUploadSuccess=YES;
                                      SFCRequestCount=0;
                                      sn_Upload=@"";
                                  }
                                  else
                                  {
                                      [self saveSFCLogWithString:[NSString stringWithFormat:@"SN %@ 上传失败！%@\n",sn_Upload,error] FileName:@"SFC_LOG"];
                                      [self saveSFCLogWithString:[NSString stringWithFormat:@"SN %@ 上传失败！%@\n",sn_Upload,error] FileName:[NSString stringWithFormat:@"%@SFC_LOG",[[GetTimeDay shareInstance] getCurrentMonth]]];
                                      sn_Upload=@"";
                                      SFCRequestCount++;
                                      isUploadSuccess=NO;
                                  }
                                  
                              }];
    
    [task resume];
    
}

-(void)stoping
{
    
    if (isNetOK && isLocalDataUploading)
    {
        [netState_TF setPlaceholderString:@"缓存数据上传中..."];
        [netState_TF setTextColor:[NSColor whiteColor]];
        [netState_TF setBackgroundColor:[NSColor yellowColor]];
        while (1)
        {
            [NSThread sleepForTimeInterval:0.2];
            if (!isLocalDataUploading)
            {
                [netState_TF setPlaceholderString:@"网络已连接..."];
                [netState_TF setTextColor:[NSColor whiteColor]];
                [netState_TF setBackgroundColor:[NSColor greenColor]];
                break;
            }
        }
    }
    
}






- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
