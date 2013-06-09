//
//  DetailViewController.m
//  Coaster
//
//  Created by naoty on 2013/06/09.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import "DetailViewController.h"
#import "Konashi.h"
#import "SVProgressHUD.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

const float kAnalogReadInterval = 10.0f;

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
    
    [Konashi addObserver:self selector:@selector(analogValueUpdated) name:KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO2];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"chart" ofType:@"html"];
    NSString *htmlText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlText baseURL:[NSURL fileURLWithPath:path]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendAnalogReadRequest
{
    [Konashi analogReadRequest:AIO2];
}

- (void)analogValueUpdated
{
    [self addPoint:[Konashi analogRead:AIO2]];
}

- (void)addPoint:(float)value
{
    NSString *jsString = [NSString stringWithFormat:@"window.addPoint(%f)", value];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    [NSTimer scheduledTimerWithTimeInterval:kAnalogReadInterval target:self selector:@selector(sendAnalogReadRequest) userInfo:nil repeats:YES];
}

@end
