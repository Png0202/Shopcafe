package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.cafe.util.DBConnection;
import com.cafe.util.PasswordUtil;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");        

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
                // Kiểm tra mật khẩu
                if (PasswordUtil.checkPassword(password, hashedPasswordFromDB)) {
                    HttpSession session = request.getSession();
                    session.setAttribute("userName", rs.getString("name"));
                    session.setAttribute("userEmail", rs.getString("email"));
                    response.sendRedirect(request.getContextPath() + "/index.jsp");
                } else {
                    // Sai mật khẩu
                    response.sendRedirect(request.getContextPath() + "/login.jsp?error=login_failed");
                }
            } else {
                // Không tìm thấy email
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=login_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=db");
        }
    }
}