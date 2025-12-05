<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tài Khoản - Quán Cà Phê</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

    <style>
        /* Tinh chỉnh lại một chút để Bootstrap không đánh nhau với CSS cũ */
        body { background-color: #f8f9fa; }
        
        /* --- SIDEBAR MENU --- */
        .list-group-item { cursor: pointer; transition: 0.3s; }
        
        /* Style cho mục đang chọn (Active) */
        .list-group-item.active {
            background-color: #d35400 !important;
            border-color: #d35400 !important;
            color: white !important;
        }

        /* Style Hover: Chỉ áp dụng khi KHÔNG CÓ class active */
        .list-group-item:not(.active):hover { 
            background-color: #f1f1f1 !important; 
            color: #d35400;
        }
        
        /* Đảm bảo khi hover vào mục đang active thì màu vẫn giữ nguyên */
        .list-group-item.active:hover {
            background-color: #d35400 !important;
            color: white !important;
        }

        /* Ẩn hiện Tab */
        .tab-content-section { display: none; }
        .tab-content-section.active-section { display: block; animation: fadeIn 0.5s; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        /* Map & Autocomplete */
        #map { height: 300px; width: 100%; border-radius: 5px; z-index: 1; margin-top: 10px;}
        
        .suggestions-list { 
            position: absolute; top: 100%; left: 0; right: 0; 
            background: white; border: 1px solid #dee2e6; border-radius: 0 0 5px 5px; 
            max-height: 200px; overflow-y: auto; z-index: 1000; 
            list-style: none; padding: 0; margin: 0; display: none; 
            box-shadow: 0 4px 6px rgba(0,0,0,0.1); 
        }
        .suggestions-list li { padding: 10px; cursor: pointer; border-bottom: 1px solid #f1f1f1; font-size: 0.9rem; }
        .suggestions-list li:hover { background-color: #f8f9fa; color: #d35400; }

        /* Badge trạng thái */
        .badge-status { 
            font-size: 14px !important; /* Tăng kích thước chữ */
            padding: 10px 15px !important; 
            font-weight: 600;
        }

        /* Tiêu đề Section (Căn giữa đồng bộ) */
        .section-header {
            text-transform: uppercase;
            border-bottom: 1px solid #dee2e6;
            padding-bottom: 10px;
            margin-bottom: 20px;
            text-align: center; /* CĂN GIỮA */
            color: #d35400;
            font-weight: bold;
        }

        /* Modal Styles (PC Default) */
        .modal-content { 
            background: white; 
            margin: 5% auto; 
            padding: 20px; 
            border-radius: 8px; 
            position: relative; 
            max-height: 90vh; 
            overflow-y: auto; 
        }

        /* --- RESPONSIVE (MOBILE & TABLET) --- */
        @media (max-width: 992px) {
            /* Layout 1 cột */
            .account-layout { flex-direction: column; }
            
            /* Modal Responsive (Khóa kéo ngang khung, cho phép cuộn bảng) */
            .modal-content {
                width: 95% !important;
                max-width: 95% !important;
                margin: 15% auto;
                padding: 15px;
                max-height: 80vh;
                box-sizing: border-box;
                overflow-x: hidden; /* Khóa kéo ngang của khung Modal */
                overflow-y: auto;
            }
            
            #modalOrderItems {
                width: 100%;
                overflow-x: auto; /* Chỉ cho bảng cuộn ngang */
            }
            #modalOrderItems table {
                width: 100%;
                min-width: 100%;
                border-collapse: collapse;
            }

            /* --- BIẾN BẢNG ĐƠN HÀNG THÀNH DẠNG CARD DỌC --- */
            .table-responsive thead { display: none; } /* Ẩn tiêu đề bảng */
            
            .table-responsive tbody tr {
                display: block;
                background: #fff;
                border: 1px solid #ddd;
                border-radius: 8px;
                margin-bottom: 15px;
                padding: 15px;
                box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            }
            
            .table-responsive td {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 8px 0;
                border-bottom: 1px dashed #eee;
                text-align: right;
                border-top: none !important; /* Xóa border mặc định của bootstrap table */
            }
            
            .table-responsive td:last-child {
                border-bottom: none;
                justify-content: center; /* Căn giữa nút bấm */
                padding-top: 15px;
            }
            
            /* Hiển thị nhãn (Label) trước nội dung */
            .table-responsive td::before {
                content: attr(data-label);
                font-weight: bold;
                text-align: left;
                color: #666;
                flex: 1;
            }
        }
        /* --- TOAST NOTIFICATION --- */
        #toast-container {
            position: fixed; top: 20px; right: 20px; z-index: 9999;
            display: flex; flexDirection: column; gap: 10px;
        }
        .vue-toast {
            background-color: #28a745; color: #fff;
            border-radius: 8px; padding: 16px 24px 20px 20px;
            display: flex; alignItems: flex-start;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            position: relative; overflow: hidden; min-width: 320px;
            animation: slideInRight 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            transition: all 0.5s ease;
        }
        .vue-toast.error { background-color: #dc3545; }
        .vue-toast-icon { margin-right: 15px; font-size: 20px; }
        .vue-toast-body { flex-grow: 1; font-size: 14px; font-weight: 500; }
        .vue-toast-close { background: transparent; border: none; color: #fff; cursor: pointer; font-size: 20px; opacity: 0.7; }
        .vue-toast-progress {
            position: absolute; 
            bottom: 0; 
            left: 0; 
            width: 100%; 
            height: 4px;
            background-color: rgba(255, 255, 255, 0.5);
            transform-origin: left; 
            animation: timeOut 3s linear forwards;
        }
        
        @keyframes slideInRight { from { transform: translateX(120%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        @keyframes timeOut { to { transform: scaleX(0); } }
        .toast-hide { transform: translateX(120%); opacity: 0; }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>☕ Garden Coffee & Cake</h1>
            <nav>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/home">Trang Chủ</a></li>
                    <li><a href="${pageContext.request.contextPath}/menu">Thực Đơn</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart">Giỏ Hàng</a></li>
                    <c:choose>
                        <c:when test="${not empty sessionScope.userEmail}">
                            <li><a href="${pageContext.request.contextPath}/profile" class="active" style="font-weight: bold; color: #d35400;">Tài Khoản (${sessionScope.userName})</a></li>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/login.jsp">Đăng Nhập</a></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container mt-3">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="home" class="text-decoration-none text-secondary">Trang chủ</a></li>
                <li class="breadcrumb-item active" aria-current="page">Trang khách hàng</li>
            </ol>
        </nav>
    </div>

    <div class="container mb-5">
        <div class="row">
            
            <%-- SIDEBAR (Cột trái - col-md-3) --%>
            <div class="col-md-3 mb-4">
                <div class="card shadow-sm border-0">
                    <div class="card-body text-center">
                        <img src="https://cdn-icons-png.flaticon.com/512/149/149071.png" class="rounded-circle mb-2" width="80" alt="Avatar">
                        <h5 class="card-title mb-0">Xin chào,</h5>
                        <p class="text-danger fw-bold">${requestScope.fullname}</p>
                    </div>
                    <div class="list-group list-group-flush">
                        <a onclick="showTab('info')" id="nav-info" class="list-group-item list-group-item-action active">
                            <i class="fa-solid fa-user me-2"></i> Thông tin tài khoản
                        </a>
                        <a onclick="showTab('addresses')" id="nav-addresses" class="list-group-item list-group-item-action">
                            <i class="fa-solid fa-location-dot me-2"></i> Sổ địa chỉ (${empty requestScope.addressCount ? 0 : requestScope.addressCount})
                        </a>
                        <a onclick="showTab('orders')" id="nav-orders" class="list-group-item list-group-item-action">
                            <i class="fa-solid fa-box me-2"></i> Đơn hàng của bạn
                        </a>
                        <a onclick="showTab('password')" id="nav-password" class="list-group-item list-group-item-action">
                            <i class="fa-solid fa-key me-2"></i> Đổi mật khẩu
                        </a>
                        <a href="${pageContext.request.contextPath}/logout.jsp" class="list-group-item list-group-item-action text-danger">
                            <i class="fa-solid fa-right-from-bracket me-2"></i> Đăng xuất
                        </a>
                    </div>
                </div>
            </div>

            <%-- CONTENT (Cột phải - col-md-9) --%>
            <div class="col-md-9">
                <div class="card shadow-sm border-0">
                    <div class="card-body p-4">
                        <%-- Thông báo --%>
                        <div id="toast-container">
                            
                            <%-- THÀNH CÔNG --%>
                            <c:if test="${param.status == 'success'}">
                                <div class="vue-toast" data-autohide="true">
                                    <div class="vue-toast-icon"><i class="fa-solid fa-check-circle"></i></div>
                                    <div class="vue-toast-body">Thao tác thành công!</div>
                                    <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                                    <div class="vue-toast-progress"></div>
                                </div>
                            </c:if>
                            <c:if test="${param.status == 'deleted'}">
                                <div class="vue-toast" data-autohide="true">
                                    <div class="vue-toast-icon"><i class="fa-solid fa-trash"></i></div>
                                    <div class="vue-toast-body">Đã xóa địa chỉ thành công!</div>
                                    <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                                    <div class="vue-toast-progress"></div>
                                </div>
                            </c:if>
                            <c:if test="${param.status == 'updated'}">
                                <div class="vue-toast" data-autohide="true">
                                    <div class="vue-toast-icon"><i class="fa-solid fa-pen-to-square"></i></div>
                                    <div class="vue-toast-body">Cập nhật thông tin thành công!</div>
                                    <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                                    <div class="vue-toast-progress"></div>
                                </div>
                            </c:if>
                            <c:if test="${param.status == 'phone_exists'}">
                                <div class="vue-toast error" data-autohide="true">
                                    <div class="vue-toast-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                                    <div class="vue-toast-body">Số điện thoại này đã được sử dụng bởi tài khoản khác!</div>
                                    <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                                    <div class="vue-toast-progress"></div>
                                </div>
                            </c:if>
                            <%-- LỖI --%>
                            <c:if test="${param.status == 'error'}">
                                <div class="vue-toast error" data-autohide="true">
                                    <div class="vue-toast-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                                    <div class="vue-toast-body">Có lỗi xảy ra, vui lòng thử lại!</div>
                                    <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                                    <div class="vue-toast-progress"></div>
                                </div>
                            </c:if>
                            <c:if test="${param.error == 'wrong_pass'}">
                                <div class="vue-toast error" data-autohide="true">
                                    <div class="vue-toast-icon"><i class="fa-solid fa-lock"></i></div>
                                    <div class="vue-toast-body">Mật khẩu cũ không đúng!</div>
                                    <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                                    <div class="vue-toast-progress"></div>
                                </div>
                            </c:if>
                            <c:if test="${param.error == 'mismatch'}">
                                <div class="vue-toast error" data-autohide="true">
                                    <div class="vue-toast-icon"><i class="fa-solid fa-circle-xmark"></i></div>
                                    <div class="vue-toast-body">Mật khẩu xác nhận không khớp!</div>
                                    <button class="vue-toast-close" onclick="closeToast(this)">×</button>
                                    <div class="vue-toast-progress"></div>
                                </div>
                            </c:if>
                        </div>

                        <%-- TAB 1: THÔNG TIN TÀI KHOẢN (ĐÃ SỬA LỖI FORM) --%>
                        <div id="tab-info" class="tab-content-section active-section">
                            <h4 class="section-header">Thông Tin Tài Khoản</h4>
                            
                            <%-- Các ô input chỉ xem (Không cần nằm trong form) --%>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted">Họ và tên</label>
                                <input type="text" value="${requestScope.fullname}" class="form-control bg-light" disabled>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted">Email</label>
                                <input type="text" value="${requestScope.email}" class="form-control bg-light" disabled>
                            </div>

                            <%-- LOGIC CẬP NHẬT SỐ ĐIỆN THOẠI --%>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted">Số điện thoại</label>
                                <c:choose>
                                    <%-- Trường hợp 1: Chưa có SĐT -> Hiện Form nhập liệu --%>
                                    <c:when test="${empty requestScope.phone}">
                                        <form action="${pageContext.request.contextPath}/profile" method="post">
                                            <input type="hidden" name="action" value="update_phone">
                                            <div class="input-group">
                                                <span class="input-group-text bg-white text-warning"><i class="fa-solid fa-phone"></i></span>
                                                <input type="tel" name="phone" class="form-control" placeholder="Vui lòng cập nhật số điện thoại..." required pattern="^0[0-9]{9}$" maxlength="10" inputmode="numeric" oninput="this.value = this.value.replace(/[^0-9]/g, '');">
                                                <button class="btn btn-warning text-white fw-bold" type="submit">Lưu SĐT</button>
                                            </div>
                                            <div class="form-text text-danger small">
                                                <i class="fa-solid fa-circle-exclamation"></i> Bạn đang đăng nhập bằng Google và chưa có số điện thoại. Vui lòng cập nhật để đặt hàng.
                                            </div>
                                        </form>
                                    </c:when>
                                    
                                    <%-- Trường hợp 2: Đã có SĐT -> Chỉ hiện ô input disabled --%>
                                    <c:otherwise>
                                        <input type="text" value="${requestScope.phone}" class="form-control bg-light" disabled>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="text-center mt-4">
                                <a onclick="showTab('addresses')" class="text-decoration-none text-warning fw-bold" style="cursor:pointer;">
                                    Quản lý sổ địa chỉ <i class="fa-solid fa-arrow-right"></i>
                                </a>
                            </div>
                        </div>

                        <%-- TAB 2: SỔ ĐỊA CHỈ --%>
                        <div id="tab-addresses" class="tab-content-section">
                            <h4 class="section-header">Sổ Địa Chỉ</h4>
                            
                            <div class="mb-4">
                                <c:choose>
                                    <c:when test="${empty requestScope.addressList}">
                                        <p class="text-center text-muted fst-italic">Bạn chưa lưu địa chỉ nào.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="addr" items="${requestScope.addressList}">
                                            <div class="card mb-2 ${addr['default'] ? 'border-success bg-light' : ''}">
                                                <div class="card-body d-flex justify-content-between align-items-center">
                                                    <div>
                                                        <i class="fa-solid fa-map-marker-alt text-danger me-2"></i>
                                                        <span>${addr.addressLine}</span>
                                                        <c:if test="${addr['default']}">
                                                            <span class="badge bg-success ms-2">Mặc định</span>
                                                        </c:if>
                                                    </div>
                                                    <div class="d-flex gap-2">
                                                        <c:if test="${!addr['default']}">
                                                            <form action="${pageContext.request.contextPath}/profile" method="post" class="m-0">
                                                                <input type="hidden" name="action" value="set_default">
                                                                <input type="hidden" name="id" value="${addr.id}">
                                                                <button class="btn btn-sm btn-outline-primary">Đặt mặc định</button>
                                                            </form>
                                                        </c:if>
                                                        <form action="${pageContext.request.contextPath}/profile" method="post" class="m-0" onsubmit="return confirm('Xóa địa chỉ này?')">
                                                            <input type="hidden" name="action" value="delete_address">
                                                            <input type="hidden" name="id" value="${addr.id}">
                                                            <button class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-trash"></i></button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <h5 class="mt-4 mb-3 text-center"><i class="fa-solid fa-plus-circle text-success"></i> Thêm địa chỉ mới</h5>
                            <form action="${pageContext.request.contextPath}/profile" method="post" class="card p-3 bg-light">
                                <input type="hidden" name="action" value="add_address">
                                <div class="mb-3 position-relative">
                                    <label class="form-label fw-bold">Tìm kiếm địa chỉ</label>
                                    <textarea name="address" id="addressInput" rows="2" class="form-control" placeholder="Nhập tên đường, phường/xã..." required autocomplete="off"></textarea>
                                    <ul id="suggestions" class="suggestions-list"></ul>
                                </div>
                                <div id="map"></div>
                                <p class="text-muted small fst-italic">* Chọn trên bản đồ hoặc danh sách gợi ý.</p>
                                <button type="submit" class="btn btn-warning text-white w-100 fw-bold">Lưu Địa Chỉ Mới</button>
                            </form>
                        </div>

                        <%-- TAB 3: ĐƠN HÀNG (Table Bootstrap Responsive) --%>
                        <div id="tab-orders" class="tab-content-section">
                            <h4 class="section-header">Đơn Hàng Của Bạn</h4>
                            <c:choose>
                                <c:when test="${empty requestScope.orderList}">
                                    <p class="text-center py-4 text-muted">Chưa có đơn hàng nào.</p>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-hover align-middle text-center">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>Mã ĐH</th>
                                                    <th>Ngày đặt</th>
                                                    <th>Tổng tiền</th>
                                                    <th>Trạng thái</th>
                                                    <th>Hành động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="o" items="${requestScope.orderList}">
                                                    <tr>
                                                        <td data-label="Mã ĐH" class="fw-bold">#${o.id}</td>
                                                        <td data-label="Ngày đặt"><fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy"/></td>
                                                        <td data-label="Tổng tiền" class="fw-bold text-danger"><fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/> đ</td>
                                                        <td data-label="Trạng thái">
                                                            <span class="badge rounded-pill badge-status 
                                                                ${o.status == 'Giao hàng thành công' ? 'bg-success' : 
                                                                (o.status == 'Đang giao hàng' ? 'bg-primary' : 
                                                                (o.status == 'Đã hủy' ? 'bg-danger' : 
                                                                (o.status == 'Chờ thanh toán' ? 'bg-secondary' : 'bg-warning text-dark')))}">
                                                                ${o.status}
                                                            </span>
                                                        </td>
                                                        <td data-label="">
                                                            <div class="d-flex justify-content-center gap-2">
                                                                <button class="btn btn-sm btn-info text-white" onclick="viewOrderDetails('${o.id}', '${o.address}', '${o.paymentMethod}', '${o.note}')">Chi tiết</button>
                                                                <c:if test="${o.status == 'Chờ thanh toán'}">
                                                                    <a href="payment_qr.jsp?orderId=${o.id}&amount=${o.totalPrice}" class="btn btn-sm btn-success">Thanh toán</a>
                                                                </c:if>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <%-- TAB 4: ĐỔI MẬT KHẨU --%>
                        <div id="tab-password" class="tab-content-section">
                            <h4 class="section-header">Đổi Mật Khẩu</h4>
                            <form action="${pageContext.request.contextPath}/changePassword" method="post" class="mx-auto" style="max-width: 400px;">
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Mật khẩu cũ</label>
                                    <input type="password" name="oldPass" class="form-control" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Mật khẩu mới</label>
                                    <input type="password" name="newPass" class="form-control" required minlength="6">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Nhập lại mật khẩu mới</label>
                                    <input type="password" name="confirmPass" class="form-control" required>
                                </div>
                                <button type="submit" class="btn btn-warning text-white w-100 fw-bold">Đổi Mật Khẩu</button>
                            </form>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="orderModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-warning text-white">
                    <h5 class="modal-title fw-bold">Chi Tiết Đơn Hàng #<span id="modalOrderId"></span></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="bg-light p-3 rounded mb-3">
                        <p class="mb-1"><strong><i class="fa-solid fa-location-dot text-danger"></i> Địa chỉ:</strong> <span id="modalAddress"></span></p>
                        <p class="mb-1"><strong><i class="fa-regular fa-credit-card text-primary"></i> Thanh toán:</strong> <span id="modalPayment"></span></p>
                        <p class="mb-0"><strong><i class="fa-regular fa-note-sticky text-warning"></i> Ghi chú:</strong> <span id="modalNote" class="fst-italic"></span></p>
                    </div>
                    <div id="modalOrderItems" class="text-center">
                        <div class="spinner-border text-warning" role="status"><span class="visually-hidden">Loading...</span></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <footer>
        <div class="container">
            <p>&copy; 2025 Quán Cà Phê Vĩnh Long. Đồ án môn học Công Nghệ Thông Tin 1.</p>
            <p>Sinh viên thực hiện: Phan Tuấn Cảnh - Võ Phúc Nguyên</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // --- TOAST NOTIFICATION ---
        // Hàm đóng toast ngay lập tức khi bấm nút X
    function closeToast(button) {
        const toast = button.closest('.vue-toast');
        toast.classList.add('toast-hide');
        setTimeout(() => toast.remove(), 500); // Đợi hiệu ứng bay ra xong mới xóa DOM
    }

    // Tự động đóng sau 3 giây
    document.addEventListener("DOMContentLoaded", function() {
        const toasts = document.querySelectorAll('.vue-toast[data-autohide="true"]');
        
        toasts.forEach(toast => {
            setTimeout(() => {
                // Thêm class để kích hoạt animation bay ra
                toast.classList.add('toast-hide');
                
                // Xóa khỏi DOM sau khi animation kết thúc (0.5s)
                setTimeout(() => {
                    toast.remove();
                }, 500);
            }, 3000); // 3000ms = 3 giây
        });
    });

        // --- XỬ LÝ TAB ---
        function handleTabClick(tabName) {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => alert.style.display = 'none'); 
            showTab(tabName);
        }

        function showTab(name) {
            document.querySelectorAll('.tab-content-section').forEach(el => el.classList.remove('active-section'));
            document.querySelectorAll('.list-group-item').forEach(el => el.classList.remove('active'));
            
            document.getElementById('tab-' + name).classList.add('active-section');
            document.getElementById('nav-' + name).classList.add('active');
            
            if(name === 'addresses' && map) { setTimeout(() => { map.invalidateSize(); }, 200); }
        }

        // --- MAP & AUTOCOMPLETE ---
        const defaultLat = 10.253698, defaultLng = 105.972298;
        var map = L.map('map').setView([defaultLat, defaultLng], 14);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);
        var marker;

        function updateMap(lat, lng) {
            const newLatLng = new L.LatLng(lat, lng);
            if (marker) marker.setLatLng(newLatLng); else marker = L.marker(newLatLng).addTo(map);
            map.setView(newLatLng, 16);
        }

        const addressInput = document.getElementById('addressInput');
        const suggestionsList = document.getElementById('suggestions');
        let debounceTimer;

        addressInput.addEventListener('input', function() {
            const query = this.value;
            clearTimeout(debounceTimer);
            if (query.length < 3) { suggestionsList.style.display = 'none'; return; }
            debounceTimer = setTimeout(() => {
                fetch(`https://nominatim.openstreetmap.org/search?format=json&q=\${encodeURIComponent(query)}&countrycodes=vn&limit=5`)
                    .then(res => res.json())
                    .then(data => {
                        suggestionsList.innerHTML = '';
                        if (data.length > 0) {
                            suggestionsList.style.display = 'block';
                            data.forEach(place => {
                                const li = document.createElement('li');
                                li.textContent = place.display_name;
                                li.addEventListener('click', () => {
                                    addressInput.value = place.display_name;
                                    suggestionsList.style.display = 'none';
                                    updateMap(parseFloat(place.lat), parseFloat(place.lon));
                                });
                                suggestionsList.appendChild(li);
                            });
                        } else suggestionsList.style.display = 'none';
                    });
            }, 500);
        });

        document.addEventListener('click', function(e) { if (!addressInput.contains(e.target)) suggestionsList.style.display = 'none'; });
        map.on('click', function(e) {
            updateMap(e.latlng.lat, e.latlng.lng);
            document.getElementById('addressInput').value = "Đang tải địa chỉ...";
            fetch(`https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=\${e.latlng.lat}&lon=\${e.latlng.lng}`)
                .then(res => res.json())
                .then(data => { document.getElementById('addressInput').value = data.display_name || `\${e.latlng.lat}, \${e.latlng.lng}`; });
        });

        // --- MODAL CHI TIẾT ---
        const orderModal = new bootstrap.Modal(document.getElementById('orderModal'));

        function viewOrderDetails(id, address, payment, note) {
            document.getElementById('modalOrderId').innerText = id;
            document.getElementById('modalAddress').innerText = address;
            
            let payText = payment === 'banking' ? 'Chuyển khoản' : (payment === 'cash' ? 'Tiền mặt (COD)' : payment);
            document.getElementById('modalPayment').innerText = payText || 'Không rõ';
            document.getElementById('modalNote').innerText = note ? note : 'Không có';

            document.getElementById('modalOrderItems').innerHTML = '<div class="spinner-border text-warning" role="status"><span class="visually-hidden">Loading...</span></div>';
            orderModal.show();
            
            fetch('${pageContext.request.contextPath}/order-detail?id=' + id)
                .then(res => res.text())
                .then(html => { 
                    const tableHtml = html.replace('<table', '<table class="table table-striped table-sm"');
                    document.getElementById('modalOrderItems').innerHTML = tableHtml; 
                })
                .catch(() => { document.getElementById('modalOrderItems').innerHTML = '<p class="text-danger">Lỗi tải dữ liệu!</p>'; });
        }

        const params = new URLSearchParams(window.location.search);
        if(params.get('tab')) showTab(params.get('tab'));
    </script>
</body>
</html>