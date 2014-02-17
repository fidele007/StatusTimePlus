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
  // Send notification to STUpdateClock function
  notify_post("com.lkemitchll.statustime+prefs/STUpdate");
  notify_post("com.lkemitchll.statustime+prefs/STSettingsChanged");
}

- (void)STFormatGuide {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://146.185.180.252/statustime/"]];
}

- (void)STDonate {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=XFRCAVRLSTY4L"]];
}

- (void)STSource {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/LkeMitchll/StatusTimePlus"]];
}

@end
