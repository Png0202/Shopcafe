<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thực Đơn - Quán Cà Phê</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <style>
        body { background-color: #f8f9fa; }

        /* Tùy chỉnh nút bộ lọc cho đẹp hơn Bootstrap mặc định */
        .filter-btn {
            border-radius: 50px;
            padding: 8px 25px;
            font-weight: 600;
            transition: all 0.3s;
            border: 2px solid transparent;
        }
        
        /* Trạng thái chưa chọn */
        .filter-btn.btn-outline-custom {
            background: white;
            border-color: #d35400;
            color: #d35400;
        }
        
        .filter-btn:not(.active):hover { 
            background: #fdf2e9;
            transform: translateY(-2px);
        }
        .filter-btn.active:hover {
            background: linear-gradient(45deg, #d35400, #e67e22);
            color: white;
            border-color: transparent;
            box-shadow: 0 4px 10px rgba(211, 84, 0, 0.3);
            transform: translateY(-2px); /* Thêm nảy lên */
        }
        /* Trạng thái đang chọn */
        .filter-btn.active {
            background: linear-gradient(45deg, #d35400, #e67e22);
            color: white;
            border-color: transparent;
            box-shadow: 0 4px 10px rgba(211, 84, 0, 0.3);
        }

        /* Card Sản Phẩm */
        .product-card {
            border: none;
            border-radius: 15px;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
            background: white;
        }
        
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }

        .product-img-wrapper {
            height: 200px;
            overflow: hidden;
            position: relative;
        }

        .product-img-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s;
        }

        .product-card:hover .product-img-wrapper img {
            transform: scale(1.1);
        }

        .price-tag {
            font-size: 1.2rem;
            font-weight: 800;
            color: #d35400;
        }

        /* Nút thêm giỏ hàng */
        .btn-add-cart {
            background-color: #6f4e37;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 600;
        }
        .btn-add-cart:hover {
            background-color: #5a3e2b;
            color: white;
        }
        .btn:hover {
            background-color: #f3867fff;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }
        
    </style>
</head>
<body>
    
    <%-- 
       1. THANH TRẠNG THÁI POS (MÀU ĐỎ - ĐÃ SỬA)
    --%>
    <c:if test="${not empty sessionScope.currentTableId}">
        <div class="bg-danger text-white py-2 sticky-top shadow-sm">
            <div class="container d-flex justify-content-between align-items-center">
                <h5 class="m-0"><i class="fa-solid fa-utensils me-2"></i>ĐANG GỌI MÓN CHO BÀN SỐ ${sessionScope.currentTableId}</h5>
                <div>
                    <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-light btn-sm fw-bold me-2" style="min-width: 180px;">
                        <i class="fa-solid fa-cart-shopping"></i> Xem Order Bàn Này
                    </a>
                    <a href="${pageContext.request.contextPath}/staff" class="btn btn-outline-light btn-sm fw-bold" style="min-width: 180px;">
                        <i class="fa-solid fa-arrow-left"></i> Trang Nhân Viên
                    </a>
                </div>
            </div>
        </div>
    </c:if>

    <%-- 
       2. HEADER CHÍNH (MÀU NÂU)
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
                                        <li><a href="${pageContext.request.contextPath}/admin" style="color:#ff6b6b;font-weight:bold;">QUẢN TRỊ</a></li>
                                    </c:when>
                                    <c:when test="${sessionScope.permission == 1}">
                                        <li><a href="${pageContext.request.contextPath}/staff" style="color:#4dabf7;font-weight:bold;">NHÂN VIÊN</a></li>
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

    <section class="products-section py-5">
        <div class="container">
            <h2 class="text-center mb-4 text-uppercase fw-bold" style="color: #6f4e37;">Thực Đơn Của Chúng Tôi</h2>
            
            <%-- BỘ LỌC DANH MỤC --%>
            <div class="d-flex justify-content-center flex-wrap gap-2 mb-5">
                <button class="filter-btn btn-outline-custom active" data-category="all">Tất Cả</button>
                <button class="filter-btn btn-outline-custom" data-category="coffee"><i class="fa-solid fa-mug-hot me-1"></i> Cà Phê</button>
                <button class="filter-btn btn-outline-custom" data-category="tea"><i class="fa-solid fa-leaf me-1"></i> Trà</button>
                <button class="filter-btn btn-outline-custom" data-category="cake"><i class="fa-solid fa-bread-slice me-1"></i> Bánh & Snack</button>
            </div>

            <%-- DANH SÁCH SẢN PHẨM (GRID SYSTEM BOOTSTRAP) --%>
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
                <c:forEach var="product" items="${allProducts}">
                    
                    <%-- 
                        Logic xác định category cho JS lọc
                        Lưu ý: data-category đặt ở thẻ COL để ẩn hiện nguyên cột
                    --%>
                    <div class="col product-col" data-category="${product.category == 'Cà Phê' ? 'coffee' : product.category == 'Trà' ? 'tea' : 'cake'}">
                        <div class="card h-100 product-card shadow-sm">
                            
                            <div class="product-img-wrapper">
                                <img src="${product.imageUrl}" class="card-img-top" alt="${product.name}" 
                                     onerror="this.src='https://placehold.co/400x200?text=${product.name}'">
                            </div>
                            
                            <div class="card-body d-flex flex-column text-center">
                                <h5 class="card-title fw-bold" style="color: #333;">${product.name}</h5>
                                <p class="card-text text-muted small flex-grow-1 text-truncate-2">
                                    ${product.description}
                                </p>
                                
                                <div class="mt-3">
                                    <div class="price-tag mb-3">
                                        <fmt:formatNumber value="${product.price}" type="number" pattern="#,###"/> ₫
                                    </div>
                                    
                                    <form action="cart" method="post">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="productId" value="${product.id}">
                                        <button type="submit" class="btn btn-add-cart w-100 py-2">
                                            <i class="fa-solid fa-cart-plus me-2"></i>Thêm Vào Giỏ
                                        </button>
                                    </form>
                                </div>
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
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        const filterButtons = document.querySelectorAll('.filter-btn');
        const productCols = document.querySelectorAll('.product-col'); // Lấy các cột chứa sản phẩm

        filterButtons.forEach(button => {
            button.addEventListener('click', function() {
                // 1. Xử lý Active Button
                filterButtons.forEach(btn => btn.classList.remove('active'));
                this.classList.add('active');
                
                const selectedCategory = this.getAttribute('data-category');
                
                // 2. Xử lý Ẩn/Hiện Sản Phẩm
                productCols.forEach(col => {
                    if (selectedCategory === 'all') {
                        col.style.display = 'block'; // Hiện tất cả
                        // Fix lỗi animation của Bootstrap grid khi hiện lại
                        col.classList.add('animate__fadeIn'); 
                    } else {
                        const cardCategory = col.getAttribute('data-category');
                        if (cardCategory === selectedCategory) {
                            col.style.display = 'block';
                        } else {
                            col.style.display = 'none'; // Ẩn đi
                        }
                    }
                });
            });
        });
    </script>
</body>
</html>