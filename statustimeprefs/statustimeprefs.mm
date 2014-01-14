#import <Preferences/Preferences.h>

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
@end

// vim:ft=objc
