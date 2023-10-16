package vote.directdemocracy.plugin;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;

import java.security.KeyPairGenerator;
import java.security.NoSuchProviderException;
import java.security.NoSuchAlgorithmException;
import java.security.InvalidAlgorithmParameterException;
import java.security.Signature;
import java.security.KeyStore;
import java.security.KeyStore.Entry;
import java.security.KeyStore.PrivateKeyEntry;
import java.security.PrivateKey;
import java.util.Calendar;
import java.util.Base64;

import android.security.keystore.KeyProperties;
import android.security.keystore.KeyGenParameterSpec;

public class DdKeyStore extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        String alias = data.getString(0);
        if (action.equals("greet")) {
          String message = "Hello " + alias;
          callbackContext.success(message);

          return true;
        } else if (action.equals("createKeyPair")) {
          try {
            return createKeyPair(alias, callbackContext);
          } catch (Exception e) {
            return false;
          }
        } else if (action.equals("sign")) {
          try {
            byte[] message = data.getString(1).getBytes("UTF-8");
            return sign(alias, message, callbackContext);
          } catch (Exception e) {
            callbackContext.success(e.toString());
            return false;
          }
        } else if (action.equals("verify")) {
          try {
            byte[] message = data.getString(1).getBytes("UTF-8");
            byte[] signature = Base64.getDecoder().decode(data.getString(2).getBytes("UTF-8"));
            return verify(alias, message, signature, callbackContext);
          } catch (Exception e) {
            callbackContext.success(e.toString());
            return false;
          }
        } else {
            return false;
        }
    }

    public boolean sign(String alias, byte[] message, CallbackContext callbackContext) throws Exception {
      KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
      keyStore.load(null);

      KeyStore.Entry entry = keyStore.getEntry(alias, null);
      if (!(entry instanceof PrivateKeyEntry))
          return false;

      PrivateKey key = ((PrivateKeyEntry) entry).getPrivateKey();
      Signature s = Signature.getInstance("SHA256withRSA");
      s.initSign(key);
      s.update(message);
      byte[] signature = s.sign();
      
      callbackContext.success(signature);
      return true;
    }

    public boolean verify(String alias, byte[] message, byte[] signature, CallbackContext callbackContext) throws Exception {
      KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
      keyStore.load(null);
      KeyStore.Entry entry = keyStore.getEntry(alias, null);
      if (!(entry instanceof PrivateKeyEntry))
          return false;

      Signature s = Signature.getInstance("SHA256withRSA");
      s.initVerify(((PrivateKeyEntry) entry).getCertificate());
      s.update(message);

      callbackContext.success(s.verify(signature) ? 1 : 0);
      return true;
    }


    private boolean createKeyPair(String alias, CallbackContext callbackContext) throws
      NoSuchAlgorithmException, NoSuchProviderException, InvalidAlgorithmParameterException {
      KeyPairGenerator kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_RSA, "AndroidKeyStore");

      Calendar start = Calendar.getInstance();
      KeyGenParameterSpec spec = new KeyGenParameterSpec.Builder(
              alias,
              KeyProperties.PURPOSE_SIGN | KeyProperties.PURPOSE_VERIFY)
              .setDigests(KeyProperties.DIGEST_SHA256)
              .setCertificateNotBefore (start.getTime())
              .setSignaturePaddings(KeyProperties.SIGNATURE_PADDING_RSA_PKCS1)
              .build();

      kpg.initialize(spec);

      callbackContext.success(kpg.generateKeyPair().getPublic().getEncoded().toString());
      return true;
    }
}
