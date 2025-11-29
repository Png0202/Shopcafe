<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quán Cà Phê - Trang Chủ</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <style>
        /* Tùy chỉnh Hero Section cho đẹp hơn */
        .hero-section {
            background: linear-gradient(135deg, #6f4e37, #d4a373);
            color: white;
            padding: 80px 0;
            margin-bottom: 0;
        }
        
        /* Hiệu ứng ảnh sản phẩm */
        .layer-image img {
            transition: transform 0.5s ease;
            cursor: pointer;
        }
        .layer-image img:hover {
            transform: scale(1.03);
        }
        
        /* Badge Top Ranking */
        .rank-badge {
            position: absolute;
            top: -15px;
            left: -15px;
            z-index: 10;
            padding: 10px 25px;
            border-radius: 50px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            font-size: 1.1rem;
            text-transform: uppercase;
        }
        
        /* Gradient Text cho giá */
        .price-text {
            background: -webkit-linear-gradient(45deg, #d35400, #e67e22);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 2rem;
        }
    </style>
</head>
<body>
    
    <header>
        <div class="container">
            <h1>☕ Quán Cà Phê Vĩnh Long</h1>
            <nav>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/home" class="active">Trang Chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/menu">Thực Đơn</a></li>
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

    <section class="hero-section text-center">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <h1 class="display-4 fw-bold mb-3">Hương Vị Đánh Thức Mọi Giác Quan</h1>
                    <p class="lead mb-4">Trải nghiệm cà phê nguyên bản và không gian thư giãn tuyệt vời tại Vĩnh Long. Chúng tôi mang đến những ly cà phê đậm đà nhất.</p>
                    <a href="${pageContext.request.contextPath}/menu" class="btn btn-light btn-lg fw-bold text-dark px-5 py-3 rounded-pill shadow">
                        <i class="fa-solid fa-mug-hot me-2"></i>Khám Phá Menu
                    </a>
                </div>
            </div>
        </div>
    </section>

    <section class="py-5 bg-white">
        <div class="container py-4">
            <div class="text-center mb-5">
                <h2 class="text-uppercase fw-bold" style="color: #6f4e37;">Những món được khách hàng yêu thích nhất tại quán</h2>
                <div style="width: 80px; height: 4px; background: #d35400; margin: 0 auto;"></div>
            </div>
            
            <c:forEach var="product" items="${featuredProducts}" varStatus="status">
                
                <div class="row align-items-center mb-5 g-5 ${status.index % 2 != 0 ? 'flex-lg-row-reverse' : ''}">
                    
                    <div class="col-lg-6 position-relative layer-image">
                        
                        <img src="${product.imageUrl}" alt="${product.name}" 
                             class="img-fluid rounded-4 shadow-lg w-100" 
                             style="height: 400px; object-fit: cover;"
                             onerror="this.src='https://placehold.co/600x450?text=${product.name}'">
                    </div>

                    <div class="col-lg-6 ${status.index % 2 != 0 ? 'text-lg-end' : 'text-lg-start'} text-center">
                        <h2 class="fw-bold mb-3" style="color: #2c3e50;">${product.name}</h2>
                        
                        <p class="lead text-muted mb-4">
                            ${not empty product.description ? product.description : 'Hương vị đậm đà khó quên, được pha chế từ những nguyên liệu tuyển chọn kỹ lưỡng nhất. Một sự lựa chọn hoàn hảo để bắt đầu ngày mới.'}
                        </p>
                        
                        <div class="price-text fw-bold mb-4">
                            <fmt:formatNumber value="${product.price}" pattern="#,###"/> VNĐ
                        </div>

                        <form action="cart" method="post" class="d-inline-block">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="productId" value="${product.id}">
                            <button type="submit" class="btn btn-dark btn-lg rounded-pill px-5 py-3 shadow hover-effect">
                                Đặt Món Ngay <i class="fa-solid fa-arrow-right ms-2"></i>
                            </button>
                        </form>
                    </div>

                </div>
                
                <c:if test="${!status.last}">
                    <hr class="my-5" style="opacity: 0.1;">
                </c:if>

            </c:forEach>

            <div class="text-center mt-5">
                <a href="${pageContext.request.contextPath}/menu" class="btn btn-outline-secondary rounded-pill px-5 py-3 fw-bold">
                    Xem Tất Cả Thực Đơn
                </a>
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
</body>
</html>