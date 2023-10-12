package vote.directdemocracy.plugin;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONException;

import java.security.KeyPairGenerator;
import java.security.NoSuchProviderException;
import java.security.NoSuchAlgorithmException;
import java.security.InvalidAlgorithmParameterException;
import java.util.Calendar;

import android.security.keystore.KeyProperties;
import android.security.keystore.KeyGenParameterSpec;

public class KeyStore extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {

        if (action.equals("greet")) {

            String name = data.getString(0);
            String message = "Hello, " + name;
            callbackContext.success(message);

            return true;

        } else {

            return false;

        }
    }

    private void createKeyPair() throws NoSuchAlgorithmException, NoSuchProviderException, InvalidAlgorithmParameterException {
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
    }
}
