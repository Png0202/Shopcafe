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
        body { background-color: #f0f2f5; min-height: 100vh; display: flex; flex-direction: column; }
        
        .staff-header { background: #343a40; padding: 15px 0; }
        
        /* Tab Navigation đẹp hơn */
        .nav-pills .nav-link { 
            color: #adb5bd; font-weight: bold; margin-right: 10px; cursor: pointer;
        }
        .nav-pills .nav-link.active { 
            background-color: #d35400; color: white; 
        }
        .nav-pills .nav-link:hover:not(.active) { 
            background-color: rgba(255,255,255,0.1); color: white;
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
        .table-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.15); }
        
        .bg-table-empty { background-color: #28a745; } /* Xanh lá */
        .bg-table-busy { background-color: #dc3545; }  /* Đỏ */

        .tab-content-section { display: none; animation: fadeIn 0.3s; }
        .tab-content-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        /* Responsive Modal */
        @media (max-width: 992px) {
            .modal-content {
                width: 95% !important;
                margin: 10% auto;
            }
        }
        .badge {
            font-size: 14px !important; /* Tăng cỡ chữ lên 14px */
            padding: 10px 15px !important; /* Tăng khoảng cách để badge không bị chật */
            font-weight: 600; /* Độ đậm chữ vừa phải */
            letter-spacing: 0.5px; /* Khoảng cách chữ cho dễ đọc */
        }
        
        /* Riêng badge ở chế độ Mobile/Tablet thì có thể chỉnh khác nếu cần */
        @media (max-width: 992px) {
            .badge {
                font-size: 13px !important; /* Mobile nhỏ hơn xíu cho gọn */
                padding: 8px 12px !important;
            }
        }
        /* --- RESPONSIVE CHO MOBILE & TABLET --- */
        @media (max-width: 768px) {
            /* Header: Logo và Menu xếp dọc */
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

            /* Grid Bàn: Hiển thị 2 cột trên điện thoại */
            .row-cols-2 {
                --bs-gutter-x: 10px; /* Giảm khoảng cách giữa các cột */
            }
            .table-card {
                padding: 1rem 0;
            }
            .table-card h4 { font-size: 1.1rem; }

            /* Bảng Đơn hàng: Cuộn ngang nếu quá dài */
            .table-responsive {
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
            }
            .table th, .table td {
                white-space: nowrap; /* Giữ nội dung trên 1 dòng để bảng đẹp */
                font-size: 0.85rem;
                padding: 8px;
            }

            /* Modal Full màn hình */
            .modal-content {
                width: 95% !important;
                margin: 10% auto;
                padding: 15px;
            }
            
            /* Nút bấm nhỏ lại */
            .btn-sm {
                padding: 4px 8px;
                font-size: 0.75rem;
            }
            
        }
    </style>
</head>
<body>

    <header class="staff-header shadow-sm">
        <div class="container d-flex justify-content-between align-items-center">
            <h3 class="text-white m-0"><i class="fa-solid fa-mug-hot me-2"></i>STAFF PORTAL</h3>
            <ul class="nav nav-pills">
                <li class="nav-item">
                    <a onclick="showTab('pos')" id="link-pos" class="nav-link active"><i class="fa-solid fa-shop me-2"></i>Quản Lý Bàn</a>
                </li>
                <li class="nav-item">
                    <a onclick="showTab('online')" id="link-online" class="nav-link"><i class="fa-solid fa-globe me-2"></i>Đơn Online</a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/logout.jsp" class="nav-link bg-danger text-white ms-3"><i class="fa-solid fa-right-from-bracket me-2"></i>Đăng Xuất</a>
                </li>
            </ul>
        </div>
    </header>

    <div class="container mt-4 mb-5 flex-grow-1">
        
        <div id="tab-pos" class="tab-content-section active">
            <h4 class="border-start border-5 border-warning ps-3 mb-4 text-uppercase fw-bold text-dark">Sơ Đồ Bàn</h4>
            
            <div class="row row-cols-2 row-cols-md-3 row-cols-lg-5 g-4">
                <c:forEach var="t" items="${tables}">
                    <div class="col">
                        <div class="card table-card shadow-sm py-4 ${t.status == 0 ? 'bg-table-empty' : 'bg-table-busy'}" 
                             onclick="handleTableClick('${t.id}', '${t.name}', ${t.status})">
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
                                    <tr>
                                        <td class="fw-bold">#${o.id}</td>
                                        <td class="fw-bold text-center">${o.userEmail}</td>
                                        <td><fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td class="fw-bold text-warning"><fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/> đ</td>
                                        <td>
                                            <%-- LOGIC BADGE BOOTSTRAP --%>
                                            <span class="badge rounded-pill 
                                                ${o.status == 'Giao hàng thành công' ? 'bg-success' : 
                                                (o.status == 'Đang giao hàng' ? 'bg-primary' : 
                                                (o.status == 'Đã hủy' ? 'bg-danger' : 
                                                (o.status == 'Chờ thanh toán' ? 'bg-secondary' : 'bg-warning text-dark')))}">
                                                ${o.status}
                                            </span>
                                        </td>
                                        <td>
                                            <%-- LOGIC NÚT BẤM BOOTSTRAP --%>
                                            <div class="d-flex justify-content-center gap-2">
                                                <button class="btn btn-sm btn-info text-white fw-bold" onclick="viewOrderDetail('${o.id}', '${o.address}', '${o.paymentMethod}', '${o.note}')">
                                                    <i class="fa-solid fa-eye"></i> Xem
                                                </button>
                                                
                                                <c:if test="${o.status == 'Chờ thanh toán'}">
                                                </c:if>
                                                <c:if test="${o.status == 'Đang xử lý'}">
                                                    <button class="btn btn-sm btn-primary fw-bold" onclick="updateStatus('${o.id}', 'Đang giao hàng')">
                                                        <i class="fa-solid fa-truck-fast"></i> Giao hàng
                                                    </button>
                                                </c:if>
                                                <c:if test="${o.status == 'Đang giao hàng'}">
                                                    <button class="btn btn-sm btn-success fw-bold" onclick="updateStatus('${o.id}', 'Giao hàng thành công')">
                                                        <i class="fa-solid fa-check-circle"></i> Hoàn tất
                                                    </button>
                                                </c:if>
                                            </div>
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
                                <button onclick="submitCheckout()" class="btn btn-danger w-100 py-2">
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // Init Modals
        const tableModal = new bootstrap.Modal(document.getElementById('tableModal'));
        const orderDetailModal = new bootstrap.Modal(document.getElementById('orderDetailModal'));

        // 1. CHUYỂN TAB
        function showTab(name) {
            document.querySelectorAll('.tab-content-section').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.nav-link').forEach(el => el.classList.remove('active'));
            
            document.getElementById('tab-' + name).classList.add('active');
            document.getElementById('link-' + name).classList.add('active');
        }

        // 2. XỬ LÝ CLICK BÀN
        function handleTableClick(id, name, status) {
            document.getElementById('modalTableTitle').innerText = name;
            
            // Reset display
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

        // 3. LOAD CHI TIẾT BÀN (AJAX)
        function loadTableOrders(tableId) {
            document.getElementById('tableOrderList').innerHTML = '<div class="text-center"><div class="spinner-border text-warning" role="status"></div></div>';
            fetch('${pageContext.request.contextPath}/staff?action=get_table_detail&tableId=' + tableId)
                .then(res => res.text())
                .then(html => { document.getElementById('tableOrderList').innerHTML = html; });
        }

        // 4. XỬ LÝ THANH TOÁN
        function submitCheckout() {
            if(confirm('Xác nhận thanh toán và hoàn tất bàn này?')) {
                document.getElementById('checkoutForm').submit();
            }
        }

        // 5. XỬ LÝ ĐƠN ONLINE
        function updateStatus(orderId, newStatus) {
            if(confirm('Cập nhật trạng thái thành: ' + newStatus + '?')) {
                window.location.href = '${pageContext.request.contextPath}/staff?action=update_status&orderId=' + orderId + '&status=' + encodeURIComponent(newStatus);
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

        // 6. AUTO RELOAD (Polling) - Tự động cập nhật đơn online mới mỗi 5 giây
        function autoReloadOrders() {
            const onlineTab = document.getElementById('tab-online');
            // Kiểm tra xem tab online có đang active không
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

        // 7. AUTO OPEN TAB FROM URL
        document.addEventListener("DOMContentLoaded", function() {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('tab') === 'online') {
                showTab('online');
            }
        });
    </script>
</body>
</html>