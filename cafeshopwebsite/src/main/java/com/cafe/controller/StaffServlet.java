package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.cafe.model.Order;
import com.cafe.model.Table;
import com.cafe.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/staff")
public class StaffServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer perm = (Integer) session.getAttribute("permission");

        // Bảo mật
        if (perm == null || perm > 1) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {
            
            // --- 1. AJAX: CẬP NHẬT ĐƠN ONLINE (POLLING) ---
            if ("get_online_orders_ajax".equals(action)) {
                response.setContentType("text/html;charset=UTF-8");
                
                String sqlOrder = "SELECT o.*, u.name AS user_name FROM orders o JOIN users u ON o.user_email = u.email WHERE o.order_type = 'online' ORDER BY o.order_date DESC";
                PreparedStatement psOrder = conn.prepareStatement(sqlOrder);
                ResultSet rsOrder = psOrder.executeQuery();
                
                StringBuilder html = new StringBuilder();
                
                while (rsOrder.next()) {
                    int id = rsOrder.getInt("id");
                    String userName = rsOrder.getString("user_name");
                    String date = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rsOrder.getTimestamp("order_date"));
                    double total = rsOrder.getDouble("total_money");
                    String status = rsOrder.getString("status");
                    
                    String address = rsOrder.getString("address");
                    String payment = rsOrder.getString("payment_method");
                    String note = rsOrder.getString("note");

                    // --- [SỬA 1] CẬP NHẬT LOGIC BADGE VỚI TRẠNG THÁI MỚI ---
                    String badgeClass = "bg-secondary"; // Mặc định (Chờ thanh toán)
                    
                    if ("Đang xử lý".equals(status)) badgeClass = "status-new";
                    else if ("Đang giao hàng".equals(status)) badgeClass = "status-shipping";
                    else if ("Giao hàng thành công".equals(status)) badgeClass = "status-done"; 
                    else if ("Đã hủy".equals(status)) badgeClass = "status-cancel";
                    else if ("Chờ thanh toán".equals(status)) badgeClass = "status-waiting";

                    // Tạo HTML dòng tr chuẩn Bootstrap
                    html.append("<tr>");
                    html.append("<td><strong>#").append(id).append("</strong></td>");
                    html.append("<td class='fw-bold text-center'>").append(userName).append("</td>");
                    html.append("<td>").append(date).append("</td>");
                    html.append("<td class='fw-bold text-warning'>").append(String.format("%,.0f", total)).append(" đ</td>");
                    html.append("<td><span class='badge rounded-pill ").append(badgeClass.replace("status-", "bg-").replace("new", "warning text-dark").replace("shipping", "primary").replace("done", "success").replace("cancel", "danger").replace("waiting", "secondary")).append("'>").append(status).append("</span></td>");
                    html.append("<td><div class='d-flex justify-content-center gap-2'>");
                    
                    // Nút Xem
                    html.append("<button class='btn btn-sm btn-info text-white fw-bold' onclick=\"viewOrderDetail('")
                        .append(id).append("', '").append(address).append("', '").append(payment).append("', '").append(note).append("')\"><i class='fa-solid fa-eye'></i> Xem</button> ");
                    
                    // Nút Hành động
                    if ("Chờ thanh toán".equals(status)) {} 
                    else if ("Đang xử lý".equals(status)) {
                        html.append("<button class='btn btn-sm btn-primary fw-bold' onclick=\"updateStatus('").append(id).append("', 'Đang giao hàng')\"><i class='fa-solid fa-truck-fast'></i> Giao hàng</button>");
                    } 
                    else if ("Đang giao hàng".equals(status)) {
                        html.append("<button class='btn btn-sm btn-success fw-bold' onclick=\"updateStatus('").append(id).append("', 'Giao hàng thành công')\"><i class='fa-solid fa-check-circle'></i> Hoàn tất</button>");
                    }
                    html.append("</div></td></tr>");
                }
                
                response.getWriter().write(html.toString());
                return;
            }

            // --- 2. AJAX: LẤY CHI TIẾT MÓN ĂN CỦA BÀN ---
            if ("get_table_detail".equals(action)) {
                int tableId = Integer.parseInt(request.getParameter("tableId"));
                response.setContentType("text/html;charset=UTF-8");
                
                String sql = "SELECT p.name, c.quantity, p.price, c.note FROM cart_items c JOIN products p ON c.product_id = p.id WHERE c.table_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, tableId);
                ResultSet rs = ps.executeQuery();
                
                StringBuilder html = new StringBuilder();
                html.append("<table style='width:100%; font-size:14px; border-collapse: collapse;'>");
                boolean hasItem = false;
                double total = 0;
                while(rs.next()) {
                    hasItem = true;
                    String name = rs.getString("name");
                    int qty = rs.getInt("quantity");
                    double price = rs.getDouble("price");
                    String note = rs.getString("note");
                    double subtotal = price * qty;
                    total += subtotal;
                    
                    html.append("<tr style='border-bottom:1px dashed #eee;'>");
                    html.append("<td style='padding:5px;'>").append(name);
                    if(note != null && !note.isEmpty()) html.append("<br><i style='color:gray; font-size:12px;'>(").append(note).append(")</i>");
                    html.append("</td>");
                    html.append("<td style='padding:5px; text-align:center;'>x").append(qty).append("</td>");
                    html.append("<td style='padding:5px; text-align:right;'>").append(String.format("%,.0f", subtotal)).append("</td>");
                    html.append("</tr>");
                }
                html.append("</table>");
                if(!hasItem) html.append("<p style='text-align:center; color:#888; margin:10px 0;'>Chưa có món nào.</p>");
                else html.append("<div style='text-align:right; font-weight:bold; margin-top:10px; color:#d35400;'>Tổng: ").append(String.format("%,.0f", total)).append(" VNĐ</div>");
                
                response.getWriter().write(html.toString());
                return;
            }

            // --- 3. UPDATE TRẠNG THÁI ---
            if ("update_status".equals(action)) {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String status = request.getParameter("status");
                String sql = "UPDATE orders SET status = ? WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, status);
                ps.setInt(2, orderId);
                ps.executeUpdate();
                response.sendRedirect("staff?tab=online"); 
                return;
            }

            // --- 4. MẶC ĐỊNH: LOAD TRANG ---
            List<Table> tables = new ArrayList<>();
            String sqlTable = "SELECT * FROM tables";
            PreparedStatement psTable = conn.prepareStatement(sqlTable);
            ResultSet rsTable = psTable.executeQuery();
            while(rsTable.next()){
                tables.add(new Table(rsTable.getInt("id"), rsTable.getString("name"), rsTable.getInt("status")));
            }
            request.setAttribute("tables", tables);

            List<Order> onlineOrders = new ArrayList<>();
            String sqlOrder = "SELECT o.*, u.name AS user_name FROM orders o JOIN users u ON o.user_email = u.email WHERE o.order_type = 'online' ORDER BY o.order_date DESC";
            PreparedStatement psOrder = conn.prepareStatement(sqlOrder);
            ResultSet rsOrder = psOrder.executeQuery();
            while (rsOrder.next()) {
                Order order = new Order();
                order.setId(rsOrder.getInt("id"));
                order.setUserEmail(rsOrder.getString("user_name"));
                order.setOrderDate(rsOrder.getTimestamp("order_date"));
                order.setTotalPrice(rsOrder.getDouble("total_money"));
                order.setStatus(rsOrder.getString("status"));
                order.setAddress(rsOrder.getString("address"));
                order.setPaymentMethod(rsOrder.getString("payment_method"));
                order.setNote(rsOrder.getString("note"));
                onlineOrders.add(order);
            }
            request.setAttribute("onlineOrders", onlineOrders);

            request.getRequestDispatcher("/account_nhanvien.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        int tableId = Integer.parseInt(request.getParameter("tableId"));
        HttpSession session = request.getSession();
        String staffEmail = (String) session.getAttribute("userEmail"); 

        try (Connection conn = DBConnection.getConnection()) {
            
            if ("open_table".equals(action)) {
                String sql = "UPDATE tables SET status = 1 WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, tableId);
                ps.executeUpdate();
                response.sendRedirect(request.getContextPath() + "/menu?tableId=" + tableId);
                return;
            } 
            else if ("checkout_table".equals(action)) {
                double totalMoney = 0;
                String sqlSum = "SELECT SUM(c.quantity * p.price) FROM cart_items c JOIN products p ON c.product_id = p.id WHERE c.table_id = ?";
                PreparedStatement psSum = conn.prepareStatement(sqlSum);
                psSum.setInt(1, tableId);
                ResultSet rsSum = psSum.executeQuery();
                if (rsSum.next()) totalMoney = rsSum.getDouble(1);

                if (totalMoney > 0) {
                    // [SỬA 3] Cập nhật trạng thái khi thanh toán tại bàn: 'Giao hàng thành công'
                    String sqlOrder = "INSERT INTO orders (user_email, address, total_money, status, order_date, order_type, table_id) VALUES (?, ?, ?, 'Giao hàng thành công', NOW(), 'offline', ?)";
                    PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
                    psOrder.setString(1, staffEmail);
                    psOrder.setString(2, "Tại bàn số " + tableId);
                    psOrder.setDouble(3, totalMoney);
                    psOrder.setInt(4, tableId);
                    psOrder.executeUpdate();
                    
                    int orderId = 0;
                    ResultSet rsKey = psOrder.getGeneratedKeys();
                    if(rsKey.next()) orderId = rsKey.getInt(1);

                    String sqlDetail = "INSERT INTO order_details (order_id, product_name, price, quantity, image_url) SELECT ?, p.name, p.price, c.quantity, p.image_url FROM cart_items c JOIN products p ON c.product_id = p.id WHERE c.table_id = ?";
                    PreparedStatement psDetail = conn.prepareStatement(sqlDetail);
                    psDetail.setInt(1, orderId);
                    psDetail.setInt(2, tableId);
                    psDetail.executeUpdate();
                }

                String sqlTable = "UPDATE tables SET status = 0 WHERE id = ?";
                PreparedStatement psTable = conn.prepareStatement(sqlTable);
                psTable.setInt(1, tableId);
                psTable.executeUpdate();

                String sqlClear = "DELETE FROM cart_items WHERE table_id = ?";
                PreparedStatement psClear = conn.prepareStatement(sqlClear);
                psClear.setInt(1, tableId);
                psClear.executeUpdate();
                
                response.sendRedirect("staff");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}