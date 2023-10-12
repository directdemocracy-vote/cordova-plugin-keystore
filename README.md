# Cordova KeyStore Plugin

## Using
Install the plugin

    $ cd hello
    $ cordova plugin add https://github.com/don/cordova-plugin-hello.git


Edit `www/js/index.js` and add the following code inside `onDeviceReady`

```js
    var success = function(message) {
        alert(message);
    }

    var failure = function() {
        alert("Error calling Hello Plugin");
    }

    KeyStore.greet("World", success, failure);
```

Install iOS or Android platform

    cordova platform add ios
    cordova platform add android

Run the code

    cordova run
