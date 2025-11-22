<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<%-- LOGIC XÁC ĐỊNH TAB NÀO SẼ ĐƯỢC ACTIVE KHI TẢI TRANG --%>
<c:set var="activeTab" value="login" />
<c:if test="${param.error == 'email_exists' || param.error == 'phone_exists' || param.error == 'password_mismatch'}">
    <c:set var="activeTab" value="register" />
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Nhập - Quán Cà Phê</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style_login.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* CSS bổ sung để hiển thị thông báo lỗi đẹp hơn */
        .alert {
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 5px;
            font-size: 14px;
            text-align: center;
            font-weight: bold;
        }
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>☕ Quán Cà Phê Vĩnh Long</h1>
            <nav>
                <ul>
                    <%-- 1. MENU CÔNG KHAI (Ai cũng thấy) --%>
                    <li><a href="${pageContext.request.contextPath}/index.jsp">Trang Chủ</a></li>
                    
                    <%-- Lưu ý: Ở file menu.jsp thì thêm class="active" vào dòng này --%>
                    <li><a href="${pageContext.request.contextPath}/menu">Thực Đơn</a></li>

                    <%-- 2. LOGIC KIỂM TRA ĐĂNG NHẬP --%>
                    <c:choose>
                        <%-- TRƯỜNG HỢP ĐÃ ĐĂNG NHẬP --%>
                        <c:when test="${not empty sessionScope.userEmail}">
                            <%-- A. Hiện Giỏ Hàng (Chỉ dành cho thành viên) --%>
                            <li><a href="${pageContext.request.contextPath}/cart">Giỏ Hàng</a></li>
                            
                            <%-- B. Hiện Tài Khoản --%>
                            <li>
                                <a href="${pageContext.request.contextPath}/profile" style="font-weight: bold; color: #d35400;">
                                    Tài Khoản (${sessionScope.userName})
                                </a>
                            </li>
                        </c:when>
                        
                        <%-- TRƯỜNG HỢP CHƯA ĐĂNG NHẬP --%>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/login.jsp">Đăng Nhập</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </nav>
        </div>
    </header>

    <section class="login-wrapper">
        <div class="login-container">
            <div class="login-header">
                <h2>Chào Mừng Bạn Trở Lại</h2>
                
                <%-- Thông báo chung (Thành công hoặc Lỗi hệ thống) --%>
                <c:if test="${param.register == 'success'}">
                    <div class="alert alert-success">✅ Đăng ký thành công! Vui lòng đăng nhập.</div>
                </c:if>
                <c:if test="${param.error == 'db'}">
                    <div class="alert alert-danger">⚠️ Lỗi hệ thống, vui lòng thử lại sau!</div>
                </c:if>
            </div>

            <div class="form-container">
                <%-- Nút chuyển Tab: Class active phụ thuộc vào biến activeTab --%>
                <div class="login-tabs">
                    <button class="login-tab ${activeTab == 'login' ? 'active' : ''}" onclick="switchTab('login')">Đăng Nhập</button>
                    <button class="login-tab ${activeTab == 'register' ? 'active' : ''}" onclick="switchTab('register')">Đăng Ký</button>
                </div>

                <%-- ================= FORM ĐĂNG NHẬP ================= --%>
                <div id="login-tab" class="tab-content ${activeTab == 'login' ? 'active' : ''}">
                    
                    <%-- Hiển thị lỗi Đăng nhập tại đây --%>
                    <c:if test="${param.error == 'login_failed'}">
                        <div class="alert alert-danger">❌ Sai email hoặc mật khẩu!</div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/login" method="post">
                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" name="email" required placeholder="Nhập email của bạn">
                        </div>
                        <div class="form-group">
                            <label>Mật khẩu</label>
                            <input type="password" name="password" required placeholder="Nhập mật khẩu">
                        </div>
                        <div class="form-group remember">
                            <input type="checkbox" id="remember-me" name="rememberMe">
                            <label for="remember-me">Ghi nhớ đăng nhập</label>
                        </div>
                        <button type="submit" class="btn full">Đăng Nhập</button>
                        <div class="center-text">
                            <a href="#" class="link-disabled" onclick="alert('Chức năng đang phát triển!'); return false;">Quên mật khẩu?</a>
                        </div>
                    </form>
                </div>

                <%-- ================= FORM ĐĂNG KÝ ================= --%>
                <div id="register-tab" class="tab-content ${activeTab == 'register' ? 'active' : ''}">
                    
                    <%-- Hiển thị lỗi Đăng ký tại đây --%>
                    <c:if test="${param.error == 'email_exists'}">
                        <div class="alert alert-danger">⚠️ Email này đã được sử dụng!</div>
                    </c:if>
                    <c:if test="${param.error == 'phone_exists'}">
                        <div class="alert alert-danger">⚠️ Số điện thoại này đã tồn tại!</div>
                    </c:if>
                    <c:if test="${param.error == 'password_mismatch'}">
                        <div class="alert alert-danger">❌ Mật khẩu xác nhận không khớp!</div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/register" method="post">
                        <div class="form-group">
                            <label>Họ và tên</label>
                            <input type="text" name="name" required placeholder="Nhập họ và tên">
                        </div>
                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" name="email" required placeholder="Nhập email">
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại</label>
                            <input type="tel" name="phone" required pattern="[0-9]{10}" placeholder="Nhập 10 số điện thoại">
                        </div>
                        <div class="form-group">
                            <label>Mật khẩu</label>
                            <input type="password" name="password" required minlength="6" placeholder="Tối thiểu 6 ký tự">
                        </div>
                        <div class="form-group">
                            <label>Xác nhận mật khẩu</label>
                            <input type="password" name="confirmPassword" required placeholder="Nhập lại mật khẩu">
                        </div>
                        <div class="form-group terms">
                            <input type="checkbox" id="agree-terms" required>
                            <label for="agree-terms">
                                Tôi đồng ý với <a href="#">Điều khoản sử dụng</a>
                            </label>
                        </div>
                        <button type="submit" class="btn full">Đăng Ký</button>
                    </form>
                </div>

                <%-- Mạng xã hội --%>
                <div class="social-login">
                    <p>Hoặc đăng nhập bằng</p>
                    <div class="social-buttons">
                        <button class="btn-secondary" onclick="alert('Chức năng đang phát triển!')">Facebook</button>
                        <button class="btn-secondary" onclick="alert('Chức năng đang phát triển!')">Google</button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <p>&copy; 2025 Quán Cà Phê Vĩnh Long</p>
        </div>
    </footer>

    <script>
        function switchTab(tabName) {
            // Xóa class active ở tất cả các tab và button
            document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.login-tab').forEach(b => b.classList.remove('active'));
            
            // Thêm class active vào đúng tab được chọn
            if (tabName === 'login') {
                document.getElementById('login-tab').classList.add('active');
                document.querySelectorAll('.login-tab')[0].classList.add('active');
            } else {
                document.getElementById('register-tab').classList.add('active');
                document.querySelectorAll('.login-tab')[1].classList.add('active');
            }
        }
    </script>
</body>
</html>