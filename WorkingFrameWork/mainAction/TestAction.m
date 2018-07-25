//
//  TestAction.m
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import "TestAction.h"



#define SNChangeNotice  @"SNChangeNotice"
#define ReturnWebBodyStringNotice  @"ReturnWebBodyStrNotice"

NSString  *param_path=@"Param";

@interface TestAction ()
{

    
    //For SFC
    NSMutableString * jsonStrM;
    
    //************ testItems ************
    double num;
    NSString        *agilentReadString;
    NSDictionary    *dic;
    NSString        *SonTestDevice;
    NSString        *SonTestName;
    NSString        *testResultStr;                           //测试结果
    NSMutableArray  *testResultArr;                           // 返回的结果数组

    
    NSThread        * thread;                                   //开启的线程
    AgilentE4980A   * agilentE4980A;                            //LCR表
    AgilentB2987A   * agilentB2987A;                            //静电计
    SerialPort      * serialport;                               //串口通讯类
    UpdateItem      * updateItem;                               //
    Plist           * plist;                                    //plist文件处理类
    enum AgilentB2987ACommunicateType  AgilentB2987A_USB_Type;
    Param           * param;                                    // param参数类
    
    
    
    int        delayTime;
    int        index;                                         // 测试流程下标
    int        item_index;                                    // 测试项下标
    int        row_index;                                     // table 每一行下标
    Item     * testItem;                                      //测试项
    Item     * showItem;                                      //显示的测试项
    
    
    NSString * fixtureBackString;                             //治具返回来的数据
    NSString * testvalue;                                   //测试项的字符串
   
    
    AppDelegate  * app;                                       //存储测试的次数
    Folder       * fold;                                      //文件夹的类
    FileCSV      * csv_file;                                  //csv文件的类
    FileCSV      * total_file;                                //写csv总文件
    FileTXT      * txt_file;                                  //txt文件
    
    //************* timer *************
    NSString            * start_time;                         //启动测试的时间
    NSString            * end_time;                           //结束测试的时间
    GetTimeDay          * timeDay;                            //创建日期类
    
    //csv数据相关处理
    NSMutableArray * ItemArr;                                 //存测试对象的数组
    NSMutableArray * TestValueArr;                            //存储测试结果的数组
    NSMutableString     * txtContentString;                   //打印txt文件中的log
    
    //检测PDCA和SFC的BOOL//测试结果PASS、FAIL
    BOOL      isPDCA;
    BOOL      isSFC;
    PDCA    *  pdca;
    BOOL       PF;
    
    //存储生成文件的具体地址
    NSString   * eachCsvDir;
    int          fix_type;
    
    //所有的测试项均存入字典中
    NSMutableDictionary  * store_Dic;                          //所有的测试项存入字典中

    BOOL    nulltest;                                          //产品进行空测试
    float   nullTimes;                                         //空测试的次数
    double  B_E_Sum;                                           //产品测试nullTimes的总和
    double  B2_E2_Sum;                                         //产品测试B2_E2
    double  B4_E4_Sum;                                         //产品测试B4_E4
    double  ABC_DEF_Sum;                                       //产品测试ABC_DEF
    double  Cap_Sum;                                           //治具的容抗值
    
    //处理SFC相关的类
    BYDSFCManager          * sfcManager;                         //处理sfc的类
    NSString               * FixtureID;                         //治具的ID
    
    NSString               * humitString;
    NSString               * temp_Str;
    NSString               * humid_Str;
    NSString               * itemResult;

    BOOL                     isAgilentConnect;
    BOOL                     isAlreadyStart;
    
    NSString *SFC_ItemNO;
    NSString *SFC_Version;
    NSString *SFC_MechineNO;
    NSString *SFC_ModelNO;
    NSString *SFC_SN;
    NSString *SFC_TestResult;
    NSString *SFC_startTime;
    NSString *SFC_endTime;
    NSString *jsonStr;

    
}
@end

@implementation TestAction

/**相关的说明
  1.Fixture ID 返回的值    Fixture ID?\r\nEW011X*_*\r\n       其中x代表治具中A,B,C,D

 
 
*/





