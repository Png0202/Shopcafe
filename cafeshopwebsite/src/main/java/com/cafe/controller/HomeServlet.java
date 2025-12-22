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

import com.cafe.model.Product;
import com.cafe.util.DBConnection;

// Servlet này sẽ chạy khi người dùng vào trang chủ "/"
@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Product> featuredProducts = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            
            // 1. Truy vấn tìm TOP 3 sản phẩm bán chạy nhất
            // Logic: Join bảng products và order_details, đếm số lượng bán, sắp xếp giảm dần
            String sqlBestSeller = 
                "SELECT p.*, SUM(od.quantity) as total_sold " +
                "FROM products p " +
                "JOIN order_details od ON p.id = od.product_id " + // Giả sử bạn cần thêm cột product_id vào order_details hoặc join qua tên
                // Tuy nhiên, bảng order_details hiện tại lưu 'product_name'. 
                // Để đơn giản và chính xác với DB hiện tại, ta query theo tên sản phẩm:
                
                // CÁCH 1: Nếu bảng order_details chưa có cột product_id, ta join theo tên (hơi rủi ro nếu đổi tên)
                // CÁCH 2 (Tốt hơn): Lấy random nếu chưa có dữ liệu bán hàng, hoặc lấy theo tên
                
                // Ở đây tôi dùng query kết hợp: Lấy top bán chạy, nếu không có thì lấy random
                "";

            // QUERY THỰC TẾ CHO DB CỦA BẠN (Dựa vào bảng order_details lưu product_name)
            String sql = "SELECT p.* FROM products p " +
                         "LEFT JOIN (SELECT product_name, SUM(quantity) as sold FROM order_details GROUP BY product_name) sold_items " +
                         "ON p.name = sold_items.product_name " +
                         "ORDER BY sold_items.sold DESC, RAND() " + // Ưu tiên bán chạy, sau đó random
                         "LIMIT 3";

            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                featuredProducts.add(new Product(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("description"),
                    rs.getDouble("price"),
                    rs.getString("category"),
                    rs.getString("image_url"),
                    rs.getInt("status")
                ));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Gửi dữ liệu sang JSP
        request.setAttribute("featuredProducts", featuredProducts);
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}