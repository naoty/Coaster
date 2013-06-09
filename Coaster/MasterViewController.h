//
//  MasterViewController.h
//  Coaster
//
//  Created by naoty on 2013/06/09.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface MasterViewController : UITableViewController
{
    AppDelegate *_appDelegate;
    NSMutableArray *_reports;
    NSDateFormatter *_dateFormatter;
}

- (void)reloadReports;

@end
