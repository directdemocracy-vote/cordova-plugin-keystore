/*global cordova, module*/

module.exports = {
    greet: function (name, successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "DdKeyStore", "greet", [name]);
    },
    createKeyPair: function(alias, successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "DdKeyStore", "createKeyPair", [alias]);
    },
    sign: function(alias, message, successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "DdKeyStore", "sign", [alias, message]);
    },
    verify: function(alias, message, signature, successCallback, errorCallback) {
      cordova.exec(successCallback, errorCallback, "DdKeyStore", "verify", [alias, message, signature]);
    }
};
