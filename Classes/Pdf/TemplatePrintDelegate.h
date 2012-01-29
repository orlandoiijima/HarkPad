//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


@protocol TemplatePrintDelegate

@required
- (NSString *) stringForVariable: (NSString *)variable;
- (NSString *) stringForVariable: (NSString *)variable inRow: (NSUInteger)row;
- (NSUInteger) countOfRows;
@end