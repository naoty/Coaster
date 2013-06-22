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

#import <AudioToolbox/AudioServices.h>

@interface DetailViewController ()

@end

@implementation DetailViewController

// センサーの値を取得する間隔
const float kAnalogReadInterval = 3.0f;

// バイブレーションを動作させる閾値
// NOTE: グラスが空のとき value = 341
const NSInteger kThreshold = 250;

// 何も圧力が加わってないときの値
const NSInteger kValueWithoutPressure = 1000;

// LEDを点滅させる間隔
const float kRotateLEDInterval = 0.01f;

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
    
    [Konashi addObserver:self selector:@selector(analogValueUpdated) name:KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO0];
    
    // 圧力が低いかどうか
    _isLessPressure = NO;
    
    // LEDのピン
    _rotateCounter = 0;
    _pios = @[@PIO0, @PIO1, @PIO2, @PIO3, @PIO4, @PIO5, @PIO6, @PIO7];
    [Konashi pinMode:PIO0 mode:OUTPUT];
    [Konashi pinMode:PIO1 mode:OUTPUT];
    [Konashi pinMode:PIO2 mode:OUTPUT];
    [Konashi pinMode:PIO3 mode:OUTPUT];
    [Konashi pinMode:PIO4 mode:OUTPUT];
    [Konashi pinMode:PIO5 mode:OUTPUT];
    [Konashi pinMode:PIO6 mode:OUTPUT];
    [Konashi pinMode:PIO7 mode:OUTPUT];
    
    // saveボタン
    if ([self.report isNew]) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveObjects)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    // プログレスダイアログ
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    // webview表示
    NSString *path = [[NSBundle mainBundle] pathForResource:@"chart" ofType:@"html"];
    NSString *htmlText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlText baseURL:[NSURL fileURLWithPath:path]];
    
    // スリープしないようにする
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // 移動する前にLEDタイマーを終了させる
    [_rotateLEDTimer invalidate];
    
    // スリープするように戻す
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendAnalogReadRequest
{
    [Konashi analogReadRequest:AIO0];
}

- (void)analogValueUpdated
{
    NSInteger value = [Konashi analogRead:AIO0];
    
    // 閾値を超えた場合はバイブを動作させる
    if (value > kThreshold && value < kValueWithoutPressure) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        _isLessPressure = YES;
    } else {
        _isLessPressure = NO;
    }
    
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
    [_analogReadTimer invalidate];
    [self.masterViewController reloadReports];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loadPoints
{
    for (Log *log in [self.report sortedLogs]) {
        [self addPoint:[log.voltage floatValue] timestamp:log.timestamp];
    }
}

- (void)rotateLED
{
    if (!_isLessPressure) {
        [Konashi digitalWrite:PIO0 value:LOW];
        [Konashi digitalWrite:PIO1 value:LOW];
        [Konashi digitalWrite:PIO2 value:LOW];
        [Konashi digitalWrite:PIO3 value:LOW];
        [Konashi digitalWrite:PIO4 value:LOW];
        [Konashi digitalWrite:PIO5 value:LOW];
        [Konashi digitalWrite:PIO6 value:LOW];
        [Konashi digitalWrite:PIO7 value:LOW];
        
        return;
    }
    
    _rotateCounter++;
    
    [Konashi digitalWrite:PIO0 value:(_rotateCounter % 3 == 0) ? HIGH : LOW];
    [Konashi digitalWrite:PIO1 value:(_rotateCounter % 3 == 1) ? HIGH : LOW];
    [Konashi digitalWrite:PIO2 value:(_rotateCounter % 3 == 2) ? HIGH : LOW];
    [Konashi digitalWrite:PIO3 value:(_rotateCounter % 3 == 0) ? HIGH : LOW];
    [Konashi digitalWrite:PIO4 value:(_rotateCounter % 3 == 1) ? HIGH : LOW];
    [Konashi digitalWrite:PIO5 value:(_rotateCounter % 3 == 2) ? HIGH : LOW];
    [Konashi digitalWrite:PIO6 value:(_rotateCounter % 3 == 0) ? HIGH : LOW];
    [Konashi digitalWrite:PIO7 value:(_rotateCounter % 3 == 1) ? HIGH : LOW];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    
    if ([self.report isNew]) {
        _analogReadTimer = [NSTimer scheduledTimerWithTimeInterval:kAnalogReadInterval target:self selector:@selector(sendAnalogReadRequest) userInfo:nil repeats:YES];
        _rotateLEDTimer = [NSTimer scheduledTimerWithTimeInterval:kRotateLEDInterval target:self selector:@selector(rotateLED) userInfo:nil repeats:YES];
    } else {
        [self loadPoints];
    }
}

@end
