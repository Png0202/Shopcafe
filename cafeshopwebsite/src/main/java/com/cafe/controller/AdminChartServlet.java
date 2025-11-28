package com.cafe.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.cafe.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/admin-chart")
public class AdminChartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // Cấu hình trả về JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String type = request.getParameter("type");   // "revenue" hoặc "order"
        String period = request.getParameter("period"); // "today", "week", "month", "year"
        
        // Query SQL mặc định
        String sql = "";
        String selectPart = "";
        String groupBy = "";
        String condition = "";
        
        // 1. XÁC ĐỊNH LOẠI DỮ LIỆU (DOANH THU HAY ĐƠN HÀNG)
        if ("revenue".equals(type)) {
            // Doanh thu: Tính tổng tiền, chỉ tính đơn Đã giao
            selectPart = "SUM(total_money)";
            condition = " WHERE status = 'Đã giao' ";
        } else {
            // Đơn hàng: Đếm số lượng, tính tất cả trạng thái
            selectPart = "COUNT(*)";
            condition = " WHERE 1=1 "; 
        }

        // 2. XÂY DỰNG QUERY THEO THỜI GIAN
        if ("today".equals(period)) {
            // Theo giờ trong ngày (0h - 23h)
            sql = "SELECT CONCAT(HOUR(order_date), 'h') as label, " + selectPart + " as value " +
                  "FROM orders " + condition + " AND DATE(order_date) = CURDATE() " +
                  "GROUP BY HOUR(order_date) ORDER BY HOUR(order_date)";
                  
        } else if ("week".equals(period)) {
            // 7 ngày gần nhất (Hiện Thứ/Ngày)
            sql = "SELECT DATE_FORMAT(order_date, '%d/%m') as label, " + selectPart + " as value " +
                  "FROM orders " + condition + " AND order_date >= DATE_SUB(NOW(), INTERVAL 7 DAY) " +
                  "GROUP BY DATE(order_date) ORDER BY order_date";
                  
        } else if ("month".equals(period)) {
            // Các ngày trong tháng này
            sql = "SELECT DATE_FORMAT(order_date, '%d') as label, " + selectPart + " as value " +
                  "FROM orders " + condition + " AND MONTH(order_date) = MONTH(CURRENT_DATE()) AND YEAR(order_date) = YEAR(CURRENT_DATE()) " +
                  "GROUP BY DATE(order_date) ORDER BY order_date";
                  
        } else if ("year".equals(period)) {
            // 12 tháng trong năm nay
            sql = "SELECT CONCAT('Tháng ', MONTH(order_date)) as label, " + selectPart + " as value " +
                  "FROM orders " + condition + " AND YEAR(order_date) = YEAR(CURRENT_DATE()) " +
                  "GROUP BY MONTH(order_date) ORDER BY MONTH(order_date)";
        }

        // 3. THỰC THI VÀ TẠO JSON THỦ CÔNG
        // (Để không cần thư viện Gson/Jackson, ta tự build chuỗi JSON)
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            
            List<String> labels = new ArrayList<>();
            List<Double> data = new ArrayList<>();
            
            while (rs.next()) {
                labels.add("\"" + rs.getString("label") + "\""); // Thêm dấu ngoặc kép cho chuỗi JSON
                data.add(rs.getDouble("value"));
            }
            
            // Build JSON String: { "labels": ["A", "B"], "data": [10, 20] }
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