-(id)initWithTable:(Table *)tab withFixDic:(NSDictionary *)fix withFileDir:foldDir withType:(int)type_num
{
    if (self =[super init]) {
        
        agilentReadString=[[NSString alloc]init];

        jsonStr=[NSString stringWithFormat:@""];
        self.tab =tab;
        fix_type = type_num;
        
        index = 0;
        item_index   = 0;
        row_index    = 0;
        nullTimes    = 0;
        B_E_Sum      = 0;
        B2_E2_Sum    = 0;
        B4_E4_Sum    = 0;
        ABC_DEF_Sum  = 0;
        Cap_Sum      = 0;
        nulltest     = NO;
        isAgilentConnect=NO;
        isAlreadyStart=NO;
        
        PF = YES;
        
        //初始化各类数组和可变字符串
        ItemArr =      [[NSMutableArray alloc]initWithCapacity:10];
        TestValueArr = [[NSMutableArray alloc] initWithCapacity:10];
        txtContentString=[[NSMutableString alloc]init];
        store_Dic = [[NSMutableDictionary alloc] initWithCapacity:10];
        testResultArr=[[NSMutableArray alloc] init];
        jsonStrM = [[NSMutableString alloc]init];
        
        param = [[Param alloc]init];
        [param ParamRead:param_path];
        plist = [Plist shareInstance];
        
        //初始化各种串口
        timeDay     =  [GetTimeDay shareInstance];
        pdca        =  [[PDCA alloc]init];
        sfcManager  =  [BYDSFCManager Instance];
        serialport  =  [[SerialPort alloc]init];
        updateItem  =  [[UpdateItem alloc] init];
        [serialport setTimeout:1 WriteTimeout:1];
        
        agilentB2987A=[[AgilentB2987A alloc]init];
        agilentE4980A=[[AgilentE4980A alloc]init];
        
        //初始化文件的类
        csv_file  = [[FileCSV alloc] init];
        [csv_file addGlobalLock];
        txt_file  = [[FileTXT  alloc]init];
        total_file= [[FileCSV alloc] init];
        [total_file addGlobalLock];
        fold     =  [[Folder  alloc] init];
        
        
        //初始化各种数据及其设备消息
        self.fixture_uart_port_name = [fix objectForKey:@"fixture_uart_port_name"];
        self.fixture_uart_port_name_e = [fix objectForKey:@"fixture_uart_port_name_e"];

        self.fixture_uart_baud      = [fix objectForKey:@"fixture_uart_baud"];
        self.instr_2987             = [fix objectForKey:@"b2987_adress"];
        self.instr_4980             = [fix objectForKey:@"e4980_adress"];
        
        
        //从param.plist文件中获取相关的值
        updateItem.fix_ABC_DEF_Res  = [fix objectForKey:@"fix_ABC_DEF_Res"];
        updateItem.fix_B2_E2_Res    = [fix objectForKey:@"fix_B2_E2_Res"];
        updateItem.fix_B4_E4_Res    = [fix objectForKey:@"fix_B4_E4_Res"];
        updateItem.fix_B_E_Res      = [fix objectForKey:@"fix_B_E_Res"];
        updateItem.fix_Cap          = [fix objectForKey:@"fix_Cap"];
        
        
        
        //通知PDCA和SFC值
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCAandSCFNoti:) name:@"NoticePDCASTATE" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPDCAandSCFNoti:) name:@"NoticeSFCSTATE" object:nil];
        
        //监听空测试
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectNTNoti:) name:@"NTNotification" object:nil];
        
        //写入空测的值
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeNullValueToPlist:) name:@"WriteNullValue" object:nil];
        
        //检测开启软件测试的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NSThreadStart_Notification:) name:@"NSThreadStart_Notification" object:nil];
        
        

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCurrentThread:) name:@"cancelCurrentThread" object:nil];
        
        //获取全局变量
        app = [NSApplication sharedApplication].delegate;
        thread = [[NSThread alloc]initWithTarget:self selector:@selector(TestAction) object:nil];
        [thread start];
    }
    
    return self;
}




-(void)TestAction
{
    NSInteger count=0;
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
        
#pragma mark--------index=0 连接治具
        if (index == 0) {
            
            [NSThread sleepForTimeInterval:0.2];
            
            if (param.isDebug)
            {
                [txtContentString appendFormat:@"%@:index=0,进入debug模式\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=0,进入debug模式" andClear:YES andTextView:self.Log_View];
                 index =1;
                
                switch (fix_type)
                {
                    case 1:
                        FixtureID=@"EW001-A";
                        break;
                    case 2:
                        FixtureID=@"EW001-B";
                        break;
                    case 3:
                        FixtureID=@"EW001-C";
                        break;
                    case 4:
                        FixtureID=@"EW001-D";
                        break;

                    default:
                        break;
                }
                SFC_MechineNO=FixtureID;

            }
            else
            {
                
                BOOL isCollect = [serialport Open:self.fixture_uart_port_name];
                if (!isCollect)
                {
                    isCollect = [serialport Open:self.fixture_uart_port_name_e];
                    self.fixture_uart_port_name=self.fixture_uart_port_name_e;
                }
                if (isCollect)
                {
                     //发送指令获取ID的值
                    [NSThread sleepForTimeInterval:0.5];
                    [serialport WriteLine:@"Fixture ID?"];
                    [NSThread sleepForTimeInterval:0.8];
                     NSString *backStr = [serialport ReadExisting];
                    if ([backStr containsString:@"*_*"])
                    {
                        FixtureID = [backStr componentsSeparatedByString:@"*_*"][0];
                        SFC_MechineNO=FixtureID;
                    }
                    
                    [txtContentString appendFormat:@"%@:index=0,治具已经连接\n",[timeDay getFileTime]];
                    [self UpdateTextView:@"index=0,治具已经连接" andClear:NO andTextView:self.Log_View];
                    
                    index =1;
                }
            }
            
           
        }
        
#pragma mark--------index=1 连接LCR表4980 和 静电仪器2987A
        if (index == 1) {
            
            [NSThread sleepForTimeInterval:0.2];
            if (param.isDebug) {
                
                [txtContentString appendFormat:@"%@:index=1,debug模式中\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=1,进入debug模式\n" andClear:NO andTextView:self.Log_View];
                index =1000;
            }
            else
            {
                BOOL is_LRC_Collect = [agilentE4980A Find:self.instr_4980 andCommunicateType:AgilentE4980A_Communicate_DEFAULT]&&[agilentE4980A OpenDevice:nil andCommunicateType:AgilentE4980A_USB_Type];
                if (!is_LRC_Collect)
                {
                    [self UpdateTextView:@"index=1,LCR-4980 Not Connected" andClear:NO andTextView:self.Log_View];
                }
                else
                {
                     [self UpdateTextView:@"index=1,LCR-E4980 已连接！" andClear:NO andTextView:self.Log_View];
                }
                
                
               
                BOOL is_JDY_Collect = [agilentB2987A Find:self.instr_2987 andCommunicateType:AgilentB2987A_CommunicateType_DEFAULT]&&[agilentB2987A OpenDevice:self.instr_2987 andCommunicateType:AgilentB2987A_CommunicateType_DEFAULT];
                if (!is_JDY_Collect)
                {
                    [self UpdateTextView:@"index=1,静电仪B2987 连接失败！\n" andClear:NO andTextView:self.Log_View];
                }
                else
                {
                    [self UpdateTextView:@"index=1,静电仪B2987 已连接！\n" andClear:NO andTextView:self.Log_View];
                    
                }
                
                if (is_LRC_Collect && is_JDY_Collect)
                {
                     [txtContentString appendFormat:@"%@:index=1,测试仪器已连接\n",[timeDay getFileTime]];
                     [self UpdateTextView:@"index=1,测试仪器已连接" andClear:NO andTextView:self.Log_View];
                    isAgilentConnect=YES;
                    index=1000;
                    
                    if (isAlreadyStart)
                    {
                        index=2;
                    }
                }
            }
        }
#pragma mark--------index=2 获取输入框中的SN
        if (index == 2) {
            //通过通知抛过来SN，以及气缸的状态
            [NSThread sleepForTimeInterval:0.1];
            isAlreadyStart=YES;
            if (isAgilentConnect || param.isDebug)
            {
                if (_dut_sn.length == 17||_dut_sn.length==21)
                {

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.resultTF setStringValue:@"--"];
                        [self.resultTF setTextColor:[NSColor greenColor]];
                    });

                    if (count > 0)
                    {
                        [self UpdateTextView:nil andClear:YES andTextView:self.Log_View];
                        [self UpdateTextView:nil andClear:YES andTextView:self.Fail_View];
                    };
                    
                    
                    //启动测试的时间,csv里面用
                    start_time = [[GetTimeDay shareInstance] getFileTime];
                    SFC_startTime=[[GetTimeDay shareInstance] getSFCTime];
                    [txtContentString appendFormat:@"%@:index=2,SN已经检验成功\n",[timeDay getFileTime]];
                    [self UpdateTextView:@"index=2,SN已经检验成功" andClear:NO andTextView:self.Log_View];
                    count = 1;
                    SFC_SN=_dut_sn;
                    index =3;
                    isAlreadyStart=NO;
                }
            }
            else
            {
                [self UpdateTextView:@"index=2,安捷伦仪器已连接Fail" andClear:NO andTextView:self.Log_View];
                index=1;
            }
        }
        
