# Foornal
Transform your eating habits through behavioural science and On-Demand's SOTA AI-powered tools.

## App
This repository is a flutter application which you should be able to get working by cd-ing into this repo's directory and running `flutter pub get` followed by `flutter run`. Here is what the app should look like:


https://github.com/user-attachments/assets/f77c1e2c-715d-4f1c-9e75-384102709772


## Server
The flutter app talks to a server hosted by On-Demand's Serverless Applications tool. The code for the server lives at this repository: `https://github.com/ssocolow/docker-test` so On-Demand can pull the changes and run the dockerfile. For the convenience of the reviewers - you guys :) - it is included in `/server` in this repository as well.

## How it Works
App: upload image -> On-Demand's server -> On-Demand model API call to get nutrient information about the picture and advice on the user's food choices and current streak -> back to App to render
