async function createKeyPair(succes, error, args) {
  const keyPair = await window.crypto.subtle.generateKey(
    {
      name: "RSASSA-PKCS1-v1_5",
      modulusLength: 4096,
      publicExponent: new Uint8Array([1, 0, 1]),
      hash: "SHA-256",
    },
    true,
    ["encrypt", "decrypt"],
  )

  const publicKey = await exportCryptoKey(keyPair.publicKey);
  const privateKey = await exportCryptoKey(keyPair.privateKey);
  localStorage.setItem('privateKey', privateKey);
  success(Buffer.from(publicKey).toString('base64'))
}

async function exportCryptoKey(key) {
  const exported = await window.crypto.subtle.exportKey("pkcs8", key);
  return new Uint8Array(exported);
}

async function sign(success, error, args) {
  const encoder = new TextEncoder();
  const encoded = encoder.encode(args[1]); // args[0] is the alias of the key

  signature = await window.crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    localStorage.getItem('privateKey'),
    encoded,
  );

  success(Buffer.from(signature).toString('base64'))
}

module.exports = {
  createKeyPair: function (success, error, opts) {
    success("test browser");
  }
};
require('cordova/exec/proxy').add('DdKeyStore', module.exports);
