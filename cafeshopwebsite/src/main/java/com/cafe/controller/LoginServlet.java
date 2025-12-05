package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
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
                int permission = rs.getInt("permissions");

                if (PasswordUtil.checkPassword(password, hashedPasswordFromDB)) {
                    HttpSession session = request.getSession();
                    session.setAttribute("userName", rs.getString("name"));
                    session.setAttribute("userEmail", rs.getString("email"));
                    session.setAttribute("permission", permission);

                    // --- 2. XỬ LÝ REMEMBER ME (Thêm đoạn này) ---
                    String remember = request.getParameter("remember");
                    
                    // Tạo cookie chứa email và password (Lưu ý: Đồ án có thể lưu pass thường, thực tế nên mã hóa)
                    Cookie cEmail = new Cookie("c_email", email);
                    Cookie cPass = new Cookie("c_pass", password);

                    if (remember != null) {
                        // Nếu chọn ghi nhớ: Lưu trong 7 ngày (giây)
                        cEmail.setMaxAge(60 * 60 * 24 * 7);
                        cPass.setMaxAge(60 * 60 * 24 * 7);
                    } else {
                        // Nếu không chọn: Xóa cookie ngay lập tức
                        cEmail.setMaxAge(0);
                        cPass.setMaxAge(0);
                    }
                    
                    // Gửi cookie về trình duyệt
                    response.addCookie(cEmail);
                    response.addCookie(cPass);
                    // ---------------------------------------------

                    // --- PHÂN QUYỀN CHUYỂN HƯỚNG ---
                    if (permission == 0) {
                        response.sendRedirect(request.getContextPath() + "/admin");
                    } else if (permission == 1) {
                        response.sendRedirect(request.getContextPath() + "/staff");
                    } else {
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