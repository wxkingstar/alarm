//
//  ViewController.h
//  alarm
//
//  Created by 王 鑫 on 13-3-27.
//  Copyright (c) 2013年 王 鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectViewController.h"
#import "AsyncUdpSocket.h"
//#import "IPAddress.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *projectList;
@property (nonatomic, retain) ProjectViewController *projectView;
@property (strong, nonatomic) AsyncUdpSocket *udpSocket;
- (IBAction)setting:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UITableView *messageTableView;
- (IBAction)logout:(UIBarButtonItem *)sender;

@end
