# Example Projects

## Login

Login portal: create a personal account / login, logs you into your profile page where you can edit your profile details, upload picture. Everyone has a profile, that's it. Foundation for social media-type apps.

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/login.gif)

## Browse

Browse the entire database in a simple UITableView. Firebase sometimes delivers JSON objects as an `Array` or `Dictionary`, this handles each case, and includes object type detection.

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/browse.gif)

## Setup Example Projects

1. Install Cocoa Pods:
   * in command line navigate to the directory with the .xcodeproj file, type `pod install`
   * from now on, open the .xcworkspace file
2. Copy in your `GoogleService-Info.plist` with your Firebase account info. Get it here:

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/config1.png)

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/config2.png)

see [Firebase Getting Started Documentation](https://firebase.google.com/docs/ios/setup) sections __Add Firebase to your app__ and __Add the SDK__

# Documentation

## Fire.swift divided into 3 parts:

* Database
* User
* Storage

## Database

Convenience functions for setting and retrieving data, properly handling JSON data types: nil, bool, int, float, string, array, dictionary, and Firebase uses arrays which takes some extra safeguarding to manage.

* `getData()` get data from database
* `setData()` overwrite data at a certain location in the database
* `addData()` generate a new key and add data as a child
* `doesDataExist()` check if data exists at a certain location

### Firebase uses Arrays

Example of the behavior to prevent. An auto-generated firebase key doesn't match the array type, only uses dictionary-style string keys:

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/array-bad.gif)

using this function checks against the database before adding:

```swift
func addData(_ object:Any, asChildAt path:String, completionHandler: ...){}
```

Corrected:

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/array-good.gif)

## User

Firebase comes with FireAuth with a "user" class, but you can't edit it. Solution: create a "users" entry in database with copies of User data but with more info.

* each user is stored under their user.uid
* can add as many fields as you want (nickname, photo, etc..)

all the references to "user" are to our database's user entries, not the proper FIRAuth entry

* `getCurrentUser()` get all your profile information
* `updateCurrentUserWith()` update your profile with new information
* `newUser()` create a new entry for a user (usually for yourself after 1st login)
* `userExists()` check if a user exists

## Storage

since Firebase Storage doesn't keep track of the files you upload,
this maintains a record of the uploaded files in your database

* `uploadFileAndMakeRecord()` upload a file to storage and make a record in our database

