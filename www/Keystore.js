export default class Keystore {
    constructor(name) {
        cordova.exec(successCallback, errorCallback, "Hello", "greet", [name]);
    }
}