//
//  MK_FileTXT.m
//  File
//
//  Created by Michael on 16/11/3.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "MK_FileTXT.h"

@implementation MK_FileTXT

//=============================
+(MK_FileTXT *)shareInstance
{
    static MK_FileTXT *fileTXT = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileTXT = [[MK_FileTXT alloc] init];
    });
    
    return fileTXT;
}


//新建 txt 文件:判断文件是否存在,不存在则新建文件,存在则追加文件数据
//=============================
-(BOOL)createOrFlowTXTFileWithFolderPath:(NSString *)folderPath Sn:(NSString *)sn TestItemStartTime:(NSString *)testItemStartTime TestItemEndTime:(NSString *)testItemEndTime TestItemContent:(NSString *)testItemContent TestResult:(NSString *)testResult
{
    if (folderPath==nil || [folderPath isEqual:@""] || sn==nil || [sn isEqual:@""] || testItemStartTime==nil || [testItemStartTime isEqual:@""] || testItemEndTime==nil || [testItemEndTime isEqual:@""] || testItemContent==nil || [testItemContent isEqual:@""] || testResult==nil || [testResult isEqual:@""])
    {
        if (sn)
        {
            sn = sn;
        }
        else
        {
            sn = @"123456789";
            sn = [NSString stringWithFormat:@"MK_%@",sn];
        }
        
        if (folderPath)
        {
            folderPath = folderPath;
        }
        else
        {
            folderPath = @"/Users/";
        }
        if (testItemStartTime)
        {
            testItemStartTime = testItemStartTime;
        }
        else
        {
            testItemStartTime = @"_Year-Month-Day-Times";
        }
        
        if (testItemEndTime)
        {
            testItemEndTime = testItemEndTime;
        }
        else
        {
            testItemEndTime = @"_Year-Month-Day-Times";
        }
        if (testItemContent)
        {
            testItemContent = testItemContent;
        }
        else
        {
            testItemContent  =@"your data is NULL NULL NULL NULL!!";
        }
        if (testResult)
        {
            testResult = testResult;
        }
        else
        {
            testResult  =@"NA";
        }
    }
    
    //创建由 日期 命名的文件
    //获取本地时间日期
    NSDate *dateT = [[NSDate alloc] init];
    //    NSLog(@"%@",dateT);
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    // Get Current  time
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *folderDateStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:dateT]];
    
    //=============== 创建 txt 文件 =====================
    //创建文件管理对象
    NSString *defaultFileName = [NSString stringWithFormat:@"%@/%@_%@_%@.txt", folderPath,sn,[[NSUserDefaults standardUserDefaults] objectForKey:@"mainFolderNameKey"],folderDateStr];
    //    NSString *defaultFileName = [NSString stringWithFormat:@"%@/%@.txt", folderPath,sn];
    
    
    //在当前路径下判断该文件是否存在,不存在则新建文件,存在则追加文件数据
    if (![[NSFileManager defaultManager] fileExistsAtPath:defaultFileName])
    {
        //----------------------新建文件并写入数据
        //        NSLog(@"\n\ntestItemContent1111===%@\n\n",testItemContent);
        //写入字符数据
        testItemContent = [NSString stringWithFormat:@"%@\n%@\n%@\n\n",testItemStartTime,testItemEndTime,testItemContent];
        //        NSLog(@"\n\ntestItemContent===%@\n\n",testItemContent);
        BOOL res = [testItemContent writeToFile:defaultFileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        if (res)
        {
            NSLog(@"TXT====文件%@写入数据成功!!",defaultFileName);
            return YES;
        }
        else
        {
            NSLog(@"TXT====文件%@写入数据失败!!",defaultFileName);
            return NO;
        }
    }
    else
    {
        //----------------------追加文件数据
        //打开原文件
        NSFileHandle *inFile = [NSFileHandle fileHandleForReadingAtPath:defaultFileName];
        
        //打开文件处理类,用于写操作
        inFile = [NSFileHandle fileHandleForWritingAtPath:defaultFileName];
        
        //找到并定位到 infile 的末尾位置(在此后追加文件数据
        [inFile seekToEndOfFile];
        
        //写入新的字符数据
        NSString *newStr = [NSString stringWithFormat:@"%@\n%@\n%@\n\n",testItemStartTime,testItemEndTime,testItemContent];
        NSLog(@"\n\n");
        //        NSLog(@"newStr==%@",newStr);
        NSLog(@"\n\n");
        //与第一次写入的字符对比
        if (![newStr isEqualToString:testItemContent])
        {
            [inFile writeData:[newStr dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"TXT===追加文件成功");
            //关闭文件
            [inFile closeFile];
            return YES;
        }
        else
        {
            NSLog(@"TXT====追加文件失败");
            //关闭文件
            [inFile closeFile];
            return NO;
        }
    }
}

//新建 txt 文件:判断文件是否存在,不存在则新建文件,存在则追加文件数据
//=============================
-(BOOL)createOrFlowTXTFileWithFolderPath:(NSString *)folderPath FileName:(NSString *)fileName Content:(NSString *)content
{
    
    //获取本地时间日期
    NSDate *dateT = [[NSDate alloc] init];
    //    NSLog(@"%@",dateT);
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];

    // Get Current  time
    [formatter setDateFormat:@"yyyy-MM-dd(HH:mm:ss)"];
    [formatter1 setDateFormat:@"_yyyy-MM"];

    NSString *fileDateStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:dateT]];
