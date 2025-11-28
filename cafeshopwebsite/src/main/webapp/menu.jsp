<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thực Đơn - Quán Cà Phê</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* --- CSS CHO BỘ LỌC (STYLE NỔI) --- */
        .category-filter {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-bottom: 40px;
            flex-wrap: wrap;
        }

        .category-btn {
            padding: 12px 25px;
            border: none;
            background-color: #f8f9fa;
            color: #555;
            font-size: 15px;
            font-weight: 600;
            border-radius: 50px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            border: 1px solid transparent;
        }

        .category-btn:hover {
            background-color: #fff;
            transform: translateY(-3px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.15);
            color: #d35400; 
            border-color: #d35400;
        }

        .category-btn.active {
            background: linear-gradient(45deg, #d35400, #e67e22);
            color: white;
            box-shadow: 0 4px 15px rgba(211, 84, 0, 0.4);
            transform: scale(1.05);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .category-btn { padding: 10px 15px; font-size: 13px; }
        }
    </style>
</head>
<body>
    
    <%-- 
       =========================================================
       PHẦN 1: THANH TRẠNG THÁI POS (MÀU XANH)
       Chỉ hiển thị khi NHÂN VIÊN đang gọi món cho bàn
       =========================================================
    --%>
    <c:if test="${not empty sessionScope.currentTableId}">
        <div style="background: #28a745; color: white; padding: 15px; text-align: center; position: sticky; top: 0; z-index: 1000; box-shadow: 0 2px 10px rgba(0,0,0,0.2); width: 100%; margin: 0;">
            <div class="container" style="display: flex; justify-content: space-between; align-items: center;">
                <h3 style="margin: 0; font-size: 18px;">GỌI MÓN CHO BÀN SỐ ${sessionScope.currentTableId}</h3>
                <div>
                    <a href="${pageContext.request.contextPath}/cart" class="btn" style="background: white; color: #28a745; border: none; padding: 8px 15px; font-size: 14px; text-decoration: none;">Xem Món Đã Gọi</a>
                    <a href="${pageContext.request.contextPath}/staff" class="btn btn-secondary" style="margin-left: 10px; padding: 8px 15px; font-size: 14px; background: rgba(0,0,0,0.2); color: white; text-decoration: none;">Trở Về Trang Chủ</a>
                </div>
            </div>
        </div>
    </c:if>

    <%-- 
       =========================================================
       PHẦN 2: HEADER CHÍNH (MÀU NÂU)
       Chỉ hiển thị khi KHÁCH HÀNG truy cập (Không có bàn)
       =========================================================
    --%>
    <c:if test="${empty sessionScope.currentTableId}">
        <header>
            <div class="container">
                <h1>☕ Quán Cà Phê Vĩnh Long</h1>
                <nav>
                    <ul>
                        <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
                        <li><a href="${pageContext.request.contextPath}/menu" class="active">Thực Đơn</a></li>
                        
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
    </c:if>

    <section class="products-section">
        <div class="container">
            <%-- BỘ LỌC --%>
            <div class="category-filter">
                <button class="category-btn active" data-category="all">Tất Cả</button>
                <button class="category-btn" data-category="coffee">Cà Phê</button>
                <button class="category-btn" data-category="tea">Trà</button>
                <button class="category-btn" data-category="cake">Bánh & Snack</button>
            </div>

            <%-- DANH SÁCH SẢN PHẨM --%>
            <div class="products-grid">
                <c:forEach var="product" items="${allProducts}">
                    <div class="product-card" data-category="${product.category == 'Cà Phê' ? 'coffee' : product.category == 'Trà' ? 'tea' : 'cake'}">
                        
                        <img src="${product.imageUrl}" alt="${product.name}" class="product-image" onerror="this.src='https://placehold.co/400x200?text=${product.name}'">
                        
                        <div class="product-info">
                            <h3 class="product-name">${product.name}</h3>
                            <p class="product-description">${product.description}</p>
                            
                            <p class="product-price">
                                <fmt:formatNumber value="${product.price}" type="number" pattern="#,###"/> VNĐ
                            </p>
                            
                            <div class="product-actions">
                                <form action="cart" method="post">
                                    <input type="hidden" name="action" value="add">
                                    <input type="hidden" name="productId" value="${product.id}">
                                    <button type="submit" class="btn">Thêm Vào Giỏ</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>

    <footer>
        <div class="container">
            <p>&copy; 2025 Quán Cà Phê Vĩnh Long. Đồ án môn học Công Nghệ Thông Tin 1.</p>
            <p>Sinh viên thực hiện: Phan Tuấn Cảnh - Võ Phúc Nguyên</p>
        </div>
    </footer>

    <script>
        const categoryButtons = document.querySelectorAll('.category-btn');
        const productCards = document.querySelectorAll('.product-card');

        categoryButtons.forEach(button => {
            button.addEventListener('click', function() {
                categoryButtons.forEach(btn => btn.classList.remove('active'));
                this.classList.add('active');
                
                const selectedCategory = this.getAttribute('data-category');
                
                productCards.forEach(card => {
                    if (selectedCategory === 'all') {
                        card.style.display = 'block';
                    } else {
                        const cardCategory = card.getAttribute('data-category');
                        card.style.display = cardCategory === selectedCategory ? 'block' : 'none';
                    }
                });
            });
        });
    </script>
</body>
</html>