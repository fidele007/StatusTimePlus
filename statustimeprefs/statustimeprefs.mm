#import <Preferences/Preferences.h>
#import <Foundation/NSTask.h>

@interface statustimeprefsListController: PSListController {
}
@end

@implementation statustimeprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"statustimeprefs" target:self] retain];
	}
	return _specifiers;
}

-(void)save
{
    [self.view endEditing:YES];

    NSTask *restartSpringboard = [NSTask new];
    NSMutableArray *restartSpringboardArgs = [[NSMutableArray alloc] initWithCapacity:5];

    [restartSpringboardArgs addObject: [NSString @"-9"]];
    [restartSpringboardArgs addObject: [NSString @"SpringBoard"]];

    restartSpringboard = [NSTask launchedTaskWithLaunchPath: @"/usr/bin/killall" arguments: restartSpringboardArgs];
    [restartSpringboard launch];
}
@end

// vim:ft=objc
