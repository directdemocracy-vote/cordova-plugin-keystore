export default class KeyStore {
    constructor(name) {
        cordova.exec(successCallback, errorCallback, "Hello", "greet", [name]);
    }
}