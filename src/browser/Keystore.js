async function createKeyPair(success, error, args) {
  const keyPair = await window.crypto.subtle.generateKey(
    {
      name: "RSASSA-PKCS1-v1_5",
      modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]),
      hash: "SHA-256",
    },
    true,
    ["sign", "verify"]
  );
  const publicKey = await exportCryptoKey(keyPair.publicKey, 'public');
  const privateKey = await exportCryptoKey(keyPair.privateKey, 'private');
  localStorage.setItem('privateKey', privateKey);
  success(publicKey);
}

async function exportCryptoKey(key, type) {
  const format = type === 'public' ? 'spki' : 'jwk';
  let exported = await window.crypto.subtle.exportKey(format, key);
  if (type === 'public')
    exported = arraryBufferToBase64(exported);
  else
    exported = JSON.stringify(exported);

  return exported
}

function arraryBufferToBase64(arrayBuffer) {
  let result = new Uint8Array(arrayBuffer);
  result = btoa(String.fromCharCode(...result));

  return result;
}

async function sign(success, error, args) {
  const encoder = new TextEncoder();
  const encoded = encoder.encode(args[1]); // args[0] is the alias of the key
  let privatekey = JSON.parse(localStorage.getItem('privateKey'));
  const privateCryptoKey = await window.crypto.subtle.importKey(
    "jwk",
    privatekey,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    true,
    ["sign"],
  );
  signature = await window.crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateCryptoKey,
    encoded,
  );

  success(arraryBufferToBase64(signature));
}

module.exports = {
  createKeyPair: createKeyPair,
  sign: sign
};
require('cordova/exec/proxy').add('Keystore', module.exports);
