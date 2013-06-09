//
//  DetailViewController.m
//  Coaster
//
//  Created by naoty on 2013/06/09.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import "DetailViewController.h"
#import "Konashi.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

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
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sendAnalogReadRequest) userInfo:nil repeats:YES];
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
    NSLog(@"FSR: %d", [Konashi analogRead:AIO2]);
}

@end
