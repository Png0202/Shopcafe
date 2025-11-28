<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán - Quán Cà Phê</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
    /* --- CSS CHO Ô CHỌN ĐỊA CHỈ (CUSTOM SELECT) --- */
        .custom-select {
            width: 100%;
            height: 55px;
            padding: 10px 30px 10px 10px; /* Padding phải lớn hơn để tránh đè lên mũi tên */
            border: 1px solid #ddd;
            border-radius: 4px;
            background-color: #fff;
            font-family: inherit;
            font-size: 14px;
            color: #333;
            cursor: pointer;
            
            /* Xử lý khi chữ quá dài */
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            
            /* Xóa style mặc định */
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            
            /* Mũi tên tùy chỉnh */
            background-image: url("data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23007CB2%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E");
            background-repeat: no-repeat;
            background-position: right 10px top 50%;
            background-size: 12px auto;
        }
        
        /* Style cho Option bên trong (khi xổ xuống) */
        .custom-select option {
            padding: 10px;
            font-size: 14px;
            /* Giới hạn độ rộng option */
            max-width: 100%; 
            white-space: pre-wrap; /* Cho phép xuống dòng nếu cần thiết trong dropdown */
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>☕ Quán Cà Phê Vĩnh Long</h1>
            <nav>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/menu">Thực Đơn</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart">Giỏ Hàng</a></li>
                    <c:choose>
                        <c:when test="${not empty sessionScope.userEmail}">
                            <li><a href="${pageContext.request.contextPath}/profile" style="font-weight: bold; color: #d35400;">Tài Khoản (${sessionScope.userName})</a></li>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/login.jsp">Đăng Nhập</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </nav>
        </div>
    </header>

    <section class="cart-section">
        <div class="container">
            <h2 class="section-title">Thanh Toán</h2>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-top: 2rem;">
                
                <%-- PHẦN 1: FORM THÔNG TIN --%>
                <div class="form-container" style="margin: 0;">
                    <h3 style="color: var(--primary-color); margin-bottom: 1.5rem;">Thông Tin Khách Hàng</h3>
                    
                    <%-- ID checkoutForm dùng để liên kết với nút Submit ở cột bên phải --%>
                    <form action="checkout" method="post" id="checkoutForm">
                        <div class="form-group">
                            <label>Họ và Tên</label>
                            <input type="text" name="customerName" value="${requestScope.customerName}" readonly style="background: #eee;">
                        </div>
                        
                        <div class="form-group">
                            <label>Số Điện Thoại</label>
                            <input type="tel" name="phone" value="${requestScope.customerPhone}" readonly style="background: #eee;">
                        </div>
                        
                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" value="${sessionScope.userEmail}" readonly style="background: #eee;">
                        </div>
                        
                        <%-- PHẦN CHỌN ĐỊA CHỈ MỚI --%>
                        <div class="form-group">
                            <label>Địa Chỉ Giao Hàng <span style="color: red;">*</span></label>
                            
                            <c:choose>
                                <%-- Nếu chưa có địa chỉ nào -> Hiện ô nhập tay --%>
                                <c:when test="${empty requestScope.listAddresses}">
                                    <textarea name="address" rows="3" required class="info-control" placeholder="Bạn chưa có địa chỉ lưu sẵn..."></textarea>
                                    <div style="margin-top: 5px; font-size: 12px;">
                                        <a href="${pageContext.request.contextPath}/profile?tab=addresses" target="_blank" style="color: #d35400;">+ Thêm địa chỉ mới</a>
                                    </div>
                                </c:when>
                                
                                <%-- Nếu đã có địa chỉ -> Hiện danh sách chọn --%>
                                <c:otherwise>
                                    <select name="address" id="addressSelect" required class="custom-select" onchange="previewAddress(this)">
                                        <c:forEach var="addr" items="${requestScope.listAddresses}">
                                            <%-- 
                                                Logic cắt chuỗi thông minh: 
                                                - Chỉ cắt hiển thị trong ô select (label)
                                                - Giá trị thực (value) vẫn giữ nguyên đầy đủ để gửi đi 
                                            --%>
                                            <option value="${addr}">
                                                <c:choose>
                                                    <c:when test="${addr.length() > 60}">
                                                        ${addr.substring(0, 60)}...
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${addr}
                                                    </c:otherwise>
                                                </c:choose>
                                            </option>
                                        </c:forEach>
                                    </select>

                                    <div id="addressMarquee" class="marquee-container">
                                        <span id="marqueeText" class="marquee-content"></span>
                                    </div>

                                    <div style="margin-top: 8px; text-align: right;">
                                        <a href="${pageContext.request.contextPath}/profile?tab=addresses" target="_blank" style="font-size: 13px; color: #d35400; text-decoration: none;">
                                            ⚙ Quản lý sổ địa chỉ
                                        </a>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="form-group">
                            <label>Phương Thức Thanh Toán <span style="color: red;">*</span></label>
                            <select name="paymentMethod" required class="custom-select">
                                <option value="cash">Tiền Mặt (COD)</option>
                                <option value="banking">Chuyển Khoản Ngân Hàng</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label>Ghi Chú</label>
                            <textarea name="notes" rows="3" placeholder="Ghi chú cho đơn hàng (nếu có)"></textarea>
                        </div>
                        
                        <a href="${pageContext.request.contextPath}/cart" class="btn btn-secondary" style="width: 100%; text-align: center; display: block;">← Quay Lại Giỏ Hàng</a>
                    </form>
                </div>
        
                <%-- PHẦN 2: TÓM TẮT ĐƠN HÀNG --%>
                <div>
                    <div class="cart-summary">
                        <h3>Tóm Tắt Đơn Hàng</h3>
                        
                        <div id="order-summary" style="margin: 1.5rem 0; max-height: 300px; overflow-y: auto;">
                            <c:forEach var="item" items="${requestScope.cartItems}">
                                <div style="display: flex; justify-content: space-between; padding: 0.8rem 0; border-bottom: 1px solid #eee;">
                                    <div>
                                        <strong>${item.productName}</strong>
                                        <div style="color: #666; font-size: 0.9rem;">
                                            <fmt:formatNumber value="${item.price}" pattern="#,###"/> VNĐ × ${item.quantity}
                                        </div>
                                    </div>
                                    <div style="font-weight: bold;">
                                        <fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/> VNĐ
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        
                        <div style="border-top: 1px solid #ddd; padding-top: 1rem; margin-top: 1rem;">
                            <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                                <span>Tạm tính:</span>
                                <span><fmt:formatNumber value="${requestScope.subTotal}" pattern="#,###"/> VNĐ</span>
                            </div>
                            <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                                <span>Phí vận chuyển:</span>
                                <span><fmt:formatNumber value="${requestScope.shippingFee}" pattern="#,###"/> VNĐ</span>
                            </div>
                            <div class="cart-total">
                                <span>Tổng cộng:</span>
                                <span style="color: #d35400;"><fmt:formatNumber value="${requestScope.finalTotal}" pattern="#,###"/> VNĐ</span>
                            </div>
                        </div>
                        
                        <div style="margin-top: 1.5rem;">
                            <%-- Nút Submit nằm ngoài form nhưng có attribute form="checkoutForm" để liên kết --%>
                            <button type="submit" form="checkoutForm" class="btn" style="width: 100%; padding: 1rem; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;" onclick="return confirm('Xác nhận đặt hàng?');">Xác Nhận Đặt Hàng</button>
                        </div>
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

    <%-- Script xử lý Marquee và Responsive --%>
    <script>
        // Hàm hiển thị chữ chạy khi chọn địa chỉ
        function previewAddress(selectElement) {
            const selectedAddress = selectElement.value;
            const marqueeContainer = document.getElementById('addressMarquee');
            const marqueeText = document.getElementById('marqueeText');

            if (selectedAddress) {
                marqueeText.innerText = "Giao đến: " + selectedAddress;
                marqueeContainer.style.display = 'block';
            } else {
                marqueeContainer.style.display = 'none';
            }
        }

        // Chạy khi load trang
        window.addEventListener('load', function() {
            // Xử lý Responsive
            const container = document.querySelector('.cart-section .container > div');
            const handleResize = () => {
                if (window.innerWidth <= 768) container.style.gridTemplateColumns = '1fr';
                else container.style.gridTemplateColumns = '1fr 1fr';
            };
            window.addEventListener('resize', handleResize);
            handleResize();

            // Khởi tạo preview địa chỉ mặc định
            const addrSelect = document.getElementById('addressSelect');
            if (addrSelect) {
                previewAddress(addrSelect);
            }
        });
    </script>
</body>
</html>