package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.cafe.model.Product;
import com.cafe.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/menu")
public class MenuServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Product> productList = new ArrayList<>();
        // --- LOGIC CHO NHÂN VIÊN (POS) ---
        HttpSession session = request.getSession();
        String tableId = request.getParameter("tableId");
        
        if (tableId != null) {
            // Nếu có tableId trên URL, nghĩa là đang gọi món cho bàn này
            session.setAttribute("currentTableId", tableId);
            request.setAttribute("isOrderingForTable", true); // Để hiện thông báo trên JSP
        } else {
            // Nếu không có param, kiểm tra xem trong session có đang giữ bàn nào không
            // Nếu muốn thoát chế độ bàn, nhân viên phải bấm nút "Thoát" (sẽ làm sau)
        }
        try (Connection conn = DBConnection.getConnection()) {
            // Lấy tất cả sản phẩm từ database
            String sql = "SELECT * FROM products";
            PreparedStatement ps = conn.prepareStatement(sql);
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