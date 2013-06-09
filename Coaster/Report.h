//
//  Report.h
//  Coaster
//
//  Created by naoty on 2013/06/09.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Report : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *logs;
@end

@interface Report (CoreDataGeneratedAccessors)

- (void)addLogsObject:(NSManagedObject *)value;
- (void)removeLogsObject:(NSManagedObject *)value;
- (void)addLogs:(NSSet *)values;
- (void)removeLogs:(NSSet *)values;

@end
