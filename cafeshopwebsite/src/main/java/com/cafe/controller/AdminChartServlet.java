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

import com.cafe.util.DBConnection;

@WebServlet("/admin-chart")
public class AdminChartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String type = request.getParameter("type");   // "revenue" hoặc "order"
        String period = request.getParameter("period"); // "today", "week", "month", "year"
        
        String sql = "";
        String selectPart = "";
        // Chỉ tính doanh thu cho đơn hàng thành công (cả online và offline)
        String revenueCondition = " WHERE status IN ('Giao hàng thành công', 'Đã giao') "; 
        String orderCondition = " WHERE status IN ('Giao hàng thành công', 'Đã giao') "; 

        // 1. XÁC ĐỊNH LOẠI DỮ LIỆU
        String condition = "";
        if ("revenue".equals(type)) {
            selectPart = "SUM(total_money)";
            condition = revenueCondition;
        } else {
            selectPart = "COUNT(*)";
            condition = orderCondition;
        }

        // 2. XÂY DỰNG QUERY THEO THỜI GIAN
        if ("today".equals(period)) {
            // Theo giờ trong ngày (0h - 23h)
            sql = "SELECT CONCAT(HOUR(order_date), 'h') as label, " + selectPart + " as value " +
                  "FROM orders " + condition + " AND DATE(order_date) = CURDATE() " +
                  "GROUP BY HOUR(order_date) ORDER BY HOUR(order_date)";
                  
        } else if ("week".equals(period)) {
            // 7 ngày gần nhất (Hiện ngày/tháng)
            sql = "SELECT DATE_FORMAT(order_date, '%d/%m') as label, " + selectPart + " as value " +
                  "FROM orders " + condition + " AND order_date >= DATE_SUB(NOW(), INTERVAL 7 DAY) " +
                  "GROUP BY DATE(order_date) ORDER BY order_date";
                  
        } else if ("month".equals(period)) {
            // Các ngày trong tháng hiện tại
            sql = "SELECT DATE_FORMAT(order_date, '%d') as label, " + selectPart + " as value " +
                  "FROM orders " + condition + " AND MONTH(order_date) = MONTH(NOW()) AND YEAR(order_date) = YEAR(NOW()) " +
                  "GROUP BY DATE(order_date) ORDER BY order_date";
                  
        } else if ("year".equals(period)) {
            // 12 tháng trong năm nay
            sql = "SELECT CONCAT('Tháng ', MONTH(order_date)) as label, " + selectPart + " as value " +
                  "FROM orders " + condition + " AND YEAR(order_date) = YEAR(NOW()) " +
                  "GROUP BY MONTH(order_date) ORDER BY MONTH(order_date)";
        }

        // 3. THỰC THI VÀ TRẢ VỀ JSON
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            
            List<String> labels = new ArrayList<>();
            List<Double> data = new ArrayList<>();
            
            while (rs.next()) {
                labels.add("\"" + rs.getString("label") + "\"");
                data.add(rs.getDouble("value"));
            }
            
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"labels\": ").append(labels.toString()).append(",");
            json.append("\"data\": ").append(data.toString());
            json.append("}");
            
            PrintWriter out = response.getWriter();
            out.print(json.toString());
            out.flush();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}