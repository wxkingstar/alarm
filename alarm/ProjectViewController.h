//
//  ProjectViewController.h
//  alarm
//
//  Created by 王 鑫 on 13-3-27.
//  Copyright (c) 2013年 王 鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadingView.h"

@interface ProjectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    //  Reloading var should really be your tableviews datasource
    //  Putting it here for demo purposes
    BOOL _reloading;
}
-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;

- (IBAction)back:(UIBarButtonItem *)sender;
- (IBAction)sendMessageClick:(UIBarButtonItem *)sender;//发送消息按钮
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;//消息发布框
@property (strong, nonatomic) IBOutlet UITableView *chatTableView;

@property (strong, nonatomic) NSString *messageString;
@property (strong, nonatomic) NSMutableArray *chatArray;
@property (strong, nonatomic) NSString *session;
@property (strong, nonatomic) AsyncUdpSocket *udpSocket;
@property (strong, nonatomic) NSString *firstId;
@property (strong, nonatomic) NSString *userList;
@property (strong, nonatomic) UINavigationItem *myNavigationItem;

@end
