//
//  LoadingView.h
//  alarm
//
//  Created by 王 鑫 on 13-4-14.
//  Copyright (c) 2013年 王 鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface LoadingView :UIView {
    
    UIActivityIndicatorView* indicator;
    
    UILabel* label;
    
    BOOL visible,blocked;
    
    UIView* maskView;
    
    CGRect rectHud,rectSuper,rectOrigin;//外壳区域、父视图区域
    
    UIView* viewHud;//外壳
    
}

@property (assign) BOOL visible;



-(id)initWithFrame:(CGRect)frame superView:(UIView*)superView;

-(void)show:(BOOL)block;// block:是否阻塞父视图

-(void)hide;

-(void)setMessage:(NSString*)newMsg;

-(void)alignToCenter;

@end