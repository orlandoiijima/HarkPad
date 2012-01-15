//
//  CellPath.h
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellPath : NSObject {
    int column;
    int row;
    int line;
}

@property int column;
@property int row;
@property int line;

+ (CellPath *)pathForColumn: (int)column row : (int)row line: (int) line;
+ (CellPath *)pathWithPath: (CellPath *)fromPath;
- (BOOL) isEqualTo: (CellPath *)path;
- (NSComparisonResult) compare: (CellPath *)path;

@end