#pragma mark--------index=3 检测SN是否上传
        if (index == 3) {
            
            [NSThread sleepForTimeInterval:0.1];
            if (param.isDebug)
            {
                [txtContentString appendFormat:@"%@:index=3,debug模式\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=3,进入debug模式,检测SN上传" andClear:NO andTextView:self.Log_View];
                index = 4;
            }
            else
            {
                index = 4;
                [txtContentString appendFormat:@"%@:index=3,SN检验成功\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=3,SN检验成功" andClear:NO andTextView:self.Log_View];
            }
            
        }
        
        
#pragma mark--------index=4 进入正常测试中
        if (index == 4) {
            
            [NSThread sleepForTimeInterval:0.1];
            [txtContentString appendFormat:@"%@:index=4,正式进入测试\n",[timeDay getFileTime]];
            
            testItem = [[Item alloc]initWithItem:self.tab.testArray[item_index]];
            
            BOOL isPass =[self TestItem:testItem];
            
            if (isPass)
            {//测试成功
                itemResult = @"PASS";
                [self UpdateTextView:[NSString stringWithFormat:@"index=4:%@ 测试OK",testItem.testName] andClear:NO andTextView:self.Log_View];
                
            }
            else//测试结果失败
            {
                 itemResult = @"FAIL";
                 [self UpdateTextView:[NSString stringWithFormat:@"index=4:%@ 测试NG",testItem.testName] andClear:NO andTextView:self.Log_View];
                 [self UpdateTextView:[NSString stringWithFormat:@"FailItem:%@\n",testItem.testName] andClear:NO andTextView:self.Fail_View];
            }
    
            [testResultArr addObject:itemResult];

            //刷新界面
            [txtContentString appendFormat:@"%@:index=4,准备刷新界面\n",[timeDay getFileTime]];
            [self.tab flushTableRow:testItem RowIndex:row_index with:fix_type];
            [txtContentString appendFormat:@"%@:index=4,刷新界面成功\n",[timeDay getFileTime]];

            
            item_index++;
            row_index++;
            //走完测试流程,进入下一步
            if (item_index == [self.tab.testArray count])
            {
                //给设备复位
                [txtContentString appendFormat:@"%@:index=4,测试项测试结束\n",[timeDay getFileTime]];
                [self UpdateTextView:@"index=4,测试项测试结束" andClear:NO andTextView:self.Log_View];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //遍历测试结果,输出总测试结果
                    for (int i = 0; i< testResultArr.count; i++)
                    {
                        if ([testResultArr[i] containsString:@"FAIL"])
                        {
                            PF=NO;
                            SFC_TestResult=@"NG";
                            break;
                        }
                        else
                        {
                            PF=YES;
                            SFC_TestResult=@"OK";

                        }
                    }
                    

                });

                index = 5;
            }
            
        }
        
