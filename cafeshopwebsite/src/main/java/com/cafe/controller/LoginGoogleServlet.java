package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.cafe.util.DBConnection;
import com.cafe.util.GoogleSupport;
import com.cafe.util.GoogleUser; 

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet; 
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login-google")
public class LoginGoogleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("code");
        
        if (code == null || code.isEmpty()) {
            response.sendRedirect("login.jsp?error=google_error");
            return;
        }

        try {
            // 1. Lấy thông tin từ Google
            String accessToken = GoogleSupport.getToken(code);
            GoogleUser googleUser = GoogleSupport.getUserInfo(accessToken);
            String email = googleUser.email;
            String name = googleUser.name;

            // 2. Kiểm tra trong Database
            try (Connection conn = DBConnection.getConnection()) {
                String sqlCheck = "SELECT * FROM users WHERE email = ?";
                PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
                psCheck.setString(1, email);
                ResultSet rs = psCheck.executeQuery();

                if (rs.next()) {
                    // --- TRƯỜNG HỢP 1: ĐÃ CÓ TÀI KHOẢN -> ĐĂNG NHẬP ---
                    HttpSession session = request.getSession();
                    session.setAttribute("userName", rs.getString("name"));
                    session.setAttribute("userEmail", rs.getString("email"));
                    session.setAttribute("permission", rs.getInt("permissions"));

                    // Phân quyền chuyển hướng
                    int perm = rs.getInt("permissions");
                    if(perm == 0) response.sendRedirect("admin");
                    else if(perm == 1) response.sendRedirect("staff");
                    else response.sendRedirect("profile");

                } else {
                    // --- TRƯỜNG HỢP 2: CHƯA CÓ TÀI KHOẢN -> TỰ ĐỘNG ĐĂNG KÝ ---
                    String sqlInsert = "INSERT INTO users (name, email, password, phone, permissions) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement psInsert = conn.prepareStatement(sqlInsert);
                    psInsert.setString(1, name);
                    psInsert.setString(2, email);
                    psInsert.setString(3, "GOOGLE_LOGIN"); // Mật khẩu giả định
                    psInsert.setString(4, ""); // SĐT trống
                    psInsert.setInt(5, 2); // Quyền khách hàng
                    psInsert.executeUpdate();

                    // Đăng nhập luôn sau khi tạo
                    HttpSession session = request.getSession();
                    session.setAttribute("userName", name);
                    session.setAttribute("userEmail", email);
                    session.setAttribute("permission", 2);
                    
                    response.sendRedirect("profile");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=google_error");
        }
    }
}