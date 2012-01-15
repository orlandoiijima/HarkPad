//
//  CellPath.m
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "CellPath.h"


@implementation CellPath

@synthesize row, column, line;

- (id)init
{
    self = [super init];
    self.row = 0;
    self.column = 0;
    self.line =0;
    return self;
}

+ (CellPath *)pathForColumn: (int)column row : (int)row line: (int) line
{
    CellPath *path = [[CellPath alloc] init];
    path.column = column;
    path.row = row;
    path.line = line;
    return path;
}

+ (CellPath *)pathWithPath: (CellPath *)fromPath
{
    return [CellPath pathForColumn: fromPath.column row:fromPath.row line:fromPath.line];    
}

- (BOOL) isEqualTo: (CellPath *)path
{
    return [self compare:path] == NSOrderedSame;
}

- (NSComparisonResult) compare: (CellPath *)path
{
    if (self.row > path.row)
        return NSOrderedDescending;
    if (self.row < path.row)
        return NSOrderedAscending;
    if (self.column > path.column)
        return NSOrderedDescending;
    else
        if (self.column == path.column)
            return NSOrderedSame;
        else
            return NSOrderedAscending;
}

@end
