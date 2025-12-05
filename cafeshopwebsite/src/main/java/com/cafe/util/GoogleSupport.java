package com.cafe.util;

import java.io.IOException;
import org.apache.hc.client5.http.fluent.Form;
import org.apache.hc.client5.http.fluent.Request;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

public class GoogleSupport {
    
    // Client ID và Secret (Đã kiểm tra khớp với Google Console của bạn)
    public static final String CLIENT_ID = "197666350056-9pqv4650vrejdaurpflk52l6ks65emse.apps.googleusercontent.com"; 
    public static final String CLIENT_SECRET = "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";
    
    // --- LINK WEB THẬT TRÊN RENDER ---
    public static final String REDIRECT_URI = "https://shopcafe.onrender.com/login-google";
    // ---------------------------------
    
    public static final String LINK_GET_TOKEN = "https://accounts.google.com/o/oauth2/token";
    public static final String LINK_GET_USER_INFO = "https://www.googleapis.com/oauth2/v1/userinfo?access_token=";

    public static String getToken(String code) throws IOException {
        String response = Request.post(LINK_GET_TOKEN)
                .bodyForm(Form.form()
                        .add("client_id", CLIENT_ID)
                        .add("client_secret", CLIENT_SECRET)
                        .add("redirect_uri", REDIRECT_URI)
                        .add("code", code)
                        .add("grant_type", "authorization_code")
                        .build())
                .execute().returnContent().asString();

        JsonObject jobj = new Gson().fromJson(response, JsonObject.class);
        return jobj.get("access_token").getAsString();
    }

    public static GoogleUser getUserInfo(String accessToken) throws IOException {
        String link = LINK_GET_USER_INFO + accessToken;
        String response = Request.get(link).execute().returnContent().asString();
        return new Gson().fromJson(response, GoogleUser.class);
    }
}