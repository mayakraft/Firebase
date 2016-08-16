* make sure to install cocoa pods `pod install`
* make sure to copy in your `GoogleService-Info.plist` with your Firebase account info

see [Firebase Getting Started Documentation](https://firebase.google.com/docs/ios/setup) sections __Add Firebase to your app__ and __Add the SDK__

# Login

Login portal: create a personal account / login, logs you into your profile page where you can edit your profile details, upload picture. Everyone has a profile, that's it. Foundation for social media-type apps.

# Browse

Browse your entire database in a simple UITableView. Firebase sometimes delivers data as an `Array` or `Dictionary`, this handles each case.

# Storage

Upload images from your iOS device onto Firebase Storage. Firebase doesn't handle directory contents, so the app also mirrors the contents of the Storage on a folder in the database which is accessible.