<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ Hàng - Quán Cà Phê</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <style>
        /* Tùy chỉnh thêm để không xung đột với style.css cũ */
        body { background-color: #f8f9fa; }
        
        /* Chỉnh ảnh sản phẩm trong bảng */
        .cart-product-img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 8px;
        }
        
        /* --- CSS Nút Số Lượng (Mới - Nhỏ gọn) --- */
        .qty-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0;
        }
        
        .qty-form { margin: 0; }
        
        .qty-btn { 
            background: #fff; 
            border: 1px solid #ced4da; 
            width: 25px; 
            height: 25px; 
            cursor: pointer;
            font-size: 12px; 
            display: flex; 
            align-items: center; 
            justify-content: center;
            border-radius: 4px;
            color: #6c757d;
            transition: all 0.2s;
            padding: 0;
        }
        
        .qty-btn:hover:not(:disabled) {
            background-color: #e9ecef;
            color: #000;
            border-color: #adb5bd;
        }
        
        .qty-input {
            width: 35px;
            height: 25px;
            text-align: center;
            border: 1px solid #ced4da;
            border-left: 0;
            border-right: 0;
            font-size: 13px;
            padding: 0;
            background-color: #fff;
            color: #333;
            font-weight: 500;
        }
        
        /* Bảng cuộn ngang trên mobile */
        .table-responsive {
            width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            margin-bottom: 20px;
            border: 1px solid #eee;
            background: white;
            border-radius: 8px;
        }
        .table-responsive table {
            width: 100%;
            min-width: 600px; /* Đảm bảo bảng không bị co dúm */
            border-collapse: collapse;
        }
        
        /* Card tổng tiền */
        .cart-summary-card {
            border: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            position: sticky;
            top: 80px; /* Dính khi cuộn trang */
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
                                    <li><a href="${pageContext.request.contextPath}/cart" class="active">Giỏ Hàng</a></li>
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
                <li class="breadcrumb-item active" aria-current="page">Giỏ hàng của bạn</li>
            </ol>
        </nav>
    </div>

    <section class="cart-section py-4">
        <div class="container">
            <h2 class="text-center mb-4 text-uppercase fw-bold" style="color: #6f4e37;">Giỏ Hàng Của Bạn</h2>
            
            <%-- KIỂM TRA GIỎ HÀNG RỖNG HAY KHÔNG --%>
            <c:choose>
                <c:when test="${empty requestScope.cartItems}">
                    <div class="text-center py-5 bg-white rounded shadow-sm">
                        <div class="mb-3">
                            <i class="fa-solid fa-cart-arrow-down fa-4x text-muted"></i>
                        </div>
                        <h3 class="text-muted mb-3">Giỏ hàng của bạn đang trống</h3>
                        <p class="mb-4">Hãy thêm sản phẩm vào giỏ hàng để tiếp tục mua sắm</p>
                        <a href="${pageContext.request.contextPath}/menu" class="btn btn-warning text-white fw-bold px-4 py-2">
                            <i class="fa-solid fa-utensils me-2"></i>Xem Thực Đơn
                        </a>
                    </div>
                </c:when>
                
                <c:otherwise>
                    <div class="row">
                        <%-- CỘT TRÁI: DANH SÁCH SẢN PHẨM --%>
                        <div class="col-lg-8 mb-4">
                            <div class="card border-0 shadow-sm">
                                <div class="card-body p-0">
                                    <div class="table-responsive">
                                        <table class="table table-hover align-middle mb-0 text-center">
                                            <thead class="table-light">
                                                <tr>
                                                    <th class="text-start ps-4">Sản phẩm</th>
                                                    <th>Đơn giá</th>
                                                    <th>Số lượng</th>
                                                    <th>Thành tiền</th>
                                                    <th>Xóa</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="item" items="${requestScope.cartItems}">
                                                    <tr>
                                                        <td class="text-start ps-4">
                                                            <div class="d-flex align-items-center">
                                                                <img src="${item.imageUrl}" alt="${item.productName}" class="cart-product-img me-3 border">
                                                                <div>
                                                                    <div class="fw-bold text-dark">${item.productName}</div>
                                                                    <%-- Nếu có Note thì hiện ở đây --%>
                                                                    <c:if test="${not empty item.note}">
                                                                        <small class="text-muted fst-italic">(${item.note})</small>
                                                                    </c:if>
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td class="text-muted">
                                                            <fmt:formatNumber value="${item.price}" pattern="#,###"/> ₫
                                                        </td>
                                                        <td>
                                                            <div class="qty-wrapper">
                                                                <form action="cart" method="post" class="qty-form">
                                                                    <input type="hidden" name="action" value="update">
                                                                    <input type="hidden" name="productId" value="${item.productId}">
                                                                    <input type="hidden" name="quantity" value="${item.quantity - 1}">
                                                                    <button class="qty-btn" type="submit" ${item.quantity <= 1 ? 'disabled' : ''}>
                                                                        <i class="fa-solid fa-minus"></i>
                                                                    </button>
                                                                </form>
                                                                
                                                                <input type="text" class="qty-input" value="${item.quantity}" readonly>
                                                                
                                                                <form action="cart" method="post" class="qty-form">
                                                                    <input type="hidden" name="action" value="update">
                                                                    <input type="hidden" name="productId" value="${item.productId}">
                                                                    <input type="hidden" name="quantity" value="${item.quantity + 1}">
                                                                    <button class="qty-btn" type="submit">
                                                                        <i class="fa-solid fa-plus"></i>
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </td>
                                                        <td class="fw-bold text-danger">
                                                            <fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/> ₫
                                                        </td>
                                                        <td>
                                                            <form action="cart" method="post" onsubmit="return confirm('Xóa sản phẩm này?');" class="m-0">
                                                                <input type="hidden" name="action" value="remove">
                                                                <input type="hidden" name="productId" value="${item.productId}">
                                                                <button class="btn btn-sm btn-danger border-0">
                                                                    <i class="fa-solid fa-trash"></i>
                                                                </button>
                                                            </form>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- CỘT PHẢI: TỔNG KẾT & THANH TOÁN --%>
                        <div class="col-lg-4">
                            <div class="card cart-summary-card">
                                <div class="card-header bg-white border-bottom py-3">
                                    <h5 class="mb-0 fw-bold text-dark"><i class="fa-solid fa-file-invoice-dollar me-2 text-warning"></i>Tóm Tắt Đơn Hàng</h5>
                                </div>
                                <div class="card-body">
                                    <div class="d-flex justify-content-between mb-2">
                                        <span class="text-muted">Tạm tính:</span>
                                        <span class="fw-bold"><fmt:formatNumber value="${grandTotal}" pattern="#,###"/> ₫</span>
                                    </div>
                                    <div class="d-flex justify-content-between mb-3 border-bottom pb-3">
                                        <span class="text-muted">Phí vận chuyển:</span>
                                        <span class="text-success">Miễn phí</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mb-4">
                                        <span class="h5 mb-0 fw-bold">Tổng cộng:</span>
                                        <span class="h4 mb-0 fw-bold text-danger"><fmt:formatNumber value="${grandTotal}" pattern="#,###"/> ₫</span>
                                    </div>
                                    
                                    <%-- CÁC NÚT BẤM --%>
                                    <div class="d-grid gap-2">
                                        <a href="${pageContext.request.contextPath}/checkout" class="btn btn-success py-2 fw-bold">
                                            <i class="fa-solid fa-credit-card me-2"></i>THANH TOÁN NGAY
                                        </a>
                                        
                                        <div class="row g-2">
                                            <div class="col-6">
                                                <a href="${pageContext.request.contextPath}/menu" class="btn btn-outline-secondary w-100">
                                                    <i class="fa-solid fa-arrow-left me-1"></i> Mua thêm
                                                </a>
                                            </div>
                                            <div class="col-6">
                                                <form action="cart" method="post" onsubmit="return confirm('Xóa hết giỏ hàng?');" class="m-0">
                                                    <input type="hidden" name="action" value="clear">
                                                    <input type="hidden" name="productId" value="0">
                                                    <button class="btn btn-outline-danger w-100">
                                                        <i class="fa-solid fa-trash-can me-1"></i> Xóa hết
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <footer>
        <div class="container">
            <p>&copy; 2025 Quán Cà Phê Vĩnh Long. Đồ án môn học Công Nghệ Thông Tin 1.</p>
            <p>Sinh viên thực hiện: Phan Tuấn Cảnh - Võ Phúc Nguyên</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>