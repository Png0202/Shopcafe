<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <title>Thanh Toán Chuyển Khoản</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .payment-container { max-width: 600px; margin: 50px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.1); text-align: center; }
        .qr-box { margin: 20px 0; border: 2px dashed #d35400; padding: 10px; display: inline-block; border-radius: 10px; }
        .qr-img { max-width: 100%; height: auto; }
        .amount-text { font-size: 24px; color: #d35400; font-weight: bold; margin: 10px 0; }
        .note-text { color: #666; font-size: 14px; margin-bottom: 20px; }
    </style>
</head>
<body style="background-color: #f5f5f5;">

    <div class="payment-container">
        <h2 style="color: #2c3e50;">Thanh Toán Đơn Hàng #${param.orderId}</h2>
        <p>Vui lòng quét mã QR bên dưới để thanh toán</p>

        <div class="qr-box">
            <img src="https://img.vietqr.io/image/VietinBank-109876340295-compact2.png?amount=${param.amount}&addInfo=THANHTOAN DON ${param.orderId}&accountName=VO PHUC NGUYEN" 
                alt="QR Code" class="qr-img">
        </div>

        <div class="amount-text">
            Số tiền: <fmt:formatNumber value="${param.amount}" pattern="#,###"/> VNĐ
        </div>

        <div class="note-text">
            <p>Nội dung chuyển khoản: <strong>THANHTOAN DON ${param.orderId}</strong></p>
            <p>Sau khi chuyển khoản thành công, vui lòng bấm nút bên dưới.</p>
        </div>

        <a href="${pageContext.request.contextPath}/profile?tab=orders" class="btn" style="width: 100%; display: block; padding: 15px;">
            ✅ Tôi Đã Chuyển Khoản
        </a>
        
        <div style="margin-top: 10px;">
            <a href="${pageContext.request.contextPath}/profile?tab=orders" style="color: #666; text-decoration: underline; font-size: 14px;">Thanh toán sau</a>
        </div>
    </div>

</body>
</html>