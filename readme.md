# SETUP

1. Install Cocoa Pods:
   * in command line navigate to the directory with the .xcodeproj file, type `pod install`
   * from now on, open the .xcworkspace file
2. Copy in your `GoogleService-Info.plist` with your Firebase account info. Get it here:

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/config1.png)

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/config2.png)

see [Firebase Getting Started Documentation](https://firebase.google.com/docs/ios/setup) sections __Add Firebase to your app__ and __Add the SDK__

# Login

Login portal: create a personal account / login, logs you into your profile page where you can edit your profile details, upload picture. Everyone has a profile, that's it. Foundation for social media-type apps.

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/login.gif)

# Browse

Browse your entire database in a simple UITableView. Firebase sometimes delivers data as an `Array` or `Dictionary`, this handles each case.

# Storage

A handy set of file upload functions - since Firebase Storage doesn't keep track of the files you upload, this also maintains a record of the uploaded files in your database.