#pragma mark--------index=5 生成本地数据
        if (index == 5)
        {

            [agilentB2987A CloseDevice];
            [agilentE4980A CloseDevice];
           
           //测试结束的时间,csv里面用
            end_time = [[GetTimeDay shareInstance] getFileTime];
            SFC_endTime=[[GetTimeDay shareInstance] getSFCTime];
            SFC_ItemNO=_Product_config;
            SFC_ModelNO=[self.Config_Dic objectForKey:kProductNestID];
                //===============================
                [NSThread sleepForTimeInterval:0.1];
                /********生成总文件************/
            

            NSString   * totalCSV = [self backTotalFilePath];
            NSString   *csv_config=[NSString stringWithFormat:@"%@/%@_%@.csv",_foldDir,[[GetTimeDay shareInstance] getCurrentDay],_Product_config];
            NSString   *csv_day=[NSString stringWithFormat:@"%@/%@.csv",_foldDir2,[[GetTimeDay shareInstance] getCurrentDay]];


                if (total_file!=nil)
                {
                    
                    [total_file CSV_Open:totalCSV];
                    [txtContentString appendFormat:@"%@:index=5,打开总csv文件->%@\n",[timeDay getFileTime],totalCSV];
                    [self SaveCSV:total_file withBool:NO];
                    [txtContentString appendFormat:@"%@:index=5,添加数据到totalCSV文件->%@\n",[timeDay getFileTime],totalCSV];
                    [self UpdateTextView:@"index=5,往总文件中添加数据" andClear:NO andTextView:self.Log_View];
                    
                    /*****=======================**************/
                    [total_file CSV_Open:csv_config];
                    
                    [self SaveCSV:total_file withBool:NO];
                    
                    /*****=======================**************/
                    
                    /*****=======================**************/
                    [total_file CSV_Open:csv_day];
                    
                    [self SaveCSV:total_file withBool:NO];
                    
                    /*****=======================**************/
                    
                }
            
            @synchronized (self)
            {
                //生成单个产品的value值csv文件
                [NSThread sleepForTimeInterval:0.1];
                eachCsvDir = [NSString stringWithFormat:@"%@/%@",self.foldDir,self.dut_sn];
                [fold Folder_Creat:eachCsvDir];
                NSString * eachCsvFile = [NSString stringWithFormat:@"%@/%@.csv",eachCsvDir,self.dut_sn];
                if (csv_file!=nil)
                {
                    BOOL need_title = [csv_file CSV_Open:eachCsvFile];
                    [self SaveCSV:csv_file withBool:!need_title];
                    [txtContentString appendFormat:@"%@:index=5,生成单个csv文件%@\n",[timeDay getFileTime],eachCsvFile];
                    [self UpdateTextView:@"index=5,生成单个CSV文件" andClear:NO andTextView:self.Log_View];
                }
                
                
            }
            
            
            //生成log文件
            NSString * logFile = [NSString stringWithFormat:@"%@/log.txt",eachCsvDir];
            if (txt_file!=nil)
            {
                
                [txt_file TXT_Open:logFile];
                [txt_file TXT_Write:txtContentString];
            }
            
            
           //===============================
            [NSThread sleepForTimeInterval:0.2];
            [self UpdateTextView:@"index=5,本地数据生成完成" andClear:NO andTextView:self.Log_View];
            index = 6;
        }
        
#pragma mark--------index=6 上传PDCA和SFC
        if (index == 6)
        {
            //PDCA测试结束
            [pdca PDCA_GetEndTime];
            
            
            //上传PDCA和SFC
            [NSThread sleepForTimeInterval:0.2];
            [txtContentString appendFormat:@"%@:index=6,准备上传PDCA\n",[timeDay getFileTime]];
            [self UpdateTextView:@"index=6,准备上传PDCA" andClear:NO andTextView:self.Log_View];
           if (isPDCA)
           {
              [self UploadPDCA];
            }
            
            [txtContentString appendFormat:@"%@:index=6,准备上传SFC\n",[timeDay getFileTime]];
            [self UpdateTextView:@"index=6,准备上传SFC" andClear:NO andTextView:self.Log_View];
            
            //For SFC
            NSString *str=[[NSString alloc]initWithString:jsonStrM];
            [[NSNotificationCenter defaultCenter] postNotificationName:ReturnWebBodyStringNotice object:[self getWebBodyStringWithJsonString:str]];
            index = 7;
        }
        
#pragma mark--------index=7
        //将结果显示在界面上
        if (index == 7)
        {

            //清空字符串
            [txtContentString setString:@""];
            [testResultArr removeAllObjects];
            [ItemArr removeAllObjects];
            [TestValueArr removeAllObjects];
            [store_Dic removeAllObjects];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.resultTF setStringValue:PF?@"PASS":@"FAIL"];
               if (PF)
               {
                    [self.resultTF setTextColor:[NSColor greenColor]];
    
                   [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dP",fix_type]];
               }
               else
               {
                
                    [self.resultTF setTextColor:[NSColor redColor]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SNChangeNotice object:[NSString stringWithFormat:@"%dF",fix_type]];
                    
               }
                
            });
            
            index = 8;
        }
        
#pragma mark--------index=8
        //刷新结果，重新等待SN
        if (index == 8)
        {
            [NSThread sleepForTimeInterval:0.2];
            
            //发送复位的指令
            [serialport WriteLine:@"reset"];
            
            
            [NSThread sleepForTimeInterval:0.3];
            
           
            //清空SN
             _dut_sn=@"";
            if (nulltest)
            {
                nullTimes++;
            }
           
            index = 1;
            isAlreadyStart=NO;
            item_index =0;
            row_index = 0;
        }
     
        if (index == 1000)
        {
            [NSThread sleepForTimeInterval:1];
        }
        

    }
}


