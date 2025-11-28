package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.cafe.util.DBConnection;
import com.cafe.util.PasswordUtil; // Nhớ import cái này để Hash mật khẩu

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    // GET: Giữ nguyên không đổi
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // ... (Code phần doGet GIỮ NGUYÊN NHƯ CŨ) ...
        // Copy lại y hệt phần doGet từ code cũ của bạn
        HttpSession session = request.getSession();
        Integer perm = (Integer) session.getAttribute("permission");

        if (perm == null || perm != 0) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sqlRevenue = "SELECT SUM(total_money) FROM orders WHERE status = 'Đã giao'";
            try (PreparedStatement psRev = conn.prepareStatement(sqlRevenue)) {
                ResultSet rsRev = psRev.executeQuery();
                request.setAttribute("totalRevenue", rsRev.next() ? rsRev.getDouble(1) : 0.0);
            }

            String sqlOrders = "SELECT COUNT(*) FROM orders";
            try (PreparedStatement ps = conn.prepareStatement(sqlOrders)) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) request.setAttribute("totalOrders", rs.getInt(1));
            }

            int staffCount = 0;
            int customerCount = 0;
            String sqlCount = "SELECT permissions, COUNT(*) FROM users GROUP BY permissions";
            try (PreparedStatement ps = conn.prepareStatement(sqlCount)) {
                ResultSet rs = ps.executeQuery();
                while(rs.next()) {
                    int p = rs.getInt(1);
                    int count = rs.getInt(2);
                    if(p == 1) staffCount = count;
                    if(p == 2) customerCount = count;
                }
            }
            request.setAttribute("staffCount", staffCount);
            request.setAttribute("customerCount", customerCount);

            List<String[]> users = new ArrayList<>();
            String sqlUsers = "SELECT id, name, email, permissions FROM users ORDER BY permissions ASC, id ASC";
            try (PreparedStatement psUsers = conn.prepareStatement(sqlUsers)) {
                ResultSet rsUsers = psUsers.executeQuery();
                while(rsUsers.next()){
                    int roleId = rsUsers.getInt("permissions");
                    String roleName = (roleId == 0) ? "Chủ" : (roleId == 1 ? "Nhân viên" : "Khách");
                    users.add(new String[]{
                        String.valueOf(rsUsers.getInt("id")), 
                        rsUsers.getString("name"), 
                        rsUsers.getString("email"), 
                        roleName
                    });
                }
            }
            request.setAttribute("userList", users);
            request.getRequestDispatcher("/account_admin.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }

    // POST: CẬP NHẬT (ĐÃ SỬA ĐỂ UPDATE TÊN, MAIL, PASS)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer perm = (Integer) session.getAttribute("permission");

        if (perm == null || perm != 0) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {
            
            if ("update_user".equals(action)) { // Đổi tên action cho khớp
                int userId = Integer.parseInt(request.getParameter("userId"));
                String name = request.getParameter("fullname");
                String email = request.getParameter("email");
                int newPerm = Integer.parseInt(request.getParameter("permission"));
                String newPass = request.getParameter("newPassword");

                // Logic: Nếu ô mật khẩu không rỗng thì update cả mật khẩu, ngược lại chỉ update thông tin
                String sql;
                PreparedStatement ps;

                if (newPass != null && !newPass.trim().isEmpty()) {
                    // Có đổi mật khẩu -> Hash mật khẩu mới
                    String hashedPassword = PasswordUtil.hashPassword(newPass);
                    
                    sql = "UPDATE users SET name=?, email=?, permissions=?, password=? WHERE id=?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, name);
                    ps.setString(2, email);
                    ps.setInt(3, newPerm);
                    ps.setString(4, hashedPassword);
                    ps.setInt(5, userId);
                } else {
                    // Không đổi mật khẩu
                    sql = "UPDATE users SET name=?, email=?, permissions=? WHERE id=?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, name);
                    ps.setString(2, email);
                    ps.setInt(3, newPerm);
                    ps.setInt(4, userId);
                }

                ps.executeUpdate();
                response.sendRedirect(request.getContextPath() + "/admin?status=updated");
            }

        } catch (Exception e) {
            e.printStackTrace();
            // Nếu lỗi (ví dụ trùng email)
            response.sendRedirect(request.getContextPath() + "/admin?error=failed");
        }
    }
}