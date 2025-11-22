package com.cafe.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    // Băm mật khẩu (dùng khi đăng ký)
    public static String hashPassword(String plainTextPassword) {
        return BCrypt.hashpw(plainTextPassword, BCrypt.gensalt(12));
    }

    // Kiểm tra mật khẩu (dùng khi đăng nhập)
    public static boolean checkPassword(String plainTextPassword, String hashedPassword) {
        return BCrypt.checkpw(plainTextPassword, hashedPassword);
    }
}