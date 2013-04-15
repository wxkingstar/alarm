//
//  ViewController.m
//  alarm
//
//  Created by 王 鑫 on 13-3-27.
//  Copyright (c) 2013年 王 鑫. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize projectList = _projectList;

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
    currentView = @"View";
    
    self.projectList = [[NSMutableArray alloc] init];
    if(_refreshHeaderView == nil){
        
        EGORefreshTableHeaderView *view =[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.messageTableView.bounds.size.height, self.view.frame.size.width, self.messageTableView.bounds.size.height)];
        view.delegate = self;
        [self.messageTableView addSubview:view];
        _refreshHeaderView = view;        
    }
    //  update the last update date
    //[_refreshHeaderView refreshLastUpdatedDate];

    NSLog(@"viewDidLoad");
    [self loadData:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    NSLog(@"viewDidUnload");
    self.projectList = nil;
    
}

//建立基于UDP的Socket连接
-(void)openUDPServer{
    NSLog(@"begin socket connect");
	//初始化udp
	AsyncUdpSocket *tempSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
	self.udpSocket=tempSocket;
	//绑定端口
	NSError *error = nil;
	[self.udpSocket bindToPort:21345 error:&error];
    [self.udpSocket joinMulticastGroup:UDP_HOST error:&error];
    
   	//启动接收线程
	[self.udpSocket receiveWithTimeout:-1 tag:0];
    NSLog(@"begin send message");
    
    
    NSMutableString *sendString=[NSMutableString stringWithCapacity:100];
	[sendString appendString:@"1"];
	//开始发送
	[self.udpSocket sendData:[sendString dataUsingEncoding:NSUTF8StringEncoding] toHost:UDP_HOST port:21345 withTimeout:-1 tag:0];

}

#pragma mark -
#pragma mark UDP Delegate Methods
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"didReceiveData called");

    [self.udpSocket receiveWithTimeout:-1 tag:0];
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[[dict objectForKey:@"time"] integerValue]];
    [self.projectList addObject:[NSDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:@"message"], @"message", [dict objectForKey:@"session"], @"session", [self bubbleView:[dict objectForKey:@"message"] time:date level:[dict objectForKey:@"level"]], @"view", nil]];
	
    [self.messageTableView reloadData];
    [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.projectList count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
									  animated:YES];//自动滑动到底部

	//已经处理完毕
	return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag called");
	//无法发送时,返回的异常提示信息
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
	
}
- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotReceiveDataWithTag called");
	//无法接收时，返回异常提示信息
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
}


//生成泡泡UIView
- (UIView *)bubbleView:(NSString *)text time:(NSDate *)time level:(NSString *)level {
    //单条消息
    UIView *returnView =  [self assembleMessageAtIndex:text];
    returnView.backgroundColor = [UIColor clearColor];
    //单条消息内容
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    //消息时间
    UILabel *timeView = [[UILabel alloc] initWithFrame:CGRectZero];
    timeView.backgroundColor = [UIColor clearColor];
    NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    NSMutableString *timeString = [NSMutableString stringWithFormat:@"%@",[formatter stringFromDate:time]];
    timeView.text = timeString;
    timeView.font = [UIFont fontWithName:@"Arial" size:12];
    timeView.textColor = [UIColor darkTextColor];
    timeView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //消息汽泡框
    UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:level ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];

    returnView.frame= CGRectMake(35.0f, 25.0f, returnView.frame.size.width, returnView.frame.size.height);
    bubbleImageView.frame = CGRectMake(20.0f, 17.0f, returnView.frame.size.width+34.0f, returnView.frame.size.height+34.0f);
    cellView.frame = CGRectMake(0.0f, 5.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+20.0f);
    timeView.frame = CGRectMake(25.0f, 0.0f, 200.0f, 20.0f);
    
    [cellView addSubview:timeView];
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:returnView];
    return cellView;
}


