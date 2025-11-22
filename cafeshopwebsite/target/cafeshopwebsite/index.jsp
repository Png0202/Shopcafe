<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quán Cà Phê - Trang Chủ</title>
    <!-- Link đến file CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- 
        PHẦN HEADER - Thanh điều hướng phía trên
        Header này sẽ được sử dụng lại trên mọi trang
    -->
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

    <!-- 
        PHẦN HERO - Banner chào mừng lớn
        Đây là phần thu hút sự chú ý đầu tiên của khách hàng
    -->
    <section class="hero">
        <div class="container">
            <h2>Chào Mừng Đến Với Quán Cà Phê Của Chúng Tôi</h2>
            <p>Nơi mang đến cho bạn những tách cà phê thơm ngon nhất và không gian thư giãn tuyệt vời</p>
            <a href="${pageContext.request.contextPath}/menu" class="btn">Xem Thực Đơn</a>
        </div>
    </section>

    <!-- 
        PHẦN SẢN PHẨM NỔI BẬT
        Hiển thị một số sản phẩm đặc biệt để thu hút khách hàng
        
        LƯU Ý QUAN TRỌNG: Đây là MOCK DATA (dữ liệu giả)
        Trong thực tế, dữ liệu này sẽ được gửi từ Servlet (backend)
        Nhưng để test frontend độc lập, chúng ta tạo dữ liệu trực tiếp trong JSP
    -->
    <section class="products-section">
        <div class="container">
            <h2 class="section-title">Sản Phẩm Nổi Bật</h2>
            
            <%-- 
                Tạo mock data cho sản phẩm nổi bật
                Trong thực tế, phần này sẽ được thay bằng: ${products} từ Servlet
            --%>
            <jsp:useBean id="featuredProducts" class="java.util.ArrayList" scope="page"/>
            <%
                // Import các class cần thiết
                java.util.List<com.cafe.model.Product> products = 
                    (java.util.List<com.cafe.model.Product>) pageContext.getAttribute("featuredProducts");
                
                // Tạo dữ liệu giả cho sản phẩm
                // Khi có backend, phần này sẽ được thay bằng dữ liệu từ database
                products.add(new com.cafe.model.Product(
                    1, 
                    "Cà Phê Sữa Đá", 
                    "Cà phê truyền thống Việt Nam với sữa đặc thơm ngon",
                    25000,
                    "Cà Phê",
                    "https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=400"
                ));
                
                products.add(new com.cafe.model.Product(
                    2,
                    "Trà Đào Cam Sả",
                    "Trà trái cây tươi mát với đào, cam và sả thơm",
                    35000,
                    "Trà",
                    "https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400"
                ));
                
                products.add(new com.cafe.model.Product(
                    3,
                    "Bánh Tiramisu",
                    "Bánh Tiramisu Italia với cà phê espresso đậm đà",
                    45000,
                    "Bánh",
                    "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400"
                ));
            %>
            
            <%-- 
                Hiển thị danh sách sản phẩm sử dụng JSTL
                JSTL giúp code sạch hơn so với scriptlet Java thuần
                
                Giải thích:
                - c:forEach: Vòng lặp giống như "for each" trong Java
                - var="product": Biến đại diện cho từng sản phẩm trong vòng lặp
                - items="${featuredProducts}": Danh sách sản phẩm cần lặp
            --%>
            <div class="products-grid">
                <c:forEach var="product" items="${featuredProducts}">
                    <div class="product-card">
                        <%-- 
                            Hiển thị hình ảnh sản phẩm
                            ${product.imageUrl} là Expression Language (EL) 
                            Nó tương đương với product.getImageUrl() trong Java
                        --%>
                        <img src="${product.imageUrl}" 
                             alt="${product.name}" 
                             class="product-image"
                             onerror="this.src='https://placehold.co/400x200?text=Cafe'">
                        
                        <div class="product-info">
                            <h3 class="product-name">${product.name}</h3>
                            <p class="product-description">${product.description}</p>
                            
                            <%-- 
                                Định dạng giá tiền sử dụng JSTL fmt
                                pattern="#,###" sẽ hiển thị: 25000 thành 25,000
                            --%>
                            <p class="product-price">
                                <c:out value="${product.price}"/> VNĐ
                            </p>
                            
                            <%-- Nút thêm vào giỏ hàng --%>
                            <div class="product-actions">
                                <a href="${pageContext.request.contextPath}/cart.jsp?add=${product.id}" 
                                   class="btn">
                                    Thêm Vào Giỏ
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
            
            <%-- Nút xem thêm sản phẩm --%>
            <div style="text-align: center; margin-top: 2rem;">
                <a href="${pageContext.request.contextPath}/menu" class="btn btn-secondary">
                    Xem Tất Cả Sản Phẩm
                </a>
            </div>
        </div>
    </section>

    <%-- 
        PHẦN FOOTER - Chân trang
        Footer này cũng sẽ được sử dụng lại trên mọi trang
    --%>
    <footer>
        <div class="container">
            <p>&copy; 2025 Quán Cà Phê Vĩnh Long. Đồ án môn học Công Nghệ Thông Tin 1.</p>
            <p>Sinh viên thực hiện: Phan Tuấn Cảnh - Võ Phúc Nguyên</p>
        </div>
    </footer>

    <%-- 
        JAVASCRIPT (nếu cần)
        Có thể thêm các script để làm trang động hơn
    --%>
    <script>
        // Script đơn giản để thông báo khi thêm vào giỏ hàng
        document.querySelectorAll('.product-actions .btn').forEach(btn => {
            btn.addEventListener('click', function(e) {
                // Tạm thời không chặn link để có thể chuyển trang
                // e.preventDefault();
                
                // Hiển thị thông báo
                alert('Đã thêm sản phẩm vào giỏ hàng!');
            });
        });
    </script>
</body>
<script>
    // Debug script - xem context path
    console.log('Context Path:', '${pageContext.request.contextPath}');
    
    // Kiểm tra tất cả các link
    document.querySelectorAll('a').forEach(link => {
        if (link.href.includes('cart')) {
            console.log('Cart Link:', link.href);
        }
    });
</script>
</html>