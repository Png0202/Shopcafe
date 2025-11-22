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
        
        // 1. Lấy thông tin cơ bản (Tên, SĐT)
        String userSql = "SELECT name, phone FROM users WHERE email = ?";
        PreparedStatement psUser = conn.prepareStatement(userSql);
        psUser.setString(1, email);
        ResultSet rsUser = psUser.executeQuery();
        if (rsUser.next()) {
            request.setAttribute("customerName", rsUser.getString("name"));
            request.setAttribute("customerPhone", rsUser.getString("phone"));
        }

        // 2. LẤY DANH SÁCH ĐỊA CHỈ (Sổ địa chỉ)
        // Sắp xếp: Địa chỉ mặc định lên đầu tiên
        List<String> addressList = new ArrayList<>();
        String addrSql = "SELECT address_line FROM user_addresses WHERE user_email = ? ORDER BY is_default DESC, id DESC";
        PreparedStatement psAddr = conn.prepareStatement(addrSql);
        psAddr.setString(1, email);
        ResultSet rsAddr = psAddr.executeQuery();
        
        while (rsAddr.next()) {
            addressList.add(rsAddr.getString("address_line"));
        }
        request.setAttribute("listAddresses", addressList);

            // 3. LẤY GIỎ HÀNG
            String sql = "SELECT c.product_id, p.name, p.price, c.quantity " +
                         "FROM cart_items c JOIN products p ON c.product_id = p.id " +
                         "WHERE c.user_email = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
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

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Nếu giỏ hàng rỗng, không cho vào trang thanh toán
        if (cart.isEmpty()) {
            response.sendRedirect("cart"); 
            return;
        }

        // 4. Gửi dữ liệu sang JSP
        request.setAttribute("cartItems", cart);
        request.setAttribute("subTotal", grandTotal);
        request.setAttribute("shippingFee", 15000.0); // Phí ship cố định 15k
        request.setAttribute("finalTotal", grandTotal + 15000.0);

        request.getRequestDispatcher("/checkout.jsp").forward(request, response);
    }

    // POST: Xử lý đặt hàng
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");

        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Lấy địa chỉ giao hàng từ form (người dùng có thể sửa lại ở bước này)
        String address = request.getParameter("address");
        String note = request.getParameter("notes"); // Lấy ghi chú (nếu có)

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Bắt đầu Transaction (Giao dịch)

            // 1. Tính lại tổng tiền (Server-side calculation để bảo mật)
            double totalMoney = 0;
            String sqlCart = "SELECT c.quantity, p.price FROM cart_items c JOIN products p ON c.product_id = p.id WHERE user_email=?";
            PreparedStatement psCart = conn.prepareStatement(sqlCart);
            psCart.setString(1, email);
            ResultSet rsCart = psCart.executeQuery();
            while (rsCart.next()) {
                totalMoney += rsCart.getInt("quantity") * rsCart.getDouble("price");
            }
            totalMoney += 15000; // Cộng phí ship

            // 2. Lưu vào bảng ORDERS
            String sqlOrder = "INSERT INTO orders (user_email, address, total_money, status, order_date) VALUES (?, ?, ?, 'Đang xử lý', NOW())";
            PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setString(1, email);
            psOrder.setString(2, address); // Lưu địa chỉ khách chốt tại thời điểm đặt
            psOrder.setDouble(3, totalMoney);
            psOrder.executeUpdate();

            // 3. Xóa giỏ hàng sau khi đặt thành công
            String sqlClear = "DELETE FROM cart_items WHERE user_email = ?";
            PreparedStatement psClear = conn.prepareStatement(sqlClear);
            psClear.setString(1, email);
            psClear.executeUpdate();

            conn.commit(); // Xác nhận Transaction thành công

            // Chuyển hướng về trang quản lý đơn hàng
            response.sendRedirect(request.getContextPath() + "/profile?tab=orders&status=success");

        } catch (Exception e) {
            e.printStackTrace();
            // Nếu lỗi thì chuyển về lại trang checkout kèm thông báo lỗi
            response.sendRedirect(request.getContextPath() + "/checkout?error=failed");
        }
    }
}