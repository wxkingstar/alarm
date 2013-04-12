//
//  ProjectViewController.m
//  alarm
//
//  Created by 王 鑫 on 13-3-27.
//  Copyright (c) 2013年 王 鑫. All rights reserved.
//

#import "ProjectViewController.h"

#define TOOLBARTAG		100
#define TABLEVIEWTAG	200

@interface ProjectViewController ()

@end

@implementation ProjectViewController

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
    //设置bar
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [navigationBar setBarStyle:UIBarStyleDefault];
    UINavigationItem *myNavigationItem = [[UINavigationItem alloc] initWithTitle: self.title];
    
    //设置左按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    myNavigationItem.leftBarButtonItem = leftButton;
    
    [navigationBar setItems:[NSArray arrayWithObject:myNavigationItem]];
    
    [self.view addSubview: navigationBar];
    
    //self.navigationItem.title = @"标题";
    //初始化变量
    self.chatArray = [[NSMutableArray alloc] init];
    NSError *error;
    //加载一个NSURL对象
    NSString *url = [[NSString alloc] initWithFormat:@"%@%@%@%@", @"http://", API_HOST, @"?s=client&a=session_list&format=json&session=", self.session];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSLog(@"%@", url);
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    NSArray *dictData = [[dict objectForKey:@"result"] objectForKey:@"data"];
    NSLog(@"weatherInfo字典里面的内容为--》%@", dictData );
    
    for (NSDictionary *key in dictData) {
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[[key objectForKey:@"time"] integerValue]];
        BOOL from;
        if ([[key objectForKey:@"send_user"] isEqual:@"system"]) {
            from = NO;
        } else if ([[key objectForKey:@"send_user"] isEqual:loginStatus]) {
            from = YES;
        } else {
            from = NO;
        }
        [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[key objectForKey:@"message"], @"text", [self bubbleView:[key objectForKey:@"message"] time:date from:from], @"view", [key objectForKey:@"send_user"], @"speaker", nil]];
    }

    
    //键盘事件监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //监听键盘事件，>=IOS5.0
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //[self openUDPServer];
    
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                              atScrollPosition: UITableViewScrollPositionBottom
									  animated:YES];//自动滑动到底部
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//键盘显示状态控制输入toobar位置
- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self autoMovekeyBoard:keyboardRect.size.height];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    [self autoMovekeyBoard:0];
}

//根据键盘计算tableview和toolbar的位置和高度
-(void) autoMovekeyBoard: (float) h{
    
    UIToolbar *toolbar = (UIToolbar *)[self.view viewWithTag:TOOLBARTAG];
	//toolbar.frame = CGRectMake(0.0f, (float)(480.0-h-108.0), 320.0f, 44.0f);
	toolbar.frame = CGRectMake(0.0f, (float)(480.0-h-64.0), 320.0f, 44.0f);
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	tableView.frame = CGRectMake(0.0f, 44.0f, 320.0f,(float)(480.0-h-108.0));
    //[self.chatTableView reloadData];
    
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
	BOOL res = [self.udpSocket sendData:[sendString dataUsingEncoding:NSUTF8StringEncoding] toHost:UDP_HOST port:21345 withTimeout:-1 tag:0];
}

#pragma mark -
#pragma mark UDP Delegate Methods
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"didReceiveData called");
    
    NSLog(@"host---->%@",host);
    [self.udpSocket receiveWithTimeout:-1 tag:0];
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    if ([[dict objectForKey:@"send_user"] isEqual:loginStatus]) {
        return YES;
    }
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[[dict objectForKey:@"time"] integerValue]];
    [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:@"message"], @"text", [self bubbleView:[dict objectForKey:@"message"] time:date from:NO], @"view", [dict objectForKey:@"send_user"], @"speaker", nil]];
    [self.chatTableView reloadData];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
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



//cell渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    UIView *cellView = [[self.chatArray objectAtIndex:row] objectForKey:@"view"];
    [cell.contentView addSubview:cellView];

 

    return cell;
}

