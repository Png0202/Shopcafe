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

    // GET: Hiển thị trang thanh toán
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");

        // 1. Nếu chưa đăng nhập -> Chuyển về login
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<CartItem> cart = new ArrayList<>();
        double grandTotal = 0;

        try (Connection conn = DBConnection.getConnection()) {
        
            // 2. Lấy thông tin cơ bản (Tên, SĐT) để điền sẵn vào form
            String userSql = "SELECT name, phone FROM users WHERE email = ?";
            try (PreparedStatement psUser = conn.prepareStatement(userSql)) {
                psUser.setString(1, email);
                ResultSet rsUser = psUser.executeQuery();
                if (rsUser.next()) {
                    request.setAttribute("customerName", rsUser.getString("name"));
                    request.setAttribute("customerPhone", rsUser.getString("phone"));
                }
            }

            // 3. LẤY DANH SÁCH ĐỊA CHỈ (Sổ địa chỉ) để hiển thị trong Dropdown
            // Sắp xếp: Địa chỉ mặc định lên đầu tiên
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

            // 4. LẤY GIỎ HÀNG để hiển thị tóm tắt
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
                    grandTotal += item.getPrice() * item.getQuantity(); // Tính tổng tiền
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Nếu giỏ hàng rỗng, không cho vào trang thanh toán
        if (cart.isEmpty()) {
            response.sendRedirect("cart"); 
            return;
        }

        // 5. Gửi dữ liệu sang JSP
        request.setAttribute("cartItems", cart);
        request.setAttribute("subTotal", grandTotal);
        request.setAttribute("shippingFee", 15000.0); // Phí ship cố định 15k
        request.setAttribute("finalTotal", grandTotal + 15000.0);

        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }

    // POST: Xử lý đặt hàng
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");

        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Lấy dữ liệu từ Form Checkout
        String address = request.getParameter("address");
        String note = request.getParameter("notes");
        String paymentMethod = request.getParameter("paymentMethod"); // Lấy phương thức thanh toán

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Bắt đầu Transaction (Giao dịch)

            // 1. Tính lại tổng tiền & Lấy chi tiết giỏ hàng (Để lưu vào order_details)
            double totalMoney = 0;
            List<CartItem> cartItems = new ArrayList<>();
            
            // Cần lấy thêm image_url và name để lưu cố định vào detail đơn hàng
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
            totalMoney += 15000; // Cộng phí ship 15k

            // 2. INSERT ORDERS (Thêm note, payment_method)
            String sqlOrder = "INSERT INTO orders (user_email, address, total_money, status, order_date, note, payment_method) VALUES (?, ?, ?, 'Đang xử lý', NOW(), ?, ?)";
            int orderId = 0;
            
            try (PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setString(1, email);
                psOrder.setString(2, address);
                psOrder.setDouble(3, totalMoney);
                psOrder.setString(4, note);
                psOrder.setString(5, paymentMethod);
                psOrder.executeUpdate();
                
                // Lấy ID của đơn hàng vừa tạo
                ResultSet rsKey = psOrder.getGeneratedKeys();
                if (rsKey.next()) {
                    orderId = rsKey.getInt(1);
                }
            }

            // 3. INSERT ORDER DETAILS (Lưu từng món ăn vào bảng chi tiết)
            String sqlDetail = "INSERT INTO order_details (order_id, product_name, price, quantity, image_url) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail)) {
                for (CartItem item : cartItems) {
                    psDetail.setInt(1, orderId);
                    psDetail.setString(2, item.getProductName());
                    psDetail.setDouble(3, item.getPrice());
                    psDetail.setInt(4, item.getQuantity());
                    psDetail.setString(5, item.getImageUrl());
                    psDetail.addBatch(); // Gom lại chạy 1 lần cho tối ưu
                }
                psDetail.executeBatch();
            }

            // 4. Xóa giỏ hàng sau khi đặt thành công
            String sqlClear = "DELETE FROM cart_items WHERE user_email = ?";
            try (PreparedStatement psClear = conn.prepareStatement(sqlClear)) {
                psClear.setString(1, email);
                psClear.executeUpdate();
            }

            conn.commit(); // Xác nhận Transaction thành công

            // Chuyển hướng về trang quản lý đơn hàng (Tab Orders)
            response.sendRedirect(request.getContextPath() + "/profile?tab=orders&status=success");

        } catch (Exception e) {
            e.printStackTrace(); // In lỗi ra Console của Eclipse/VS Code
            
            // SỬA ĐOẠN NÀY ĐỂ XEM LỖI TRỰC TIẾP TRÊN TRÌNH DUYỆT
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3>Lỗi đặt hàng:</h3>");
            response.getWriter().println("<p style='color:red'>" + e.getMessage() + "</p>");
            response.getWriter().println("<pre>");
            e.printStackTrace(response.getWriter());
            response.getWriter().println("</pre>");
            
            // Tạm thời comment dòng chuyển hướng này lại
            // response.sendRedirect(request.getContextPath() + "/checkout?error=failed");
        }
    }
}