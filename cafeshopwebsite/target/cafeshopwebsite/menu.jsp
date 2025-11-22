<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thực Đơn - Quán Cà Phê</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%-- HEADER --%>
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

    <section class="products-section">
        <div class="container">
            <h2 class="section-title">Thực Đơn Của Chúng Tôi</h2>
            
            <%-- BỘ LỌC --%>
            <div class="category-filter">
                <button class="category-btn active" data-category="all">Tất Cả</button>
                <button class="category-btn" data-category="coffee">Cà Phê</button>
                <button class="category-btn" data-category="tea">Trà</button>
                <button class="category-btn" data-category="cake">Bánh & Snack</button>
            </div>

            <%-- 
                HIỂN THỊ DANH SÁCH SẢN PHẨM TỪ DATABASE
                Biến ${allProducts} được gửi từ MenuServlet
            --%>
            <div class="products-grid">
                <c:forEach var="product" items="${allProducts}">
                    <%-- Logic xác định category để filter JS hoạt động --%>
                    <div class="product-card" 
                         data-category="${product.category == 'Cà Phê' ? 'coffee' : 
                                          product.category == 'Trà' ? 'tea' : 'cake'}">
                        
                        <img src="${product.imageUrl}" 
                             alt="${product.name}" 
                             class="product-image"
                             onerror="this.src='https://placehold.co/400x200?text=${product.name}'">
                        
                        <div class="product-info">
                            <h3 class="product-name">${product.name}</h3>
                            <p class="product-description">${product.description}</p>
                            
                            <p class="product-price">
                                <fmt:formatNumber value="${product.price}" type="number" pattern="#,###"/> VNĐ
                            </p>
                            
                            <%-- 
                                NÚT THÊM VÀO GIỎ HÀNG (DATABASE)
                                Sử dụng Form để gửi dữ liệu sang CartServlet
                            --%>
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

    <%-- FOOTER --%>
    <footer>
        <div class="container">
            <p>&copy; 2025 Quán Cà Phê Vĩnh Long. Đồ án môn học Công Nghệ Thông Tin 1.</p>
            <p>Sinh viên thực hiện: Phan Tuấn Cảnh - Võ Phúc Nguyên</p>
        </div>
    </footer>

    <%-- JAVASCRIPT FILTER (Giữ nguyên) --%>
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