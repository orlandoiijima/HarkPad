
#import "OrderLineCell.h"
#import "OrderLine.h"
#import "OrderLinePropertyValue.h"
//#import "OrderViewDetailController.h"
#import "OrderTableView.h"

@implementation OrderLineCell

@synthesize newLineIcon, orderLine, price, name, note, props, seat, course, quantity;

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

+ (OrderLineCell *) cellWithOrderLine: (OrderLine *) line
{
    OrderLineCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderLineCell" owner:self options:nil] lastObject];
    cell.orderLine = line;
    return cell;
}

- (void) setOrderLine : (OrderLine *) line
{
    orderLine = line;
    
    seat.titleLabel.text = [NSString stringWithFormat: @"%d", line.guest.seat + 1];
    NSArray *chars = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F", nil];
    course.titleLabel.text = [chars objectAtIndex:line.course.offset];
    quantity.text = [NSString stringWithFormat:@"%dx", line.quantity];
    if(line.quantity == 1)
    {
        int offset = quantity.frame.origin.x - name.frame.origin.x;
        name.frame = CGRectOffset(name.frame, offset, 0);
        note.frame = CGRectOffset(note.frame, offset, 0);
        quantity.hidden = YES;
    }
    name.text = line.product.key;

    if(line.entityState == New)
    {
        name.font = [UIFont boldSystemFontOfSize:18];
        price.font = [UIFont boldSystemFontOfSize:18];
    }
    else
    {
        newLineIcon.hidden = YES;
    }
    
    if(line.note.length > 0) {
        note.text = line.note;
        name.frame = CGRectOffset(name.frame, 0, -5);
        quantity.frame = CGRectOffset(quantity.frame, 0, -5);
    }
    else
        note.text = @"";
    
    props.text = @"";
    for(OrderLinePropertyValue *propertyValue in line.propertyValues)
    {
        props.text = [NSString stringWithFormat:@"%@ %@", props.text, propertyValue.displayValue];
    }
    price.text = [NSString stringWithFormat:@"%0.2f", [line.product.price doubleValue] * line.quantity];

    self.backgroundColor = [orderLine.product.category.color colorWithAlphaComponent:0.8];
    self.opaque = NO;
}

- (void)dealloc
{
    [super dealloc];
}

@end
