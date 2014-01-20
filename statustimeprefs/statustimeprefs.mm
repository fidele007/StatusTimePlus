#import <Preferences/Preferences.h>
#import <notify.h>

@interface statustimeprefsListController: PSListController
@end

@implementation statustimeprefsListController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"statustimeprefs" target:self] retain];
	}
	return _specifiers;
}

- (void)STSave {

  // Dismiss keyboard
  [self.view endEditing:YES];
  // Send notification to respring function
  notify_post("com.lkemitchll.statustime+prefs/STUpdate");

}

@end