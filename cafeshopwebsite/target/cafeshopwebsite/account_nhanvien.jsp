<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhân Viên - Quán Cà Phê</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <style>
        body { 
            background-color: #f0f2f5;
            min-height: 100vh; 
            display: flex; 
            flex-direction: column; 
        }
        
        .staff-header { 
            background: #343a40;
            padding: 15px 0; 
        }
        
        /* Tab Navigation */
        .nav-pills .nav-link { 
            color: #adb5bd;
            font-weight: bold; 
            margin-right: 10px; 
            cursor: pointer;
        }
        .nav-pills .nav-link.active { 
            background-color: #d35400;
            color: white; 
        }
        .nav-pills .nav-link:hover:not(.active) { 
            background-color: rgba(255,255,255,0.1);
            color: white;
        }

        /* Card Bàn */
        .table-card {
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
            color: white;
            font-weight: bold;
            text-align: center;
            height: 100%;
        }
        .table-card:hover { 
            transform: translateY(-5px); 
            box-shadow: 0 10px 20px rgba(0,0,0,0.15);
        }
        
        .bg-table-empty { background-color: #28a745; } /* Xanh lá */
        .bg-table-busy { background-color: #dc3545; }  /* Đỏ */

        .tab-content-section { display: none; animation: fadeIn 0.3s; }
        .tab-content-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        /* Badge Custom */
        .badge {
            font-size: 14px !important;
            padding: 10px 15px !important;
            font-weight: 600;
            letter-spacing: 0.5px;
        }

        /* RESPONSIVE */
        @media (max-width: 992px) {
            .modal-content {
                width: 95% !important;
                margin: 10% auto;
            }
            .badge {
                font-size: 13px !important;
                padding: 8px 12px !important;
            }
        }

        @media (max-width: 768px) {
            /* Header Mobile */
            .staff-header .container {
                flex-direction: column;
                text-align: center;
            }
            .staff-header h3 { margin-bottom: 10px; font-size: 1.5rem; }
            .nav-pills {
                justify-content: center;
                width: 100%;
                gap: 5px;
            }
            .nav-pills .nav-link {
                font-size: 0.9rem;
                padding: 8px 10px;
                margin-right: 0;
            }

            /* Grid & Table Mobile */
            .row-cols-2 { --bs-gutter-x: 10px; }
            .table-card { padding: 1rem 0; }
            .table-card h4 { font-size: 1.1rem; }
            .table-responsive { overflow-x: auto; -webkit-overflow-scrolling: touch; }
            .table th, .table td { white-space: nowrap; font-size: 0.85rem; padding: 8px; }
            
            /* Buttons */
            .btn-sm { padding: 4px 8px; font-size: 0.75rem; }
            .btn-add-mobile {
                padding: 5px 10px !important;
                font-size: 12px !important;
                white-space: nowrap;
            }
        }
        .btn-green {
            background-color: #28a745 !important;  /* xanh lá đậm */
            border-color: #28a745 !important;
            color: white !important;
        }
        .btn-green:hover {
            background-color: #218838 !important;
            border-color: #1e7e34 !important;
        }
    </style>
</head>
<body>

    <header class="staff-header shadow-sm">
        <div class="container d-flex justify-content-between align-items-center">
            <h3 class="text-white m-0"><i class="fa-solid fa-mug-hot me-2"></i>Nhân Viên</h3>
            <ul class="nav nav-pills">
                <li class="nav-item">
                    <a onclick="showTab('pos')" id="link-pos" class="nav-link active"><i class="fa-solid fa-shop me-2"></i>Quản Lý Bàn</a>
                </li>
                <li class="nav-item">
                    <a onclick="showTab('online')" id="link-online" class="nav-link"><i class="fa-solid fa-globe me-2"></i>Đơn Online</a>
                </li>
                <li class="nav-item">
                    <a onclick="showTab('menu')" id="link-menu" class="nav-link"><i class="fa-solid fa-book-open me-2"></i>Quản Lý Menu</a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/logout.jsp" class="nav-link bg-danger text-white ms-3"><i class="fa-solid fa-right-from-bracket me-2"></i>Đăng Xuất</a>
                </li>
            </ul>
        </div>
    </header>

    <div class="container mt-4 mb-5 flex-grow-1">
        
        <div id="tab-pos" class="tab-content-section active">
            <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
                <h4 class="border-start border-5 border-warning ps-3 text-uppercase fw-bold text-dark m-0">Sơ Đồ Bàn</h4>
                <button class="btn btn-warning fw-bold text-white btn-add-mobile" data-bs-toggle="modal" data-bs-target="#addTableModal">
                    <i class="fa-solid fa-plus me-2"></i>Thêm Bàn
                </button>
            </div>
            
            <div class="row row-cols-2 row-cols-md-3 row-cols-lg-5 g-4">
                <c:forEach var="t" items="${tables}">
                    <div class="col">
                        <div class="card table-card shadow-sm py-4 position-relative ${t.status == 0 ? 'bg-table-empty' : 'bg-table-busy'}" 
                             onclick="handleTableClick('${t.id}', '${t.name}', ${t.status})">

                            <div class="position-absolute top-0 end-0 p-2" onclick="event.stopPropagation()">
                                <%-- Nút Sửa --%>
                                <button class="btn btn-sm btn-success border-0 shadow-sm me-1" 
                                        style="width: 30px; height: 30px; border-radius: 50%; padding: 0;"
                                        onclick="openEditTableModal('${t.id}', '${t.name}')" title="Sửa tên bàn">
                                    <i class="fa-solid fa-pen text-white" style="font-size: 12px;"></i>
                                </button>
                                
                                <%-- Nút Xóa (Chỉ hiện khi bàn Trống để tránh lỗi) --%>
                                <c:if test="${t.status == 0}">
                                    <button class="btn btn-sm btn-light text-danger border-0 shadow-sm" 
                                            style="width: 30px; height: 30px; border-radius: 50%; padding: 0;"
                                            onclick="openDeleteTableModal('${t.id}', '${t.name}')" title="Xóa bàn này">
                                        <i class="fa-solid fa-trash text-white" style="font-size: 12px;"></i>
                                    </button>
                                </c:if>
                            </div>

                            <div class="card-body">
                                <h4 class="mb-2"><i class="fa-solid fa-utensils me-2"></i>${t.name}</h4>
                                <span class="badge bg-light text-dark rounded-pill px-3">${t.status == 0 ? 'TRỐNG' : 'CÓ KHÁCH'}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
            
            <div class="mt-4 text-muted small fst-italic">
                <span class="text-success fw-bold"><i class="fa-solid fa-square"></i> Bàn Trống</span> &nbsp;|&nbsp; 
                <span class="text-danger fw-bold"><i class="fa-solid fa-square"></i> Có Khách</span>
            </div>
        </div>

        <div id="tab-online" class="tab-content-section">
            <h4 class="border-start border-5 border-info ps-3 mb-4 text-uppercase fw-bold text-dark">Đơn Hàng Online</h4>
            
            <div class="card border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0 text-center">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã Đơn</th>
                                    <th class="text-center">Tên Khách Hàng</th>
                                    <th>Ngày Đặt</th>
                                    <th>Tổng Tiền</th>
                                    <th>Trạng Thái</th>
                                    <th>Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="o" items="${onlineOrders}">
                                    <c:if test="${o.status != 'Đã hủy'}">
                                        <tr>
                                            <td class="fw-bold">#${o.id}</td>
                                            <td class="fw-bold text-center">${o.userEmail}</td>
                                            <td><fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                            <td class="fw-bold text-warning"><fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/> đ</td>
                                            <td>
                                                <span class="badge rounded-pill 
                                                    ${o.status == 'Giao hàng thành công' ? 'bg-success' : 
                                                    (o.status == 'Đang giao hàng' ? 'bg-primary' : 
                                                    (o.status == 'Đã hủy' ? 'bg-danger' : 
                                                    (o.status == 'Chờ thanh toán' ? 'bg-secondary' : 'bg-warning text-dark')))}">
                                                    ${o.status}
                                                </span>
                                            </td>
                                            <td>
                                                <div class="d-flex justify-content-center gap-2">
                                                    <button class="btn btn-sm btn-info text-white fw-bold" onclick="viewOrderDetail('${o.id}', '${o.address}', '${o.paymentMethod}', '${o.note}')">
                                                        <i class="fa-solid fa-eye"></i> Xem
                                                    </button>
                                                    <c:if test="${o.status == 'Chờ thanh toán' || o.status == 'Đang xử lý'}">
                                                        <button class="btn btn-sm btn-danger fw-bold ms-1" onclick="updateStatus('${o.id}', 'Đã hủy')">
                                                            <i class="fa-solid fa-ban"></i> Hủy
                                                        </button>
                                                    </c:if>
                                                    <c:if test="${o.status == 'Đang xử lý'}">
                                                        <button class="btn btn-sm btn-green fw-bold" onclick="updateStatus('${o.id}', 'Đang giao hàng')">
                                                            <i class="fa-solid fa-truck-fast"></i> Giao hàng
                                                        </button>
                                                    </c:if>
                                                    
                                                    <c:if test="${o.status == 'Đang giao hàng'}">
                                                        <button class="btn btn-sm btn-green fw-bold" onclick="updateStatus('${o.id}', 'Giao hàng thành công')">
                                                            <i class="fa-solid fa-check-circle"></i> Hoàn tất
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div id="tab-menu" class="tab-content-section">
            <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
                <h4 class="border-start border-5 border-success ps-3 text-uppercase fw-bold text-dark m-0">Danh Sách Món</h4>
                <button class="btn btn-success fw-bold btn-add-mobile" onclick="openProductModal()">
                    <i class="fa-solid fa-plus me-2"></i>Thêm Món Mới
                </button>
            </div>

            <div class="card border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Hình ảnh</th>
                                    <th>Tên món</th>
                                    <th>Danh mục</th>
                                    <th>Giá</th>
                                    <th>Trạng thái</th>
                                    <th class="text-center">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${productList}">
                                    <tr>
                                        <td>
                                            <img src="${p.imageUrl}" alt="${p.name}" 
                                                 style="width: 50px; height: 50px; object-fit: cover; border-radius: 5px;"
                                                 onerror="this.src='https://placehold.co/50x50'">
                                        </td>
                                        <td class="fw-bold">${p.name}</td>
                                        <td><span class="badge bg-secondary">${p.category}</span></td>
                                        <td class="text-danger fw-bold"><fmt:formatNumber value="${p.price}" pattern="#,###"/> đ</td>
                                        <%-- CỘT TRẠNG THÁI --%>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.status == 1}">
                                                    <span class="badge bg-success">Đang bán</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">Tạm hết</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <%-- NÚT KHÓA / MỞ KHÓA (Đã sửa lỗi xuống dòng) --%>
                                            <button class="btn btn-sm ${p.status == 1 ? 'btn-outline-dark' : 'btn-outline-success'} me-2" 
                                                    onclick="toggleProductStatus('${p.id}', ${p.status})" 
                                                    title="${p.status == 1 ? 'Khóa món này' : 'Mở bán lại'}">
                                                <i class="fa-solid ${p.status == 1 ? 'fa-lock' : 'fa-lock-open'}"></i>
                                            </button>

                                            <%-- Nút Sửa --%>
                                            <button class="btn btn-sm btn-warning me-2" 
                                                onclick="editProduct('${p.id}', '${p.name}', '${p.description}', '${p.price}', '${p.category}', '${p.imageUrl}')">
                                                <i class="fa-solid fa-pen"></i>
                                            </button>
                                            
                                            <%-- Nút Xóa --%>
                                            <button class="btn btn-sm btn-danger" onclick="openDeleteModal('${p.id}', '${p.name}')">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <div class="modal fade" id="tableModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-light">
                    <h5 class="modal-title fw-bold text-warning" id="modalTableTitle">Xử Lý Bàn</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    
                    <div id="emptyTableAction" class="text-center d-none">
                        <p class="mb-4 text-muted">Bàn này hiện đang trống.</p>
                        <form action="staff" method="post">
                            <input type="hidden" name="action" value="open_table">
                            <input type="hidden" name="tableId" id="inputTableIdOpen">
                            <button type="submit" class="btn btn-success w-100 py-3 fw-bold">
                                <i class="fa-solid fa-play me-2"></i>MỞ BÀN & GỌI MÓN
                            </button>
                        </form>
                    </div>

                    <div id="busyTableAction" class="d-none">
                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <a href="#" id="btnOrderMore" class="btn btn-primary w-100 py-2">
                                    <i class="fa-solid fa-plus me-1"></i> Gọi Món
                                </a>
                            </div>
                            <div class="col-6">
                                <button class="btn btn-danger w-100 py-2" data-bs-target="#checkoutConfirmModal" data-bs-toggle="modal">
                                    <i class="fa-solid fa-money-bill-wave me-1"></i> Thanh Toán
                                </button>
                            </div>
                        </div>
                        
                        <h6 class="fw-bold border-bottom pb-2">Danh sách món đã gọi:</h6>
                        <div id="tableOrderList" class="bg-light p-3 rounded mb-3" style="max-height: 250px; overflow-y: auto;">
                            <div class="text-center"><div class="spinner-border text-warning" role="status"></div></div>
                        </div>

                        <form id="checkoutForm" action="staff" method="post" class="d-none">
                            <input type="hidden" name="action" value="checkout_table">
                            <input type="hidden" name="tableId" id="inputTableIdCheckout">
                        </form>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary w-100" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="productModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title fw-bold" id="productModalTitle">Thêm Món Mới</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form action="staff" method="post" id="productForm">
                        <input type="hidden" name="action" id="formAction" value="add_product">
                        <input type="hidden" name="id" id="prodId">
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Tên món</label>
                            <input type="text" name="name" id="prodName" class="form-control" required>
                        </div>
                        
                        <div class="row">
                            <div class="col-6 mb-3">
                                <label class="form-label fw-bold">Giá tiền</label>
                                <input type="number" name="price" id="prodPrice" class="form-control" required>
                            </div>
                            <div class="col-6 mb-3">
                                <label class="form-label fw-bold">Danh mục</label>
                                <select name="category" id="prodCategory" class="form-select">
                                    <option value="Cà Phê">Cà Phê</option>
                                    <option value="Trà">Trà</option>
                                    <option value="Bánh">Bánh & Snack</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Link Hình Ảnh</label>
                            <input type="text" name="image_url" id="prodImg" class="form-control" placeholder="https://...">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mô tả</label>
                            <textarea name="description" id="prodDesc" class="form-control" rows="2"></textarea>
                        </div>

                        <button type="submit" class="btn btn-success w-100 fw-bold">LƯU SẢN PHẨM</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="orderDetailModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title fw-bold">Chi Tiết Đơn Hàng #<span id="modalOrderId"></span></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="bg-light p-3 rounded mb-3">
                        <p class="mb-1"><strong><i class="fa-solid fa-location-dot text-danger"></i> Địa chỉ:</strong> <span id="modalAddress"></span></p>
                        <p class="mb-1"><strong><i class="fa-regular fa-credit-card text-primary"></i> Thanh toán:</strong> <span id="modalPayment"></span></p>
                        <p class="mb-0"><strong><i class="fa-regular fa-note-sticky text-warning"></i> Ghi chú:</strong> <span id="modalNote" class="fst-italic"></span></p>
                    </div>
                    <div id="onlineOrderDetailContent" class="text-center">
                        <div class="spinner-border text-info" role="status"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="checkoutConfirmModal" tabindex="-1" aria-labelledby="confirmTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow-lg border-0">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title fw-bold" id="confirmTitle">
                        <i class="fa-solid fa-circle-question me-2"></i>Xác Nhận Thanh Toán
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center py-4">
                    <div class="mb-3">
                        <i class="fa-solid fa-cash-register text-danger fa-4x"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Bạn có chắc chắn muốn thanh toán?</h5>
                    <p class="text-muted mb-0">
                        Hành động này sẽ hoàn tất đơn hàng và <strong class="text-danger">trả bàn về trạng thái trống</strong>.
                    </p>
                </div>
                <div class="modal-footer justify-content-center bg-light border-0">
                    <button type="button" class="btn btn-secondary px-4" data-bs-target="#tableModal" data-bs-toggle="modal">Hủy Bỏ</button>
                    <button type="button" class="btn btn-danger px-4 fw-bold" onclick="confirmCheckoutAction()">
                        <i class="fa-solid fa-check me-2"></i>Xác Nhận
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="statusConfirmModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow-lg border-0">
                <div class="modal-header bg-info text-white" id="statusModalHeader">
                    <h5 class="modal-title fw-bold">
                        <i class="fa-solid fa-circle-question me-2"></i>Xác Nhận Cập Nhật
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                
                <div class="modal-body text-center py-4">
                    <div class="mb-3">
                        <i class="fa-solid fa-truck-fast text-info fa-4x" id="statusModalIcon"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Cập nhật trạng thái đơn hàng?</h5>
                    <p class="text-muted mb-0">
                        Trạng thái mới sẽ được chuyển thành:<br>
                        <strong class="text-primary fs-5" id="displayNewStatus"></strong>
                    </p>
                </div>
                
                <div class="modal-footer justify-content-center bg-light border-0">
                    <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Hủy Bỏ</button>
                    <button type="button" class="btn btn-info px-4 fw-bold text-white" id="btnConfirmStatus" onclick="executeStatusUpdate()">
                        <i class="fa-solid fa-check me-2"></i>Xác Nhận
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="deleteProductModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow-lg border-0">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title fw-bold">
                        <i class="fa-solid fa-triangle-exclamation me-2"></i>Xác Nhận Xóa
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                
                <div class="modal-body text-center py-4">
                    <div class="mb-3">
                        <i class="fa-solid fa-trash-can text-danger fa-4x"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Bạn có chắc chắn muốn xóa?</h5>
                    <p class="text-muted mb-0">
                        Món <strong id="deleteProductName" class="text-danger"></strong> sẽ bị xóa vĩnh viễn khỏi thực đơn.
                    </p>
                </div>
                
                <div class="modal-footer justify-content-center bg-light border-0">
                    <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Hủy Bỏ</button>
                    <button type="button" class="btn btn-danger px-4 fw-bold" onclick="executeDeleteProduct()">
                        <i class="fa-solid fa-trash me-2"></i>Xóa Ngay
                    </button>
                </div>
            </div>
        </div>
    </div>
    <form id="deleteProductForm" action="staff" method="post" class="d-none">
        <input type="hidden" name="action" value="delete_product">
        <input type="hidden" name="id" id="inputDeleteProductId">
    </form>

    <div class="modal fade" id="addTableModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-warning text-white">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-chair me-2"></i>Thêm Bàn Mới</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form action="staff" method="post">
                        <input type="hidden" name="action" value="add_table">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Tên bàn</label>
                            <input type="text" name="tableName" class="form-control" placeholder="Ví dụ: Bàn 10, Bàn VIP..." required>
                        </div>
                        <button type="submit" class="btn btn-warning text-white w-100 fw-bold">
                            <i class="fa-solid fa-floppy-disk me-2"></i>LƯU BÀN
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editTableModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-pen-to-square me-2"></i>Đổi Tên Bàn</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form action="staff" method="post">
                        <input type="hidden" name="action" value="edit_table">
                        <input type="hidden" name="tableId" id="inputEditTableId">
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Tên bàn mới</label>
                            <input type="text" name="tableName" id="inputEditTableName" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 fw-bold">LƯU THAY ĐỔI</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="deleteTableModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-trash me-2"></i>Xóa Bàn</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center">
                    <i class="fa-solid fa-circle-exclamation text-danger fa-3x mb-3"></i>
                    <p>Bạn có chắc chắn muốn xóa <strong id="deleteTableNameDisplay"></strong>?</p>
                    <p class="small text-muted">Hành động này không thể hoàn tác.</p>
                    
                    <form action="staff" method="post">
                        <input type="hidden" name="action" value="delete_table">
                        <input type="hidden" name="tableId" id="inputDeleteTableId">
                        <div class="d-flex gap-2 justify-content-center mt-4">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-danger fw-bold">Xóa Ngay</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // === INIT MODALS ===
        const tableModal = new bootstrap.Modal(document.getElementById('tableModal'));
        const orderDetailModal = new bootstrap.Modal(document.getElementById('orderDetailModal'));
        const productModal = new bootstrap.Modal(document.getElementById('productModal'));
        const checkoutConfirmModal = new bootstrap.Modal(document.getElementById('checkoutConfirmModal'));

        // === 1. TAB NAVIGATION ===
        function showTab(name) {
            document.querySelectorAll('.tab-content-section').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.nav-link').forEach(el => el.classList.remove('active'));
            
            document.getElementById('tab-' + name).classList.add('active');
            document.getElementById('link-' + name).classList.add('active');
        }

        // === 2. XỬ LÝ BÀN (POS) ===
        function handleTableClick(id, name, status) {
            document.getElementById('modalTableTitle').innerText = name;
            
            const emptyDiv = document.getElementById('emptyTableAction');
            const busyDiv = document.getElementById('busyTableAction');
            
            if (status == 0) {
                // Bàn trống
                emptyDiv.classList.remove('d-none');
                busyDiv.classList.add('d-none');
                document.getElementById('inputTableIdOpen').value = id;
            } else {
                // Bàn có khách
                emptyDiv.classList.add('d-none');
                busyDiv.classList.remove('d-none');
                
                document.getElementById('inputTableIdCheckout').value = id;
                document.getElementById('btnOrderMore').href = "${pageContext.request.contextPath}/menu?tableId=" + id;
                
                loadTableOrders(id);
            }
            
            tableModal.show();
        }

        function loadTableOrders(tableId) {
            document.getElementById('tableOrderList').innerHTML = '<div class="text-center"><div class="spinner-border text-warning" role="status"></div></div>';
            fetch('${pageContext.request.contextPath}/staff?action=get_table_detail&tableId=' + tableId)
                .then(res => res.text())
                .then(html => { document.getElementById('tableOrderList').innerHTML = html; });
        }
        // Xử lý xác nhận thanh toán
        function confirmCheckoutAction() {
            document.getElementById('checkoutForm').submit();
            checkoutConfirmModal.hide();
        }

        // --- KHAI BÁO BIẾN TOÀN CỤC & MODAL ---
        let targetOrderId = null;
        let targetStatus = null;
        const statusConfirmModal = new bootstrap.Modal(document.getElementById('statusConfirmModal'));

        function updateStatus(orderId, newStatus) {
            // Lưu biến tạm
            targetOrderId = orderId;
            targetStatus = newStatus;

            // Lấy các phần tử giao diện
            const header = document.getElementById('statusModalHeader');
            const icon = document.getElementById('statusModalIcon');
            const btn = document.getElementById('btnConfirmStatus');
            const statusText = document.getElementById('displayNewStatus');

            statusText.innerText = newStatus;

            // KIỂM TRA: Nếu là HỦY ĐƠN thì đổi sang màu ĐỎ
            if (newStatus === 'Đã hủy') {
                // Style ĐỎ (Danger)
                header.className = 'modal-header bg-danger text-white';
                icon.className = 'fa-solid fa-trash-can text-danger fa-4x'; // Icon thùng rác
                btn.className = 'btn btn-danger px-4 fw-bold';
                statusText.className = 'text-danger fs-5 fw-bold';
            } else {
                // Style XANH (Info) - Mặc định
                header.className = 'modal-header bg-info text-white';
                icon.className = 'fa-solid fa-truck-fast text-info fa-4x'; // Icon xe tải
                btn.className = 'btn btn-info px-4 fw-bold text-white';
                statusText.className = 'text-primary fs-5';
            }

            // Mở Modal
            statusConfirmModal.show();
        }

        // 2. Hàm thực thi khi bấm nút "Xác Nhận" trong Modal
        function executeStatusUpdate() {
            if (targetOrderId && targetStatus) {
                // Chuyển hướng server để xử lý cập nhật trạng thái
                window.location.href = '${pageContext.request.contextPath}/staff?action=update_status&orderId=' + targetOrderId + '&status=' + encodeURIComponent(targetStatus);
            }
        }

        function viewOrderDetail(orderId, address, payment, note) {
            document.getElementById('modalOrderId').innerText = orderId;
            document.getElementById('modalAddress').innerText = address;
            
            let payText = payment === 'banking' ? 'Chuyển khoản' : (payment === 'cash' ? 'Tiền mặt (COD)' : payment);
            document.getElementById('modalPayment').innerText = payText || 'Không rõ';
            document.getElementById('modalNote').innerText = note ? note : 'Không có';

            document.getElementById('onlineOrderDetailContent').innerHTML = '<div class="spinner-border text-info" role="status"></div>';
            orderDetailModal.show();
            
            fetch('${pageContext.request.contextPath}/order-detail?id=' + orderId)
                .then(res => res.text())
                .then(html => { 
                     const tableHtml = html.replace('<table', '<table class="table table-striped table-sm"');
                     document.getElementById('onlineOrderDetailContent').innerHTML = tableHtml; 
                });
        }

        // Auto Reload Orders (Polling)
        function autoReloadOrders() {
            const onlineTab = document.getElementById('tab-online');
            if (onlineTab.classList.contains('active') || getComputedStyle(onlineTab).display !== 'none') {
                fetch('${pageContext.request.contextPath}/staff?action=get_online_orders_ajax')
                    .then(res => res.text())
                    .then(html => {
                        const tbody = document.querySelector('#tab-online tbody');
                        if (tbody && html.trim() !== "") {
                            tbody.innerHTML = html;
                        }
                    })
                    .catch(console.error);
            }
        }
        setInterval(autoReloadOrders, 5000);

        // === 4. QUẢN LÝ MENU (CRUD) ===
        function openProductModal() {
            document.getElementById('productForm').reset();
            document.getElementById('formAction').value = 'add_product';
            document.getElementById('productModalTitle').innerText = 'Thêm Món Mới';
            productModal.show();
        }

        function editProduct(id, name, desc, price, cat, img) {
            document.getElementById('formAction').value = 'edit_product';
            document.getElementById('productModalTitle').innerText = 'Cập Nhật Món';
            
            document.getElementById('prodId').value = id;
            document.getElementById('prodName').value = name;
            document.getElementById('prodDesc').value = desc;
            document.getElementById('prodPrice').value = price;
            document.getElementById('prodCategory').value = cat;
            document.getElementById('prodImg').value = img;
            
            productModal.show();
        }

        // === 5. URL PARAMS HANDLER ===
        document.addEventListener("DOMContentLoaded", function() {
            const urlParams = new URLSearchParams(window.location.search);
            const activeTab = urlParams.get('tab');
            
            if (activeTab === 'online') showTab('online');
            else if (activeTab === 'menu') showTab('menu');
            else showTab('pos');
        });
        // --- 6. KHÓA / MỞ MÓN ---
        function toggleProductStatus(id, currentStatus) {
            // Tạo form ẩn để gửi yêu cầu
            const form = document.createElement('form');
            form.method = 'post';
            form.action = 'staff';

            const inputAction = document.createElement('input');
            inputAction.type = 'hidden';
            inputAction.name = 'action';
            inputAction.value = 'toggle_product_status';

            const inputId = document.createElement('input');
            inputId.type = 'hidden';
            inputId.name = 'id';
            inputId.value = id;

            const inputStatus = document.createElement('input');
            inputStatus.type = 'hidden';
            inputStatus.name = 'currentStatus';
            inputStatus.value = currentStatus;

            form.appendChild(inputAction);
            form.appendChild(inputId);
            form.appendChild(inputStatus);
            document.body.appendChild(form);
            
            form.submit();
        }
        // --- 7. XỬ LÝ XÓA MÓN ĂN (MODAL) ---
        const deleteProductModal = new bootstrap.Modal(document.getElementById('deleteProductModal'));

        function openDeleteModal(id, name) {
            // Hiển thị tên món ăn lên Modal cho người dùng dễ check
            document.getElementById('deleteProductName').innerText = name;
            
            // Gán ID vào form ẩn
            document.getElementById('inputDeleteProductId').value = id;
            
            // Mở Modal
            deleteProductModal.show();
        }

        function executeDeleteProduct() {
            // Submit form ẩn
            document.getElementById('deleteProductForm').submit();
        }
        // --- QUẢN LÝ BÀN (SỬA / XÓA) ---
        const editTableModal = new bootstrap.Modal(document.getElementById('editTableModal'));
        const deleteTableModal = new bootstrap.Modal(document.getElementById('deleteTableModal'));

        function openEditTableModal(id, name) {
            document.getElementById('inputEditTableId').value = id;
            document.getElementById('inputEditTableName').value = name;
            editTableModal.show();
        }

        function openDeleteTableModal(id, name) {
            document.getElementById('inputDeleteTableId').value = id;
            document.getElementById('deleteTableNameDisplay').innerText = name;
            deleteTableModal.show();
        }
    </script>
    <jsp:include page="chat_widget.jsp" />
</body>
</html>