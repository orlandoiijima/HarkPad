//
//  Created by wbison on 12-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "OrderDataSourceSection.h"


@implementation OrderDataSourceSection {

}

@synthesize isCollapsed, isSelected, lines, subTitle, title;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.lines = [[NSMutableArray alloc] init];
        self.isSelected = NO;
        self.isCollapsed = NO;
        self.subTitle = @"";
        self.title = @"";
	}
    return(self);
}

@end