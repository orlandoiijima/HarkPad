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
    NSString *title;
}

@property BOOL isSelected;
@property BOOL isCollapsed;
@property (retain) NSMutableArray *lines;
@property (retain) NSString *subTitle;
@property (retain) NSString *title;
@end