//生成泡泡UIView
- (UIView *)bubbleView:(NSString *)text time:(NSDate *)time from:(BOOL)fromSelf {
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
    UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelf":@"bubble" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
    //头像
    UIImageView *headImageView = [[UIImageView alloc] init];
    //处理消息位置
    if(fromSelf){
        [headImageView setImage:[UIImage imageNamed:@"face_test.png"]];
        returnView.frame= CGRectMake(19.0f, 28.0f, returnView.frame.size.width, returnView.frame.size.height);
        //根据内容计算汽泡框的长度
        bubbleImageView.frame = CGRectMake(10.0f, 22.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height+30.0f );
        //将汽泡框放到cell上
        cellView.frame = CGRectMake(265.0f-bubbleImageView.frame.size.width, 10.0f,bubbleImageView.frame.size.width+50.0f, bubbleImageView.frame.size.height+20.0f);
        headImageView.frame = CGRectMake(bubbleImageView.frame.size.width + 10.0f, cellView.frame.size.height-30.0f, 30.0f, 30.0f);
        timeView.frame = CGRectMake(cellView.frame.size.width - 110.0f, 5.0f, 200.0f, 20.0f);
    } else {
        [headImageView setImage:[UIImage imageNamed:@"default_head_online.png"]];
        returnView.frame= CGRectMake(55.0f, 25.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleImageView.frame = CGRectMake(40.0f, 22.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height+24.0f);
		  cellView.frame = CGRectMake(0.0f, 10.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+20.0f);
        headImageView.frame = CGRectMake(5.0f, cellView.frame.size.height-30.0f, 30.0f, 30.0f);
        timeView.frame = CGRectMake(45.0f, 5.0f, 200.0f, 20.0f);
    }
    
    [cellView addSubview:timeView];
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:returnView];
    [cellView addSubview:headImageView];
    return cellView;
}


//计算文字高度
#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH 150
-(UIView *)assembleMessageAtIndex : (NSString *) message
{
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    UIFont *fon = [UIFont systemFontOfSize:13.0f];
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
                X = 150;
            }
            CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(150, 40)];
            UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
            la.font = fon;
            la.text = temp;
            la.backgroundColor = [UIColor clearColor];
            [returnView addSubview:la];
            upX=upX+size.width;
            if (X<150) {
                X = upX;
            }
        }
        Y = upY;
    }
    returnView.frame = CGRectMake(9.0f,15.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
    return returnView;
}

//cell选择效果
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.messageTextField resignFirstResponder];
}

//行数
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.chatArray count];
}
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *chatView = [[self.chatArray objectAtIndex:[indexPath row]] objectForKey:@"view"];
    return chatView.frame.size.height + 20;
}

//返回按钮
- (IBAction)back:(UIBarButtonItem *)sender {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                  bundle:nil];
    UIViewController* view = [sb
                              instantiateViewControllerWithIdentifier:@"ViewController"];
    
    //[self.udpSocket close];
    [self presentViewController:view animated:NO completion:nil];
}

//消息发送按钮
- (IBAction)sendMessageClick:(UIBarButtonItem *)sender {
    NSString *messageStr = self.messageTextField.text;
    self.messageString = self.messageTextField.text;
    
    if ([messageStr isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送失败！" message:@"发送的内容不能为空！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } else {
        //[self sendMassage:messageStr];
        //加入时间行
        NSDate *nowTime = [NSDate date];
        self.messageTextField.text = @"";
        [self.chatArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:messageStr, @"text", [self bubbleView:messageStr time:nowTime from:YES], @"view", @"self", @"speaker", nil]];
        [self.chatTableView reloadData];
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatArray count]-1 inSection:0]
                                  atScrollPosition: UITableViewScrollPositionBottom
									  animated:YES];//自动滑动到底部
        //self.messageString = self.messageTextField.text;
        [self.messageTextField resignFirstResponder];
        //加载一个NSURL对象
        NSString *url = [[NSString alloc] initWithFormat:@"http://%@/?s=client&a=message&format=json&content=%@&from=%@&session=%@", API_HOST, messageStr, loginStatus, self.session];
        NSLog(@"http://%@/?s=client&a=message&format=json&content=%@&from=%@&session=%@", API_HOST, messageStr, loginStatus, self.session);
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    }

}
@end
