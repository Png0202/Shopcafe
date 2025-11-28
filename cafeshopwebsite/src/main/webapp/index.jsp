<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quán Cà Phê - Trang Chủ</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* CSS RIÊNG CHO LAYOUT XẾP TẦNG (BEST SELLER) */
        .best-seller-section {
            padding: 80px 0;
            background-color: #fff;
        }
        .layer-item {
            display: flex;
            align-items: center;
            gap: 60px;
            margin-bottom: 100px; /* Khoảng cách giữa các món */
            opacity: 0;
            transform: translateY(50px);
            animation: fadeInUp 0.8s forwards;
        }
        .layer-image {
            flex: 1;
            position: relative;
        }
        .layer-image img {
            width: 100%;
            height: 450px;
            object-fit: cover;
            border-radius: 20px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
            transition: transform 0.5s ease;
        }
        .layer-image img:hover {
            transform: scale(1.03);
        }
        
        /* Badge Top 1, 2, 3 */
        .rank-badge {
            position: absolute; top: -25px;
            background: linear-gradient(45deg, #d35400, #e67e22);
            color: #fff;
            padding: 12px 25px;
            font-weight: 800;
            font-size: 16px;
            border-radius: 50px;
            box-shadow: 0 5px 15px rgba(211, 84, 0, 0.4);
            z-index: 2;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .layer-content {
            flex: 1;
        }
        .layer-title {
            font-size: 42px;
            color: #2c3e50;
            margin-bottom: 25px;
            font-weight: 900;
            line-height: 1.2;
        }
        .layer-desc {
            font-size: 18px;
            color: #666;
            line-height: 1.8;
            margin-bottom: 30px;
        }
        .layer-price {
            font-size: 32px;
            color: #d35400;
            font-weight: bold;
            margin-bottom: 35px;
            font-family: 'Arial', sans-serif;
        }
        
        .btn-order-now {
            display: inline-block;
            padding: 15px 50px;
            background-color: #2c3e50;
            color: #fff;
            border: none;
            border-radius: 50px;
            font-size: 16px;
            font-weight: bold;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 5px 15px rgba(44, 62, 80, 0.3);
        }
        .btn-order-now:hover {
            background-color: #d35400;
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(211, 84, 0, 0.4);
        }

        @keyframes fadeInUp {
            to { opacity: 1; transform: translateY(0); }
        }

        /* Responsive Mobile */
        @media (max-width: 768px) {
            .layer-item { flex-direction: column !important; gap: 30px; text-align: center !important; }
            .layer-content { text-align: center !important; }
            .rank-badge { left: 50% !important; right: auto !important; transform: translateX(-50%); }
            .layer-image img { height: 300px; }
        }
    </style>
</head>
<body>
    
    <%-- HEADER --%>
    <header>
        <div class="container">
            <h1>☕ Quán Cà Phê Vĩnh Long</h1>
            <nav>
                <ul>
                    <%-- MENU CHUNG --%>
                    <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/menu">Thực Đơn</a></li>

                    <%-- LOGIC PHÂN QUYỀN --%>
                    <c:choose>
                        <c:when test="${not empty sessionScope.userEmail}">
                            <%-- ĐÃ ĐĂNG NHẬP --%>
                            <c:choose>
                                <%-- QUYỀN ADMIN (0) --%>
                                <c:when test="${sessionScope.permission == 0}">
                                    <li><a href="${pageContext.request.contextPath}/admin" style="color:red;font-weight:bold;">QUẢN TRỊ</a></li>
                                </c:when>
                                
                                <%-- QUYỀN NHÂN VIÊN (1) --%>
                                <c:when test="${sessionScope.permission == 1}">
                                    <li><a href="${pageContext.request.contextPath}/staff" style="color:blue;font-weight:bold;">NHÂN VIÊN</a></li>
                                </c:when>
                                
                                <%-- QUYỀN KHÁCH HÀNG (2 hoặc khác) --%>
                                <c:otherwise>
                                    <li><a href="${pageContext.request.contextPath}/cart">Giỏ Hàng</a></li>
                                    <li><a href="${pageContext.request.contextPath}/profile" style="color:#d35400;font-weight:bold;">Tài Khoản (${sessionScope.userName})</a></li>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        
                        <%-- CHƯA ĐĂNG NHẬP --%>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/login.jsp">Đăng Nhập</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </nav>
        </div>
    </header>

    <%-- HERO BANNER --%>
    <section class="hero">
        <div class="container">
            <h2>Hương Vị Đánh Thức Mọi Giác Quan</h2>
            <p>Trải nghiệm cà phê nguyên bản và không gian thư giãn tuyệt vời tại Vĩnh Long</p>
        </div>
    </section>

    <%-- SẢN PHẨM NỔI BẬT (BEST SELLER - KIỂU XẾP TẦNG) --%>
    <section class="best-seller-section">
        <div class="container">
            
            <c:forEach var="product" items="${featuredProducts}" varStatus="status">
                
                <div class="layer-item" style="animation-delay: ${status.index * 0.2}s; flex-direction: ${status.index % 2 == 0 ? 'row' : 'row-reverse'};">
                    
                    <div class="layer-image">
                        <img src="${product.imageUrl}" alt="${product.name}" onerror="this.src='https://placehold.co/600x450?text=${product.name}'">
                    </div>

                    <div class="layer-content" style="text-align: ${status.index % 2 == 0 ? 'left' : 'right'};">
                        <h3 class="layer-title">${product.name}</h3>
                        
                        <p class="layer-desc">
                            ${not empty product.description ? product.description : 'Hương vị đậm đà khó quên, được pha chế từ những nguyên liệu tuyển chọn kỹ lưỡng nhất. Một sự lựa chọn hoàn hảo để bắt đầu ngày mới.'}
                        </p>
                        
                        <div class="layer-price">
                            <fmt:formatNumber value="${product.price}" pattern="#,###"/> VNĐ
                        </div>

                        <form action="cart" method="post" style="display: inline-block;">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="productId" value="${product.id}">
                            <button type="submit" class="btn-order-now">
                                Đặt Món Ngay ➔
                            </button>
                        </form>
                    </div>

                </div>
            </c:forEach>

            <div style="text-align: center; margin-top: 50px;">
                <a href="${pageContext.request.contextPath}/menu" class="btn btn-secondary" style="padding: 15px 40px; border-radius: 50px;">Xem Tất Cả Thực Đơn</a>
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
</body>
</html>