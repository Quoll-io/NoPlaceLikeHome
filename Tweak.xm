@interface SBHomeGrabberView : UIView
@end

@interface MTLumaDodgePillView : UIView
@end

@interface SpringBoard
@property (retain, nonatomic) UIButton *circleView;
-(void)_handleMenuButtonEvent;
-(void)handleMenuDoubleTap;
-(void)_simulateHomeButtonPress;
-(BOOL)respondsToSelector:(SEL)aSelector;
@end

@interface SBMainSwitcherViewController
+(id)sharedInstance;
-(BOOL)toggleSwitcherNoninteractivelyWithSource:(long long)arg1;
@end

%hook SBHomeGrabberView
-(void)layoutSubviews {
  %orig;

  MTLumaDodgePillView *pillView = [self valueForKey:@"_pillView"];
  [pillView removeFromSuperview];
  pillView.alpha = 0;
  pillView.hidden = TRUE;

  self.userInteractionEnabled = TRUE;
  self.superview.userInteractionEnabled = TRUE;
}
%end


%hook SpringBoard
%property (retain, nonatomic) UIButton *circleView;
- (void)applicationDidFinishLaunching:(UIApplication *)arg1
{
      CGRect screenBounds = [UIScreen mainScreen].bounds;

      UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - (75/2), screenBounds.size.height - 100, 75, 75)];

      // If I wanted to match the top cut out I could do this:
      //UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - (200/2), screenBounds.size.height - 30, 200, 150)];

      window.backgroundColor = [UIColor clearColor];
      window.windowLevel = UIWindowLevelAlert-10;
      [window setHidden:NO];
      window.userInteractionEnabled = YES;

      if(!self.circleView){

        self.circleView = [[UIButton alloc] initWithFrame:window.bounds];
        self.circleView.alpha = 1;
        self.circleView.layer.cornerRadius = (75/2);  // half the width/height
        self.circleView.backgroundColor = [UIColor blackColor];

        UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(pressTheButton)];
        UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(pressTheButtonTwice)];
        UITapGestureRecognizer *tapTrice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(pressTheButtonThrice)];

        tapOnce.numberOfTapsRequired = 1;
        tapTwice.numberOfTapsRequired = 2;
        tapTrice.numberOfTapsRequired = 3;

        //stops tapOnce from overriding tapTwice
        [tapOnce requireGestureRecognizerToFail:tapTwice];
        [tapTwice requireGestureRecognizerToFail:tapTrice];

        //then need to add the gesture recogniser to a view - this will be the view that recognises the gesture
        [self.circleView addGestureRecognizer:tapOnce]; //remove the other button action which calls method `button`
        [self.circleView addGestureRecognizer:tapTwice];
        [self.circleView addGestureRecognizer:tapTrice];

        self.circleView.layer.borderColor = [UIColor grayColor].CGColor;
        self.circleView.layer.borderWidth = 3.0f;

        [window addSubview:self.circleView];
      }

      %orig;
}
%new
-(void)pressTheButton {
  if ([(SpringBoard *)[%c(UIApplication) sharedApplication] respondsToSelector:@selector(_handleMenuButtonEvent)]) {
    [(SpringBoard *)[%c(UIApplication) sharedApplication] _handleMenuButtonEvent];
  } else {
    [(SpringBoard *)[%c(UIApplication) sharedApplication] _simulateHomeButtonPress];
  }
}
%new
-(void)pressTheButtonTwice {
  [[%c(SBMainSwitcherViewController) sharedInstance] toggleSwitcherNoninteractivelyWithSource:nil];
}
%new
-(void)pressTheButtonThrice {
  [[%c(SBMainSwitcherViewController) sharedInstance] toggleSwitcherNoninteractivelyWithSource:nil];
}
%end

%hook SBHomeGestureSettings
-(BOOL)isHomeGestureEnabled {
  return FALSE;
}
%end
