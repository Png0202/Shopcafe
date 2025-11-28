<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Cho Bàn ${sessionScope.currentTableId}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { background-color: #f0f2f5; }
        .pos-container { max-width: 800px; margin: 30px auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .pos-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #28a745; padding-bottom: 15px; margin-bottom: 20px; }
        .pos-title { color: #28a745; font-size: 24px; font-weight: bold; margin: 0; }
        
        .pos-table { width: 100%; border-collapse: collapse; }
        .pos-table th { background: #f8f9fa; text-align: left; padding: 10px; border-bottom: 1px solid #ddd; }
        .pos-table td { padding: 15px 10px; border-bottom: 1px solid #eee; vertical-align: middle; }
        .pos-table img { width: 50px; height: 50px; border-radius: 4px; object-fit: cover; margin-right: 10px; vertical-align: middle; }
        
        .qty-control { display: inline-flex; border: 1px solid #ddd; border-radius: 4px; }
        .qty-btn { width: 30px; height: 30px; border: none; background: #fff; cursor: pointer; font-weight: bold; }
        .qty-val { width: 40px; text-align: center; border: none; border-left: 1px solid #ddd; border-right: 1px solid #ddd; line-height: 30px; }
        
        .pos-footer { margin-top: 30px; padding-top: 20px; border-top: 2px solid #eee; }
        .total-row { display: flex; justify-content: space-between; font-size: 20px; font-weight: bold; margin-bottom: 20px; }
        .action-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        
        .btn-pos { padding: 15px; border: none; border-radius: 5px; font-weight: bold; cursor: pointer; text-align: center; text-decoration: none; font-size: 16px; display: block; }
        .btn-back { background: #6c757d; color: white; }
        .btn-confirm { background: #28a745; color: white; }
    </style>
</head>
<body>

    <div class="pos-container">
        <div class="pos-header">
            <h1 class="pos-title">BÀN SỐ ${sessionScope.currentTableId}</h1>
            <span style="background: #e9ecef; padding: 5px 10px; border-radius: 20px; font-size: 14px;">Nhân viên: ${sessionScope.userName}</span>
        </div>

        <c:choose>
            <c:when test="${empty requestScope.cartItems}">
                <div style="text-align: center; padding: 40px; color: #666;">
                    <p>Chưa có món nào được chọn.</p>
                    <a href="${pageContext.request.contextPath}/menu" class="btn-pos btn-confirm" style="width: 200px; margin: 20px auto;">+ Gọi Món Ngay</a>
                </div>
            </c:when>
            <c:otherwise>
                <table class="pos-table">
                    <thead>
                        <tr>
                            <th>Món ăn</th>
                            <th>Đơn giá</th>
                            <th>Số lượng</th>
                            <th>Thành tiền</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${requestScope.cartItems}">
                            <tr>
                                <%-- Cột 1: Món ăn + Ghi chú --%>
                                <td>
                                    <div style="display:flex; align-items:center;">
                                        <img src="${item.imageUrl}" alt="img" style="width:50px; height:50px; margin-right:10px;">
                                        <div>
                                            <strong>${item.productName}</strong>
                                            
                                            <form action="cart" method="post" style="margin-top: 5px;">
                                                <input type="hidden" name="action" value="update_note">
                                                <input type="hidden" name="productId" value="${item.productId}">
                                                <input type="text" name="note" value="${item.note}" 
                                                       placeholder="Thêm ghi chú..." 
                                                       style="border: 1px dashed #ccc; padding: 3px; font-size: 12px; width: 150px; border-radius: 4px;"
                                                       onblur="this.form.submit()">
                                            </form>
                                        </div>
                                    </div>
                                </td>

                                <%-- Cột 2: Đơn giá --%>
                                <td><fmt:formatNumber value="${item.price}" pattern="#,###"/></td>

                                <%-- Cột 3: Số lượng (Có nút tăng giảm) --%>
                                <td>
                                    <div class="qty-control">
                                        <form action="cart" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="productId" value="${item.productId}">
                                            <input type="hidden" name="quantity" value="${item.quantity - 1}">
                                            <button class="qty-btn" ${item.quantity <= 1 ? 'disabled' : ''}>-</button>
                                        </form>
                                        
                                        <div class="qty-val">${item.quantity}</div>
                                        
                                        <form action="cart" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="productId" value="${item.productId}">
                                            <input type="hidden" name="quantity" value="${item.quantity + 1}">
                                            <button class="qty-btn">+</button>
                                        </form>
                                    </div>
                                </td>

                                <%-- Cột 4: Thành tiền --%>
                                <td><fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/></td>

                                <%-- Cột 5: Xóa --%>
                                <td>
                                    <form action="cart" method="post">
                                        <input type="hidden" name="action" value="remove">
                                        <input type="hidden" name="productId" value="${item.productId}">
                                        <button style="background:none; border:none; color:red; cursor:pointer; font-size: 18px;">❌</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <div class="pos-footer">
                    <div class="total-row">
                        <span>Tổng cộng:</span>
                        <span style="color: #d35400;"><fmt:formatNumber value="${grandTotal}" pattern="#,###"/> VNĐ</span>
                    </div>
                    
                    <div class="action-row">
                        <a href="${pageContext.request.contextPath}/menu" class="btn-pos btn-back">Quay lại Menu</a>
                        <a href="${pageContext.request.contextPath}/staff" class="btn-pos btn-confirm" style="background-color: #007bff; color: white; text-decoration: none;">
                            Trở Về Trang Chính
                        </a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

</body>
</html>