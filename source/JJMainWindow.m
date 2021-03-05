#import "JJMainWindow.h"

@implementation JJMainWindow

static const CGFloat JJMainWindowMargin = 15.0;
static CFStringRef WebURLScheme = CFSTR("http");
static NSWindow* _mainWindow;
static NSPopUpButton* _popUp;

+(void)popUpAction:(nonnull id)sender {
	NSString* bundleID = [sender representedObject];
	OSStatus status = LSSetDefaultHandlerForURLScheme(WebURLScheme, (__bridge CFStringRef _Nonnull)bundleID);
	if (status != noErr) {
		NSAlert* alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Cannot set default web browser"];
		[alert setInformativeText:[NSString stringWithFormat:@"LSSetDefaultHandlerForURLScheme returned %i", status]];
		[alert beginSheetModalForWindow:_mainWindow completionHandler:nil];
	}
}

+(void)popUpPopUp {
	NSNotification* fakeNotification = [NSNotification notificationWithName:NSPopUpButtonWillPopUpNotification object:_popUp];
	[self popUpWillPopUp:fakeNotification];
}

+(void)popUpWillPopUp:(nonnull NSNotification*)notification {
	NSPopUpButton* popUp = [notification object];
	NSMenu* menu = [popUp menu];
	[menu removeAllItems];
	
	NSArray* handlers = CFBridgingRelease(LSCopyAllHandlersForURLScheme(WebURLScheme));
	if (handlers == nil || [handlers count] == 0) {
		NSLog(@"LSCopyAllHandlersForURLScheme returned nil!");
		[popUp selectItem:nil];
		return;
	}
	NSString* defaultHandler = CFBridgingRelease(LSCopyDefaultHandlerForURLScheme(WebURLScheme));
	if (defaultHandler == nil) {
		NSLog(@"LSCopyDefaultHandlerForURLScheme returned nil!");
	}
	
	NSMenuItem* selectedItem = nil;
	
	NSMutableArray* menuItems = [NSMutableArray array];
	for (NSString* bundleID in handlers) {
		NSURL* bundleURL = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:bundleID];
		if (bundleURL != nil) {
			NSArray<NSURLResourceKey>* keys = @[NSURLLocalizedNameKey, NSURLEffectiveIconKey];
			NSDictionary<NSURLResourceKey,id>* values = [bundleURL resourceValuesForKeys:keys error:NULL];
			if (values != nil) {
				NSString* name = values[NSURLLocalizedNameKey];
				if (name != nil) {
					if ([name hasSuffix:@".app"])
						name = [name stringByDeletingPathExtension];
					NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:name action:NULL keyEquivalent:@""];
					[item setRepresentedObject:bundleID];
					NSImage* image = values[NSURLEffectiveIconKey];
					if (image != nil) {
						[image setSize:NSMakeSize(16.0, 16.0)];
						[item setImage:image];
					}
					[menuItems addObject:item];
					if (selectedItem == nil && defaultHandler != nil && [bundleID caseInsensitiveCompare:defaultHandler] == NSOrderedSame)
						selectedItem = item;
				}
			}
		}
	}
	
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)];
	[menuItems sortUsingDescriptors:@[descriptor]];
	for (NSMenuItem* item in menuItems) {
		[menu addItem:item];
	}
	
	[popUp selectItem:selectedItem];
}

+(void)windowDidBecomeMain:(nonnull NSNotification*)notification {
	// This is necessary because calling LSSetDefaultHandlerForURLScheme
	// triggers a system dialog with "Use" and "Keep" buttons.
	dispatch_async(dispatch_get_main_queue(), ^{
		[self popUpPopUp];
	});
}

+(void)windowWillClose:(nonnull NSNotification*)notification {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:_popUp];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:_mainWindow];
	_popUp = nil;
	_mainWindow = nil;
}

+(void)showMainWindow {
	if (_mainWindow != nil) {
		[_mainWindow makeKeyAndOrderFront:self];
		return;
	}
	
	NSWindowStyleMask style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;
	_mainWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 480.0, 300.0) styleMask:style backing:NSBackingStoreBuffered defer:YES];
	[_mainWindow setExcludedFromWindowsMenu:YES];
	[_mainWindow setReleasedWhenClosed:NO]; // Necessary under ARC to avoid a crash.
	[_mainWindow setTabbingMode:NSWindowTabbingModeDisallowed];
	[_mainWindow setTitle:JJApplicationName];
	NSView* contentView = [_mainWindow contentView];
	
	_popUp = [[NSPopUpButton alloc] initWithFrame:NSMakeRect( 0.0, 0.0, 300.0, 16.0 ) pullsDown:NO];
	[_popUp setAction:@selector(popUpAction:)];
	[_popUp setAutoenablesItems:NO];
	[_popUp setTarget:self];
	[_popUp setTranslatesAutoresizingMaskIntoConstraints:NO];
	[contentView addSubview:_popUp];
	[_mainWindow setInitialFirstResponder:_popUp];
	
	[NSLayoutConstraint activateConstraints:@[
											  [[_popUp topAnchor] constraintEqualToAnchor:[contentView topAnchor] constant:JJMainWindowMargin],
											  [[contentView bottomAnchor] constraintEqualToAnchor:[_popUp bottomAnchor] constant:JJMainWindowMargin],
											  [[_popUp leadingAnchor] constraintEqualToAnchor:[contentView leadingAnchor] constant:JJMainWindowMargin],
											  [[contentView trailingAnchor] constraintEqualToAnchor:[_popUp trailingAnchor] constant:JJMainWindowMargin],
											  [[_popUp widthAnchor] constraintEqualToConstant:300.0]
										  ]];
	
	[_mainWindow makeKeyAndOrderFront:nil];
	[_mainWindow center]; // Wait until after makeKeyAndOrderFront so the window sizes properly first
	
	[self popUpPopUp];
	
	NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:self selector:@selector(popUpWillPopUp:) name:NSPopUpButtonWillPopUpNotification object:_popUp];
	[defaultCenter addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:_mainWindow];
	[defaultCenter addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:_mainWindow];
}
@end
