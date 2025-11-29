package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.cafe.model.CartItem;
import com.cafe.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    // GET: Hiển thị trang thanh toán HOẶC Xử lý xác nhận chuyển khoản
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Xử lý lỗi font
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");
        
        // 1. Kiểm tra xem có phải là yêu cầu xác nhận thanh toán không?
        String action = request.getParameter("action");
        if ("confirm_payment".equals(action)) {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            try (Connection conn = DBConnection.getConnection()) {
                // Cập nhật trạng thái từ "Chờ thanh toán" sang "Đang xử lý"
                String sql = "UPDATE orders SET status = 'Đang xử lý' WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, orderId);
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
            // Chuyển hướng về lịch sử đơn hàng
            response.sendRedirect(request.getContextPath() + "/profile?tab=orders&status=success");
            return;
        }

        // 2. Nếu chưa đăng nhập -> Chuyển về login
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<CartItem> cart = new ArrayList<>();
        double grandTotal = 0;

        try (Connection conn = DBConnection.getConnection()) {
            
            // 3. LẤY THÔNG TIN KHÁCH HÀNG & ĐỊA CHỈ MẶC ĐỊNH
            // Sử dụng LEFT JOIN để lấy địa chỉ từ bảng user_addresses (nơi lưu sổ địa chỉ)
            String userSql = "SELECT u.name, u.phone, ua.address_line " +
                             "FROM users u " +
                             "LEFT JOIN user_addresses ua ON u.email = ua.user_email AND ua.is_default = 1 " +
                             "WHERE u.email = ?";
            
            try (PreparedStatement psUser = conn.prepareStatement(userSql)) {
                psUser.setString(1, email);
                ResultSet rsUser = psUser.executeQuery();
                if (rsUser.next()) {
                    request.setAttribute("customerName", rsUser.getString("name"));
                    request.setAttribute("customerPhone", rsUser.getString("phone"));
                    
                    // Nếu có địa chỉ mặc định thì lấy, không thì để trống
                    String defaultAddress = rsUser.getString("address_line");
                    request.setAttribute("customerAddress", defaultAddress != null ? defaultAddress : "");
                }
            }

            // 4. LẤY DANH SÁCH TẤT CẢ ĐỊA CHỈ (Để hiện Dropdown chọn)
            List<String> addressList = new ArrayList<>();
            String addrSql = "SELECT address_line FROM user_addresses WHERE user_email = ? ORDER BY is_default DESC, id DESC";
            try (PreparedStatement psAddr = conn.prepareStatement(addrSql)) {
                psAddr.setString(1, email);
                ResultSet rsAddr = psAddr.executeQuery();
                while (rsAddr.next()) {
                    addressList.add(rsAddr.getString("address_line"));
                }
            }
            request.setAttribute("listAddresses", addressList);

            // 5. LẤY GIỎ HÀNG
            String sql = "SELECT c.product_id, p.name, p.price, c.quantity " +
                         "FROM cart_items c JOIN products p ON c.product_id = p.id " +
                         "WHERE c.user_email = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);
                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    CartItem item = new CartItem();
                    item.setProductId(rs.getInt("product_id"));
                    item.setProductName(rs.getString("name"));
                    item.setPrice(rs.getDouble("price"));
                    item.setQuantity(rs.getInt("quantity"));
                    
                    cart.add(item);
                    grandTotal += item.getPrice() * item.getQuantity();
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Nếu giỏ hàng rỗng, quay về trang cart
        if (cart.isEmpty()) {
            response.sendRedirect("cart"); 
            return;
        }

        // 6. Gửi dữ liệu sang JSP
        request.setAttribute("cartItems", cart);
        request.setAttribute("subTotal", grandTotal);
        request.setAttribute("shippingFee", 15000.0);
        request.setAttribute("finalTotal", grandTotal + 15000.0);

        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }

    // POST: Xử lý đặt hàng
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // QUAN TRỌNG: Set UTF-8 để không lỗi font chữ Việt
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");

        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Lấy dữ liệu từ Form
        String address = request.getParameter("address");
        String note = request.getParameter("notes");
        String paymentMethod = request.getParameter("paymentMethod"); 

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Tính lại tổng tiền & Lấy chi tiết giỏ hàng
            double totalMoney = 0;
            List<CartItem> cartItems = new ArrayList<>();
            
            String sqlCart = "SELECT c.quantity, p.price, p.name, p.image_url FROM cart_items c JOIN products p ON c.product_id = p.id WHERE user_email=?";
            try (PreparedStatement psCart = conn.prepareStatement(sqlCart)) {
                psCart.setString(1, email);
                ResultSet rsCart = psCart.executeQuery();
                while (rsCart.next()) {
                    CartItem item = new CartItem();
                    item.setProductName(rsCart.getString("name"));
                    item.setPrice(rsCart.getDouble("price"));
                    item.setImageUrl(rsCart.getString("image_url"));
                    item.setQuantity(rsCart.getInt("quantity"));
                    
                    cartItems.add(item);
                    totalMoney += item.getPrice() * item.getQuantity();
                }
            }
            totalMoney += 15000; // Phí ship

            // 2. XÁC ĐỊNH TRẠNG THÁI ĐƠN HÀNG
            // Nếu chuyển khoản -> "Chờ thanh toán", Tiền mặt -> "Đang xử lý"
            String initialStatus = "banking".equals(paymentMethod) ? "Chờ thanh toán" : "Đang xử lý";

            // 3. INSERT ORDERS
            String sqlOrder = "INSERT INTO orders (user_email, address, total_money, status, order_date, note, payment_method) VALUES (?, ?, ?, ?, NOW(), ?, ?)";
            int orderId = 0;
            
            try (PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setString(1, email);
                psOrder.setString(2, address);
                psOrder.setDouble(3, totalMoney);
                psOrder.setString(4, initialStatus); // Trạng thái
                psOrder.setString(5, note);
                psOrder.setString(6, paymentMethod);
                psOrder.executeUpdate();
                
                ResultSet rsKey = psOrder.getGeneratedKeys();
                if (rsKey.next()) {
                    orderId = rsKey.getInt(1);
                }
            }

            // 4. INSERT ORDER DETAILS
            String sqlDetail = "INSERT INTO order_details (order_id, product_name, price, quantity, image_url) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail)) {
                for (CartItem item : cartItems) {
                    psDetail.setInt(1, orderId);
                    psDetail.setString(2, item.getProductName());
                    psDetail.setDouble(3, item.getPrice());
                    psDetail.setInt(4, item.getQuantity());
                    psDetail.setString(5, item.getImageUrl());
                    psDetail.addBatch(); 
                }
                psDetail.executeBatch();
            }

            // 5. XÓA GIỎ HÀNG
            String sqlClear = "DELETE FROM cart_items WHERE user_email = ?";
            try (PreparedStatement psClear = conn.prepareStatement(sqlClear)) {
                psClear.setString(1, email);
                psClear.executeUpdate();
            }

            conn.commit(); // Xác nhận thành công

            // --- ĐIỀU HƯỚNG ---
            if ("banking".equals(paymentMethod)) {
                // Chuyển sang trang mã QR
                response.sendRedirect(request.getContextPath() + "/payment_qr.jsp?orderId=" + orderId + "&amount=" + (int)totalMoney);
            } else {
                // Về trang lịch sử đơn hàng
                response.sendRedirect(request.getContextPath() + "/profile?tab=orders&status=success");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/checkout?error=failed");
        }
    }
}