
%hook SBStatusBarStateAggregator

-(void)_updateTimeItems {
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

  // set new clock format
  [newDateFormat setDateFormat:@"hh:mm:ss - E dd"];

}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