//计算文字高度
#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH 200
-(UIView *)assembleMessageAtIndex : (NSString *) message
{
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    UIFont *fon = [UIFont systemFontOfSize:14.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (message) {
        for (int i = 0; i < [message length]; i++) {
            NSString *temp = [message substringWithRange:NSMakeRange(i, 1)];
            if (upX >= MAX_WIDTH) {
                upY = upY + KFacialSizeHeight;
                upX = 0;
                X = MAX_WIDTH;
            }
            CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(150, 40)];
            UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
            la.font = fon;
            la.text = temp;
            la.backgroundColor = [UIColor clearColor];
            [returnView addSubview:la];
            upX=upX+size.width;
            if (X < MAX_WIDTH) {
                X = upX;
            }
        }
        Y = upY;
    }
    returnView.frame = CGRectMake(9.0f,15.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
    return returnView;
}

//cell渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%@", [[self.projectList objectAtIndex:row] objectForKey:@"id"]];
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: TableSampleIdentifier];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
   
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    UIView *cellView = [[self.projectList objectAtIndex:row] objectForKey:@"view"];
    [cell addSubview:cellView];
    //长按
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleTableviewCellLongPressed:)];
    //代理
    longPress.delegate = self;
    longPress.minimumPressDuration = 2.0;
    //将长按手势添加到需要实现长按操作的视图里
    [cell addGestureRecognizer:longPress];
    return cell;
}
//长按事件的实现方法
- (void) handleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self.messageTableView];
        NSIndexPath *indexPath = [self.messageTableView indexPathForRowAtPoint:point];
        if (indexPath != nil) {
            int row = [indexPath row];
            NSString *openUrl = [[self.projectList objectAtIndex:row] objectForKey:@"link"];
            if ([openUrl length] > 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
            }
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"UIGestureRecognizerStateChanged");
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
    }
    
}


//行数
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"numberOfRowsInSection");
    return [self.projectList count];
}

//点击当项目事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    NSString *rowString = [[self.projectList objectAtIndex:[indexPath row]] objectForKey:@"message"];
    session = [[self.projectList objectAtIndex:[indexPath row]] objectForKey:@"session"];
    if (![session isEqual:@""]) {
        /*
        ProjectViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectViewController"];
        
        [self.navigationController pushViewController:detail animated:YES];
        */
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                  bundle:nil];
        ProjectViewController* projectView = [sb instantiateViewControllerWithIdentifier:@"ProjectViewController"];
        
        [projectView setTitle:rowString];
        /*
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        transition.delegate = self;
        [self.view.layer addAnimation:transition forKey:nil];
        
        [self.view addSubview:projectView.view];
    */
        //[self.udpSocket close];
    
        [self presentViewController:projectView animated:YES completion:nil];
    }
}

//设置行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *chatView = [[self.projectList objectAtIndex:[indexPath row]] objectForKey:@"view"];
    return chatView.frame.size.height + 20;
}

