//
//  Created by wbison on 28-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "GuestProperties.h"
#import "SeatView.h"
#import "ToggleButton.h"
#import "UIImage+Tint.h"

@implementation GuestProperties {
}

@synthesize guest = _guest, delegate = _delegate, viewFemale, viewMale;

+ (GuestProperties *)viewWithGuest: (Guest *)guest frame: (CGRect)frame
{
    GuestProperties *view = [[GuestProperties alloc] initWithFrame:frame];

    view.guest = guest;
    
    UIImage *maleImage = [[UIImage imageNamed:@"user.png"] imageTintedWithColor: [UIColor blueColor]];
    view.viewMale = [ToggleButton buttonWithTitle:NSLocalizedString(@"Male", nil) image: maleImage frame:CGRectMake(10, 10, 0, 0)];
    view.viewMale.isOn = guest.isMale;
    [view.viewMale addTarget:view action:@selector(tapGender:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:view.viewMale];

    UIImage *femaleImage = [[UIImage imageNamed:@"user.png"] imageTintedWithColor: [UIColor colorWithRed:1.0 green:105/255.0 blue:180/255.0 alpha:1]];
    view.viewFemale = [ToggleButton buttonWithTitle:NSLocalizedString(@"Female", nil) image: femaleImage frame:CGRectMake(10 + view.viewMale.bounds.size.width + 10, 10, 0, 0)];
    view.viewFemale.isOn = guest.isMale == NO;
    [view.viewFemale addTarget:view action:@selector(tapGender:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:view.viewFemale];

    ToggleButton *isHostView  = [ToggleButton buttonWithTitle:NSLocalizedString(@"Host", nil) image:[UIImage imageNamed:@"BlueStar.png"] frame:CGRectMake(10, 50, 0, 0)];
    isHostView.isOn = guest.isHost;
    [isHostView addTarget:view action:@selector(tapHost:) forControlEvents:UIControlEventTouchDown];
    [view addSubview: isHostView];

    NSArray *diets = [NSArray arrayWithObjects:
        NSLocalizedString(@"Gluten allergy", nil),
        NSLocalizedString(@"Nut allergy", nil),
        NSLocalizedString(@"Lactose intolerance", nil),
        NSLocalizedString(@"Milk allergy", nil),
        NSLocalizedString(@"Halal", nil),
        NSLocalizedString(@"Kosher", nil),
        NSLocalizedString(@"Montignac", nil),
        NSLocalizedString(@"No meat", nil),
        NSLocalizedString(@"No fish", nil),
        NSLocalizedString(@"Salt free", nil),
        nil];
    int i = 0;
    for(NSString *diet in diets) {
        ToggleButton *toggle = [ToggleButton buttonWithTitle:NSLocalizedString([diets objectAtIndex:i], nil) image: [UIImage imageNamed:@"errorRedDot.png"] frame:CGRectZero];
        [toggle addTarget:view action:@selector(tapDiet:) forControlEvents:UIControlEventTouchDown];
        [view addSubview:toggle];
        toggle.tag = 1 << i;
        i++;
    }
    return view;
}

- (void) layoutSubviews {
    CGFloat x = 10,y = 90;
    int firstAtLine = 0;
    for(int i = 0; i < 10; i++) {
        ToggleButton *toggle = (ToggleButton *) [self viewWithTag: 1 << i];
        if (toggle == nil) break;
        if (x + toggle.bounds.size.width + 10 > self.bounds.size.width) {
            CGFloat extraSpace = (self.bounds.size.width - x) / (i - firstAtLine );
            x = 10;
            for(int j = firstAtLine; j < i; j++) {
                ToggleButton *toggle = (ToggleButton *)[self viewWithTag: 1 << j];
                toggle.frame = CGRectMake(x, y, toggle.bounds.size.width + extraSpace, toggle.bounds.size.height);
                x += toggle.frame.size.width + 10;
            }
            x = 10;
            y += toggle.bounds.size.height + 5;
            firstAtLine = i;
        }
        toggle.frame = CGRectMake(x, y, toggle.bounds.size.width, toggle.bounds.size.height);
        x += toggle.bounds.size.width + 10;
    }
}

- (void) tapDiet:(id) sender
{
    ToggleButton *toggleButton = (ToggleButton *)sender;
    if (toggleButton == nil) return;
    if (toggleButton.isOn)
        _guest.diet |= toggleButton.tag;
    else
        _guest.diet &= ~toggleButton.tag;

    if([self.delegate respondsToSelector:@selector(didModifyItem:)])
        [self.delegate didModifyItem:_guest];
}

- (void) tapGender: (id)sender {
    ToggleButton *seatView = (ToggleButton *)sender;
    if (seatView == nil) return;
    ToggleButton *other = seatView == viewFemale ? viewMale : viewFemale;
    other.isOn = seatView.isOn == NO;
    _guest.isMale = viewMale.isOn;

    if([self.delegate respondsToSelector:@selector(didModifyItem:)])
        [self.delegate didModifyItem:_guest];
}

- (void) tapHost: (id)sender {
    ToggleButton *isHostView = (ToggleButton *)sender;
    _guest.isHost = isHostView.isOn;

    if([self.delegate respondsToSelector:@selector(didModifyItem:)])
        [self.delegate didModifyItem:_guest];
}

@end