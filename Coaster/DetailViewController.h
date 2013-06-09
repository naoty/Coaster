//
//  DetailViewController.h
//  Coaster
//
//  Created by naoty on 2013/06/09.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class Report;

@interface DetailViewController : UIViewController <UIWebViewDelegate> {
    AppDelegate *_appDelegate;
    Report *_report;
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
