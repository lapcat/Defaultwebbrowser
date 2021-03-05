#import "JJApplicationDelegate.h"

#import "JJLicenseWindow.h"
#import "JJMainMenu.h"
#import "JJMainWindow.h"

NSString* JJApplicationName;

@implementation JJApplicationDelegate

#pragma mark NSApplicationDelegate

-(void)applicationWillFinishLaunching:(nonnull NSNotification *)notification {
	JJApplicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	if (JJApplicationName == nil) {
		NSLog(@"CFBundleName nil!");
		JJApplicationName = @"Default web browser";
	}
	[JJMainMenu populateMainMenu];
}

-(void)applicationDidFinishLaunching:(nonnull NSNotification*)notification {
	[self openMainWindow:nil];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)application {
	return YES;
}

#pragma mark JJApplicationDelegate

-(void)openLicense:(nullable id)sender {
	[JJLicenseWindow showLicenseWindow];
}

-(void)openMainWindow:(nullable id)sender {
	[JJMainWindow showMainWindow];
}

-(void)openWebSite:(nullable id)sender {
	NSURL* url = [NSURL URLWithString:@"https://github.com/lapcat/Defaultwebbrowser"];
	if (url != nil)
		[[NSWorkspace sharedWorkspace] openURL:url];
	else
		NSLog(@"Support URL nil!");
}

@end
