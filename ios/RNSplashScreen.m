/**
 * SplashScreen
 * 启动屏
 * from：http://www.devio.org
 * Author:CrazyCodeBoy
 * GitHub:https://github.com/crazycodeboy
 * Email:crazycodeboy@gmail.com
 */

#import "RNSplashScreen.h"
#import <React/RCTBridge.h>

static bool waiting = true;
static bool isAnimationFinished = false;
static bool addedJsLoadErrorObserver = false;
static UIView* loadingView = nil;

@implementation RNSplashScreen
- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE(SplashScreen)

+ (void)show {
  if (!addedJsLoadErrorObserver) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsLoadError:)
                                                 name:RCTJavaScriptDidFailToLoadNotification
                                               object:nil];
    addedJsLoadErrorObserver = true;
  }

  while (waiting) {
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    [self showSplash:@"Splash" inRootView:rootView];
  }
}

+ (void)showSplash:(NSString*)splashScreen inRootView:(UIView*)rootView {
  if (!loadingView) {
    loadingView = [[[NSBundle mainBundle] loadNibNamed:splashScreen owner:self
                                               options:nil] objectAtIndex:0];
    CGRect frame = rootView.frame;
    frame.origin = CGPointMake(0, 0);
    loadingView.frame = frame;
  }
  waiting = false;

  [rootView addSubview:loadingView];
}

+ (void)showLottieSplash:(UIView*)animationView inRootView:(UIView*)rootView {
  loadingView = animationView;
  waiting = false;
  [rootView addSubview:animationView];
}

+ (void)hide {
  if (waiting) {
    dispatch_async(dispatch_get_main_queue(), ^{
      waiting = false;
    });
  } else {
    waiting = true;
      if (isAnimationFinished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                         [UIView animateWithDuration:0.2
                         animations:^{loadingView.alpha = 0.0;}
                         completion:^(BOOL finished){ [loadingView removeFromSuperview]; }];
                       });
      }
  }
}

+ (void)setAnimationFinished:(Boolean)flag {
    isAnimationFinished = flag;
    if (waiting) {
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{
                       [loadingView removeFromSuperview];
                     });
    }
}

+ (void)jsLoadError:(NSNotification*)notification {
  // If there was an error loading javascript, hide the splash screen so it can be shown.  Otherwise
  // the splash screen will remain forever, which is a hassle to debug.
  [RNSplashScreen hide];
}

RCT_EXPORT_METHOD(hide) { [RNSplashScreen hide]; }

RCT_EXPORT_METHOD(show) { [RNSplashScreen show]; }

@end