//================================================
//测试项指令解析
//================================================
-(BOOL)TestItem:(Item*)testitem
{
    BOOL ispass=NO;
    NSDictionary  * dict;
    NSString      * subTestDevice;
    NSString      * subTestName;
    double          DelayTime;
    NSString      * startTime;
    NSString      * endTime;
    NSString        *SonTestCommand;

    startTime = [timeDay getCurrentSecond];
    
    for (int i=0; i<[testitem.testAllCommand count]; i++)
    {
        dict =[testitem.testAllCommand objectAtIndex:i];
        subTestDevice = dict[@"TestDevice"];
        SonTestCommand=dict[@"TestCommand"];
        subTestName=dict[@"TestName"];
        DelayTime = [dict[@"TestDelayTime"] floatValue]/1000.0;
    
        //治具中收发指令
        if ([subTestDevice isEqualToString:@"Fixture"])
        {
          [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestName] andClear:NO andTextView:self.Log_View];
            
           int indexTime = 0;
            while (YES)
            {
                
                [txtContentString appendFormat:@"%@:index=4,%@治具发送指令->%@\n",[timeDay getFileTime],self.fixture_uart_port_name,subTestName];
                
                
                 [serialport WriteLine:SonTestCommand];
                

                 [NSThread sleepForTimeInterval:0.5];
                 fixtureBackString = [serialport ReadExisting];
                
                 [self UpdateTextView:[NSString stringWithFormat:@"fixtureBackString:%@",fixtureBackString] andClear:NO andTextView:self.Log_View];
                
                 [txtContentString appendFormat:@"%@:index=4,%@治具接收返回值->%@\n",[timeDay getFileTime],self.fixture_uart_port_name,fixtureBackString];
                
                if ([fixtureBackString containsString:@"OK"]&&[fixtureBackString containsString:@"*_*"])
                {
                    break;
                }
                if (indexTime>=3 && !param.isDebug)
                {
                    
                    break;
                }
                
                indexTime++;
                break;//
                
            }
        }
        //LCR表
        else if ([subTestDevice isEqualToString:@"LCR"])
        {
            
             [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestName] andClear:NO andTextView:self.Log_View];
            
            if ([SonTestCommand isEqualToString:@"RES"])
            {

                [agilentE4980A SetMessureMode:AgilentE4980A_RX andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                

            }
            else if([SonTestCommand isEqualToString:@"CPD"])
            {
                [agilentE4980A SetMessureMode:AgilentE4980A_CPD andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                
            }
            else if ([SonTestCommand isEqualToString:@"CPQ"])
            {
                [agilentE4980A SetMessureMode:AgilentE4980A_CPQ andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];

            }
            else if ([SonTestCommand isEqualToString:@"CSD"])
            {
                [agilentE4980A SetMessureMode:AgilentE4980A_CSD andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
            }
            else if ([SonTestCommand containsString:@"CSQ"])
            {
                
                [agilentE4980A SetMessureMode:AgilentE4980A_CPQ andCommunicateType:AgilentE4980A_USB_Type];
                [agilentE4980A setFrequency:testItem.freq];
                
            }
            else if ([SonTestCommand containsString:@"Read"])
            {
                if (!param.isDebug)
                {
                    [agilentE4980A WriteLine:@":FETC?" andCommunicateType:AgilentE4980A_USB_Type];
                    [NSThread sleepForTimeInterval:0.6];
                    agilentReadString=[agilentE4980A ReadData:16 andCommunicateType:AgilentE4980A_USB_Type];

                }
                
                NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                num = [arrResult[0] floatValue];
            }
            else
            {
                NSLog(@"Other situation");
            
            }
            
        }
        //静电仪
        else if ([subTestDevice isEqualToString:@"DMM"])
        {
            
             [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestName] andClear:NO andTextView:self.Log_View];
            
            if ([SonTestCommand containsString:@"RES"])
            {
               [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_CommunicateType_DEFAULT];
                
            }
            else if([SonTestCommand containsString:@"Read"])
            {
                
                if (!param.isDebug)
                {
                    [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_CommunicateType_DEFAULT];
                    
                    
                    [NSThread sleepForTimeInterval:0.6];
                    
                    agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_CommunicateType_DEFAULT];
                }
                    
                    NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                    num = [arrResult[0] floatValue];
                
            }
            else
            {
                NSLog(@"Other situation");
            }
        }
        
        else if ([subTestDevice isEqualToString:@"TempHimu"])
        {
            humitString=_tem_humit;
            if ([humitString containsString:@","]&&[humitString containsString:@"%"])
            {
                NSArray  * array =[humitString componentsSeparatedByString:@","];
                
                temp_Str   = [array objectAtIndex:0];
                
                humid_Str  = [[array objectAtIndex:1] stringByReplacingOccurrencesOfString:@"%" withString:@""];
                
                if ([humid_Str containsString:@"\n"])
                {
                    NSArray *tmp;
                    tmp=[humid_Str componentsSeparatedByString:@"\n"];
                    humid_Str=[tmp objectAtIndex:0];
                }
                
            }
            else
            {
                temp_Str  = @"0.0";
                
                humid_Str = @"0.0";
            }
        }
        
        //延迟时间
        else if ([subTestDevice isEqualToString:@"SW"])
        {
            [self UpdateTextView:[NSString stringWithFormat:@"subTestDevice%@====subTestCommand:%@",subTestDevice,subTestName] andClear:NO andTextView:self.Log_View];
            
            if (!param.isDebug)
            {
                [NSThread sleepForTimeInterval:DelayTime];
                [txtContentString appendFormat:@"%@:index=4,%@软件延时处理\n",[timeDay getFileTime],subTestDevice];
            }

        }
        else
        {
            NSLog(@"其它的情形");
        }
        
    }
    
    
#pragma mark--------对数据进行处理
    if ([testitem.units containsString:@"GOhm"]) {//GOhm
        if (![testitem.testName containsString:@"B2987_CHECK"])
        {
            
            if (!nulltest)
            {
                if ([testitem.testName isEqualToString:@"B_E_DCR"]||[testitem.testName isEqualToString:@"B2_E2_DCR"]||[testitem.testName isEqualToString:@"B4_E4_DCR"]||[testitem.testName isEqualToString:@"ABC_DEF_DCR"]) {
                    
                     testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
                    [self storeValueToDic_with_name:testitem.testName];
                }
            }
            else//空测试的情况
            {
                double Rfixture   =fabs(num) * 1E-9;
                [self add_RFixture_Value_To_Sum_Testname:testitem.testName RFixture:Rfixture];
                
            }

            
        }
        else
        {
              testvalue = [NSString stringWithFormat:@"%.3f",num*1E-9];
        }
        
    }
    else if ([testitem.units containsString:@"MOhm"])//MOhm
    {
        if (!nulltest)
        {
            
            if ([testitem.testName isEqualToString:@"B2_E2_ACR_1000"]||[testitem.testName isEqualToString:@"B4_E4_ACR_1000"])
            {
                
                testvalue=[NSString stringWithFormat:@"%.3f",1E-6/(num*2*3.14159*testitem.freq.integerValue)];
                [self storeValueToDic_With_Item:testitem];       //存储其它测试项的值
            }
        }
        else //空测试情况
        {
            
            double Cdut,Cfix,Rdut;
            NSString *smallCap=@"<1fF";
            NSString *largeACR=@">100GOhm";
            Cdut=0.0;
            Rdut=9999.00;
            Cfix=num*1E+12;
            if (fabs(Cfix) > 10000)
            {
                exit(0);
            }
            testvalue=[NSString stringWithFormat:@"%.3f",1E-6/(num*2*3.14159*testitem.freq.integerValue)];
            
            if ([testitem.testName isEqualToString:@"B2_E2_ACR_1000"])
            {
                
                if (Cdut <= 0)
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:@"B2_E2_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:@"B2_E2_ACR_1000_Rdut"];
                }
                else
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:@"B2_E2_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B2_E2_ACR_1000_Rdut"];
                }
                
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:@"B2_E2_ACR_1000_Cfix"];
            }
            
            if ([testitem.testName isEqualToString:@"B4_E4_ACR_1000"])
            {
                Cap_Sum+=Cfix;
                
                if (Cdut <= 0)
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:@"B4_E4_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:@"B4_E4_ACR_1000_Rdut"];
                }
                else
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:@"B4_E4_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B4_E4_ACR_1000_Rdut"];
                }
                
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:@"B4_E4_ACR_1000_Cfix"];
            }
            
        }
        
        
    }
    else if ([testitem.units containsString:@"Ohm"])//Ohm
    {
        testvalue = [NSString stringWithFormat:@"%.2f",num];
        if (fabs(testvalue.floatValue) > 1000000)
        {
            testvalue=@">1MOhm";
        }
        if (param.isDebug)
        {
            double i=arc4random()%10+100.000000;
            testvalue=[NSString stringWithFormat:@"%.2f",i];
        }
    }
    else if ([testitem.testName isEqualToString:@"TEMP"])
    {
        testvalue = temp_Str;
    }
    
    else if ([testitem.testName isEqualToString:@"HUMID"])
    {
        testvalue = humid_Str;
    }
    
    else
    {
    
    }
    

