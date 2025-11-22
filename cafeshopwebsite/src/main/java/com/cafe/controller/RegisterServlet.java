package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.cafe.util.DBConnection;
import com.cafe.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
            String insertQuery = "INSERT INTO users(name, email, phone, password) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertQuery)) {
                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, phone);
                ps.setString(4, hashedPassword);
                ps.executeUpdate();
            }

            // Thành công -> Chuyển về trang login (tab login sẽ tự mở vì không có error)
            response.sendRedirect(request.getContextPath() + "/login.jsp?register=success");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=db");
        }
    }
}