package com.cafe.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.TimeZone; // Import thêm TimeZone

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.cafe.util.DBConnection;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        String userEmail = (String) session.getAttribute("userEmail");
        Integer perm = (Integer) session.getAttribute("permission"); // 1: Staff, 2: User
        
        if (userEmail == null) return;

        try (Connection conn = DBConnection.getConnection()) {
            
            // --- GỬI TIN NHẮN ---
            if ("send".equals(action)) {
                String msg = request.getParameter("message");
                String receiver = request.getParameter("receiver");
                String role = (perm != null && perm == 1) ? "staff" : "user";
                
                String sql = "INSERT INTO messages (sender_email, receiver_email, message, role) VALUES (?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, userEmail);
                ps.setString(2, receiver);
                ps.setString(3, msg);
                ps.setString(4, role);
                ps.executeUpdate();
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        String currentUser = (String) session.getAttribute("userEmail");
        Integer perm = (Integer) session.getAttribute("permission");

        if (currentUser == null) return;

        try (Connection conn = DBConnection.getConnection()) {
            
            // --- LẤY TIN NHẮN (LOAD) ---
            if ("load".equals(action)) {
                String targetUser = request.getParameter("targetUser");
                String sql;
                PreparedStatement ps;

                if (perm != null && perm == 1) { 
                    // [NHÂN VIÊN] Xem tin của khách cụ thể
                    
                    // 1. Đánh dấu tất cả tin nhắn của khách này là "Đã xem"
                    String updateSql = "UPDATE messages SET is_read = 1 WHERE sender_email = ? AND role = 'user'";
                    PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                    psUpdate.setString(1, targetUser);
                    psUpdate.executeUpdate();

                    // 2. Lấy nội dung tin nhắn
                    sql = "SELECT * FROM messages WHERE (sender_email = ? OR receiver_email = ?) ORDER BY created_at ASC";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, targetUser);
                    ps.setString(2, targetUser);
                } else { 
                    // [KHÁCH HÀNG] Xem tin của mình
                    sql = "SELECT * FROM messages WHERE sender_email = ? OR receiver_email = ? ORDER BY created_at ASC";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, currentUser);
                    ps.setString(2, currentUser);
                }

                ResultSet rs = ps.executeQuery();
                StringBuilder html = new StringBuilder();
                
                // Thiết lập định dạng ngày giờ theo múi giờ Việt Nam (GMT+7)
                SimpleDateFormat sdf = new SimpleDateFormat("HH:mm dd/MM");
                sdf.setTimeZone(TimeZone.getTimeZone("GMT+7")); 
                // -------------------------------------------------------------------

                while (rs.next()) {
                    String sender = rs.getString("sender_email");
                    String msg = rs.getString("message");
                    String time = sdf.format(rs.getTimestamp("created_at"));
                    
                    boolean isMine = sender.equals(currentUser);
                    
                    html.append("<div class='d-flex mb-2 ").append(isMine ? "justify-content-end" : "justify-content-start").append("'>");
                    html.append("  <div class='p-2 rounded shadow-sm text-break' style='max-width: 75%; background-color: ")
                        .append(isMine ? "#dcf8c6" : "#fff").append(";'>");
                    html.append("    <div>").append(msg).append("</div>");
                    html.append("    <div class='text-end text-muted mt-1' style='font-size: 10px;'>").append(time).append("</div>");
                    html.append("  </div>");
                    html.append("</div>");
                }
                response.getWriter().write(html.toString());
            }
            
            // --- LOAD DANH SÁCH KHÁCH HÀNG (CHO NHÂN VIÊN) ---
            else if ("get_users".equals(action)) {
                // SQL Logic:
                // 1. Lấy tất cả user không phải admin/nhân viên
                // 2. Sắp xếp: Tin chưa đọc lên đầu > Tin mới nhất > Tên A-Z
                String sql = "SELECT u.email, u.name, " +
                             "MAX(m.created_at) as last_msg_time, " +
                             "SUM(CASE WHEN m.role = 'user' AND m.is_read = 0 THEN 1 ELSE 0 END) as unread_count " +
                             "FROM users u " +
                             "LEFT JOIN messages m ON (u.email = m.sender_email OR u.email = m.receiver_email) " +
                             "WHERE u.permissions NOT IN (0, 1) " +
                             "GROUP BY u.email, u.name " +
                             "ORDER BY unread_count DESC, last_msg_time DESC, u.name ASC";

                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery();
                
                StringBuilder html = new StringBuilder();
                
                while(rs.next()){
                    String email = rs.getString("email");
                    String name = rs.getString("name");
                    int unread = rs.getInt("unread_count");
                    
                    if (name == null || name.isEmpty()) name = email; // Fallback nếu chưa có tên

                    String bgClass = (unread > 0) ? "bg-light" : ""; 
                    String fwClass = (unread > 0) ? "fw-bold text-dark" : "text-secondary";

                    // Truyền cả email và name vào hàm openWidgetChat
                    html.append("<a href='#' class='list-group-item list-group-item-action ").append(bgClass).append("' ")
                        .append("onclick=\"openWidgetChat('").append(email).append("', '").append(name).append("')\">");
                    
                    html.append("  <div class='d-flex justify-content-between align-items-center'>");
                    html.append("    <div class='overflow-hidden'>");
                    html.append("      <div class='").append(fwClass).append(" text-truncate'>").append(name).append("</div>");
                    html.append("      <small class='text-muted' style='font-size: 11px;'>").append(email).append("</small>");
                    html.append("    </div>");
                    
                    // Vẫn giữ lại badge đỏ tròn đếm số
                    if (unread > 0) {
                        html.append("    <span class='badge bg-danger rounded-pill ms-2'>").append(unread).append("</span>");
                        html.append("    "); // Cờ để JS nhận biết bật chấm đỏ ngoài widget
                    }
                    html.append("  </div>");
                    html.append("</a>");
                }
                
                response.getWriter().write(html.toString());
            }
            
        } catch (Exception e) { e.printStackTrace(); }
    }
}