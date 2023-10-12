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
import java.util.Calendar;

import android.security.keystore.KeyProperties;
import android.security.keystore.KeyGenParameterSpec;

public class DdKeyStore extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException; {

        if (action.equals("greet")) {

            String name = data.getString(0);
            String message = "Hello, " + name;
            callbackContext.success(message);

            return true;

        } else if (action.equals("createKeyPair")){
          return createKeyPair();
        } else {

            return false;

        }
    }

    public boolean sign(String message, CallbackContext callbackContext) throws Exception {
      byte[] messageBytes = message.getBytes("UTF-8");
      KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
      keyStore.load(null);
      KeyStore.Entry entry = keyStore.getEntry("directdemocracyAppKey", null);
      if (!(entry instanceof PrivateKeyEntry)) {
          return false;
      }
      Signature s = Signature.getInstance("SHA256withECDSA");
      s.initSign(((PrivateKeyEntry) entry).getPrivateKey());
      s.update(messageBytes);
      byte[] signature = s.sign();
      callbackContext.success(new String(signature, "UTF-8"));
      return true;
    }


    private boolean createKeyPair() throws NoSuchAlgorithmException, NoSuchProviderException, InvalidAlgorithmParameterException {
      KeyPairGenerator kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_RSA, "AndroidKeyStore");

      Calendar start = Calendar.getInstance();
      KeyGenParameterSpec spec = new KeyGenParameterSpec.Builder(
              "directdemocracyAppKey",
              KeyProperties.PURPOSE_SIGN | KeyProperties.PURPOSE_VERIFY)
              .setDigests(KeyProperties.DIGEST_SHA512)
              .setKeyValidityStart(start.getTime())
              .build();

      kpg.initialize(spec);

      kpg.generateKeyPair();
      return true;
    }
}
