<%@ page import="java.sql.*" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Test JSP</title>
</head>
<body>
<h2>TEST JSP HOẠT ĐỘNG</h2>

<%
    out.println("<p>JSP đang chạy OK!</p>");

    // --- TEST BCRYPT ---
    try {
        String pass = "123456";
        String hash = BCrypt.hashpw(pass, BCrypt.gensalt(12));
        boolean check = BCrypt.checkpw("123456", hash);

        out.println("<p><b>BCrypt Hash:</b> " + hash + "</p>");
        out.println("<p><b>Check Password:</b> " + check + "</p>");
    } catch (Exception e) {
        out.println("<p style='color:red;'>Lỗi BCrypt: " + e.getMessage() + "</p>");
    }

    // --- TEST KẾT NỐI DATABASE ---
    String url = "jdbc:mysql://localhost:3306/cafe_db";
    String user = "root";
    String pass = "";   // nếu XAMPP có mật khẩu thì sửa tại đây

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(url, user, pass);

        out.println("<p style='color:green;'>Kết nối database thành công!</p>");

        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Lỗi database: " + e.getMessage() + "</p>");
    }
%>

<hr>
<p>Nếu bạn thấy tất cả đều "OK" → dự án hoạt động bình thường.</p>

</body>
</html>
