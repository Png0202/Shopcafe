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

    // GET: Xem giỏ hàng
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");
        String currentTableId = (String) session.getAttribute("currentTableId");

        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<CartItem> cart = new ArrayList<>();
        double grandTotal = 0;

        try (Connection conn = DBConnection.getConnection()) {
            String sql;
            PreparedStatement ps;

            // LOGIC PHÂN BIỆT
            if (currentTableId != null) {
                // TRƯỜNG HỢP 1: POS (BÀN)
                sql = "SELECT c.id, c.product_id, p.name, p.price, p.image_url, c.quantity, c.note " +
                      "FROM cart_items c JOIN products p ON c.product_id = p.id " +
                      "WHERE c.table_id = ?";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(currentTableId));
            } else {
                // TRƯỜNG HỢP 2: ONLINE (KHÁCH)
                sql = "SELECT c.id, c.product_id, p.name, p.price, p.image_url, c.quantity, c.note " +
                      "FROM cart_items c JOIN products p ON c.product_id = p.id " +
                      "WHERE c.user_email = ? AND c.table_id IS NULL";
                ps = conn.prepareStatement(sql);
                ps.setString(1, email);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                // --- SỬA ĐOẠN NÀY: DÙNG SETTER ĐỂ CHẮC CHẮN ĐÚNG DỮ LIỆU ---
                CartItem item = new CartItem();
                item.setId(rs.getInt("id"));
                item.setProductId(rs.getInt("product_id"));
                item.setProductName(rs.getString("name"));
                item.setPrice(rs.getDouble("price"));
                item.setImageUrl(rs.getString("image_url"));
                item.setQuantity(rs.getInt("quantity")); // Đảm bảo lấy đúng cột quantity
                item.setNote(rs.getString("note"));      // Đảm bảo lấy đúng cột note
                
                cart.add(item);
                grandTotal += item.getTotalPrice();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("cartItems", cart);
        request.setAttribute("grandTotal", grandTotal);
        
        // --- LOGIC ĐIỀU HƯỚNG ---
        if (currentTableId != null) {
            request.getRequestDispatcher("/table_order.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/cart.jsp").forward(request, response);
        }
    }

    // POST: Thêm/Sửa/Xóa món (Giữ nguyên code cũ của bạn, phần này OK)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String email = (String) session.getAttribute("userEmail");
        String currentTableId = (String) session.getAttribute("currentTableId");

        if (email == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        int productId = Integer.parseInt(request.getParameter("productId"));

        try (Connection conn = DBConnection.getConnection()) {
            
            if ("add".equals(action)) {
                String checkSql;
                PreparedStatement checkPs;

                if (currentTableId != null) {
                    checkSql = "SELECT id, quantity FROM cart_items WHERE table_id=? AND product_id=?";
                    checkPs = conn.prepareStatement(checkSql);
                    checkPs.setInt(1, Integer.parseInt(currentTableId));
                    checkPs.setInt(2, productId);
                } else {
                    checkSql = "SELECT id, quantity FROM cart_items WHERE user_email=? AND product_id=? AND table_id IS NULL";
                    checkPs = conn.prepareStatement(checkSql);
                    checkPs.setString(1, email);
                    checkPs.setInt(2, productId);
                }

                ResultSet rs = checkPs.executeQuery();
                if (rs.next()) {
                    String updateSql = "UPDATE cart_items SET quantity=? WHERE id=?";
                    PreparedStatement updatePs = conn.prepareStatement(updateSql);
                    updatePs.setInt(1, rs.getInt("quantity") + 1);
                    updatePs.setInt(2, rs.getInt("id"));
                    updatePs.executeUpdate();
                } else {
                    String insertSql = "INSERT INTO cart_items (user_email, product_id, quantity, table_id) VALUES (?, ?, 1, ?)";
                    PreparedStatement insertPs = conn.prepareStatement(insertSql);
                    insertPs.setString(1, email);
                    insertPs.setInt(2, productId);
                    
                    if (currentTableId != null) {
                        insertPs.setInt(3, Integer.parseInt(currentTableId));
                    } else {
                        insertPs.setNull(3, java.sql.Types.INTEGER);
                    }
                    insertPs.executeUpdate();
                }

            } else if ("update".equals(action)) {
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                if (quantity > 0) {
                    String updateSql;
                    PreparedStatement ps;
                    if(currentTableId != null) {
                        updateSql = "UPDATE cart_items SET quantity=? WHERE table_id=? AND product_id=?";
                        ps = conn.prepareStatement(updateSql);
                        ps.setInt(1, quantity);
                        ps.setInt(2, Integer.parseInt(currentTableId));
                        ps.setInt(3, productId);
                    } else {
                        updateSql = "UPDATE cart_items SET quantity=? WHERE user_email=? AND product_id=? AND table_id IS NULL";
                        ps = conn.prepareStatement(updateSql);
                        ps.setInt(1, quantity);
                        ps.setString(2, email);
                        ps.setInt(3, productId);
                    }
                    ps.executeUpdate();
                }

            } else if ("update_note".equals(action)) {
                String note = request.getParameter("note");
                String sql;
                PreparedStatement ps;
                
                if (currentTableId != null) {
                    sql = "UPDATE cart_items SET note=? WHERE table_id=? AND product_id=?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, note);
                    ps.setInt(2, Integer.parseInt(currentTableId));
                    ps.setInt(3, productId);
                } else {
                    sql = "UPDATE cart_items SET note=? WHERE user_email=? AND product_id=? AND table_id IS NULL";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, note);
                    ps.setString(2, email);
                    ps.setInt(3, productId);
                }
                ps.executeUpdate();

            } else if ("remove".equals(action)) {
                String sql;
                PreparedStatement ps;
                if(currentTableId != null) {
                    sql = "DELETE FROM cart_items WHERE table_id=? AND product_id=?";
                    ps = conn.prepareStatement(sql);
                    ps.setInt(1, Integer.parseInt(currentTableId));
                    ps.setInt(2, productId);
                } else {
                    sql = "DELETE FROM cart_items WHERE user_email=? AND product_id=? AND table_id IS NULL";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, email);
                    ps.setInt(2, productId);
                }
                ps.executeUpdate();

            } else if ("clear".equals(action)) {
                String sql;
                PreparedStatement ps;
                if(currentTableId != null) {
                    sql = "DELETE FROM cart_items WHERE table_id=?";
                    ps = conn.prepareStatement(sql);
                    ps.setInt(1, Integer.parseInt(currentTableId));
                } else {
                    sql = "DELETE FROM cart_items WHERE user_email=? AND table_id IS NULL";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, email);
                }
                ps.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        
        if (currentTableId != null && "add".equals(action)) {
            response.sendRedirect("menu"); 
        } else {
            response.sendRedirect("cart");
        }
    }
}