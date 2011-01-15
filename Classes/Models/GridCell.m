//
//  GridCell.m
//  HarkPad2
//
//  Created by Willem Bison on 12-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "GridCell.h"


@implementation GridCell

@synthesize column, row, line;

+ (GridCell *) cellWithColumn: (int) column row: (int) row line: (int) line
{
    GridCell *cell = [[GridCell alloc] init];
    cell.row = row;
    cell.column = column;
    cell.line = line;
    return cell;
}
@end
