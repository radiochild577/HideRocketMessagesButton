#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

// Define the target class from FLEX (adjust if exact name differs, e.g., add "BarItemWrapper" if needed)
@interface RCCMessagesNavigationButton : UIButton
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) BOOL enabled;
@end

// Hook the button class to hide/disable it
%hook RCCMessagesNavigationButton

- (instancetype)initWithFrame:(CGRect)frame {
    instancetype orig = %orig(frame);
    [self _applyHiding];
    return orig;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    instancetype orig = %orig(coder);
    [self _applyHiding];
    return orig;
}

// Private method to apply hiding (reusable)
%new
- (void)_applyHiding {
    self.hidden = YES;
    self.alpha = 0.0f;
    self.enabled = NO;
    NSLog(@"[HideRocketMessagesButton] Hidden and disabled RCCMessagesNavigationButton instance: %@", self);
}

// Ensure it stays hidden during layout or appearance changes
- (void)layoutSubviews {
    %orig;
    [self _applyHiding];
}

- (void)didMoveToSuperview {
    %orig;
    [self _applyHiding];
}

- (void)didMoveToWindow {
    %orig;
    [self _applyHiding];
}

// Disable any target-action (taps)
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (controlEvents & UIControlEventTouchUpInside) {
        // Skip adding tap handlers for messages button
        return;
    }
    return %orig;
}

%end

// Hook the parent view controller to scan and hide any instances (backup for dynamic addition)
%hook RCCMessagesViewController  // Or replace with actual parent from FLEX, e.g., MessagesNavigationController

- (void)viewDidLoad {
    %orig;
    [self _hideMessagesButtonsInView:self.view];
}

- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    [self _hideMessagesButtonsInView:self.view];
}

%new
- (void)_hideMessagesButtonsInView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:%c(RCCMessagesNavigationButton)]) {
            RCCMessagesNavigationButton *button = (RCCMessagesNavigationButton *)subview;
            button.hidden = YES;
            button.alpha = 0.0f;
            button.enabled = NO;
            NSLog(@"[HideRocketMessagesButton] Hidden button in view hierarchy: %@", button);
        }
        // Recurse into subviews (for nested UIs)
        [self _hideMessagesButtonsInView:subview];
    }
}

// Hook navigation bar item addition to prevent setting the button
- (void)setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    // Skip if it's the messages button (check properties; adapt based on FLEX)
    if (item && [item respondsToSelector:@selector(customView)] && [item.customView isKindOfClass:%c(RCCMessagesNavigationButton)]) {
        NSLog(@"[HideRocketMessagesButton] Skipped adding messages bar button.");
        return;  // Don't add it
    }
    return %orig(item, animated);
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    if (item && [item respondsToSelector:@selector(customView)] && [item.customView isKindOfClass:%c(RCCMessagesNavigationButton)]) {
        return;
    }
    return %orig(item, animated);
}

%end

// Fallback: Hook general UINavigationBar to filter bar items
%hook UINavigationItem

- (void)setLeftBarButtonItem:(UIBarButtonItem *)item {
    if (item && /* Add check for ARK/manual read, e.g., if ([item.title isEqual:@"Mark Read"]) */) {
        return;  // Skip messages button
    }
    return %orig(item);
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)item {
    if (item && /* Same check */) {
        return;
    }
    return %orig(item);
}

%end

// Constructor/Destructor
%ctor {
    %init;
    NSLog(@"[HideRocketMessagesButton] Tweak loaded successfully.");
}

%dtor {
    NSLog(@"[HideRocketMessagesButton] Tweak unloaded.");
}