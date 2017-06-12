# Fire.swift

> a singleton class to assist interfacing with the database, Firebase storage bucket, caching files, managing your Auth info and interacting with other Auth users

# Example Project: Login Portal

create a personal account / login, logs you into your profile page where you can edit your profile details, upload picture. Everyone has a profile, that's it. Foundation for social media-type apps.

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/login.gif)

# Example Project: Browse

Browse the entire database in a simple UITableView. Firebase sometimes delivers JSON objects as an `Array` or `Dictionary`, this handles each case, and includes object type detection.

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/browse.gif)

## Example projects require Cocoa Pod and Firebase Install

1. Install Cocoa Pods:
   * in command line navigate to the directory with the .xcodeproj file, type `pod install`
   * from now on, open the .xcworkspace file
2. Copy in your `GoogleService-Info.plist` with your Firebase account info. Get it here:

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/config1.png)

![animation](https://raw.github.com/robbykraft/Firebase/master/readme/config2.png)

see [Firebase Getting Started Documentation](https://firebase.google.com/docs/ios/setup) sections __Add Firebase to your app__ and __Add the SDK__

# Documentation

## Fire.swift covers 3 subjects:

* Database
* User
* Storage

## Database

* `getData()` get data from database
* `setData()` overwrite data at a certain location in the database
* `addData()` generate a new key and add data as a child
* `doesDataExist()` check if data exists at a certain location

### Why this is important

Firebase sometimes stores data as Arrays, but an auto-generated firebase key won't check to match the array type:

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
* `getUser()` get a different user's info
* `updateCurrentUserWith()` update your profile with new information
* `newUser()` create a new entry for a user (usually for yourself after 1st login)
* `userExists()` check if a user exists

## Storage

since Firebase Storage doesn't keep track of the files you upload,
this maintains a record of the uploaded files in your database

* `fileCache:[String:Data]` the cache for all incoming files (images/pdfs) from the storage bucket
* `imageFromStorageBucket()` get an image from Firebase storage (or the cache if it's already there)
* `uploadFileAndMakeRecord()` upload a file to storage, make a record in our database, a