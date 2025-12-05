package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.cafe.util.DBConnection;
import com.cafe.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Xử lý tiếng Việt
        request.setCharacterEncoding("UTF-8");
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // 1. Kiểm tra xác nhận mật khẩu
        if (!password.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=password_mismatch");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            
            // 2. Kiểm tra Email trùng
            String checkEmailQuery = "SELECT id FROM users WHERE email = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkEmailQuery)) {
                ps.setString(1, email);
                if (ps.executeQuery().next()) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?error=email_exists");
                    return;
                }
            }

            // 3. Kiểm tra Số điện thoại trùng
            String checkPhoneQuery = "SELECT id FROM users WHERE phone = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkPhoneQuery)) {
                ps.setString(1, phone);
                if (ps.executeQuery().next()) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?error=phone_exists");
                    return;
                }
            }

            // 4. Hash mật khẩu và Lưu vào DB
            String hashedPassword = PasswordUtil.hashPassword(password);
            
            // Lưu ý: Thêm cột permissions mặc định là 2 (Khách hàng) nếu DB không tự set default
            String insertQuery = "INSERT INTO users(name, email, phone, password, permissions) VALUES (?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = conn.prepareStatement(insertQuery)) {
                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, phone);
                ps.setString(4, hashedPassword);
                ps.setInt(5, 2); // 2: Quyền Khách hàng
                ps.executeUpdate();
            }

            // --- 5. TỰ ĐỘNG ĐĂNG NHẬP (MỚI) ---
            HttpSession session = request.getSession();
            session.setAttribute("userName", name);
            session.setAttribute("userEmail", email);
            session.setAttribute("permission", 2); // Lưu quyền khách hàng

            // Chuyển thẳng về trang chủ (hoặc trang profile)
            response.sendRedirect(request.getContextPath() + "/home");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=db");
        }
    }
}