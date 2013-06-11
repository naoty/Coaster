//
//  NSManagedObject+isNew.m
//  Coaster
//
//  Created by naoty on 2013/06/11.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import "NSManagedObject+isNew.h"

@implementation NSManagedObject (isNew)

- (BOOL)isNew
{
    NSDictionary *values = [self committedValuesForKeys:nil];
    return [values count] == 0;
}

@end