#pragma mark--------对测试项进行赋值
    if ([testitem.testName containsString:@"_Vmeas"] || [testitem.testName containsString:@"_Rref"] || [testitem.testName containsString:@"_Cfix"] || [testitem.testName containsString:@"_Vs"] || [testitem.testName containsString:@"_Cref"] || [testitem.testName containsString:@"_Rdut"] || [testitem.testName containsString:@"_Cdut"] || [testitem.testName containsString:@"_Rfix"])
    {
        testvalue=[NSString stringWithFormat:@"%@",store_Dic[[NSString stringWithFormat:@"%@",testitem.testName]]];
        
    }
    
    
   
    
//判断值得大小
#pragma mark--------对测试出来的结果进行判断和赋值
    //上下限值对比
    if (([testvalue floatValue]>=[testitem.min floatValue]&&[testvalue floatValue]<=[testitem.max floatValue]) || ([testitem.max isEqualToString:@"--"]&&[testvalue floatValue]>=[testitem.min floatValue]) || ([testitem.max isEqualToString:@"--"] && [testitem.min isEqualToString:@"--"]) || ([testitem.min isEqualToString:@"--"]&&[testvalue floatValue]<=[testitem.max floatValue]) || [testvalue isEqualToString:@">1TOhm"] || [testvalue isEqualToString:@">100GOhm"] || [testvalue isEqualToString:@"<1fF"])
    {
        if (fix_type == 1) {
            testitem.value1 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result1 = @"PASS";
        }
        else if (fix_type == 2)
        {
            testitem.value2 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result2 = @"PASS";
        }
        else if (fix_type == 3)
        {
            testitem.value3 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result3 = @"PASS";
        }
        else if (fix_type == 4)
        {
            testitem.value4 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result4 = @"PASS";
        }
        
        testitem.messageError=nil;
        ispass = YES;
    }
    else
    {
        if (fix_type == 1) {
            testitem.value1 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result1 = @"FAIL";
        }
        else if (fix_type == 2)
        {
            testitem.value2 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result2 = @"FAIL";
        }
        else if (fix_type == 3)
        {
            testitem.value3 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result3 = @"FAIL";
        }
        else if (fix_type == 4)
        {
            testitem.value4 = [testvalue isEqualToString:@""]?@"123":testvalue;
            testitem.result4 = @"FAIL";
        }
        testitem.messageError=[NSString stringWithFormat:@"%@ Fail",testitem.testName];
        ispass = NO;
        PF = NO;
    }
    
    NSString *resultT;
    NSString *dicStr;
    if (ispass)
    {
        resultT=@"OK";
    }
    else
    {
        resultT=@"NG";
    }
    if ([testvalue containsString:@"<1fF"])
    {
        dicStr=[NSString stringWithFormat:@"{\"SEQNO\":%d,\"TESTNAME\":\"%@\",\"TESTVALUE\":\"0.001\",\"TestResult\":%@}",item_index+1,testitem.testName,resultT];
        
    }
    else
    {        dicStr=[NSString stringWithFormat:@"{\"SEQNO\":%d,\"TESTNAME\":\"%@\",\"TESTVALUE\":\"%@\",\"TestResult\":%@}",item_index+1,testitem.testName,testvalue,resultT];
        
        
    }
    if (item_index==0)
    {
        [jsonStrM appendString:[NSString stringWithFormat:@"%@",dicStr]];
    }
    else
    {
        [jsonStrM appendString:[NSString stringWithFormat:@",%@",dicStr]];
    }
    
    //对时间进行赋值
    endTime = [timeDay getCurrentSecond];
    testitem.startTime = startTime;
    testitem.endTime   = endTime;
    
    
    
    
    //处理相关的测试项
    [TestValueArr addObject:testvalue];
    [ItemArr addObject:testitem];      //将测试项加入数组中
        
    return ispass;
}


