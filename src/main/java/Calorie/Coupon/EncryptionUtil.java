package Calorie.Coupon;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import java.util.Base64;

public class EncryptionUtil {
    private static final String ALGO = "AES/GCM/NoPadding";
    private static final byte[] IV = new byte[12];
    private static final String SECRET = "0123456789abcdef";

    public static String encrypt(String str) throws Exception {
        Cipher cipher = Cipher.getInstance(ALGO);
        SecretKey key = new SecretKeySpec(SECRET.getBytes(), "AES");

        cipher.init(Cipher.ENCRYPT_MODE, key, new GCMParameterSpec(128, IV));
        byte[] encrypted = cipher.doFinal(str.getBytes());

        return Base64.getEncoder().encodeToString(encrypted);
    }

    public static String decrypt(String encrypted) throws Exception {
        Cipher cipher = Cipher.getInstance(ALGO);
        SecretKey key = new SecretKeySpec(SECRET.getBytes(), "AES");

        cipher.init(Cipher.DECRYPT_MODE, key, new GCMParameterSpec(128, IV));
        byte[] decoded = Base64.getDecoder().decode(encrypted);

        return new String(cipher.doFinal(decoded));
    }
}