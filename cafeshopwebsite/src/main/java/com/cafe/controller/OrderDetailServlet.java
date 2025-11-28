package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DecimalFormat;

import com.cafe.util.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/order-detail")
public class OrderDetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        int orderId = Integer.parseInt(request.getParameter("id"));
        response.setContentType("text/html;charset=UTF-8");
        DecimalFormat df = new DecimalFormat("#,###");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM order_details WHERE order_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            StringBuilder html = new StringBuilder();
            html.append("<table class='order-table' style='width:100%; margin-top:10px;'>");
            html.append("<thead><tr><th>Sản phẩm</th><th>Giá</th><th>SL</th><th>Thành tiền</th></tr></thead>");
            html.append("<tbody>");

            while (rs.next()) {
                double price = rs.getDouble("price");
                int qty = rs.getInt("quantity");
                html.append("<tr>");
                html.append("<td>").append(rs.getString("product_name")).append("</td>");
                html.append("<td>").append(df.format(price)).append("</td>");
                html.append("<td>").append(qty).append("</td>");
                html.append("<td style='color:#d35400; font-weight:bold;'>").append(df.format(price * qty)).append("</td>");
                html.append("</tr>");
            }
            html.append("</tbody></table>");
            
            response.getWriter().write(html.toString());

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}