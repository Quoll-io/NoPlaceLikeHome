// Created by LaughingQuoll on 12th of September 2017.
// 4 hours after Apple announced the iPhone X.

@interface SBHomeGrabberView : UIView
@end

@interface MTLumaDodgePillView : UIView
@end

@interface SpringBoard
@property (retain, nonatomic) UIWindow *homeButtonWindow;
@property (retain, nonatomic) UIButton *homeButtonView;
-(void)_handleMenuButtonEvent;
-(void)handleMenuDoubleTap;
-(void)_simulateHomeButtonPress;
-(BOOL)respondsToSelector:(SEL)aSelector;
@end

@interface SBMainSwitcherViewController
+(id)sharedInstance;
-(BOOL)toggleSwitcherNoninteractivelyWithSource:(long long)arg1;
@end

@interface SBDockView : UIView
@end

%hook SBHomeGrabberView
-(void)layoutSubviews {
  %orig;

  // Remove the ugly home button line.
  MTLumaDodgePillView *pillView = [self valueForKey:@"_pillView"];
  [pillView removeFromSuperview];
  pillView.alpha = 0;
  pillView.hidden = TRUE;

}
%end


%hook SpringBoard
%property (retain, nonatomic) UIWindow *homeButtonWindow;
%property (retain, nonatomic) UIButton *homeButtonView;
- (void)applicationDidFinishLaunching:(UIApplication *)arg1
{
      CGRect screenBounds = [UIScreen mainScreen].bounds;

      // If I wanted to match the a normal home button:
      //self.homeButtonWindow = [[UIWindow alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - (75/2), screenBounds.size.height - 100, 75, 75)];

      // But I like the matching notch.
      self.homeButtonWindow = [[UIWindow alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - (200/2), screenBounds.size.height - 30, 200, 150)];

      self.homeButtonWindow.backgroundColor = [UIColor clearColor];
      self.homeButtonWindow.windowLevel = UIWindowLevelAlert-10;
      [self.homeButtonWindow setHidden:NO];
      self.homeButtonWindow.userInteractionEnabled = YES;

      if(!self.homeButtonView){

        self.homeButtonView = [[UIButton alloc] initWithFrame:self.homeButtonWindow.bounds];
        self.homeButtonView.alpha = 1;
        self.homeButtonView.layer.cornerRadius = (75/3);
        self.homeButtonView.backgroundColor = [UIColor blackColor];

        UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(pressTheButton)];
        UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(pressTheButtonTwice)];
        UITapGestureRecognizer *tapTrice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(pressTheButtonThrice)];

        tapOnce.numberOfTapsRequired = 1;
        tapTwice.numberOfTapsRequired = 2;
        tapTrice.numberOfTapsRequired = 3;

        [tapOnce requireGestureRecognizerToFail:tapTwice];
        [tapTwice requireGestureRecognizerToFail:tapTrice];

        [self.homeButtonView addGestureRecognizer:tapOnce];
        [self.homeButtonView addGestureRecognizer:tapTwice];
        [self.homeButtonView addGestureRecognizer:tapTrice];

        // Only for the button view will we uncomment these.
        //self.homeButtonView.layer.borderColor = [UIColor grayColor].CGColor;
        //self.homeButtonView.layer.borderWidth = 3.0f;

        [self.homeButtonWindow addSubview:self.homeButtonView];
      }

      %orig;
}
%new
-(void)pressTheButton {
  // Good ol' home button.
  if ([(SpringBoard *)[%c(UIApplication) sharedApplication] respondsToSelector:@selector(_handleMenuButtonEvent)]) {
    [(SpringBoard *)[%c(UIApplication) sharedApplication] _handleMenuButtonEvent];
  } else {
    [(SpringBoard *)[%c(UIApplication) sharedApplication] _simulateHomeButtonPress];
  }
}
%new
-(void)pressTheButtonTwice {
  // Toggle app switcher, we don't just want to activate it because the button is still there when app switcher is open.
  [[%c(SBMainSwitcherViewController) sharedInstance] toggleSwitcherNoninteractivelyWithSource:nil];
}
%new
-(void)pressTheButtonThrice {
  // At some point I'll make this toggle the accessability shortcut.
}
%end

// Disable the homescreen swipe up gesture.
// Hacking this bool actually fixes the gestures for us as well so the CC and NC are normal.
// And also it doesnt break the bottom swipe between app feature.
// Setting this to TRUE on a non-x device will make the gestures work like the iPhone X.
%hook SBHomeGestureSettings
-(BOOL)isHomeGestureEnabled {
  return FALSE;
}
%end

// Hard setting values like this isn't the best, but seeing we're only dealing with one device it is ok.
// The code below fixes the docks position into a spot that it isn't hindered by the notch button.
%hook SBDockView
-(void)layoutSubviews{
  %orig;

  // This catches the first frame setting.
  CGRect screenBounds = [UIScreen mainScreen].bounds;
  self.frame = CGRectMake(self.frame.origin.x, screenBounds.size.height - self.frame.size.height - 30, self.frame.size.width, self.frame.size.height);
}
-(void)setFrame:(CGRect)frame {

  // This catches the rest of them.
  CGRect screenBounds = [UIScreen mainScreen].bounds;
  frame.origin.y = screenBounds.size.height - frame.size.height - 30;
  %orig(frame);
}
%end
