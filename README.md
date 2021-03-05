# Default web browser

Default web browser is an app for macOS 11 Big Sur that allows you to set your default web browser.

On macOS 10 Catalina and earlier you could do this in the General pane of System Preferences, but Big Sur currently has a [bug](https://lapcatsoftware.com/articles/default-browser-bs.html) that prevents some apps from appearing in the list of web browsers.

## Building

Building Default web browser from source requires Xcode 12 or later.

Before building, you need to create a file named `DEVELOPMENT_TEAM.xcconfig` in the project folder (the same folder as `Shared.xcconfig`). This file is excluded from version control by the project's `.gitignore` file, and it's not referenced in the Xcode project either. The file specifies the build setting for your Development Team, which is needed by Xcode to code sign the app. The entire contents of the file should be of the following format:
```
DEVELOPMENT_TEAM = [Your TeamID]
```

## Author

[Jeff Johnson](https://lapcatsoftware.com/)

To support the author, you can [PayPal.Me](https://www.paypal.me/JeffJohnsonWI) or buy Link Unshortener in the [Mac App Store](https://apps.apple.com/app/link-unshortener/id1506953658).

## Copyright

Default web browser is Copyright © 2021 Jeff Johnson. All rights reserved.

## License

See the [LICENSE.txt](LICENSE.txt) file for details.
