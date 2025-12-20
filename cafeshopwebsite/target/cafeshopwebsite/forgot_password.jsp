<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quên Mật Khẩu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { background: #f0f2f5; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .card { max-width: 400px; width: 100%; border: none; border-radius: 10px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        .btn-primary { background: #d35400; border-color: #d35400; }
        .btn-primary:hover { background: #a04000; }
    </style>
</head>
<body>
    <div class="card p-4">
        <h3 class="text-center fw-bold mb-4" style="color: #6f4e37;">Khôi Phục Mật Khẩu</h3>

        <%-- THÔNG BÁO LỖI --%>
        <c:if test="${param.error == 'email_not_found'}"><div class="alert alert-danger small">Email không tồn tại trong hệ thống!</div></c:if>
        <c:if test="${param.error == 'wrong_otp'}"><div class="alert alert-danger small">Mã xác nhận không đúng!</div></c:if>
        <c:if test="${param.error == 'mismatch'}"><div class="alert alert-danger small">Mật khẩu xác nhận không khớp!</div></c:if>

        <%-- STEP 1: NHẬP EMAIL --%>
        <c:if test="${empty param.step}">
            <form action="${pageContext.request.contextPath}/forgotPassword" method="post">
                <input type="hidden" name="action" value="send_otp">
                <div class="mb-3">
                    <label class="form-label">Nhập email đăng ký</label>
                    <input type="email" name="email" class="form-control" required placeholder="name@example.com">
                </div>
                <button type="submit" class="btn btn-primary w-100">Gửi Mã Xác Nhận</button>
            </form>
        </c:if>

        <%-- STEP 2: NHẬP MÃ OTP --%>
        <c:if test="${param.step == 'verify'}">
            <div class="alert alert-info small">Mã OTP đã được gửi tới: <strong>${sessionScope.resetEmail}</strong></div>
            <form action="${pageContext.request.contextPath}/forgotPassword" method="post">
                <input type="hidden" name="action" value="verify_otp">
                <div class="mb-3">
                    <label class="form-label">Nhập mã OTP (6 số)</label>
                    <input type="text" name="otp" class="form-control text-center fw-bold" maxlength="6" required placeholder="XXXXXX">
                </div>
                <button type="submit" class="btn btn-primary w-100">Xác Thực</button>
            </form>
        </c:if>

        <%-- STEP 3: ĐỔI MẬT KHẨU --%>
        <c:if test="${param.step == 'reset'}">
            <form action="${pageContext.request.contextPath}/forgotPassword" method="post">
                <input type="hidden" name="action" value="reset_pass">
                <div class="mb-3">
                    <label class="form-label">Mật khẩu mới</label>
                    <input type="password" name="newPassword" class="form-control" required minlength="6">
                </div>
                <div class="mb-3">
                    <label class="form-label">Nhập lại mật khẩu</label>
                    <input type="password" name="confirmPassword" class="form-control" required>
                </div>
                <button type="submit" class="btn btn-primary w-100">Đổi Mật Khẩu</button>
            </form>
        </c:if>

        <div class="text-center mt-3">
            <a href="login.jsp" class="text-decoration-none text-secondary small">Quay lại Đăng Nhập</a>
        </div>
    </div>
</body>
</html>