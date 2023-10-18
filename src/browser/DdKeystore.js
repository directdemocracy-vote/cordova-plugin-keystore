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
  )
  const publicKey = await exportCryptoKey(keyPair.publicKey, 'public');
  const privateKey = await exportCryptoKey(keyPair.privateKey, 'private');
  console.log(privateKey)
  localStorage.setItem('privateKey', privateKey);
  success(publicKey);
}

async function exportCryptoKey(key, type) {
  const format = type === 'public' ? 'spki' : 'pkcs8';
  let exported = await window.crypto.subtle.exportKey(format, key);
  if (type === 'public') {
    exported = new Uint8Array(exported);
    btoa(String.fromCharCode(...exported));
  }
  
  return exported
}

async function sign(success, error, args) {
  const encoder = new TextEncoder();
  const encoded = encoder.encode(args[1]); // args[0] is the alias of the key
  localStorage.getItem('privateKey')
  signature = await window.crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    localStorage.getItem('privateKey'),
    encoded,
  );
  console.log(signature)

  success(signature)
}

module.exports = {
  createKeyPair: createKeyPair,
  sign: sign
};
require('cordova/exec/proxy').add('DdKeyStore', module.exports);
