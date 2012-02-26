//
//  Created by wbison on 12-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface OrderDataSourceSection : NSObject {
    BOOL isSelected;
    BOOL isCollapsed;
    NSMutableArray *lines;
}

@property BOOL isSelected;
@property BOOL isCollapsed;
@property (retain) NSMutableArray *lines;

@end