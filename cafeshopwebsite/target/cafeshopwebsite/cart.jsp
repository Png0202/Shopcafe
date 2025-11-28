<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ Hàng - Quán Cà Phê</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* CSS nhỏ cho nút số lượng */
        .qty-form { display: inline-block; }
        .qty-btn { 
            background: #eee; border: 1px solid #ddd; width: 30px; height: 30px; cursor: pointer;
        }
        .qty-input {
            width: 40px; text-align: center; border: 1px solid #ddd; height: 30px;
        }
        
        /* CSS cho bảng cuộn ngang trên mobile */
        .table-responsive {
            width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            margin-bottom: 20px;
            border: 1px solid #eee;
        }
        .table-responsive table {
            width: 100%;
            min-width: 600px; /* Đảm bảo bảng không bị co dúm */
            border-collapse: collapse;
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
                            <%-- KHÁCH HÀNG ĐÃ ĐĂNG NHẬP --%>
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

    <section class="cart-section">
        <div class="container">
            <h2 class="section-title">Giỏ Hàng Của Bạn</h2>
            
            <%-- KIỂM TRA GIỎ HÀNG RỖNG HAY KHÔNG --%>
            <c:choose>
                <c:when test="${empty requestScope.cartItems}">
                    <div style="text-align: center; padding: 3rem;">
                        <h3 style="color: #666; margin-bottom: 1rem;">Giỏ hàng của bạn đang trống</h3>
                        <p style="margin-bottom: 2rem;">Hãy thêm sản phẩm vào giỏ hàng để tiếp tục mua sắm</p>
                        <a href="${pageContext.request.contextPath}/menu" class="btn">Xem Thực Đơn</a>
                    </div>
                </c:when>
                
                <c:otherwise>
                    <div class="cart-table">
                        <div class="table-responsive">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th>Đơn giá</th>
                                        <th>Số lượng</th>
                                        <th>Thành tiền</th>
                                        <th>Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${requestScope.cartItems}">
                                        <tr>
                                            <td>
                                                <div style="display:flex; align-items:center; gap:10px;">
                                                    <img src="${item.imageUrl}" alt="${item.productName}" style="width:50px; height:50px; object-fit:cover; border-radius:4px;">
                                                    <strong>${item.productName}</strong>
                                                </div>
                                            </td>
                                            <td><fmt:formatNumber value="${item.price}" pattern="#,###"/> VNĐ</td>
                                            <td>
                                                <div class="quantity-controls">
                                                    <%-- Nút Giảm --%>
                                                    <form action="cart" method="post" class="qty-form">
                                                        <input type="hidden" name="action" value="update">
                                                        <input type="hidden" name="productId" value="${item.productId}">
                                                        <input type="hidden" name="quantity" value="${item.quantity - 1}">
                                                        <button class="qty-btn" ${item.quantity <= 1 ? 'disabled' : ''}>-</button>
                                                    </form>
                                                    
                                                    <input type="text" value="${item.quantity}" class="qty-input" readonly>
                                                    
                                                    <%-- Nút Tăng --%>
                                                    <form action="cart" method="post" class="qty-form">
                                                        <input type="hidden" name="action" value="update">
                                                        <input type="hidden" name="productId" value="${item.productId}">
                                                        <input type="hidden" name="quantity" value="${item.quantity + 1}">
                                                        <button class="qty-btn">+</button>
                                                    </form>
                                                </div>
                                            </td>
                                            <td><strong><fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/> VNĐ</strong></td>
                                            <td>
                                                <form action="cart" method="post" onsubmit="return confirm('Xóa sản phẩm này?');">
                                                    <input type="hidden" name="action" value="remove">
                                                    <input type="hidden" name="productId" value="${item.productId}">
                                                    <button class="btn btn-secondary" style="background-color: #dc3545; padding: 0.5rem 1rem;">Xóa</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="cart-summary">
                        <h3>Tóm Tắt Đơn Hàng</h3>
                        <div class="cart-total">
                            <span>Tổng cộng:</span>
                            <span><fmt:formatNumber value="${grandTotal}" pattern="#,###"/> VNĐ</span>
                        </div>
                        
                        <%-- KHU VỰC NÚT BẤM (ĐÃ SỬA LỖI CĂN CHỈNH) --%>
                        <div style="display: flex; gap: 1rem; margin-top: 2rem; flex-wrap: wrap;">
                            
                            <%-- Nút 1: Tiếp tục mua sắm --%>
                            <a href="${pageContext.request.contextPath}/menu" class="btn btn-secondary" 
                               style="flex: 1; text-align: center; text-decoration: none; display: flex; align-items: center; justify-content: center;">
                                Tiếp Tục Mua Sắm
                            </a>
                            
                            <%-- Nút 2: Xóa giỏ hàng --%>
                            <form action="cart" method="post" onsubmit="return confirm('Xóa hết giỏ hàng?');" 
                                  style="flex: 1; margin: 0;">
                                <input type="hidden" name="action" value="clear">
                                <input type="hidden" name="productId" value="0">
                                <button class="btn btn-secondary" 
                                        style="background-color: #666666ff; width: 100%; height: 100%; color: white; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">Xóa Giỏ Hàng</button>
                            </form>

                            <%-- Nút 3: Thanh toán --%>
                            <a href="${pageContext.request.contextPath}/checkout" class="btn" 
                               style="flex: 1; text-align: center; text-decoration: none; display: flex; align-items: center; justify-content: center;">Thanh Toán</a>
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
</body>
</html>