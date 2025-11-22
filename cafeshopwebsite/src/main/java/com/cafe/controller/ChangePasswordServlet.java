package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.cafe.util.DBConnection;
import com.cafe.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/changePassword")
public class ChangePasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");

        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String oldPass = request.getParameter("oldPass");
        String newPass = request.getParameter("newPass");
        String confirmPass = request.getParameter("confirmPass");

        // SỬA 1: Nếu lỗi xác nhận mật khẩu -> Chuyển về /profile thay vì account.jsp
        if (!newPass.equals(confirmPass)) {
            response.sendRedirect(request.getContextPath() + "/profile?tab=password&error=mismatch");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sqlGetPass = "SELECT password FROM users WHERE email = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlGetPass)) {
                ps.setString(1, email);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    String currentHash = rs.getString("password");

                    // Kiểm tra mật khẩu cũ
                    if (!PasswordUtil.checkPassword(oldPass, currentHash)) {
                        // SỬA 2: Nếu sai mật khẩu cũ -> Chuyển về /profile
                        response.sendRedirect(request.getContextPath() + "/profile?tab=password&error=wrong_pass");
                        return;
                    }

                    // Cập nhật mật khẩu mới
                    String newHash = PasswordUtil.hashPassword(newPass);
                    String sqlUpdate = "UPDATE users SET password = ? WHERE email = ?";
                    
                    try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                        psUpdate.setString(1, newHash);
                        psUpdate.setString(2, email);
                        psUpdate.executeUpdate();
                    }

                    // SỬA 3 (QUAN TRỌNG NHẤT): Thành công -> Chuyển về /profile để nạp lại dữ liệu
                    response.sendRedirect(request.getContextPath() + "/profile?tab=password&status=success");
                } else {
                    session.invalidate();
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            // SỬA 4: Nếu lỗi hệ thống -> Chuyển về /profile
            response.sendRedirect(request.getContextPath() + "/profile?tab=password&status=error");
        }
    }
}