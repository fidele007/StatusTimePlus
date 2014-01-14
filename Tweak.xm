static BOOL STIsEnabled = YES; // Default value
static NSString* STTime = nil;

%hook SBStatusBarStateAggregator

-(void)_updateTimeItems {
  // Do nothing
  %orig;
}

-(void)_restartTimeItemTimer {
  %orig;
  // Hook _timeItemTimer iVar
  NSTimer *newTimer = MSHookIvar<NSTimer *>(self, "_timeItemTimer");
  // Initialise a date in the future to fire the timer (default = 60 secs)
  NSDate *newFireDate = [NSDate dateWithTimeIntervalSinceNow: 1.0];
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
  } else {
    [newDateFormat setDateFormat:@"'nope'"];
  }

}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end

static void loadPrefs()
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lkemitchll.statustime+prefs.plist"];
    if(prefs)
    {
        STIsEnabled = ( [prefs objectForKey:@"STIsEnabled"] ? [[prefs objectForKey:@"STIsEnabled"] boolValue] : STIsEnabled );
        STTime = ( [prefs objectForKey:@"STTime"] ? [prefs objectForKey:@"STTime"] : STTime );
        [STTime retain];
    }
    [prefs release];
}

%ctor 
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.lkemitchll.statustime+prefs/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadPrefs();
}