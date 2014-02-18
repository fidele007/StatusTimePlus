#import <SpringBoard/SpringBoard.h>
#import <Foundation/NSHost.h>
#import <mach/mach.h>
#import <mach/mach_host.h>

/*
Credits:
- https://github.com/kirbylover4000/ThatSameHack
- https://github.com/r-plus/CloakStatus
- https://github.com/YuzuruS/clockStatus/blob/master/Tweak.xm
- https://github.com/daniel-nagy/CustomCarrier
- http://stackoverflow.com/questions/15318528/how-to-use-the-value-in-pslinklistcell-in-preference-bundle
- http://stackoverflow.com/a/15493211/2819263
- http://forum.openframeworks.cc/t/new-method-for-know-free-memory-in-ios-answer-myself/7451
- /u/miktr
- /u/thekirbylover
*/

@class SBStatusBarStateAggregator;
@interface SBStatusBarStateAggregator : NSObject
+ (id)sharedInstance;
- (void)_updateTimeItems;
- (void)_resetTimeItemFormatter;
- (void)_restartTimeItemTimerRAM;
- (void)updateStatusBarItem:(int)arg1;
@end

// Setup required variables
static NSString *STTime      = nil;
static BOOL STIsEnabled      = YES;    // Default value
static BOOL STShowOnLock     = false;  // Default value
static BOOL STShowFreeMemory = false;  // Default value
static BOOL STShowIPAddress  = false;  // Default value
static NSInteger STInterval  = 60;     // Default value
static NSTimer *timerRAM;
static NSTimer *timerIP;

/* GET THE FREE MEMORY OF THE SYSTEM */
static NSNumber *STGetSystemRAM()
{
  @autoreleasepool{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;

    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    vm_statistics_data_t vm_stat;
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
      NSLog(@"StatusTime+: Failed to fetch vm statistics");

    natural_t mem_free = vm_stat.free_count * pagesize;

    NSNumber *freeMemory = [NSNumber numberWithUnsignedInt:round((mem_free / 1024) / 1024)];

    return freeMemory;
  }
}

/* GET THE LOCAL IP ADDRESS OF THE SYSTEM */
static NSString *STGetSystemIPAddress()
{
  @autoreleasepool{
    NSString *ipString = [[NSString init] alloc];

    NSHost *host = [NSHost currentHost];

    if (host) {
      ipString = [host address];
    } else {
      ipString = @"No IP Found";
    }

    return ipString;
  }
}

/* FUNCTION TO FORMAT THE TIME STRING AND START RAM TIMER */
static inline void STSetStatusBarTimeWithRAM(id self)
{
  @autoreleasepool{
    if(!self) {
      self = [%c(SBStatusBarStateAggregator) sharedInstance];
    }

    NSDateFormatter *dateFormat;
    object_getInstanceVariable(self, "_timeItemDateFormatter", (void**)&dateFormat);

    NSString *STTimeWithRAM = [STTime stringByAppendingFormat:@" 'R:' %@", STGetSystemRAM()];

    [dateFormat setDateFormat:STTimeWithRAM];
    [self _updateTimeItems];
  }
}

/* FUNCTION TO FORMAT THE TIME STRING AND START IP ADDRESS TIMER */
static inline void STSetStatusBarTimeWithIPAddress(id self)
{
  @autoreleasepool{
    if(!self) {
      self = [%c(SBStatusBarStateAggregator) sharedInstance];
    }

    NSDateFormatter *dateFormat;
    object_getInstanceVariable(self, "_timeItemDateFormatter", (void**)&dateFormat);

    NSString *STTimeWithIPAddress = [STTime stringByAppendingFormat:@" %@", STGetSystemIPAddress()];

    [dateFormat setDateFormat:STTimeWithIPAddress];
    [self _updateTimeItems];
  }
}

%hook SBStatusBarStateAggregator

/* SET THE REFRESH RATE */
-(void)_restartTimeItemTimerRAM
{
  %orig;
  // Set refresh rate if ST is enabled
  if(STInterval && STIsEnabled)
  {
    if(STInterval != 60){
      // Hook _timeItemTimer iVar
      NSTimer *newTimer = MSHookIvar<NSTimer *>(self, "_timeItemtimerRAM");
      // Initialise a date in the future to fire the timer (default = 60 secs)
      NSDate *newFireDate = [NSDate dateWithTimeIntervalSinceNow: (double)STInterval];
      // Set fire date
      [newTimer setFireDate:newFireDate];
    } else {
      %orig;
    }
  } else {
    %orig;
    NSLog(@"StatusTime+: INFO: Disabled or no prefs, default refresh rate set");
  }
}

