# Las Vegas 2


## How to Run / Use this project the Project
1. Download or clone the project from git hub
2. Start the project from Xcode.
3. Push and hold for 1/2 a second or more on a location your interested in
<img src="https://github.com/carchi8py/Las-Vegas-2/blob/master/img/image1.jpg?raw=true" width="50%"></img>
4. Select that pin to open the location. (If your in a rush you can click on the pin while the images are still loading) There are 2 view for the information

###Table View
The first is a table view. The table view show the name of the location, how many people are currently checked in here on Foursquare, and the total number of people who have ever checked in here. The table view also shows a picture. <br>
<img src="https://github.com/carchi8py/Las-Vegas-2/blob/master/img/image2.jpg?raw=true" width="50%"></img>

###Table View (for thouse in a rush)
If the user clicked on a pin while the activity indicator still up they will still be taken to the table 
So that the user dosn't have to wait for all picture to be downloaded the table loads with what picture are currently aviable and popular the rest when the tables is refreashed (cell go off the screen). If there are no pictures for a location a placeholder image is loaded. Click on a location will bring up the detailed view <br>
<img src="https://raw.githubusercontent.com/carchi8py/Las-Vegas-2/master/img/image5.jpg" width="50%"></img>

The second view is a map view. The map view show the same place from the table view, but plot them on the map using the Latitude and longitude that Foursqaure provided. Clicking on a location will bring up the detailed view.

<img src="https://raw.githubusercontent.com/carchi8py/Las-Vegas-2/master/img/image3.jpg" width="50%"></img>


The detailed view bring up details about the locations. Total people who have checked in, The current number of people who are here, a URL if one is given. And 3 images from the location.
<img src="https://github.com/carchi8py/Las-Vegas-2/blob/master/img/image4.jpg?raw=true" width="50%"></img>