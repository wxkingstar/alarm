//
//  LoginViewController.h
//  alarm
//
//  Created by 王 鑫 on 13-4-7.
//  Copyright (c) 2013年 王 鑫. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
- (IBAction)login:(UIButton *)sender;

@end