/* SET THE TIME FORMAT */
- (void)_resetTimeItemFormatter
{
  %orig;
  // Hook _timeItemDateFormatter iVar
  NSDateFormatter *dateFormat = MSHookIvar<NSDateFormatter *>(self, "_timeItemDateFormatter");

  if(STIsEnabled)
  {
    if(STShowFreeMemory)
    {
      STSetStatusBarTimeWithRAM(self);
      if(!timerRAM){
        timerRAM = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(updateTimeMemoryString) userInfo:nil repeats:YES];
      }
    } else if(STShowIPAddress) {
      STSetStatusBarTimeWithIPAddress(self);
      if(!timerIP){
        timerIP = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(updateTimeIPAddressString) userInfo:nil repeats:YES];
      }
    } else {
      [dateFormat setDateFormat:STTime];
      if(timerRAM) {
        [timerRAM invalidate];
        timerRAM = nil;
      }
      if(timerIP) {
        [timerIP invalidate];
        timerIP = nil;
      }
    }
  } else {
    [dateFormat setDateFormat:@"H:mm a"];
    if(timerRAM) {
      [timerRAM invalidate];
      timerRAM = nil;
    }
    if(timerIP) {
      [timerIP invalidate];
      timerIP = nil;
    }
  }
}

/* HELPER FOR MEMORY */
%new(v@:)
- (void)updateTimeMemoryString
{
  STSetStatusBarTimeWithRAM(self);
}

/* HELPER FOR IP ADDRESS */
%new(v@:)
- (void)updateTimeIPAddressString
{
  STSetStatusBarTimeWithIPAddress(self);
}

// END HOOKING
%end

/* DISABLE TOP GRABBER ON LOCKSCREEN IF ENABLED */
%hook SBLockScreenView
-(float)_topGrabberYOriginForPercentScrolled:(float)arg1 
{
  %orig;
  if(STShowOnLock && STIsEnabled){
    NSNumber *grabberPosition = [NSNumber numberWithFloat:-12];
    return [grabberPosition floatValue];
  } else {
    return %orig;
  }
}
// END HOOKING
%end

%hook SBLockScreenViewController

/* SHOW CLOCK ON LOCKSCREEN */
-(bool)shouldShowLockStatusBarTime
{
  %orig;
  // Show on lockscreen if ST is enabled
  if(STShowOnLock && STIsEnabled){
    return STShowOnLock;
  } else {
    return %orig;
  }
}
// END HOOKING
%end

/* UPDATE THE CLOCK AFTER SAVE */
static void STUpdateClock()
{
  @autoreleasepool {
    // Create an object of SBStatusBarStateAggregator
    id stateAggregator = [%c(SBStatusBarStateAggregator) sharedInstance];
    // Send messages to new object
    [stateAggregator _resetTimeItemFormatter];
    [stateAggregator _updateTimeItems];
    [stateAggregator updateStatusBarItem: 0];
  }
}

/* LOAD PREFERENCES */
static void STLoadPrefs()
{
  @autoreleasepool {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lkemitchll.statustime+prefs.plist"];
    if(prefs)
    {
      // Set variables based on prefs
      STIsEnabled = ( [prefs objectForKey:@"STIsEnabled"] ? [[prefs objectForKey:@"STIsEnabled"] boolValue] : STIsEnabled );
      STShowOnLock = ( [prefs objectForKey:@"STShowOnLock"] ? [[prefs objectForKey:@"STShowOnLock"] boolValue] : STShowOnLock );
      STShowFreeMemory = ( [prefs objectForKey:@"STShowFreeMemory"] ? [[prefs objectForKey:@"STShowFreeMemory"] boolValue] : STShowFreeMemory );
      STShowIPAddress = ( [prefs objectForKey:@"STShowIPAddress"] ? [[prefs objectForKey:@"STShowIPAddress"] boolValue] : STShowIPAddress );
      STTime = ( [prefs objectForKey:@"STTime"] ? [prefs objectForKey:@"STTime"] : STTime );
      STInterval = ([prefs objectForKey:@"STTime"] ? [[prefs objectForKey:@"STRefresh"] integerValue] : STInterval);

      STUpdateClock();

      // Debug
      //for(NSString *key in [prefs allKeys]) {
      //  NSLog(@"StatusTime+: %@ = %@", key, [prefs objectForKey:key]);
      //}
    }
  }
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
    // Listen for Save button push
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
      NULL,
      (CFNotificationCallback)STUpdateClock,
      CFSTR("com.lkemitchll.statustime+prefs/STSave"),
      NULL,
      CFNotificationSuspensionBehaviorCoalesce);

    STLoadPrefs();
    STUpdateClock();
  }
}
