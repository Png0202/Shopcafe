package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.cafe.util.DBConnection;
import com.cafe.util.PasswordUtil; 

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password"); 

        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=db");
                return;
            }

            String sql = "SELECT * FROM users WHERE email=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String hashedPasswordFromDB = rs.getString("password");
                int permission = rs.getInt("permissions"); // Lấy quyền

                if (PasswordUtil.checkPassword(password, hashedPasswordFromDB)) {
                    HttpSession session = request.getSession();
                    session.setAttribute("userName", rs.getString("name"));
                    session.setAttribute("userEmail", rs.getString("email"));
                    session.setAttribute("permission", permission); // Lưu quyền vào session

                    // --- PHÂN QUYỀN CHUYỂN HƯỚNG ---
                    if (permission == 0) {
                        // Admin -> Trang quản trị
                        response.sendRedirect(request.getContextPath() + "/admin");
                    } else if (permission == 1) {
                        // Nhân viên -> Trang nhân viên
                        response.sendRedirect(request.getContextPath() + "/staff");
                    } else {
                        // Khách hàng -> Trang chủ (hoặc profile)
                        response.sendRedirect(request.getContextPath() + "/profile");
                    }
                } else {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?error=login_failed");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=login_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=db");
        }
    }
}