//================================================
//保存csv
//================================================
-(void)SaveCSV:(FileCSV *)csvFile withBool:(BOOL)need_title
{
    NSString *line   =  @"";
    NSString * result=  @"";
    NSString * value =  @"";
    
    
    
    for(int i=0;i<[ItemArr count];i++)
    {
        Item *testitem=ItemArr[i];
        
        if (fix_type == 1) {result = testitem.result1,value =testitem.value1;}
        if (fix_type == 2) {result = testitem.result1,value =testitem.value2;}
        if (fix_type == 3) {result = testitem.result1,value =testitem.value3;}
        if (fix_type == 4) {result = testitem.result1,value =testitem.value4;}
        
        if(testitem.isTest)  //需要测试的才需要上传
        {
            if((testitem.isShow == YES)&&(testitem.isTest))    //需要显示并且需要测试的才保存
            {
                
                if (i == [ItemArr count] - 1)
                {
                    line=[line stringByAppendingString:[NSString stringWithFormat:@"%@\n",value]];

                }
                else
                {
                    line=[line stringByAppendingString:[NSString stringWithFormat:@"%@,",value]];
                }
            }
        }
    }
    
    
    NSString *test_result;
    if (PF)
    {
        test_result = @"PASS";
    }
    else
    {
        test_result = @"FAIL";
    }
    //line字符串前面增加SN和测试结果
    NSString *  contentString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",start_time,end_time,[self.Config_Dic objectForKey:kSoftwareVersion],[self.Config_Dic objectForKey:kProductNestID],[self.Config_Dic objectForKey:kProduct_type],[self.Config_Dic objectForKey:kConfig_pro],self.dut_sn,test_result,FixtureID,line];
    

   if(need_title == YES)[csvFile CSV_Write:self.csvTitle];
    
    [csvFile CSV_Write:contentString];
    
    
    
}


//================================================
//保存csv
//================================================
-(void)SaveTimeCSV
{
    NSString * line   = @"";
    NSString * result = @"";
    NSString * value  = @"";
    
    for(int i=0;i<[ItemArr count];i++)
    {
        Item *testitem=ItemArr[i];
        
        float time = ([testitem.endTime floatValue]-[testitem.startTime floatValue])/1000.0;
        
        if (fix_type == 1) {result = testitem.result1,value   =testitem.value1;}
        if (fix_type == 2) {result = testitem.result1,value   =testitem.value2;}
        if (fix_type == 3) {result = testitem.result1,value =testitem.value3;}
        if (fix_type == 4) {result = testitem.result1,value  =testitem.value4;}
        
        line=[line stringByAppendingString:[NSString stringWithFormat:@"\n%@,%@,%@,%@,%@,%f\n",testitem.testName,result,testitem.min,value,testitem.max,time]];
        
        
    }
    
    NSString  * contentString = [NSString stringWithFormat:@"%@,%@,SN:%@\nTestName,Pass/Fail,Min Limit,Value,Max,Single Time,%@",self.sw_name,self.sw_ver,self.dut_sn,line];
    
    [csv_file CSV_Write:contentString];
    
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

-(void)setCsvTitle:(NSString *)csvTitle
{
    _csvTitle = csvTitle;
}

-(void)setDut_sn:(NSString *)dut_sn
{
    _dut_sn = dut_sn;
}

-(void)setFoldDir:(NSString *)foldDir
{
    _foldDir = foldDir;
}

-(void)threadEnd
{
    [thread cancel];
    [agilentB2987A CloseDevice];
    [agilentE4980A CloseDevice];
    [serialport Close];
    
    agilentB2987A = nil;
    agilentE4980A = nil;
    serialport = nil;
}

-(void)cancelCurrentThread:(NSNotification *)noti
{
    
    if (self.isCancel)
    {
        [thread cancel];
        thread = nil;
        [agilentB2987A CloseDevice];
        [agilentE4980A CloseDevice];
        [serialport Close];
        
        agilentB2987A = nil;
        agilentE4980A = nil;
        serialport = nil;
    }
    

}

-(void)NSThreadStart_Notification:(NSNotification *)noti
{
    [jsonStrM setString:@""];
    index = 2;

}

-(void)selectNTNoti:(NSNotification *)noti
{
    nulltest = YES;
    
}
-(void)selectPDCAandSCFNoti:(NSNotification *)noti
{
    
    if ([noti.name isEqualToString:@"NoticePDCASTATE"]) {
        
        if ([noti.object isEqualToString:@"YES"]) {
            
            isPDCA = YES;
        }
        else
        {
            isPDCA = NO;
        }
    }
    if ([noti.name isEqualToString:@"NoticeSFCSTATE"]) {
       
        if ([noti.object isEqualToString:@"YES"]) {
            
            isSFC = YES;
        }
        else
        {
            isSFC = NO;
        }
    }
    
}

-(void)writeNullValueToPlist:(NSNotification *)noti
{
    
        updateItem.fix_B_E_Res     = [NSString stringWithFormat:@"%f",B_E_Sum/nullTimes];
        updateItem.fix_B2_E2_Res   = [NSString stringWithFormat:@"%f",B2_E2_Sum/nullTimes];
        updateItem.fix_B4_E4_Res   = [NSString stringWithFormat:@"%f",B4_E4_Sum/nullTimes];
        updateItem.fix_ABC_DEF_Res = [NSString stringWithFormat:@"%f",ABC_DEF_Sum/nullTimes];
        updateItem.fix_Cap         = [NSString stringWithFormat:@"%f",Cap_Sum/nullTimes];
    if ([updateItem.fix_B4_E4_Res floatValue] < 0)
    {
        updateItem.fix_B4_E4_Res = [NSString stringWithFormat:@"%.3f",fabs(updateItem.fix_B4_E4_Res.floatValue)];
    }
        if (fix_type == 1&&nullTimes>=3) {
            [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix1];
            app.clickCount++;
        }
        if (fix_type==2&&nullTimes>=3) {
            [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix2];
            app.clickCount++;
            
        }
        if (fix_type==3&&nullTimes>=3) {
            [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix3];
            app.clickCount++;
            
        }
        if (fix_type==4&&nullTimes>=3) {
            [plist PlistWrite:@"Param" UpdateItem:updateItem Key:kFixtureFix4];
            app.clickCount++;
            
        }

    
    if (app.clickCount==4)
    {
        app.clickCount=0;
        [NSThread sleepForTimeInterval:2];
        exit(0);
    }
    
   
}


#pragma mark----PDCA相关
//================================================
//上传pdca
//================================================
-(void)UploadPDCA
{

}


#pragma mark-----------------多次测试和的值
-(void)add_RFixture_Value_To_Sum_Testname:(NSString *)testname RFixture:(double)RFixture
{
    NSString *largeRes= @">1TOhm";
    if ([testname isEqualToString:@"B_E_DCR"])         B_E_Sum   = B_E_Sum + RFixture;
    if ([testname isEqualToString:@"B2_E2_DCR"])       B2_E2_Sum = B2_E2_Sum + RFixture;
    if ([testname isEqualToString:@"B4_E4_DCR"])       B4_E4_Sum = B4_E4_Sum + RFixture;
    if ([testname isEqualToString:@"ABC_EDEF_DCR"])    ABC_DEF_Sum =ABC_DEF_Sum + RFixture;
    
    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",RFixture] forKey:[NSString stringWithFormat:@"%@_Rfix",testname]];
}



#pragma mark----------------GΩ情况下调用方法，testname为测试项的名称
-(void)storeValueToDic_with_name:(NSString *)testname
{
    double Rdut,Rfixture;
    NSString *largeRes=@">1TOhm";
    Rfixture=num*1E-9;
    Rdut=9999.00;

    if ([testname isEqualToString:@"B_E_DCR"]) {
        Rfixture = [updateItem.fix_B_E_Res floatValue];
    }
    if ([testname isEqualToString:@"B2_E2_DCR"]) {
        Rfixture = [updateItem.fix_B2_E2_Res floatValue];
    }
    if ([testname isEqualToString:@"B4_E4_DCR"]) {
         Rfixture = [updateItem.fix_B4_E4_Res floatValue];
    }
    if ([testname isEqualToString:@"ABC_DEF_DCR"]) {
         Rfixture = [updateItem.fix_ABC_DEF_Res floatValue];
    }
    
    Rdut=(num*1E-9*Rfixture)/(Rfixture-num*1E-9);
    if (num*1E-9 >= Rfixture || Rdut > 1000 || num*1E-9 < 0)
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
    }
    else
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:[NSString stringWithFormat:@"%@_Rdut",testname]];
    }
    
     [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rfixture] forKey:[NSString stringWithFormat:@"%@_Rfix",testname]];

    
}


