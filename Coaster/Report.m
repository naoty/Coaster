//
//  Report.m
//  Coaster
//
//  Created by naoty on 2013/06/09.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import "Report.h"


@implementation Report

@dynamic timestamp;
@dynamic logs;

- (NSArray *)sortedLogs
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    return [self.logs sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
