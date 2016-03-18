//
//  UILabel+WhiteUIDatePickerLabels.m
//  GoIbibo
//
//  Created by Vijay on 18/03/16.
//  Copyright © 2016 Vijay. All rights reserved.
//

#import "UILabel+WhiteUIDatePickerLabels.h"
#import <objc/runtime.h>


@implementation UILabel (WhiteUIDatePickerLabels)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceSelector:@selector(setFont:)
                      withNewSelector:@selector(swizzledSetFont:)];
        
    });
}

// Forces the text colour of the lable to be white only for UIDatePicker and its components
-(void) swizzledSetFont:(UIFont *)font {
    if([self view:self hasSuperviewOfClass:[UIDatePicker class]] ||
       [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerWeekMonthDayView")] ||
       [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerContentView")]){
        [self swizzledSetFont:[UIFont fontWithName:@"Helvetica" size:17]];
    } else {
        //Carry on with the default
        [self swizzledSetFont:font];
    }
}

// -- helpers --
- (BOOL) view:(UIView *) view hasSuperviewOfClass:(Class) class {
    if(view.superview){
        if ([view.superview isKindOfClass:class]){
            return true;
        }
        return [self view:view.superview hasSuperviewOfClass:class];
    }
    return false;
}

+ (void) swizzleInstanceSelector:(SEL)originalSelector
                 withNewSelector:(SEL)newSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    BOOL methodAdded = class_addMethod([self class],
                                       originalSelector,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));
    
    if (methodAdded) {
        class_replaceMethod([self class],
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}
@end
