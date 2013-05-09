//
//  AppDelegate.m
//  alarm
//
//  Created by 王 鑫 on 13-3-27.
//  Copyright (c) 2013年 王 鑫. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //UIRemoteNotificationTypeBadge
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    NSLog(@"didFinishLaunchingWithOptions");
    
    NSString*path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString*file = [path stringByAppendingPathComponent:@"alarm.db"];
    NSLog(@"db file path:%@", file);
    if([[NSFileManager defaultManager] fileExistsAtPath:file] == FALSE)
    {
        NSString *fromFile = [[NSBundle mainBundle] pathForResource:@"alarm.db" ofType:nil];
        [[NSFileManager defaultManager] copyItemAtPath:fromFile toPath:file error:nil];
    }
    // open
    if(sqlite3_open([file UTF8String], &database) != SQLITE_OK) {
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
    
    
    //获取最后监测时间
    NSString *lastCheckTime;
    NSString *sql = [NSString stringWithFormat:@"SELECT `value` FROM `setting` WHERE `name` = 'last_check_time'"];
    sqlite3_stmt *statementCheckTime;
    if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statementCheckTime, NULL) == SQLITE_OK) {
        if (sqlite3_step(statementCheckTime) == SQLITE_ROW) {
            lastCheckTime = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statementCheckTime, 0)];
        }
    }
    sqlite3_finalize(statementCheckTime);
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    int nowTime = (int)time;
    int lastTime = [lastCheckTime intValue];
    if ((nowTime - lastTime) > 86400){
        NSLog(@"检测新版本");
        @try {
            //检查版本
            NSError *error;
            //加载一个NSURL对象
            int rand = arc4random() % 100000000;
            NSString *url = [[NSString alloc] initWithFormat:@"http://%@/?s=client&a=version&format=json&_=%i", API_HOST, rand];
            NSLog(@"%@", url);
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            //将请求的url数据放到NSData对象中
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
            NSString *codeStatus = [[[dict objectForKey:@"result"] objectForKey:@"status"] objectForKey:@"code"];
            if ([codeStatus isKindOfClass:[NSNumber class]]) {
                codeStatus = [NSString stringWithFormat:@"%@",codeStatus];
            }
            if ([codeStatus isEqual:@"0"]) {
                float newVersion = [[[dict objectForKey:@"result"] objectForKey:@"data"] floatValue];
                if (newVersion > APP_VERSION){
                    NSLog(@"检测到新版本");
                    NSString *msg = [[[dict objectForKey:@"result"] objectForKey:@"status"] objectForKey:@"msg"];
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"新版本检测" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil];
                    [alert show];
                }
            }
            
            //更新最后检测时间
            char *err;
            if (lastTime == 0) {
                sql = [NSString stringWithFormat:@"INSERT INTO `setting` VALUES ('last_check_time', '%d')", nowTime];
            } else {
                sql = [NSString stringWithFormat:@"UPDATE `setting` SET  `value` = '%d' WHERE `name` = 'last_check_time'", nowTime];
            }
            if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                sqlite3_close(database);
                NSAssert(0, @"数据操作错误！");
            }
        }@catch (NSException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"版本检测失败" message:@"网络不给力" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }

    //检测登录状态
    NSString *ssql = [NSString stringWithFormat:@"SELECT * FROM `user`"];
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [ssql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            loginStatus = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)];
        }
    }
    sqlite3_finalize(statement);
    
    if (loginStatus.length > 0) {
        NSLog(@"直接登录了");
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController* viewController = [sb instantiateViewControllerWithIdentifier:@"ViewController"];
    
        self.window.rootViewController = viewController;
        [self.window makeKeyAndVisible];
    }

    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://%@/?s=client&a=download", API_HOST]]];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    @try {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://client.mix.sina.com.cn/api/push/reg_apns"]];
        //[request setValue:@"Some Value" forHTTPHeaderField:@"Some-Header"];
        strDeviceToken = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<"withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];
        UIDevice *dev = [UIDevice currentDevice];
        
        NSString *deviceName = dev.name;
        NSString *deviceModel = dev.model;
        NSString *deviceSystemVersion = dev.systemVersion;
        
        NSString *postString = [[NSString alloc] initWithFormat:@"appid=6486b4e9-8228-b83d-4b13-d54f-ebe5f170&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushalert=enabled&pushbadge=enabled&pushsound=enabled&appversion=%f", strDeviceToken, deviceName, deviceModel, deviceSystemVersion, APP_VERSION];
        NSLog(@"%@", postString);
        NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
        [request setHTTPMethod:@"POST"];
        [NSURLConnection connectionWithRequest:request delegate:self];
        NSLog(@"regisger success:%@", deviceToken);
    } @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设备id注册失败" message:@"网络不给力" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);

    if ([[userInfo objectForKey:@"from"] length] > 0) {
        currentView = @"ProjectView";
    }
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"] != NULL) {
        if ([currentView isEqual:@"View"] || [currentView isEqual:@"ProjectView"]) {
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UIViewController* viewController = [sb instantiateViewControllerWithIdentifier:[[NSString alloc] initWithFormat:@"%@Controller", currentView]];
            
            NSLog(@"%@", [self.window.rootViewController nibName]);
            self.window.rootViewController = viewController;
            [self.window makeKeyAndVisible];
        }
    }
     
    //UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"通知" message:@"我的信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Regist fail%@",error);
    
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([currentView isEqual:@"View"] || [currentView isEqual:@"ProjectView"]) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController* viewController = [sb instantiateViewControllerWithIdentifier:[[NSString alloc] initWithFormat:@"%@Controller", currentView]];
        
        NSLog(@"%@", [self.window.rootViewController nibName]);
        self.window.rootViewController = viewController;
        [self.window makeKeyAndVisible];
    }
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
}

- (void)dealloc
{
    sqlite3_close(database);
}


@end
