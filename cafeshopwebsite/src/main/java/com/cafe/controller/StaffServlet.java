package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet; 
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.cafe.model.Order;
import com.cafe.model.Product;
import com.cafe.model.Table;
import com.cafe.util.DBConnection;

@WebServlet("/staff")
public class StaffServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        Integer perm = (Integer) session.getAttribute("permission");

        // Bảo mật: Chỉ Admin (0) và Nhân viên (1) được vào
        if (perm == null || perm > 1) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {
            
            // --- 1. AJAX: CẬP NHẬT ĐƠN ONLINE (POLLING) ---
            if ("get_online_orders_ajax".equals(action)) {
                response.setContentType("text/html;charset=UTF-8");
                String sqlOrder = "SELECT o.*, u.name AS user_name FROM orders o " +
                                  "JOIN users u ON o.user_email = u.email " +
                                  "WHERE o.order_type = 'online' AND o.status != 'Đã hủy' " + 
                                  "ORDER BY o.order_date DESC";
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

                    String badgeClass = "bg-secondary";
                    if ("Đang xử lý".equals(status)) badgeClass = "bg-warning text-dark";
                    else if ("Đang giao hàng".equals(status)) badgeClass = "bg-primary";
                    else if ("Giao hàng thành công".equals(status)) badgeClass = "bg-success";
                    else if ("Đã hủy".equals(status)) badgeClass = "bg-danger";
                    else if ("Chờ thanh toán".equals(status)) badgeClass = "bg-secondary";

                    html.append("<tr>");
                    html.append("<td class='fw-bold'>#").append(id).append("</td>");
                    html.append("<td class='fw-bold text-center'>").append(userName).append("</td>");
                    html.append("<td>").append(date).append("</td>");
                    html.append("<td class='fw-bold text-warning'>").append(String.format("%,.0f", total)).append(" đ</td>");
                    html.append("<td><span class='badge rounded-pill ").append(badgeClass).append("'>").append(status).append("</span></td>");
                    html.append("<td><div class='d-flex justify-content-center gap-2'>");
                    
                    html.append("<button class='btn btn-sm btn-info text-white fw-bold' onclick=\"viewOrderDetail('")
                        .append(id).append("', '").append(address).append("', '").append(payment).append("', '").append(note).append("')\"><i class='fa-solid fa-eye'></i> Xem</button> ");
                    
                    if ("Chờ thanh toán".equals(status) || "Đang xử lý".equals(status)) {
                        html.append("<button class='btn btn-sm btn-danger fw-bold ms-1' onclick=\"updateStatus('")
                            .append(id)
                            .append("', 'Đã hủy')\"><i class='fa-solid fa-ban'></i> Hủy</button>");
                    }

                    if ("Chờ thanh toán".equals(status)) {
                    } else if ("Đang xử lý".equals(status)) {
                        html.append("<button class='btn btn-sm btn-green fw-bold' onclick=\"updateStatus('").append(id).append("', 'Đang giao hàng')\"><i class='fa-solid fa-truck-fast'></i> Giao hàng</button>");
                    } else if ("Đang giao hàng".equals(status)) {
                        html.append("<button class='btn btn-sm btn-green fw-bold' onclick=\"updateStatus('").append(id).append("', 'Giao hàng thành công')\"><i class='fa-solid fa-check-circle'></i> Hoàn tất</button>");
                    }
                    html.append("</div></td></tr>");
                }
                response.getWriter().write(html.toString());
                return;
            }

            // --- 2. AJAX: LẤY CHI TIẾT BÀN ---
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

            // --- 4. MẶC ĐỊNH: LOAD DỮ LIỆU TRANG CHÍNH ---
            
            // A. Load Bàn
            List<Table> tables = new ArrayList<>();
            PreparedStatement psTable = conn.prepareStatement("SELECT * FROM tables");
            ResultSet rsTable = psTable.executeQuery();
            while(rsTable.next()) tables.add(new Table(rsTable.getInt("id"), rsTable.getString("name"), rsTable.getInt("status")));
            request.setAttribute("tables", tables);

            // B. Load Đơn Online (Chia làm 2 danh sách)
            List<Order> onlineOrders = new ArrayList<>();
            List<Order> cancelledOrders = new ArrayList<>(); // Danh sách cho đơn hủy
            
            // Query lấy TẤT CẢ đơn online
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
                
                // Phân loại đơn hàng
                if ("Đã hủy".equals(order.getStatus())) {
                    cancelledOrders.add(order);
                } else {
                    onlineOrders.add(order);
                }
            }
            request.setAttribute("onlineOrders", onlineOrders);
            request.setAttribute("cancelledOrders", cancelledOrders); 

            // C. LOAD DANH SÁCH SẢN PHẨM (QUAN TRỌNG: ĐỂ TAB MENU HIỆN DỮ LIỆU)
            List<Product> productList = new ArrayList<>();
            PreparedStatement psProd = conn.prepareStatement("SELECT * FROM products ORDER BY id DESC");
            ResultSet rsProd = psProd.executeQuery();
            while (rsProd.next()) {
                productList.add(new Product(
                    rsProd.getInt("id"),
                    rsProd.getString("name"),
                    rsProd.getString("description"),
                    rsProd.getDouble("price"),
                    rsProd.getString("category"),
                    rsProd.getString("image_url"),
                    rsProd.getInt("status")
                ));
            }
            request.setAttribute("productList", productList);

            request.getRequestDispatcher("/account_nhanvien.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        HttpSession session = request.getSession();
        String staffEmail = (String) session.getAttribute("userEmail"); 

        try (Connection conn = DBConnection.getConnection()) {
            
            if ("open_table".equals(action)) {
                int tableId = Integer.parseInt(request.getParameter("tableId"));
                String sql = "UPDATE tables SET status = 1 WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, tableId);
                ps.executeUpdate();
                response.sendRedirect(request.getContextPath() + "/menu?tableId=" + tableId);
                return;
            } 
            else if ("checkout_table".equals(action)) {
                int tableId = Integer.parseInt(request.getParameter("tableId"));
                double totalMoney = 0;
                String sqlSum = "SELECT SUM(c.quantity * p.price) FROM cart_items c JOIN products p ON c.product_id = p.id WHERE c.table_id = ?";
                PreparedStatement psSum = conn.prepareStatement(sqlSum);
                psSum.setInt(1, tableId);
                ResultSet rsSum = psSum.executeQuery();
                if (rsSum.next()) totalMoney = rsSum.getDouble(1);

                if (totalMoney > 0) {
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
            
            // --- XỬ LÝ QUẢN LÝ MENU (THÊM, SỬA, XÓA) ---
            else if ("add_product".equals(action)) {
                String name = request.getParameter("name");
                String desc = request.getParameter("description");
                double price = Double.parseDouble(request.getParameter("price"));
                String category = request.getParameter("category");
                String img = request.getParameter("image_url");

                String sql = "INSERT INTO products (name, description, price, category, image_url) VALUES (?, ?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setString(2, desc);
                ps.setDouble(3, price);
                ps.setString(4, category);
                ps.setString(5, img);
                ps.executeUpdate();
                response.sendRedirect("staff?tab=menu&status=success");

            } else if ("edit_product".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String name = request.getParameter("name");
                String desc = request.getParameter("description");
                double price = Double.parseDouble(request.getParameter("price"));
                String category = request.getParameter("category");
                String img = request.getParameter("image_url");

                String sql = "UPDATE products SET name=?, description=?, price=?, category=?, image_url=? WHERE id=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setString(2, desc);
                ps.setDouble(3, price);
                ps.setString(4, category);
                ps.setString(5, img);
                ps.setInt(6, id);
                ps.executeUpdate();
                response.sendRedirect("staff?tab=menu&status=updated");

            } else if ("delete_product".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String sql = "DELETE FROM products WHERE id=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, id);
                ps.executeUpdate();
                response.sendRedirect("staff?tab=menu&status=deleted");
            }
            // --- 6. KHÓA / MỞ MÓN ĂN ---
            else if ("toggle_product_status".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                int currentStatus = Integer.parseInt(request.getParameter("currentStatus"));
                
                // Đảo ngược trạng thái: Nếu đang 1 (Bán) -> thành 0 (Hết) và ngược lại
                int newStatus = (currentStatus == 1) ? 0 : 1;
                
                try (PreparedStatement ps = conn.prepareStatement("UPDATE products SET status = ? WHERE id = ?")) {
                    ps.setInt(1, newStatus);
                    ps.setInt(2, id);
                    ps.executeUpdate();
                }
                response.sendRedirect("staff?tab=menu&status=updated");
            }
            // --- THÊM BÀN MỚI (MỚI) ---
            else if ("add_table".equals(action)) {
                String tableName = request.getParameter("tableName");
                
                // Mặc định thêm bàn với trạng thái 0 (Trống)
                String sql = "INSERT INTO tables (name, status) VALUES (?, 0)";
                
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, tableName);
                ps.executeUpdate();
                
                // Quay lại tab POS
                response.sendRedirect("staff?tab=pos&status=success");
            }
            // --- SỬA TÊN BÀN ---
            else if ("edit_table".equals(action)) {
                int id = Integer.parseInt(request.getParameter("tableId"));
                String name = request.getParameter("tableName");
                
                String sql = "UPDATE tables SET name = ? WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setInt(2, id);
                ps.executeUpdate();
                
                response.sendRedirect("staff?tab=pos&status=updated");
            }
            // --- XÓA BÀN ---
            else if ("delete_table".equals(action)) {
                int id = Integer.parseInt(request.getParameter("tableId"));
                
                // Xóa giỏ hàng liên quan trước (nếu có rác)
                PreparedStatement psCart = conn.prepareStatement("DELETE FROM cart_items WHERE table_id = ?");
                psCart.setInt(1, id);
                psCart.executeUpdate();
                
                // Sau đó xóa bàn
                String sql = "DELETE FROM tables WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, id);
                ps.executeUpdate();
                
                response.sendRedirect("staff?tab=pos&status=deleted");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staff?error=failed");
            
        }
    }
}