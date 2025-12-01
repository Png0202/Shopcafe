package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.cafe.util.DBConnection;
import com.cafe.util.PasswordUtil;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer perm = (Integer) session.getAttribute("permission");

        if (perm == null || perm != 0) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {
            
            // --- A. XỬ LÝ AJAX: BÁO CÁO CHI TIẾT ---
            if ("get_report".equals(action)) {
                response.setContentType("text/html;charset=UTF-8");
                String type = request.getParameter("type");
                
                String groupBy = "DATE(order_date)";
                if ("month".equals(type)) groupBy = "DATE_FORMAT(order_date, '%Y-%m')";
                else if ("year".equals(type)) groupBy = "YEAR(order_date)";

                // [SỬA 1] Chỉ đếm đơn hàng thành công trong báo cáo
                String sql = "SELECT " +
                             groupBy + " AS time_point, " +
                             "SUM(CASE WHEN status IN ('Giao hàng thành công', 'Đã giao') THEN 1 ELSE 0 END) AS total_orders, " + // Sửa dòng này
                             "SUM(CASE WHEN status IN ('Giao hàng thành công', 'Đã giao') THEN total_money ELSE 0 END) AS revenue " +
                             "FROM orders " +
                             "GROUP BY time_point " +
                             "HAVING total_orders > 0 " + // Chỉ hiện những ngày có đơn thành công
                             "ORDER BY time_point DESC LIMIT 50";

                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery();
                
                StringBuilder html = new StringBuilder();
                boolean hasData = false;
                
                while (rs.next()) {
                    hasData = true;
                    String timeDisplay = rs.getString("time_point");
                    if ("day".equals(type)) {
                        try {
                            java.sql.Date date = rs.getDate("time_point");
                            if (date != null) timeDisplay = new java.text.SimpleDateFormat("dd/MM/yyyy").format(date);
                        } catch (Exception e) {}
                    } else if ("month".equals(type)) {
                        String[] parts = timeDisplay.split("-");
                        if(parts.length == 2) timeDisplay = "Tháng " + parts[1] + "/" + parts[0];
                    } else if ("year".equals(type)) {
                        timeDisplay = "Năm " + timeDisplay;
                    }
                    
                    int orders = rs.getInt("total_orders");
                    double rev = rs.getDouble("revenue");
                    
                    html.append("<tr>");
                    html.append("<td>").append(timeDisplay).append("</td>");
                    html.append("<td class='text-center'>").append(orders).append("</td>");
                    html.append("<td class='text-end fw-bold text-warning'>").append(String.format("%,.0f", rev)).append(" VNĐ</td>");
                    html.append("</tr>");
                }
                
                if (!hasData) html.append("<tr><td colspan='3' class='text-center text-muted'>Chưa có dữ liệu kinh doanh</td></tr>");
                
                response.getWriter().write(html.toString());
                return;
            }

            // --- B. LOAD DASHBOARD ---

            // Tổng doanh thu
            String sqlRevenue = "SELECT SUM(total_money) FROM orders WHERE status IN ('Giao hàng thành công', 'Đã giao')";
            try (PreparedStatement psRev = conn.prepareStatement(sqlRevenue)) {
                ResultSet rsRev = psRev.executeQuery();
                request.setAttribute("totalRevenue", rsRev.next() ? rsRev.getDouble(1) : 0.0);
            }

            // [SỬA 2] Tổng đơn hàng: Chỉ đếm đơn thành công
            String sqlOrders = "SELECT COUNT(*) FROM orders WHERE status IN ('Giao hàng thành công', 'Đã giao')";
            try (PreparedStatement ps = conn.prepareStatement(sqlOrders)) {
                ResultSet rs = ps.executeQuery();
                if (rs.next()) request.setAttribute("totalOrders", rs.getInt(1));
            }

            // Số lượng nhân viên/khách (Giữ nguyên)
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

            // Danh sách tài khoản (Giữ nguyên)
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
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    // doPost giữ nguyên...
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Integer perm = (Integer) session.getAttribute("permission");
        if (perm == null || perm != 0) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        String action = request.getParameter("action");
        try (Connection conn = DBConnection.getConnection()) {
            if ("update_user".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                String name = request.getParameter("fullname");
                String email = request.getParameter("email");
                int newPerm = Integer.parseInt(request.getParameter("permission"));
                String newPass = request.getParameter("newPassword");
                String sql;
                PreparedStatement ps;
                if (newPass != null && !newPass.trim().isEmpty()) {
                    String hashedPassword = PasswordUtil.hashPassword(newPass);
                    sql = "UPDATE users SET name=?, email=?, permissions=?, password=? WHERE id=?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, name);
                    ps.setString(2, email);
                    ps.setInt(3, newPerm);
                    ps.setString(4, hashedPassword);
                    ps.setInt(5, userId);
                } else {
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
            response.sendRedirect(request.getContextPath() + "/admin?error=failed");
        }
    }
}