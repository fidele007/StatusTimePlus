#import <SpringBoard/SpringBoard.h>

/* 
Credits:
- https://github.com/kirbylover4000/ThatSameHack
- https://github.com/r-plus/CloakStatus
- https://github.com/YuzuruS/clockStatus/blob/master/Tweak.xm
- https://github.com/daniel-nagy/CustomCarrier
- /u/miktr
- /u/thekirbylover
*/

@class SBStatusBarStateAggregator;
@interface SBStatusBarStateAggregator : NSObject{
}        
+ (id)sharedInstance;
- (void)_updateTimeItems;
- (void)_resetTimeItemFormatter;
- (void)_restartTimeItemTimer;
- (void)updateStatusBarItem:(int)arg1;
@end 

// Setup required variables
static BOOL STIsEnabled = YES; // Default value
static NSString* STTime = nil;

%hook SBStatusBarStateAggregator

-(void)_restartTimeItemTimer {
  %orig;
  // Hook _timeItemTimer iVar
  NSTimer *newTimer = MSHookIvar<NSTimer *>(self, "_timeItemTimer");
  // Initialise a date in the future to fire the timer (default = 60 secs)
  NSDate *newFireDate = [NSDate dateWithTimeIntervalSinceNow: 60.0];
  // Set fire date
  [newTimer setFireDate:newFireDate];
}

-(void)_resetTimeItemFormatter {
  %orig;
  // Hook _timeItemDateFormatter iVar
  NSDateFormatter *newDateFormat = MSHookIvar<NSDateFormatter *>(self, "_timeItemDateFormatter");
  // set new clock format if ST is enabled
  if(STTime && STIsEnabled)
  {
    [newDateFormat setDateFormat:STTime];
    NSLog(@"StatusTime+: Date format set");
  } else {
    [newDateFormat setDateFormat:@"hh:mm"]; // Default value
    NSLog(@"StatusTime+: INFO: Disabled or no prefs, default value set");
  }
}
// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end

// Function to update the clock after save
static void STUpdateClock()
{
  // Create an object of SBStatusBarStateAggregator
  id stateAggregator = [%c(SBStatusBarStateAggregator) sharedInstance];
  // Send messages to new object
  [stateAggregator _updateTimeItems];
  [stateAggregator _resetTimeItemFormatter];
  [stateAggregator updateStatusBarItem:0];
  NSLog(@"StatusTime+: Clock updated");
}

// Function to load saved preferences
static void STLoadPrefs()
{
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lkemitchll.statustime+prefs.plist"];
  if(prefs)
  {
    // Set variables based on prefs
    STIsEnabled = ( [prefs objectForKey:@"STIsEnabled"] ? [[prefs objectForKey:@"STIsEnabled"] boolValue] : STIsEnabled );
    STTime = ( [prefs objectForKey:@"STTime"] ? [prefs objectForKey:@"STTime"] : STTime );
    [STTime retain];
    // Initiate clock updat for good measure
    STUpdateClock();
  }
  [prefs release];
}

%ctor 
{
  @autoreleasepool {

    // Listen for new settings changes
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
      NULL, 
      (CFNotificationCallback)STLoadPrefs, 
      CFSTR("com.lkemitchll.statustime+prefs/STSettingsChanged"), 
      NULL, 
      CFNotificationSuspensionBehaviorCoalesce);

    // Listen for update ('save') message
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
      NULL, 
      (CFNotificationCallback)STUpdateClock, 
      CFSTR("com.lkemitchll.statustime+prefs/STUpdate"),
      NULL, 
      0);

    STLoadPrefs();
  }
}