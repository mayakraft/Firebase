* make sure to install cocoa pods `pod install`
* make sure to copy in your `GoogleService-Info.plist` with your Firebase account info

see [Firebase Getting Started Documentation](https://firebase.google.com/docs/ios/setup) sections __Add Firebase to your app__ and __Add the SDK__

# Login

Login portal: create a personal account / login, logs you into your profile page where you can edit your profile details, upload picture. Everyone has a profile, that's it. Foundation for social media-type apps.

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/login.gif)

# Browse

Browse your entire database in a simple UITableView. Firebase sometimes delivers data as an `Array` or `Dictionary`, this handles each case.

# Storage

A handy set of file upload functions - since Firebase Storage doesn't keep track of the files you upload, this also maintains a record of the uploaded files in your database.