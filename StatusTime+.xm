#import <SpringBoard/SpringBoard.h>

/* 
Credits:
- https://github.com/kirbylover4000/ThatSameHack
- https://github.com/r-plus/CloakStatus
- https://github.com/YuzuruS/clockStatus/blob/master/Tweak.xm
- https://github.com/daniel-nagy/CustomCarrier
- http://stackoverflow.com/questions/15318528/how-to-use-the-value-in-pslinklistcell-in-preference-bundle
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
static NSString *STTime       = nil;
static BOOL STIsEnabled       = YES;    // Default value
static BOOL STShowOnLock      = false;   // Default value
static NSInteger STInterval   = 60;     // Default value

%hook SBStatusBarStateAggregator

/* SET THE REFRESH RATE */
-(void)_restartTimeItemTimer {
  %orig;
  // set refresh rate if ST is enabled
  if(STInterval && STIsEnabled)
  {
    // Hook _timeItemTimer iVar
    NSTimer *newTimer = MSHookIvar<NSTimer *>(self, "_timeItemTimer");
    // Initialise a date in the future to fire the timer (default = 60 secs)
    NSDate *newFireDate = [NSDate dateWithTimeIntervalSinceNow: (double)STInterval];
    // Set fire date
    [newTimer setFireDate:newFireDate];
  } else {
    %orig;
    NSLog(@"StatusTime+: INFO: Disabled or no prefs, deafult refresh rate set");
  }
}

/* FORMAT THE TIME STRING */
-(void)_resetTimeItemFormatter {
  %orig;
  // Hook _timeItemDateFormatter iVar
  NSDateFormatter *newDateFormat = MSHookIvar<NSDateFormatter *>(self, "_timeItemDateFormatter");
  // set new clock format if ST is enabled
  if(STTime && STIsEnabled)
  {
    [newDateFormat setDateFormat:STTime];
  } else {
    [newDateFormat setDateFormat: @"hh:mm a"];
    NSLog(@"StatusTime+: INFO: Disabled or no prefs, default format set");
  }
}
// END HOOKING
%end

%hook SBLockScreenViewController

/* SHOW CLOCK ON LOCKSCREEN */
-(bool)shouldShowLockStatusBarTime { 
  %orig;
  return STShowOnLock;
}
// END HOOKING
%end

/* UPDATE THE CLOCK AFTER SAVE */
static void STUpdateClock()
{
  // Create an object of SBStatusBarStateAggregator
  id stateAggregator = [%c(SBStatusBarStateAggregator) sharedInstance];
  // Send messages to new object
  [stateAggregator _updateTimeItems];
  [stateAggregator _resetTimeItemFormatter];
  [stateAggregator updateStatusBarItem: 0];
}

/* LOAD PREFERENCES */
static void STLoadPrefs()
{
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lkemitchll.statustime+prefs.plist"];
  if(prefs)
  {
    // Set variables based on prefs
    STIsEnabled = ( [prefs objectForKey:@"STIsEnabled"] ? [[prefs objectForKey:@"STIsEnabled"] boolValue] : STIsEnabled ); 
    STShowOnLock = ( [prefs objectForKey:@"STShowOnLock"] ? [[prefs objectForKey:@"STShowOnLock"] boolValue] : STShowOnLock );
    STTime = ( [prefs objectForKey:@"STTime"] ? [prefs objectForKey:@"STTime"] : STTime );
    STInterval = ([prefs objectForKey:@"STTime"] ? [[prefs objectForKey:@"STRefresh"] integerValue] : STInterval);
    [STTime retain];
    // Initiate clock update for good measure
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