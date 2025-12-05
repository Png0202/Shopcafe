package com.cafe.util;

import java.util.Properties;
import java.util.Random;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.UnsupportedEncodingException;

public class EmailUtility {
    
    private static final String HOST_NAME = "smtp.gmail.com";
    private static final int TSL_PORT = 587;
    private static final String APP_EMAIL = "vpn24112003@gmail.com"; 
    private static final String APP_PASSWORD = "bbhy vwpm romh pgmp"; 

    // Hàm gửi Email
    public static void sendEmail(String toAddress, String subject, String message) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", HOST_NAME);
        props.put("mail.smtp.port", TSL_PORT);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(APP_EMAIL, APP_PASSWORD);
            }
        });

        Message msg = new MimeMessage(session);
        try {
            msg.setFrom(new InternetAddress(APP_EMAIL, "Garden Coffee & Cake", "UTF-8"));
        } catch (UnsupportedEncodingException e) {
            msg.setFrom(new InternetAddress(APP_EMAIL));
        }
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toAddress));
        msg.setSubject(subject);
        msg.setContent(message, "text/html; charset=UTF-8"); 

        Transport.send(msg);
    }
    
    public static String generateOTP() {
        Random random = new Random();
        int number = random.nextInt(999999);
        return String.format("%06d", number);
    }
}