# MediaFlow by Alex Godly — Website App for Android and Windows

This branch uses the real site at https://alexgodly.github.io/MediaFlow/ as the application interface and functionality. Android shows the responsive mobile layout; Windows shows the responsive desktop layout. Site updates are reflected through its browser cache and reload behavior.

Separate WebView storage means you may need to sign in again. Do not remove an existing version containing unsynced local drafts before exporting them. Internet connectivity is required for first load; offline availability depends on MediaFlow's own offline support.

The native shell implements back navigation, retry, safe generated file saving and branded packaging. Browser/PWA features and full mobile/desktop feature equivalence still require device acceptance testing.

Automated builds are in the Actions page for this branch. Android artifact contains the APK; Windows artifact contains the executable and its required DLL/data files. The Windows folder must stay together. Android CI APK is a release-mode build but uses the generated default debug signing unless a release key is configured. Official distribution should use stable release signing.
