//
//  ProjectViewController.h
//  alarm
//
//  Created by 王 鑫 on 13-3-27.
//  Copyright (c) 2013年 王 鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"

@interface ProjectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 


- (IBAction)back:(UIBarButtonItem *)sender;
- (IBAction)sendMessageClick:(UIBarButtonItem *)sender;//发送消息按钮
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;//消息发布框
@property (strong, nonatomic) IBOutlet UITableView *chatTableView;

@property (strong, nonatomic) NSString *messageString;
@property (strong, nonatomic) NSMutableArray *chatArray;
@property (strong, nonatomic) NSString *session;
@property (strong, nonatomic) AsyncUdpSocket *udpSocket;

@end
