# Foornal
Transform your eating habits through behaivioural science and OnDemand's SOTA AI-powered tools.

## App
This repository is a flutter application which you should be able to get working by cd-ing into this repo's directory and running `flutter pub get` followed by `flutter run`. Here is what the app should look like:
<video src="showcase.webm" width="320" height="240" controls></video>

## Server
The flutter app talks to a server hosted by On-Demand's Serverless Applications tool. The code for the server lives at this repository: `https://github.com/ssocolow/docker-test` so On-Demand can pull the changes and run the dockerfile. For the convenience of the reviewers - you guys :) - it is included in `/server` in this repository as well.

## How it Works
App: upload image -> On-Demand's server -> On-Demand model API call to get nutrient information about the picture and advice on the user's food choices -> back to App to render