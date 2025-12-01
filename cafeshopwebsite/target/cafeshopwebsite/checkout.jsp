<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán - Quán Cà Phê</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <style>
        body { background-color: #f8f9fa; }
        
        /* Tinh chỉnh form cho đẹp hơn */
        .form-label { font-weight: 600; color: #555; }
        .form-control:focus, .form-select:focus {
            border-color: #d35400;
            box-shadow: 0 0 0 0.25rem rgba(211, 84, 0, 0.25);
        }
        
        /* Card tóm tắt đơn hàng */
        .summary-card {
            position: sticky;
            top: 20px; /* Dính khi cuộn trên PC */
            border: none;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }
        
        .marquee-content { display: inline-block; padding-left: 100%; animation: marquee 15s linear infinite; }
        @keyframes marquee { 0% { transform: translate(0, 0); } 100% { transform: translate(-100%, 0); } }

        /* Responsive Mobile */
        @media (max-width: 992px) {
            .summary-card { position: static; margin-top: 20px; } /* Bỏ dính trên mobile */
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
                    <c:choose>
                        <c:when test="${not empty sessionScope.userEmail}">
                            <c:choose>
                                <c:when test="${sessionScope.permission == 0}">
                                    <li><a href="${pageContext.request.contextPath}/admin" style="color:red;font-weight:bold;">QUẢN TRỊ</a></li>
                                </c:when>
                                <c:when test="${sessionScope.permission == 1}">
                                    <li><a href="${pageContext.request.contextPath}/staff" style="color:blue;font-weight:bold;">NHÂN VIÊN</a></li>
                                </c:when>
                                <c:otherwise>
                                    <li><a href="${pageContext.request.contextPath}/cart">Giỏ Hàng</a></li>
                                    <li><a href="${pageContext.request.contextPath}/profile" style="font-weight: bold; color: #d35400;">Tài Khoản (${sessionScope.userName})</a></li>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/login.jsp">Đăng Nhập</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container mt-3">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="home" class="text-decoration-none text-secondary">Trang chủ</a></li>
                <li class="breadcrumb-item"><a href="cart" class="text-decoration-none text-secondary">Giỏ hàng</a></li>
                <li class="breadcrumb-item active" aria-current="page">Thanh toán</li>
            </ol>
        </nav>
    </div>

    <section class="py-4">
        <div class="container">
            <h2 class="text-center mb-4 text-uppercase fw-bold" style="color: #6f4e37;">Thanh Toán Đơn Hàng</h2>
            
            <form action="checkout" method="post" id="checkoutForm">
                <div class="row g-4">
                    
                    <%-- CỘT TRÁI: THÔNG TIN GIAO HÀNG --%>
                    <div class="col-lg-7">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-bottom py-3">
                                <h5 class="m-0 fw-bold text-primary"><i class="fa-solid fa-address-card me-2"></i>Thông Tin Giao Hàng</h5>
                            </div>
                            <div class="card-body p-4">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Họ và Tên</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light"><i class="fa-solid fa-user"></i></span>
                                            <input type="text" class="form-control bg-light" value="${requestScope.customerName}" readonly>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Số Điện Thoại</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light"><i class="fa-solid fa-phone"></i></span>
                                            <input type="text" class="form-control bg-light" value="${requestScope.customerPhone}" readonly>
                                        </div>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label">Email</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light"><i class="fa-solid fa-envelope"></i></span>
                                            <input type="text" class="form-control bg-light" value="${sessionScope.userEmail}" readonly>
                                        </div>
                                    </div>
                                    
                                    <div class="col-12">
                                        <label class="form-label text-danger">Địa Chỉ Nhận Hàng *</label>
                                        <c:choose>
                                            <c:when test="${empty requestScope.listAddresses}">
                                                <textarea name="address" rows="3" class="form-control" required placeholder="Vui lòng nhập địa chỉ..."></textarea>
                                                <div class="form-text"><a href="${pageContext.request.contextPath}/profile?tab=addresses" target="_blank" class="text-decoration-none">+ Thêm địa chỉ mới</a></div>
                                            </c:when>
                                            <c:otherwise>
                                                <select name="address" id="addressSelect" class="form-select" required onchange="previewAddress(this)">
                                                    <c:forEach var="addr" items="${requestScope.listAddresses}">
                                                        <option value="${addr}">
                                                            ${addr.length() > 60 ? addr.substring(0, 60).concat("...") : addr}
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                                <div id="addressMarquee" class="marquee-container">
                                                    <span id="marqueeText" class="marquee-content"></span>
                                                </div>
                                                <div class="form-text text-end"><a href="${pageContext.request.contextPath}/profile?tab=addresses" target="_blank" class="text-decoration-none">Quản lý địa chỉ</a></div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="col-12">
                                        <label class="form-label text-danger">Phương Thức Thanh Toán *</label>
                                        <div class="form-check p-3 border rounded mb-2">
                                            <input class="form-check-input" type="radio" name="paymentMethod" id="payCash" value="cash" checked>
                                            <label class="form-check-label w-100" for="payCash">
                                                <i class="fa-solid fa-money-bill-1 me-2 text-success"></i>Tiền Mặt (COD)
                                            </label>
                                        </div>
                                        <div class="form-check p-3 border rounded">
                                            <input class="form-check-input" type="radio" name="paymentMethod" id="payBank" value="banking">
                                            <label class="form-check-label w-100" for="payBank">
                                                <i class="fa-solid fa-building-columns me-2 text-primary"></i>Chuyển Khoản Ngân Hàng (QR Code)
                                            </label>
                                        </div>
                                    </div>

                                    <div class="col-12">
                                        <label class="form-label">Ghi Chú Đơn Hàng</label>
                                        <textarea name="notes" rows="2" class="form-control" placeholder="Ví dụ: Ít đường, nhiều đá..."></textarea>
                                    </div>
                                </div>
                                
                                <div class="mt-4">
                                    <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-secondary">
                                        <i class="fa-solid fa-arrow-left me-2"></i>Quay Lại Giỏ Hàng
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- CỘT PHẢI: TÓM TẮT ĐƠN HÀNG --%>
                    <div class="col-lg-5">
                        <div class="card summary-card">
                            <div class="card-header bg-white border-bottom py-3">
                                <h5 class="m-0 fw-bold text-secondary"><i class="fa-solid fa-receipt me-2"></i>Tóm Tắt Đơn Hàng</h5>
                            </div>
                            <div class="card-body p-0">
                                <ul class="list-group list-group-flush" style="max-height: 300px; overflow-y: auto;">
                                    <c:forEach var="item" items="${requestScope.cartItems}">
                                        <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                                            <div>
                                                <h6 class="my-0 fw-bold">${item.productName}</h6>
                                                <small class="text-muted"><fmt:formatNumber value="${item.price}" pattern="#,###"/> ₫ x ${item.quantity}</small>
                                            </div>
                                            <span class="text-dark fw-bold"><fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/> ₫</span>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </div>
                            <div class="card-footer bg-light p-4">
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="text-muted">Tạm tính</span>
                                    <strong><fmt:formatNumber value="${requestScope.subTotal}" pattern="#,###"/> ₫</strong>
                                </div>
                                <div class="d-flex justify-content-between mb-3 pb-3 border-bottom">
                                    <span class="text-muted">Phí vận chuyển</span>
                                    <strong><fmt:formatNumber value="${requestScope.shippingFee}" pattern="#,###"/> ₫</strong>
                                </div>
                                <div class="d-flex justify-content-between align-items-center mb-4">
                                    <span class="h5 mb-0">Tổng cộng</span>
                                    <span class="h4 mb-0 text-danger fw-bold"><fmt:formatNumber value="${requestScope.finalTotal}" pattern="#,###"/> ₫</span>
                                </div>
                                
                                <button type="submit" class="btn btn-success w-100 py-3 fw-bold text-uppercase shadow" onclick="return confirm('Xác nhận đặt hàng?');">
                                    Xác Nhận Đặt Hàng <i class="fa-solid fa-check ms-2"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    
                </div>
            </form>
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

        window.addEventListener('load', function() {
            const addrSelect = document.getElementById('addressSelect');
            if (addrSelect) { previewAddress(addrSelect); }
        });
    </script>
</body>
</html>