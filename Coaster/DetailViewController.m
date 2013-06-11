//
//  DetailViewController.m
//  Coaster
//
//  Created by naoty on 2013/06/09.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "MasterViewController.h"
#import "Log.h"
#import "Report.h"
#import "Konashi.h"
#import "SVProgressHUD.h"
#import "NSManagedObject+isNew.h"

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
    
    _appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    self.title = [_dateFormatter stringFromDate:self.report.timestamp];
    
    [Konashi addObserver:self selector:@selector(analogValueUpdated) name:KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO2];
    
    if ([self.report isNew]) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveObjects)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
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
    NSInteger value = [Konashi analogRead:AIO2];
    [self addPoint:value];
    
    // Logを作成する
    Log *log = (Log *)[NSEntityDescription insertNewObjectForEntityForName:@"Log" inManagedObjectContext:_appDelegate.managedObjectContext];
    log.voltage = (NSDecimalNumber *) [NSNumber numberWithInteger:value];
    log.timestamp = [NSDate date];
    [self.report addLogsObject:log];
}

- (void)addPoint:(float)value
{
    NSString *jsString = [NSString stringWithFormat:@"window.addPoint(%f)", value];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)addPoint:(float)value timestamp:(NSDate *)datetime
{
    NSString *timestamp = [_dateFormatter stringFromDate:datetime];
    NSString *jsString = [NSString stringWithFormat:@"window.addPoint(%f, '%@')", value, timestamp];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)saveObjects
{
    [SVProgressHUD showSuccessWithStatus:@"Saved!"];
    [_appDelegate saveContext];
    [_timer invalidate];
    [self.masterViewController reloadReports];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loadPoints
{
    for (Log *log in [self.report sortedLogs]) {
        [self addPoint:[log.voltage floatValue] timestamp:log.timestamp];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    
    if ([self.report isNew]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kAnalogReadInterval target:self selector:@selector(sendAnalogReadRequest) userInfo:nil repeats:YES];
    } else {
        [self loadPoints];
    }
}

@end