- (IBAction)setting:(UIBarButtonItem *)sender {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                  bundle:nil];
    ProjectViewController* settingView = [sb instantiateViewControllerWithIdentifier:@"SettingViewController"];
    [self.udpSocket close];
    [self presentViewController:settingView animated:YES completion:nil];
}
- (IBAction)logout:(UIBarButtonItem *)sender {
    char *err;
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM `user`"];
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"logout");
    }
    loginStatus = @"";
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController* viewController = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void) loadData: (BOOL)isFirst {
    //加载一个NSURL对象
    int rand = arc4random() % 100000000;
    NSString *url;
    if (isFirst) {
        url = [[NSString alloc] initWithFormat:@"http://%@/?s=client&a=lists&username=%@&format=json&_=%i", API_HOST, loginStatus, rand];
    } else {
        url = [[NSString alloc] initWithFormat:@"http://%@/?s=client&a=lists&username=%@&format=json&first_id=%@&_=%i", API_HOST, loginStatus, self.firstId, rand];
    }
    NSLog(@"%@", url);
    // Do any additional setup after loading the view, typically from a nib.
    LoadingView *indicator = [[LoadingView alloc]initWithFrame:CGRectMake(0, 0, 120, 120) superView:self.view];
    [indicator alignToCenter];
    [indicator show:YES];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler: ^(NSURLResponse *response,NSData *data,NSError *error){
        if ([data length]>0 && error == nil) {
            NSDictionary *projectDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSArray *projectDictData = [[projectDict objectForKey:@"result"] objectForKey:@"data"];
            dispatch_async(dispatch_get_main_queue(), ^{
                int i = 0;
                for (NSDictionary *key in projectDictData) {
                    if ([self.firstId length] == 0) {
                        self.firstId = [key objectForKey:@"id"];
                    } else if (!isFirst && i == 0){
                        self.firstId = [key objectForKey:@"id"];
                    }
                    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[[key objectForKey:@"time"] integerValue]];
                    NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [key objectForKey:@"message"], @"message",
                                         [key objectForKey:@"session"], @"session",
                                         [self bubbleView:[key objectForKey:@"message"] time:date level:[key objectForKey:@"level"]], @"view",
                                         [key objectForKey:@"id"], @"id",
                                         [key objectForKey:@"link"], @"link",
                                         nil];
                    if (isFirst) {
                        [self.projectList addObject: obj];
                    } else {
                        [self.projectList insertObject:obj atIndex:i++];
                    }
                }
                [self.messageTableView setHidden:YES];
                [self.messageTableView reloadData];
                if (isFirst) {
                    [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.projectList count]-1 inSection:0]
                                                 atScrollPosition: UITableViewScrollPositionBottom
                                                         animated:YES];
                } else {
                    [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                                 atScrollPosition: UITableViewScrollPositionTop
                                                         animated:NO];
                }
                [indicator hide]; 
                [self.messageTableView setHidden:NO];
            });
        } else if([data length] == 0 && error == nil) {
            NSLog(@"Nothing was downloaded.");
        } else if(error != nil) {
            NSLog(@"Error = %@", error);
        } else {
            NSLog(@"other");
        }
    }];
    //[self openUDPServer];
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

-(void)reloadTableViewDataSource{
    NSLog(@"reloadTableViewDataSource");
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    
    _reloading =YES;
    
}

-(void)doneLoadingTableViewData{
    NSLog(@"doneLoadingTableViewData");
    //  model should call this when its done loading
    _reloading =NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.messageTableView];
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"scrollViewDidScroll");
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //NSLog(@"scrollViewDidEndDragging");
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    NSLog(@"egoRefreshTableHeaderDidTriggerRefresh");
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
    
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    //NSLog(@"egoRefreshTableHeaderDataSourceIsLoading");
    
    return _reloading; // should return if data source model is reloading
    
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    NSLog(@"egoRefreshTableHeaderDataSourceLastUpdated");
    /*
    NSError *error;
    //加载一个NSURL对象
    int rand = arc4random() % 100000000;
    NSString *url = [[NSString alloc] initWithFormat:@"http://%@/?s=client&a=lists&username=%@&format=json&first_id=%@&_=%i", API_HOST, loginStatus, self.firstId, rand];
    NSLog(@"%@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    NSDictionary *projectDict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    NSArray *projectDictData = [[projectDict objectForKey:@"result"] objectForKey:@"data"];
    //NSLog(@"weatherInfo字典里面的内容为--》%@", projectDictData );
    
    int i = 0;
    for (NSDictionary *key in projectDictData) {
        if (i == 0) {
            self.firstId = [key objectForKey:@"id"];
        }
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[[key objectForKey:@"time"] integerValue]];
        
        [self.projectList insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [key objectForKey:@"message"], @"message",
                                        [key objectForKey:@"session"], @"session",
                                        [self bubbleView:[key objectForKey:@"message"] time:date level:[key objectForKey:@"level"]], @"view",
                                        [key objectForKey:@"id"], @"id",
                                        [key objectForKey:@"link"], @"link",
                                        nil] atIndex:i++];
    }

    [self.messageTableView reloadData];
    [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                 atScrollPosition: UITableViewScrollPositionTop
                                         animated:NO];
     */
    [self loadData:NO];
    return[NSDate date]; // should return date data source was last changed
    
}
 
- (IBAction)refresh:(id)sender {
    [self viewDidLoad];
}
@end
