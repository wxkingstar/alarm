//
//  SettingViewController.m
//  alarm
//
//  Created by 王 鑫 on 13-3-28.
//  Copyright (c) 2013年 王 鑫. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

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
    UINavigationItem *myNavigationItem = [[UINavigationItem alloc] initWithTitle: @"设置"];
    
    //设置左按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    myNavigationItem.leftBarButtonItem = leftButton;
    
    [navigationBar setItems:[NSArray arrayWithObject:myNavigationItem]];
    
    [self.view addSubview: navigationBar];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *TableSampleIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:TableSampleIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    //设置选项
    NSArray *array = [[NSArray alloc] initWithObjects:@"一级报警铃声", @"二级报警铃声", @"三级报警铃声", nil];
    cell.textLabel.text = [array objectAtIndex:row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *name = @"设置";
    return name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (IBAction)back:(UIBarButtonItem *)sender {
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                  bundle:nil];
    UIViewController* view = [sb
                              instantiateViewControllerWithIdentifier:@"ViewController"];
    [self presentViewController:view animated:NO completion:nil];
}

@end
