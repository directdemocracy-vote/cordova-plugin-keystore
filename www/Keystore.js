/*global cordova, module*/

module.exports = {
    greet: function (name, successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "Keystore", "greet", [name]);
    },
    createKeyPair: function(alias, successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "Keystore", "createKeyPair", [alias]);
    },
    sign: function(alias, message, successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "Keystore", "sign", [alias, message]);
    },
    verify: function(alias, message, signature, successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "Keystore", "verify", [alias, message, signature]);
    }
};
