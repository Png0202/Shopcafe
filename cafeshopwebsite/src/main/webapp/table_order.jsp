<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order - Bàn ${sessionScope.currentTableId}</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>
        body { background-color: #f0f2f5; padding-bottom: 80px; /* Để chừa chỗ cho Footer cố định */ }

        .pos-card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            overflow: hidden;
        }
        
        .pos-header {
            background: #a37231ff;
            color: white;
            padding: 15px;
        }

        /* Ảnh sản phẩm */
        .item-img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 8px;
        }

        /* Nút số lượng to cho dễ bấm */
        .qty-btn {
            width: 35px;
            height: 35px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            padding: 0;
        }
        .qty-input {
            width: 40px;
            text-align: center;
            height: 35px;
            font-weight: bold;
        }

        /* Input ghi chú */
        .note-input {
            border: none;
            border-bottom: 1px dashed #ccc;
            background: transparent;
            font-size: 0.9rem;
            color: #666;
            width: 100%;
            padding: 5px 0;
        }
        .note-input:focus {
            outline: none;
            border-bottom: 1px solid #28a745;
        }

        /* Footer cố định dưới cùng */
        .fixed-bottom-action {
            position: fixed;
            bottom: 0; left: 0; right: 0;
            background: white;
            padding: 15px;
            box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
            z-index: 1000;
        }

        /* --- RESPONSIVE CHO MOBILE (BIẾN BẢNG THÀNH CARD) --- */
        @media (max-width: 768px) {
            /* Ẩn tiêu đề bảng */
            .table thead { display: none; }
            
            /* Biến dòng tr thành card */
            .table tbody tr {
                display: block;
                background: white;
                margin-bottom: 15px;
                border-radius: 8px;
                padding: 15px;
                box-shadow: 0 2px 5px rgba(0,0,0,0.05);
                border: 1px solid #eee;
            }
            
            /* Căn chỉnh các ô td */
            .table td {
                display: block;
                border: none;
                padding: 5px 0;
                text-align: left;
            }

            /* Layout lại nội dung bên trong */
            .item-row-flex {
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            
            .item-info-col {
                display: flex;
                align-items: center;
                gap: 15px;
                width: 100%;
            }

            .qty-col {
                margin-top: 10px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-top: 1px dashed #eee;
                padding-top: 10px;
            }
    </style>
</head>
<body>

    <div class="container mt-3 mb-5">
        
        <div class="card pos-card mb-3">
            <div class="pos-header d-flex justify-content-between align-items-center">
                <div>
                    <h5 class="m-0 fw-bold"><i class="fa-solid fa-utensils me-2"></i>BÀN SỐ ${sessionScope.currentTableId}</h5>
                    <small class="opacity-75">Nhân viên: ${sessionScope.userName}</small>
                </div>
                <span class="badge bg-light text-danger fw-bold">Đang phục vụ</span>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty requestScope.cartItems}">
                <div class="text-center py-5 text-muted">
                    <i class="fa-solid fa-clipboard-list fa-4x mb-3 opacity-25"></i>
                    <h4>Chưa có món nào</h4>
                    <p>Hãy chọn món từ thực đơn để thêm vào bàn này.</p>
                    <a href="${pageContext.request.contextPath}/menu" class="btn btn-success fw-bold px-4 py-2 mt-2">
                        <i class="fa-solid fa-plus me-2"></i>Gọi Món Ngay
                    </a>
                </div>
            </c:when>
            
            <c:otherwise>
                <div class="card pos-card">
                    <div class="card-body p-0">
                        <table class="table m-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Món ăn</th>
                                    <th class="text-center">Đơn giá</th>
                                    <th class="text-center">Số lượng</th>
                                    <th class="text-end">Thành tiền</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${requestScope.cartItems}">
                                    <tr>
                                        <td>
                                            <div class="item-info-col">
                                                <img src="${item.imageUrl}" class="item-img" alt="img" onerror="this.src='https://placehold.co/60x60'">
                                                <div class="flex-grow-1">
                                                    <div class="fw-bold text-dark">${item.productName}</div>
                                                    
                                                    <div class="d-block d-md-none text-muted small">
                                                        <fmt:formatNumber value="${item.price}" pattern="#,###"/> đ
                                                    </div>

                                                    <form action="cart" method="post" class="mt-1">
                                                        <input type="hidden" name="action" value="update_note">
                                                        <input type="hidden" name="productId" value="${item.productId}">
                                                        <input type="text" name="note" value="${item.note}" 
                                                               class="note-input" 
                                                               placeholder="Thêm ghi chú" 
                                                               onblur="this.form.submit()">
                                                    </form>
                                                </div>
                                            </div>
                                        </td>

                                        <td class="text-center align-middle d-none d-md-table-cell">
                                            <fmt:formatNumber value="${item.price}" pattern="#,###"/>
                                        </td>

                                        <td colspan="3" class="p-0 border-0 d-md-none">
                                            <div class="qty-col px-3 pb-2">
                                                <div class="input-group input-group-sm" style="width: 110px;">
                                                    <form action="cart" method="post" class="d-flex m-0">
                                                        <input type="hidden" name="action" value="update">
                                                        <input type="hidden" name="productId" value="${item.productId}">
                                                        <input type="hidden" name="quantity" value="${item.quantity - 1}">
                                                        <button class="btn btn-outline-secondary qty-btn" ${item.quantity <= 1 ? 'disabled' : ''}>-</button>
                                                    </form>
                                                    <input type="text" class="form-control qty-input" value="${item.quantity}" readonly>
                                                    <form action="cart" method="post" class="d-flex m-0">
                                                        <input type="hidden" name="action" value="update">
                                                        <input type="hidden" name="productId" value="${item.productId}">
                                                        <input type="hidden" name="quantity" value="${item.quantity + 1}">
                                                        <button class="btn btn-outline-secondary qty-btn">+</button>
                                                    </form>
                                                </div>

                                                <div class="d-flex align-items-center gap-3">
                                                    <span class="fw-bold text-danger"><fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/> đ</span>
                                                    <form action="cart" method="post" class="m-0">
                                                        <input type="hidden" name="action" value="remove">
                                                        <input type="hidden" name="productId" value="${item.productId}">
                                                        <button class="btn btn-sm btn-outline-danger border-0"><i class="fa-solid fa-trash"></i></button>
                                                    </form>
                                                </div>
                                            </div>
                                        </td>

                                        <td class="text-center align-middle d-none d-md-table-cell">
                                            <div class="input-group input-group-sm justify-content-center" style="width: 110px; margin: 0 auto;">
                                                <form action="cart" method="post" class="d-flex m-0">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="productId" value="${item.productId}">
                                                    <input type="hidden" name="quantity" value="${item.quantity - 1}">
                                                    <button class="btn btn-outline-secondary qty-btn" ${item.quantity <= 1 ? 'disabled' : ''}>-</button>
                                                </form>
                                                <input type="text" class="form-control qty-input" value="${item.quantity}" readonly>
                                                <form action="cart" method="post" class="d-flex m-0">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="productId" value="${item.productId}">
                                                    <input type="hidden" name="quantity" value="${item.quantity + 1}">
                                                    <button class="btn btn-outline-secondary qty-btn">+</button>
                                                </form>
                                            </div>
                                        </td>
                                        <td class="text-end align-middle fw-bold text-danger d-none d-md-table-cell">
                                            <fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/>
                                        </td>
                                        <td class="align-middle text-center d-none d-md-table-cell">
                                            <form action="cart" method="post" class="m-0">
                                                <input type="hidden" name="action" value="remove">
                                                <input type="hidden" name="productId" value="${item.productId}">
                                                <button class="btn btn-sm btn-outline-danger border-0"><i class="fa-solid fa-trash"></i></button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="fixed-bottom-action">
                    <div class="container">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted">Tổng cộng:</span>
                            <span class="h4 m-0 fw-bold text-danger"><fmt:formatNumber value="${grandTotal}" pattern="#,###"/> VNĐ</span>
                        </div>
                        <div class="row g-2">
                            <div class="col-4">
                                <a href="${pageContext.request.contextPath}/menu" class="btn btn-outline-secondary w-100 fw-bold">
                                    <i class="fa-solid fa-arrow-left"></i> Menu
                                </a>
                            </div>
                            <div class="col-8">
                                <a href="${pageContext.request.contextPath}/staff" class="btn btn-primary w-100 fw-bold">
                                    <i class="fa-solid fa-house me-1"></i> Về Trang Nhân Viên
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>