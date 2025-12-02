package com.cafe.controller;

import java.io.IOException;
import java.io.PrintWriter;
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

import com.cafe.model.Product;
import com.cafe.util.DBConnection;

@WebServlet("/menu")
public class MenuServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Quan trọng: Xử lý tiếng Việt cho request và response
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");

        // --- 1. XỬ LÝ AJAX LIVE SEARCH (Trả về HTML, không chuyển trang) ---
        if ("live_search".equals(action)) {
            response.setContentType("text/html;charset=UTF-8");
            String keyword = request.getParameter("keyword");
            
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT * FROM products WHERE name LIKE ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, "%" + keyword + "%");
                ResultSet rs = ps.executeQuery();
                
                StringBuilder html = new StringBuilder();
                boolean hasData = false;
                
                while (rs.next()) {
                    hasData = true;
                    int id = rs.getInt("id");
                    String name = rs.getString("name");
                    String desc = rs.getString("description");
                    double price = rs.getDouble("price");
                    String category = rs.getString("category");
                    String img = rs.getString("image_url");
                    
                    // Mapping category để bộ lọc JS hoạt động
                    String dataCat = "cake";
                    if("Cà Phê".equals(category)) dataCat = "coffee";
                    else if("Trà".equals(category)) dataCat = "tea";

                    // Tạo HTML Card sản phẩm chuẩn Bootstrap (Copy cấu trúc từ JSP)
                    html.append("<div class='col product-col animate__animated animate__fadeIn' data-category='").append(dataCat).append("'>");
                    html.append("  <div class='card h-100 product-card shadow-sm'>");
                    html.append("    <div class='product-img-wrapper'>");
                    html.append("      <img src='").append(img).append("' class='card-img-top' alt='").append(name).append("' onerror=\"this.src='https://placehold.co/400x200?text=").append(name).append("'\">");
                    html.append("    </div>");
                    html.append("    <div class='card-body d-flex flex-column text-center'>");
                    html.append("      <h5 class='card-title fw-bold' style='color: #333;'>").append(name).append("</h5>");
                    html.append("      <p class='card-text text-muted small flex-grow-1 text-truncate-2'>").append(desc).append("</p>");
                    html.append("      <div class='mt-3'>");
                    html.append("        <div class='price-tag mb-3'>").append(String.format("%,.0f", price)).append(" ₫</div>");
                    
                    // Form thêm vào giỏ
                    html.append("        <form action='cart' method='post'>");
                    html.append("          <input type='hidden' name='action' value='add'>");
                    html.append("          <input type='hidden' name='productId' value='").append(id).append("'>");
                    html.append("          <button type='submit' class='btn btn-add-cart w-100 py-2'><i class='fa-solid fa-cart-plus me-2'></i>Thêm Vào Giỏ</button>");
                    html.append("        </form>");
                    
                    html.append("      </div>"); 
                    html.append("    </div>");   
                    html.append("  </div>");     
                    html.append("</div>");       
                }
                
                if (!hasData) {
                    html.append("<div class='col-12 text-center py-5'>");
                    html.append("  <p class='text-muted fs-5'>Không tìm thấy sản phẩm nào phù hợp với từ khóa \"<strong>").append(keyword).append("</strong>\"</p>");
                    html.append("</div>");
                }
                
                PrintWriter out = response.getWriter();
                out.write(html.toString());
                return; // Dừng ngay để trả về kết quả Ajax
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // --- 2. LOGIC LOAD TRANG BÌNH THƯỜNG ---
        
        // Logic cho Nhân viên (POS)
        HttpSession session = request.getSession();
        String tableId = request.getParameter("tableId");
        if (tableId != null) {
            session.setAttribute("currentTableId", tableId);
            request.setAttribute("isOrderingForTable", true);
        }

        // Logic Tìm kiếm thường (khi mới vào trang hoặc reload)
        String keyword = request.getParameter("keyword");
        List<Product> productList = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            String sql;
            PreparedStatement ps;

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql = "SELECT * FROM products WHERE name LIKE ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, "%" + keyword + "%");
            } else {
                sql = "SELECT * FROM products";
                ps = conn.prepareStatement(sql);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("description"),
                    rs.getDouble("price"),
                    rs.getString("category"),
                    rs.getString("image_url")
                );
                productList.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Gửi dữ liệu sang JSP
        request.setAttribute("allProducts", productList);
        request.getRequestDispatcher("/menu.jsp").forward(request, response);
    }
}