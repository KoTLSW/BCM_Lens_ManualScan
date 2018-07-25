//
//  AppDelegate.m
//  WorkingFrameWork
//
//  Created by mac on 2017/10/27.
//  Copyright © 2017年 macjinlongpiaoxu. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginWindow.h"
#import "ConfigInstr.h"

@interface AppDelegate ()
{
    LoginWindow *loginWindow;
    ConfigInstr * configInstrWindow;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.coutNum = 0;
    self.totalNum = 0;
    self.clickCount=0;

}
- (IBAction)LoginWindow:(NSMenuItem *)sender
{
    if (!loginWindow)
    {
        loginWindow = [[LoginWindow alloc] init];
    }
    
    [loginWindow showWindow:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableToSelectStationNoti" object:nil];
    
}


- (IBAction)configInstrWindow:(id)sender {
    
    if (!configInstrWindow)
    {
        configInstrWindow = [[ConfigInstr alloc] init];
    }
    
    [configInstrWindow showWindow:self];
    
    
    
}





- (IBAction)nullTest:(NSMenuItem *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NULLTEST" object:nil];
}



- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}


@end
