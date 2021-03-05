#import "JJLicenseWindow.h"

@implementation JJLicenseWindow

static const CGFloat JJLicenseWindowMargin = 15.0;
static NSWindow* _licenseWindow;

+(void)windowWillClose:(nonnull NSNotification*)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:_licenseWindow];
	_licenseWindow = nil;
}

+(void)showLicenseWindow {
	if (_licenseWindow != nil) {
		[_licenseWindow makeKeyAndOrderFront:self];
		return;
	}
	
	NSURL* url = [[NSBundle mainBundle] URLForResource:@"LICENSE" withExtension:@"txt"];
	if (url == nil) {
		NSLog(@"LICENSE.txt not found");
		return;
	}
	NSError* error = nil;
	NSString* license = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (license == nil) {
		NSLog(@"LICENSE.txt error: %@", error);
		return;
	}
	
	NSTextField* label = [NSTextField wrappingLabelWithString:license];
	[label setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	NSWindowStyleMask style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;
	_licenseWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 630.0, 100.0) styleMask:style backing:NSBackingStoreBuffered defer:YES];
	[_licenseWindow setExcludedFromWindowsMenu:YES];
	[_licenseWindow setReleasedWhenClosed:NO]; // Necessary under ARC to avoid a crash.
	[_licenseWindow setTabbingMode:NSWindowTabbingModeDisallowed];
	[_licenseWindow setTitle:NSLocalizedString(@"License", nil)];
	
	NSView* contentView = [_licenseWindow contentView];
	[contentView addSubview:label];
	[NSLayoutConstraint activateConstraints:@[
											  [[label topAnchor] constraintEqualToAnchor:[contentView topAnchor] constant:JJLicenseWindowMargin],
											  [[contentView bottomAnchor] constraintEqualToAnchor:[label bottomAnchor] constant:JJLicenseWindowMargin],
											  [[label leadingAnchor] constraintEqualToAnchor:[contentView leadingAnchor] constant:JJLicenseWindowMargin],
											  [[contentView trailingAnchor] constraintEqualToAnchor:[label trailingAnchor] constant:JJLicenseWindowMargin],
											  [[label widthAnchor] constraintEqualToConstant:600.0]
											  ]];
	
	[_licenseWindow makeKeyAndOrderFront:nil];
	[_licenseWindow center]; // Wait until after makeKeyAndOrderFront so the window sizes properly first
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:_licenseWindow];
}

@end
