<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. Kiểm tra session có tồn tại không
    if (session != null) {
        // 2. Xóa sạch thông tin trong session (bao gồm userEmail, userName...)
        session.invalidate();
    }

    // 3. Chuyển hướng người dùng về trang đăng nhập sau khi đăng xuất xong
    response.sendRedirect(request.getContextPath() + "/login.jsp");
%>