//    NSString *fileMonStr = [NSString stringWithFormat:@"%@",[formatter1 stringFromDate:dateT]];

    NSString *defaultFileName = [NSString stringWithFormat:@"%@/%@.txt",folderPath,fileName];
//    NSString *defaultFileName1 ;
//
//    if ([folderPath containsString:@"Count"])
//    {
//        defaultFileName = [NSString stringWithFormat:@"%@/fil.txt",folderPath];
//        
//    }
//    else if ([folderPath containsString:@"SFC_LOG"])
//    {
//        defaultFileName = [NSString stringWithFormat:@"%@/SFC_LOG.txt",folderPath];
//        defaultFileName1= [NSString stringWithFormat:@"%@/SFC_LOG%@.txt",folderPath,fileMonStr];
//    }
    //在当前路径下判断该文件是否存在,不存在则新建文件,存在则追加文件数据
    if (![[NSFileManager defaultManager] fileExistsAtPath:defaultFileName])
    {
        //----------------------新建文件并写入数据
        //        NSLog(@"\n\ntestItemContent1111===%@\n\n",testItemContent);
        //写入字符数据
        if ([folderPath containsString:@"SFC_LOG"])
        {
            content=[NSString stringWithFormat:@"%@    %@\n",fileDateStr,content];
        }
        BOOL res = [content writeToFile:defaultFileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        
        if (res)
        {
            NSLog(@"TXT====文件%@写入数据成功!!",defaultFileName);
            return YES;
        }
        else
        {
            NSLog(@"TXT====文件%@写入数据失败!!",defaultFileName);
            return NO;
        }
    }
    else
    {
        //----------------------追加文件数据
        //打开原文件
        NSFileHandle *inFile = [NSFileHandle fileHandleForReadingAtPath:defaultFileName];
        
        //打开文件处理类,用于写操作
        inFile = [NSFileHandle fileHandleForWritingAtPath:defaultFileName];
        
        //找到并定位到 infile 的末尾位置(在此后追加文件数据
        [inFile seekToEndOfFile];
        
        //写入新的字符数据
        NSString *newStr = [NSString stringWithFormat:@"===%@",content];
        if ([folderPath containsString:@"SFC_LOG"])
        {
            newStr = [NSString stringWithFormat:@"%@    %@\n",fileDateStr,content];
        }
        //与第一次写入的字符对比
        if (![newStr isEqualToString:content])
        {
            [inFile writeData:[newStr dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"TXT===追加文件成功");
            //关闭文件
            [inFile closeFile];
            return YES;
        }
        else
        {
            NSLog(@"TXT====追加文件失败");
            //关闭文件
            [inFile closeFile];
            return NO;
        }
    }
}

//清空 userDefault 缓存
-(void)cleanUserDefault
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TXTsecondFolderPathKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//读取指定路径的txt文件内容
-(NSString *)TXT_ReadFromPath:(NSString *)path
{
    NSString *str=nil;
    
    if(path != nil )
    {
        //创建写文件句柄
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
        
        //找到并定位到0
        [file seekToFileOffset:0];
        
        //读入字符串
        NSData *data = [file readDataToEndOfFile];
        
        str = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        
        //关闭文件
        [file closeFile];
    }
    
    return str;
}

-(NSString *)TXT_ReadFromPath:(NSString *)path FromCurrentDay:(NSString *)curentDay
{
    NSString *str=nil;
//    NSDate *dateT = [[NSDate alloc] init];
//    //    NSLog(@"%@",dateT);
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    // Get Current  time
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    NSString *folderDateStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:dateT]];
    if(path != nil )
    {
        //创建写文件句柄
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
        
        //找到并定位到0
        
        [file seekToFileOffset:0];
        
        //读入字符串
        NSData *data = [file readDataToEndOfFile];
        
        str = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        
        //关闭文件
        [file closeFile];
    }
    
    return str;
}





@end
