package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.cafe.util.DBConnection;
import com.cafe.util.EmailUtility;
import com.cafe.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/forgotPassword")
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8"); // Hỗ trợ tiếng Việt nếu cần
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        try {
            // --- GIAI ĐOẠN 1: GỬI OTP ---
            if ("send_otp".equals(action)) {
                String email = request.getParameter("email");
                
                try (Connection conn = DBConnection.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
                    ps.setString(1, email);
                    ResultSet rs = ps.executeQuery();
                    
                    if (rs.next()) {
                        String otp = EmailUtility.generateOTP();
                        EmailUtility.sendEmail(email, "Mã xác nhận đổi mật khẩu", "Mã OTP của bạn là: " + otp);
                        
                        session.setAttribute("resetOtp", otp);
                        session.setAttribute("resetEmail", email);
                        
                        response.sendRedirect("forgot_password.jsp?step=verify");
                    } else {
                        response.sendRedirect("forgot_password.jsp?error=email_not_found");
                    }
                }

            // --- GIAI ĐOẠN 2: XÁC NHẬN OTP ---
            } else if ("verify_otp".equals(action)) {
                String inputOtp = request.getParameter("otp");
                String sessionOtp = (String) session.getAttribute("resetOtp");

                if (inputOtp != null && inputOtp.equals(sessionOtp)) {
                    response.sendRedirect("forgot_password.jsp?step=reset");
                } else {
                    response.sendRedirect("forgot_password.jsp?step=verify&error=wrong_otp");
                }

            // --- GIAI ĐOẠN 3: ĐỔI MẬT KHẨU & TỰ ĐĂNG NHẬP ---
            } else if ("reset_pass".equals(action)) {
                String newPass = request.getParameter("newPassword");
                String confirmPass = request.getParameter("confirmPassword");
                String email = (String) session.getAttribute("resetEmail");

                if (newPass != null && newPass.equals(confirmPass)) {
                    String hashedPass = PasswordUtil.hashPassword(newPass);
                    
                    try (Connection conn = DBConnection.getConnection()) {
                        // 1. Cập nhật mật khẩu mới
                        String updateSql = "UPDATE users SET password = ? WHERE email = ?";
                        try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                            psUpdate.setString(1, hashedPass);
                            psUpdate.setString(2, email);
                            psUpdate.executeUpdate();
                        }

                        // 2. Lấy thông tin user để tự động đăng nhập
                        String selectSql = "SELECT name, permissions FROM users WHERE email = ?";
                        try (PreparedStatement psSelect = conn.prepareStatement(selectSql)) {
                            psSelect.setString(1, email);
                            ResultSet rs = psSelect.executeQuery();
                            
                            if (rs.next()) {
                                String name = rs.getString("name");
                                int perm = rs.getInt("permissions");

                                // 3. Thiết lập Session Đăng nhập
                                session.setAttribute("userName", name);
                                session.setAttribute("userEmail", email);
                                session.setAttribute("permission", perm);

                                // Xóa session tạm dùng để reset pass
                                session.removeAttribute("resetOtp");
                                session.removeAttribute("resetEmail");

                                // 4. Chuyển hướng dựa trên quyền hạn
                                if (perm == 0) {
                                    response.sendRedirect("admin");
                                } else if (perm == 1) {
                                    response.sendRedirect("staff");
                                } else {
                                    response.sendRedirect("profile"); // Khách hàng về trang cá nhân
                                }
                                return;
                            }
                        }
                    }
                } else {
                    response.sendRedirect("forgot_password.jsp?step=reset&error=mismatch");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("forgot_password.jsp?error=system");
        }
    }
}