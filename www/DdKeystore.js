/*global cordova, module*/

module.exports = {
    greet: function (name, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "DdKeyStore", "greet", [name]);
    },
    createKeyPair: function(successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "DdKeyStore", "createKeyPair");
    },
    sign: function(message, successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "DdKeyStore", "sign", [message]);
    }
};
