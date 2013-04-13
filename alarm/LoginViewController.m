//
//  LoginViewController.m
//  alarm
//
//  Created by 王 鑫 on 13-4-7.
//  Copyright (c) 2013年 王 鑫. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    currentView = @"LoginView";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(UIButton *)sender {
    NSString *username = self.username.text;
    NSString *password = self.password.text;
    NSString *url = [[NSString alloc] initWithFormat:@"http://%@/?s=client&a=login&format=json", API_HOST];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    //[request setValue:@"Some Value" forHTTPHeaderField:@"Some-Header"];
    //NSString *strDeviceToken = [[NSString alloc] initWithData:deviceToken encoding:NSASCIIStringEncoding];
    NSString *postString = [[NSString alloc] initWithFormat:@"username=%@&password=%@&device_token=%@", username, password, strDeviceToken];
    NSLog(@"%@", postString);
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@".sina.com.cn" forHTTPHeaderField:@"Referer"];
    //NSData *response = [NSURLConnection connectionWithRequest:request delegate:self];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error;
    NSDictionary *projectDict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    NSString *codeStatus = [[[projectDict objectForKey:@"result"] objectForKey:@"status"] objectForKey:@"code"];
    if ([codeStatus isKindOfClass:[NSNumber class]]) {
        codeStatus = [NSString stringWithFormat:@"%@",codeStatus];
    }
    if ([codeStatus isEqualToString:@"0"]) {
        NSLog(@"登录成功");
        
        if (loginStatus.length == 0) {
            char *err;
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO `user` VALUES ('%@')", username];
            if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                sqlite3_close(database);
                NSAssert(0, @"插入数据错误！");
            }
            loginStatus = username;
        }
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController* viewController = [sb instantiateViewControllerWithIdentifier:@"ViewController"];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"用户名或密码错误" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
        [alert show];
    }
}
@end
