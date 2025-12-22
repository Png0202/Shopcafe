<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <style>
        /* Tinh chỉnh cho Form Login đẹp hơn */
        body { background-color: #f0f2f5; }
        
        .login-wrapper {
            min-height: 80vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 0;
        }
        
        .login-card {
            width: 100%;
            max-width: 450px;
            border: none;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .login-header {
            background: #6f4e37; /* Màu nâu cà phê */
            color: white;
            padding: 30px 20px;
            text-align: center;
        }
        
        .nav-tabs .nav-link {
            color: #555;
            font-weight: 600;
            border: none;
            border-bottom: 3px solid transparent;
        }
        
        .nav-tabs .nav-link.active {
            color: #d35400;
            border-bottom: 3px solid #d35400;
            background: none;
        }
        
        .social-btn {
            width: 100%;
            margin-bottom: 10px;
            font-weight: 500;
        }
                /* Container neo ở góc trên bên phải */
        #toast-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        /* Style Toast (Giữ nguyên giao diện đẹp nhưng chỉnh lại animation) */
        .vue-toast {
            background-color: #4caf50;
            color: #fff;
            border-radius: 8px;
            padding: 16px 24px 20px 20px;
            display: flex;
            align-items: flex-start;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            position: relative;
            overflow: hidden;
            font-family: "Roboto", sans-serif;
            min-width: 320px;
            /* Hiệu ứng trượt vào */
            animation: slideInRight 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            transition: all 0.5s ease;
        }

        /* Các biến thể màu */
        .vue-toast.error { background-color: #ff5252; }
        .vue-toast.warning { background-color: #ffc107; color: #333; }

        /* Icon và Nội dung */
        .vue-toast-icon { margin-right: 18px; font-size: 22px; padding-top: 2px; }
        .vue-toast-body { flex-grow: 1; font-size: 15px; font-weight: 500; line-height: 1.4; }

        /* Nút tắt */
        .vue-toast-close {
            background: transparent; border: none; color: #fff;
            cursor: pointer; font-size: 20px; opacity: 0.7; margin-left: 15px;
        }
        .vue-toast-close:hover { opacity: 1; }

        /* Thanh thời gian (Chạy trong 3 giây) */
        .vue-toast-progress {
            position: absolute; bottom: 0; left: 0; width: 100%; height: 5px;
            background-color: rgba(255, 255, 255, 0.7);
            transform-origin: left;
            /* QUAN TRỌNG: Chạy hết trong 3s */
            animation: timeOut 3s linear forwards; 
        }

        /* Keyframes */
        @keyframes slideInRight {
            from { transform: translateX(120%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        @keyframes timeOut {
            to { transform: scaleX(0); }
        }
        /* Class để JS thêm vào khi ẩn đi */
        .toast-hide {
            transform: translateX(120%);
            opacity: 0;
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>☕ Garden Coffee & Cake</h1>
            <nav>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/menu">Thực Đơn</a></li>
                    <li><a href="${pageContext.request.contextPath}/login.jsp" class="active">Đăng Nhập</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <section class="login-wrapper">
        <div class="card login-card">
            <div class="login-header">
                <h3 class="mb-1">Chào Mừng Bạn!</h3>
                <p class="mb-0 small opacity-75">Vui lòng đăng nhập để tiếp tục</p>
            </div>
            
            <div class="card-body p-4">
                <div id="toast-container">
                    <c:if test="${param.register == 'success'}">
                        <div class="vue-toast" data-autohide="true">
                            <div class="vue-toast-icon"><i class="fa-solid fa-check-circle"></i></div>
                            <div class="vue-toast-body">Đăng ký thành công!<br>Vui lòng đăng nhập.</div>
                            <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                            <div class="vue-toast-progress"></div>
                        </div>
                    </c:if>

                    <c:if test="${param.error == 'login_failed'}">
                        <div class="vue-toast error" data-autohide="true">
                            <div class="vue-toast-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                            <div class="vue-toast-body">Sai email hoặc mật khẩu!</div>
                            <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                            <div class="vue-toast-progress"></div>
                        </div>
                    </c:if>

                    <c:if test="${param.error == 'email_exists'}">
                        <div class="vue-toast error" data-autohide="true">
                            <div class="vue-toast-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                            <div class="vue-toast-body">Email này đã được sử dụng!</div>
                            <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                            <div class="vue-toast-progress"></div>
                        </div>
                    </c:if>

                    <c:if test="${param.error == 'phone_exists'}">
                        <div class="vue-toast error" data-autohide="true">
                            <div class="vue-toast-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                            <div class="vue-toast-body">Số điện thoại này đã tồn tại!</div>
                            <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                            <div class="vue-toast-progress"></div>
                        </div>
                    </c:if>

                    <c:if test="${param.error == 'password_mismatch'}">
                        <div class="vue-toast error" data-autohide="true">
                            <div class="vue-toast-icon"><i class="fa-solid fa-circle-xmark"></i></div>
                            <div class="vue-toast-body">Mật khẩu xác nhận không khớp!</div>
                            <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                            <div class="vue-toast-progress"></div>
                        </div>
                    </c:if>
                </div>

                <ul class="nav nav-tabs nav-fill mb-4" id="loginTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link ${activeTab == 'login' ? 'active' : ''}" id="login-tab-btn" data-bs-toggle="tab" data-bs-target="#login-panel" type="button">Đăng Nhập</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link ${activeTab == 'register' ? 'active' : ''}" id="register-tab-btn" data-bs-toggle="tab" data-bs-target="#register-panel" type="button">Đăng Ký</button>
                    </li>
                </ul>

                <div class="tab-content" id="loginTabContent">
                    
                    <div class="tab-pane fade ${activeTab == 'login' ? 'show active' : ''}" id="login-panel" role="tabpanel">
                        <form action="${pageContext.request.contextPath}/login" method="post">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Email</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-envelope"></i></span>
                                    <input type="email" name="email" class="form-control" placeholder="Nhập email của bạn" required value="${cookie.c_email.value}">
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Mật khẩu</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-lock"></i></span>
                                    <input type="password" name="password" class="form-control" placeholder="Nhập mật khẩu" required value="${cookie.c_pass.value}">
                                </div>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="form-check">
                                    <input type="checkbox" class="form-check-input" id="rememberMe" name="remember" ${cookie.c_email != null ? 'checked' : ''}>
                                    <label class="form-check-label small" for="rememberMe">Ghi nhớ đăng nhập</label>
                                </div>
                                <a href="forgot_password.jsp" class="small text-decoration-none">Quên mật khẩu?</a>
                            </div>
                            <button type="submit" class="btn btn-primary w-100 py-2 fw-bold" style="background-color: #d35400; border-color: #d35400;">ĐĂNG NHẬP</button>
                        </form>
                    </div>

                    <div class="tab-pane fade ${activeTab == 'register' ? 'show active' : ''}" id="register-panel" role="tabpanel">
                        <form action="${pageContext.request.contextPath}/register" method="post">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Họ và tên</label>
                                <input type="text" name="name" class="form-control" placeholder="Nhập họ tên đầy đủ" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Email</label>
                                <input type="email" name="email" class="form-control" placeholder="Nhập địa chỉ email" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Số điện thoại</label>
                                <input type="tel" name="phone" class="form-control" placeholder="Nhập số điện thoại (bắt đầu bằng số 0)" required pattern="^0[0-9]{9}$" maxlength="10" inputmode="numeric" oninput="this.value = this.value.replace(/[^0-9]/g, '');">
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Mật khẩu</label>
                                <input type="password" name="password" class="form-control" placeholder="Tối thiểu 6 ký tự" required minlength="6">
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Xác nhận mật khẩu</label>
                                <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu" required>
                            </div>
                            <div class="form-check mb-3">
                                <input type="checkbox" class="form-check-input" id="agreeTerms" required>
                                <label class="form-check-label small" for="agreeTerms">Tôi đồng ý với <a href="#">Điều khoản sử dụng</a></label>
                            </div>
                            <button type="submit" class="btn btn-success w-100 py-2 fw-bold">ĐĂNG KÝ NGAY</button>
                        </form>
                    </div>

                </div>

                <hr class="my-4">
                
                <div class="text-center mb-3 small text-muted">Hoặc đăng nhập bằng</div>
                <div class="row">
                    <div class="mb-3">
                        <a href="https://accounts.google.com/o/oauth2/auth?scope=email profile&redirect_uri=https://shopcafe.onrender.com/login-google&response_type=code&client_id=197666350056-9pqv4650vrejdaurpflk52l6ks65emse.apps.googleusercontent.com&approval_prompt=force" 
                            class="btn btn-outline-danger social-btn w-100">
                                <i class="fa-brands fa-google"></i> Google
                            </a>
                    </div>
                </div>

            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <p>&copy; 2025 Quán Cà Phê Vĩnh Long. Đồ án môn học Công Nghệ Thông Tin 1.</p>
            <p>Sinh viên thực hiện: Phan Tuấn Cảnh - Võ Phúc Nguyên</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    // Hàm đóng toast ngay lập tức khi bấm nút X
    function closeToast(button) {
        const toast = button.closest('.vue-toast');
        toast.classList.add('toast-hide');
        setTimeout(() => toast.remove(), 500); // Đợi hiệu ứng bay ra xong mới xóa DOM
    }

    // Tự động đóng sau 3 giây
    document.addEventListener("DOMContentLoaded", function() {
        const toasts = document.querySelectorAll('.vue-toast[data-autohide="true"]');
        
        toasts.forEach(toast => {
            setTimeout(() => {
                // Thêm class để kích hoạt animation bay ra
                toast.classList.add('toast-hide');
                
                // Xóa khỏi DOM sau khi animation kết thúc (0.5s)
                setTimeout(() => {
                    toast.remove();
                }, 500);
            }, 3000); // 3000ms = 3 giây
        });
    });
</script>
</body>
</html>