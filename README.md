# How to use What's Cookin'

Installations:
Xcode (latest version preferred)
Firebase iOS SDK-https://github.com/firebase/firebase-ios-sdk. 

Step 1 : Create an XCode Project 
1. Click Create New Project when you open up XCode
2. When choosing the template go to the iOS tab and click App and then hit next
3. Type in a product name, for Interface choose Storyboard, for Language choose Swift, for Storage choose Core Data then hit next
4. Choose a location on your machine and click create

Step 2 : Copying Files
1. Download a zip version of all the files present in the GitHub
2. Copy and Paste/Move all these files into the folder containing the project code files. If prompted to replace, merge etc. then always choose replace
3. When looking at the project in XCode, there should be side tab on the left side with different icons. Choose the folder icon and click the + sign on the bottom left and then click Add files to "..."
4. Add every file that ends in .swift and the GoogleService-Info.plist

Step 3 : Add Firebase SDKs to your app

Use Swift Package Manager to install and manage Firebase dependencies.
1. In Xcode, with your app project open, navigate to File > Add Packages.
2. When prompted, add the Firebase Apple platforms SDK repository: 
           https://github.com/firebase/firebase-ios-sdk
3. Select the SDK version that you want to use.
4. Choose the following Firebase libraries:
        FirebaseAnalytics
        FirebaseAuth
        FirebaseFirestore
        FirebaseStorage
        FirebaseInstallations
        FirebaseDatabase
        FirebaseVertexAI-Preview
         And any other libraries that have these names.

DONE - Now your project should be up and running and be able to create a successful build.

The following is a list of all the views in the app and what they are used for

Notifications :
Upon loading up the app, you will be asked whether you'd like to turn on notifications or not. Regardless of what you choose, you’ll be able to change your choice by navigating to settings ->What’s Cookin’ -> Notifications.

Login/Signup View: This is where you can either log in or sign up for an account. Once you sign up, a notification will appear, letting you know the account was created successfully. After you have signed up, you will be able to log in. After you have logged in, you’ll be navigated to the home view.

Home View: This is the main view. Here the user is able to navigate to various parts of the app. Once logged in, the user is presented with two randomly recommended recipe images. These images are clickable and will navigate to a detailed view of the recipe. The user can either favorite, share to social media, or repost the recipe to the user’s feed. The home view, also, enables the user to search for recipes by name or description via the search bar. As mentioned before, there are multiple buttons that navigate you to various parts of the app. Some of these buttons are:
* Menu icon (Home View):
In the home view, there is a three-lined icon in the top left corner of the app. Once clicked, it will open up the menu view.
* Profile button: This button will navigate a user to the profile view.
* Home icon: Self-explanatory. Has no functionality.
* Favorite Icon(star): This button navigates you to the favorites view.
* History icon(clock): This button navigates you to the history view.
* Settings icon(gear): This icon navigates you to the settings view.

Menu View(menu icon): In this view, the app categorizes fetched recipes by meal types. These meal types include breakfast,lunch,dinner,dessert, etc. The user can select one of the tabs to see a collection of recipes they would like to prepare based on the meal type. Within this view, there is also a shopping cart tab that navigates you to the shopping cart view. In this view, the user is able to shop for missing ingredient items from Amazon. Once you’ve added the item to the cart, it will be listed in the view. You can always delete the item from the shopping list once you’ve acquired the ingredient item.

Profile View: Once you click on the “Profile” button, it will navigate you to the user profile view. Here you’ll be able to select any image for your profile picture from your library, change your status, and write a short bio. To select a profile image, click on the circle in the top middle center of the page. From the user profile view, the user will be able to navigate to the following/followers view by clicking on the button located at the bottom of the status toggle button.

Followings/Followers View: When you click on the followings/followers button in the user profile view, you’ll be brought to the Followings/Followers View. In the search bar, a user is able to search for another user by username and follow that user. Anything that the user posts will be seen by you in your user feed. In this view, you also have the post button and the feed button. The “post” button navigates the user to the post view, where they can make text-based posts. The “feed” button navigates the user to the feed view.

Favorites View: When the star icon is clicked in the tab at the bottom a view of the user's favorite recipes comes onto the screen. The user will have the option to "favorite" any recipe they like and this is where we display that collection of recipes to them. They are also allowed to remove the recipe from their "favorites" collection on this page as well. 

Search View: Then the magnifying glass icon is chosen then the user is brought to a view where they are allowed to make a search using ingredients. There is also an option to click if you are excluding certain ingredients from the recipes you are searching for. By default, this option is already selected as no. If you choose yes then you must put ingredients in the second text bar further below and then click search which will bring up a page with your results.

Search Results View: When a user fills in the information they want to use to make a search then this page is brought up showing the user the results of their search. It returns a list of recipes using the ingredients that the user has specified in their search and either with or without ingredients that the user has chosen to exclude as well depending on the user's search parameters.


User Feed View: When you click on the “Feed” button in the Followings/Followers view, it will navigate you to the User Feed View. Here, the user will see both text-based and recipe-based posts from the users they follow, including themselves.

Post View: When you click on the “Post” button in the Followings/Followers view, it will navigate you to the Post View. This view is where you can make text-based posts rather than recipe-based posts.

Settings View: When you click on the gear button in the Home View’s tab bar, it’ll navigate you to the Settings View. Here, you’ll be able to delete your account, change your password, log out, or change the font size of all the text within the view.

History View: When you click on the clock icon in the Home View’s tab bar, it’ll navigate you to the History View. Here, you’ll be able to see all of your interactions with the app.

Shopping Cart View: When you click on the “Shopping Cart” tab within the Side Bar Menu View, it’ll navigate you to this view. Here, you can shop for ingredients by clicking on the search icon in the top right corner, typing the ingredient you’re looking for, and adding it to your shopping cart list. Once you search for the ingredient, the app will direct you to Amazon’s search page, where you can shop online to see if it’s available to purchase. If the item isn’t available to purchase or if you can’t find the item you’re looking for, you can press the “Add to Cart” button and save the item to your shopping list for a later purchase date. When you do find the item you’re looking for on Amazon, simply swipe left on the shopping list item and click delete.
