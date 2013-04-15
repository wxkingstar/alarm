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
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    NSLog(@"didFinishLaunchingWithOptions");
    
    NSString*path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString*file = [path stringByAppendingPathComponent:@"user.db"];
    if([[NSFileManager defaultManager] fileExistsAtPath:file] == FALSE)
    {
        NSString *fromFile = [[NSBundle mainBundle] pathForResource:@"user.db" ofType:nil];
        [[NSFileManager defaultManager] copyItemAtPath:fromFile toPath:file error:nil];
    }
    // open
    if(sqlite3_open([file UTF8String], &database) != SQLITE_OK) {
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
    
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
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
    
    NSString *postString = [[NSString alloc] initWithFormat:@"appid=6486b4e9-8228-b83d-4b13-d54f-ebe5f170&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushalert=enabled&pushbadge=enabled&pushsound=enabled&appversion=%@", strDeviceToken, deviceName, deviceModel, deviceSystemVersion, APP_VERSION];
    NSLog(@"%@", postString);
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    [request setHTTPMethod:@"POST"];
    [NSURLConnection connectionWithRequest:request delegate:self];
    NSLog(@"regisger success:%@", deviceToken);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);

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
