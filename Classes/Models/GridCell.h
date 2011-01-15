//
//  GridCell.h
//  HarkPad2
//
//  Created by Willem Bison on 12-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GridCell : NSObject {

}

@property int column;
@property int row;
@property int line;

+ (GridCell *) cellWithColumn: (int) column row: (int) row line: (int) line;

@end
