package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    // GET: Hiển thị giỏ hàng
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");

        // Nếu chưa đăng nhập -> Chuyển về trang login
        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<CartItem> cart = new ArrayList<>();
        double grandTotal = 0;

        try (Connection conn = DBConnection.getConnection()) {
            // Lấy thông tin giỏ hàng + thông tin sản phẩm từ bảng products
            String sql = "SELECT c.id, c.product_id, p.name, p.price, p.image_url, c.quantity " +
                         "FROM cart_items c " +
                         "JOIN products p ON c.product_id = p.id " +
                         "WHERE c.user_email = ?";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                CartItem item = new CartItem(
                    rs.getInt("id"),
                    rs.getInt("product_id"),
                    rs.getString("name"),
                    rs.getDouble("price"),
                    rs.getString("image_url"),
                    rs.getInt("quantity")
                );
                cart.add(item);
                grandTotal += item.getTotalPrice();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("cartItems", cart);
        request.setAttribute("grandTotal", grandTotal);
        request.getRequestDispatcher("/cart.jsp").forward(request, response);
    }

    // POST: Thêm, Sửa, Xóa
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");
        
        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        int productId = Integer.parseInt(request.getParameter("productId"));

        try (Connection conn = DBConnection.getConnection()) {
            if ("add".equals(action)) {
                // Kiểm tra sản phẩm đã có trong giỏ chưa
                String checkSql = "SELECT id, quantity FROM cart_items WHERE user_email=? AND product_id=?";
                PreparedStatement checkPs = conn.prepareStatement(checkSql);
                checkPs.setString(1, email);
                checkPs.setInt(2, productId);
                ResultSet rs = checkPs.executeQuery();

                if (rs.next()) {
                    // Có rồi -> Tăng số lượng
                    int newQty = rs.getInt("quantity") + 1;
                    String updateSql = "UPDATE cart_items SET quantity=? WHERE id=?";
                    PreparedStatement updatePs = conn.prepareStatement(updateSql);
                    updatePs.setInt(1, newQty);
                    updatePs.setInt(2, rs.getInt("id"));
                    updatePs.executeUpdate();
                } else {
                    // Chưa có -> Thêm mới
                    String insertSql = "INSERT INTO cart_items (user_email, product_id, quantity) VALUES (?, ?, 1)";
                    PreparedStatement insertPs = conn.prepareStatement(insertSql);
                    insertPs.setString(1, email);
                    insertPs.setInt(2, productId);
                    insertPs.executeUpdate();
                }
            } else if ("update".equals(action)) {
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                if (quantity > 0) {
                    String sql = "UPDATE cart_items SET quantity=? WHERE user_email=? AND product_id=?";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setInt(1, quantity);
                    ps.setString(2, email);
                    ps.setInt(3, productId);
                    ps.executeUpdate();
                }
            } else if ("remove".equals(action)) {
                String sql = "DELETE FROM cart_items WHERE user_email=? AND product_id=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, email);
                ps.setInt(2, productId);
                ps.executeUpdate();
            } else if ("clear".equals(action)) {
                 String sql = "DELETE FROM cart_items WHERE user_email=?";
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ps.setString(1, email);
                 ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Quay lại trang giỏ hàng (gọi lại doGet)
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}