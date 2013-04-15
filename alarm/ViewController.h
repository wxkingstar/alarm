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
#import "EGORefreshTableHeaderView.h"
#import "LoadingView.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

{
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    //  Reloading var should really be your tableviews datasource
    //  Putting it here for demo purposes
    BOOL _reloading;
}
 
-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;

@property (strong, nonatomic) NSMutableArray *projectList;
@property (nonatomic, retain) ProjectViewController *projectView;
@property (strong, nonatomic) AsyncUdpSocket *udpSocket;
- (IBAction)setting:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UITableView *messageTableView;
- (IBAction)logout:(UIBarButtonItem *)sender;
@property (strong, nonatomic) NSString *firstId;
- (IBAction)refresh:(id)sender;

@end
