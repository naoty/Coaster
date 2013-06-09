//
//  Log.h
//  Coaster
//
//  Created by naoty on 2013/06/09.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Report;

@interface Log : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSDecimalNumber * voltage;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) Report *Report;

@end
