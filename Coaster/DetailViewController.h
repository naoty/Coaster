//
//  DetailViewController.h
//  Coaster
//
//  Created by naoty on 2013/06/09.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class MasterViewController;
@class Report;

@interface DetailViewController : UIViewController <UIWebViewDelegate>
{
    AppDelegate *_appDelegate;
    NSTimer *_analogReadTimer;
    BOOL _isLessPressure;
    NSTimer *_rotateLEDTimer;
    NSInteger _rotateCounter;
    NSArray *_pios;
    NSDateFormatter *_dateFormatter;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) Report *report;
@property (nonatomic) MasterViewController *masterViewController;

@end