#pragma mark----------------MΩ情况下调用的方法，
-(void)storeValueToDic_With_Item:(Item *)item
{
    double Cdut,Cfix,Rdut;
    NSString *smallCap=@"<1fF";
    NSString *largeACR=@">100GOhm";
    Cdut=0.0;
    Rdut=9999.00;
    Cfix=[updateItem.fix_Cap floatValue];
    Cdut=num*1E+12-Cfix;
    if (fabs(num*1E+12) > 10000)
    {
        Cdut=9999.000;
    }
    Rdut=1E+6/(Cdut*2*3.14159*item.freq.integerValue);
    
    if (Cdut <= 0)
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:[NSString stringWithFormat:@"%@_Cdut",item.testName]];
        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:[NSString stringWithFormat:@"%@_Rdut",item.testName]];
    }
    else
    {
        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:[NSString stringWithFormat:@"%@_Cdut",item.testName]];
        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:[NSString stringWithFormat:@"%@_Rdut",item.testName]];
        
    }
    
    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:[NSString stringWithFormat:@"%@_Cfix",item.testName]];

}


#pragma mark-------------返回总文件
-(NSString *)backTotalFilePath
{
    if (fix_type==1) {
        
       return [NSString stringWithFormat:@"%@/%@_A.csv",self.foldDir,[timeDay getCurrentDay]];
    }
    else if (fix_type==2)
    {
       return [NSString stringWithFormat:@"%@/%@_B.csv",self.foldDir,[timeDay getCurrentDay]];
    }
    else if (fix_type==3)
    {
       return [NSString stringWithFormat:@"%@/%@_C.csv",self.foldDir,[timeDay getCurrentDay]];
    }
    else
    {
       return [NSString stringWithFormat:@"%@/%@_D.csv",self.foldDir,[timeDay getCurrentDay]];
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
                               [textView setString:[NSString stringWithFormat:@"%@",strMsg]];
                           }
                           
                           [textView setTextColor:[NSColor redColor]];
                       });
    }
}


-(NSString *)getWebBodyStringWithJsonString:(NSString *)jsonString
{
    jsonStr=[NSString stringWithFormat:@"[{\"SEQNO\":0,\"TESTNAME\":\"Version\",\"TESTVALUE\":\"%@\",\"TestResult\":OK},%@]",_sw_ver,jsonString];
    NSString *webServiceBodyStr = [NSString stringWithFormat:
                                   @"<UploadResistanceData xmlns=\"http://tempuri.org/\">"
                                   "<BEGIN_TIME>%@</BEGIN_TIME>"
                                   "<END_TIME>%@</END_TIME>"
                                   "<SN>%@</SN>"
                                   "<Item_NO>%@</Item_NO>"
                                   "<MODEL_NO>%@</MODEL_NO>"
                                   "<MACHINE_NO>%@</MACHINE_NO>"
                                   "<Test_Result>%@</Test_Result>"
                                   "<Json>%@</Json>"
                                   "<FuncionCode>%@</FuncionCode>"
                                   "</UploadResistanceData>",
                                   SFC_startTime,SFC_endTime,SFC_SN,SFC_ItemNO,SFC_ModelNO,SFC_MechineNO,SFC_TestResult,jsonStr,@"R6Mf5tbgJsng60ejCOENKeadVwaPWhkr"
                                   ];//这里是参数
    return webServiceBodyStr;
    
}



-(void)removeFolderWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDeleteSucces=[fileManager removeItemAtPath:path error:nil];
    if (isDeleteSucces)
    {
        NSLog(@"Crash_Log清除成功！");
    }
    else
    {
        NSLog(@"Crash_Log不存在！");
    }
}



@end
