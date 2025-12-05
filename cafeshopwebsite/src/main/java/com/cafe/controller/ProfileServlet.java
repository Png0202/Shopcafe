package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.cafe.model.Order;
import com.cafe.model.UserAddress;
import com.cafe.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    // GET: Hiển thị trang Profile (Thông tin, Địa chỉ, Đơn hàng)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");

        // Nếu chưa đăng nhập, chuyển về trang login
        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            
            // 1. LẤY THÔNG TIN USER (Họ tên, Email, SĐT)
            String sqlUser = "SELECT name, email, phone FROM users WHERE email = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUser)) {
                ps.setString(1, email);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    request.setAttribute("fullname", rs.getString("name"));
                    request.setAttribute("email", rs.getString("email"));
                    request.setAttribute("phone", rs.getString("phone"));
                }
            }

            // 2. LẤY DANH SÁCH ĐỊA CHỈ (Sổ địa chỉ)
            List<UserAddress> addressList = new ArrayList<>();
            String sqlAddr = "SELECT * FROM user_addresses WHERE user_email = ? ORDER BY is_default DESC, id DESC";
            try (PreparedStatement psAddr = conn.prepareStatement(sqlAddr)) {
                psAddr.setString(1, email);
                ResultSet rsAddr = psAddr.executeQuery();
                while (rsAddr.next()) {
                    addressList.add(new UserAddress(
                        rsAddr.getInt("id"),
                        rsAddr.getString("user_email"),
                        rsAddr.getString("address_line"),
                        rsAddr.getBoolean("is_default")
                    ));
                }
            }
            request.setAttribute("addressList", addressList);
            request.setAttribute("addressCount", addressList.size());

            // 3. LẤY DANH SÁCH ĐƠN HÀNG
            List<Order> orderList = new ArrayList<>();
            String sqlOrder = "SELECT * FROM orders WHERE user_email = ? ORDER BY order_date DESC";
            try (PreparedStatement psOrder = conn.prepareStatement(sqlOrder)) {
                psOrder.setString(1, email);
                ResultSet rsOrder = psOrder.executeQuery();
                while (rsOrder.next()) {
                    Order order = new Order();
                    order.setId(rsOrder.getInt("id"));
                    order.setOrderDate(rsOrder.getTimestamp("order_date"));
                    order.setAddress(rsOrder.getString("address"));
                    order.setTotalPrice(rsOrder.getDouble("total_money"));
                    order.setStatus(rsOrder.getString("status"));
                    
                    // Các thông tin chi tiết cho modal
                    order.setNote(rsOrder.getString("note"));
                    order.setPaymentMethod(rsOrder.getString("payment_method"));
                    
                    orderList.add(order);
                }
            }
            request.setAttribute("orderList", orderList);

            // Chuyển tiếp sang JSP để hiển thị
            request.getRequestDispatcher("/account.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            // Nếu có lỗi, chuyển về trang chủ để tránh lộ lỗi
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    // POST: Xử lý các hành động (Thêm/Xóa địa chỉ, Đặt mặc định, Cập nhật SĐT)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8"); // Xử lý tiếng Việt
        
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");
        String action = request.getParameter("action");

        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            
            // --- 1. THÊM ĐỊA CHỈ MỚI ---
            if ("add_address".equals(action)) {
                String newAddress = request.getParameter("address");
                
                // Kiểm tra xem đây có phải địa chỉ đầu tiên không (để set mặc định)
                boolean isFirst = true;
                String checkCount = "SELECT COUNT(*) FROM user_addresses WHERE user_email=?";
                try (PreparedStatement psCount = conn.prepareStatement(checkCount)) {
                    psCount.setString(1, email);
                    ResultSet rs = psCount.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) isFirst = false;
                }

                String sql = "INSERT INTO user_addresses(user_email, address_line, is_default) VALUES(?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, email);
                    ps.setString(2, newAddress);
                    ps.setBoolean(3, isFirst);
                    ps.executeUpdate();
                }
                
                response.sendRedirect(request.getContextPath() + "/profile?tab=addresses&status=success");
            } 
            
            // --- 2. XÓA ĐỊA CHỈ ---
            else if ("delete_address".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                // Kiểm tra xem địa chỉ sắp xóa có phải là mặc định không
                boolean wasDefault = false;
                String checkDefault = "SELECT is_default FROM user_addresses WHERE id=? AND user_email=?";
                try (PreparedStatement psCheck = conn.prepareStatement(checkDefault)) {
                    psCheck.setInt(1, id);
                    psCheck.setString(2, email);
                    ResultSet rsCheck = psCheck.executeQuery();
                    if (rsCheck.next()) {
                        wasDefault = rsCheck.getBoolean("is_default");
                    }
                }

                // Xóa địa chỉ
                String sqlDelete = "DELETE FROM user_addresses WHERE id=? AND user_email=?";
                try (PreparedStatement psDel = conn.prepareStatement(sqlDelete)) {
                    psDel.setInt(1, id);
                    psDel.setString(2, email);
                    psDel.executeUpdate();
                }

                // Nếu xóa địa chỉ mặc định -> Tìm địa chỉ khác để set làm mặc định mới
                if (wasDefault) {
                    String sqlPromote = "SELECT id FROM user_addresses WHERE user_email=? ORDER BY id DESC LIMIT 1";
                    try (PreparedStatement psPromote = conn.prepareStatement(sqlPromote)) {
                        psPromote.setString(1, email);
                        ResultSet rsPromote = psPromote.executeQuery();
                        if (rsPromote.next()) {
                            int newDefaultId = rsPromote.getInt("id");
                            String sqlUpdate = "UPDATE user_addresses SET is_default=1 WHERE id=?";
                            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                                psUpdate.setInt(1, newDefaultId);
                                psUpdate.executeUpdate();
                            }
                        }
                    }
                }
                
                response.sendRedirect(request.getContextPath() + "/profile?tab=addresses&status=deleted");
            } 
            
            // --- 3. ĐẶT LÀM MẶC ĐỊNH ---
            else if ("set_default".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                
                conn.setAutoCommit(false); // Transaction
                try {
                    // B1: Reset tất cả về 0
                    String resetSql = "UPDATE user_addresses SET is_default = 0 WHERE user_email = ?";
                    try (PreparedStatement psReset = conn.prepareStatement(resetSql)) {
                        psReset.setString(1, email);
                        psReset.executeUpdate();
                    }

                    // B2: Set địa chỉ chọn lên 1
                    String setSql = "UPDATE user_addresses SET is_default = 1 WHERE id = ? AND user_email = ?";
                    try (PreparedStatement psSet = conn.prepareStatement(setSql)) {
                        psSet.setInt(1, id);
                        psSet.setString(2, email);
                        psSet.executeUpdate();
                    }

                    conn.commit();
                } catch (Exception e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }
                
                response.sendRedirect(request.getContextPath() + "/profile?tab=addresses&status=updated");
            }

            // --- 4. CẬP NHẬT SỐ ĐIỆN THOẠI (CÓ KIỂM TRA TRÙNG) ---
            else if ("update_phone".equals(action)) {
                String phone = request.getParameter("phone");
                
                // BƯỚC 1: KIỂM TRA XEM SỐ ĐIỆN THOẠI ĐÃ TỒN TẠI CHƯA
                boolean isDuplicate = false;
                String checkSql = "SELECT id FROM users WHERE phone = ? AND email != ?"; // Kiểm tra trùng nhưng trừ chính mình ra
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setString(1, phone);
                    psCheck.setString(2, email);
                    ResultSet rs = psCheck.executeQuery();
                    if (rs.next()) {
                        isDuplicate = true;
                    }
                }

                if (isDuplicate) {
                    // Nếu trùng: Chuyển hướng về kèm thông báo lỗi
                    response.sendRedirect(request.getContextPath() + "/profile?status=phone_exists");
                } else {
                    // BƯỚC 2: NẾU KHÔNG TRÙNG THÌ CẬP NHẬT
                    String sql = "UPDATE users SET phone = ? WHERE email = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, phone);
                        ps.setString(2, email);
                        ps.executeUpdate();
                    }
                    
                    response.sendRedirect(request.getContextPath() + "/profile?status=updated");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/profile?status=error");
        }
    }
}