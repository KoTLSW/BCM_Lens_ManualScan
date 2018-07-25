//
//  LoginWindow.m
//  BCM
//
//  Created by xhkj on 2018/2/7.
//  Copyright © 2018年 macjinlongpiaoxu. All rights reserved.
//

#import "LoginWindow.h"

@interface LoginWindow ()
{
    NSMutableDictionary *m_Dic;
}
@end

@implementation LoginWindow

-(id)init
{
    self = [super initWithWindowNibName:@"LoginWindow"];
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)clickToLogin:(NSButton *)sender
{
    if ([_userName.stringValue isEqualToString:[m_Dic objectForKey:@"username"]] && [_passWord.stringValue isEqualToString:[m_Dic objectForKey:@"password"]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _logInfo.stringValue = @"enter !";
            _logInfo.textColor = [NSColor blueColor];
            
        });
        
        [self.window orderOut:self];
        
        //发送通知, 激活 PDCA 按钮功能
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PDCAButtonLimit_Notification" object:nil];
        
        //关闭StationControlWindow窗口的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseStationControlWindow_Notificcation" object:nil];
    }
    
    if ([_userName.stringValue isEqualToString:@"admin"] && [_passWord.stringValue isEqualToString:@"michael"])
    {
        [self.window orderOut:self];
        
        //发送通知,激活按钮状态
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectButtonlimit_Notification" object:nil];
        
        //发送通知, 激活 PDCA 按钮功能
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PDCAButtonLimit_Notification" object:nil];
    }
    else if ([_userName.stringValue isEqualToString:@"op"]&&[_passWord.stringValue isEqualToString:@"op"]) {
        
        
        [self.window orderOut:self];
        
        //发送通知,激活按钮状态
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CancellButtonlimit_Notification" object:nil];
        
    }
    
    //新增无限循环测试
    else if([_userName.stringValue isEqualToString:@"unlimit"]&&[_passWord.stringValue isEqualToString:@"unlimit"])
    {
        
        [self.window orderOut:self];
        
        
        //发送通知, 激活无限循环测试功能
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TestUnLimit_Notification" object:nil];
        //发送通知, 激活 PDCA 按钮功能
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PDCAButtonLimit_Notification" object:nil];
        
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _logInfo.stringValue = @"userName or passWord error!!";
            _logInfo.textColor = [NSColor redColor];
        });
    }
    
}
- (IBAction)clockToCancel:(NSButton *)sender
{
    
    [self.window orderOut:self];
}

@end
