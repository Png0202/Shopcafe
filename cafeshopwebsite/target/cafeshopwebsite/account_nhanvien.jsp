<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Nhân Viên - Quán Cà Phê</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* --- CSS GIAO DIỆN NHÂN VIÊN --- */
        body { background-color: #f0f2f5; display: flex; min-height: 100vh; flex-direction: column; }
        
        .staff-header { background: #343a40; color: white; padding: 15px 0; }
        .staff-nav ul { display: flex; gap: 20px; list-style: none; padding: 0; }
        .staff-nav a { color: #adb5bd; text-decoration: none; padding: 8px 15px; border-radius: 4px; cursor: pointer; font-weight: bold;}
        .staff-nav a.active, .staff-nav a:hover { background: #d35400; color: white; }

        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .tab-content { display: none; animation: fadeIn 0.3s; }
        .tab-content.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        /* --- CSS SƠ ĐỒ BÀN (POS) --- */
        .table-grid {
            display: flex;
            flex-wrap: wrap; /* Cho phép xuống dòng */
            gap: 20px;
        }
        /* Nếu muốn ép buộc hiển thị nhiều cột trên mobile */
        @media (max-width: 768px) {
            .table-grid {
                grid-template-columns: repeat(2, 1fr); /* Luôn hiện 2 cột trên điện thoại */
            }
        }
        .table-card { 
            width: 150px;
            padding: 30px 10px; border-radius: 12px; text-align: center; color: white; 
            font-weight: bold; cursor: pointer; transition: 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            position: relative;
        }
        .table-card:hover { transform: translateY(-5px); }
        .table-empty { background-color: #28a745; } /* Xanh: Trống */
        .table-busy { background-color: #dc3545; }  /* Đỏ: Có khách */
        .table-name { font-size: 18px; margin-bottom: 5px; }
        .table-status { font-size: 13px; opacity: 0.9; text-transform: uppercase; }

        /* --- CSS BẢNG ĐƠN ONLINE --- */
        .order-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .order-table th, .order-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; }
        .order-table th { background: #e9ecef; font-weight: bold; color: #495057; }
        .status-badge { padding: 5px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; color: white; }
        .status-new { background: #ffc107; color: #333; }      /* Chờ duyệt */
        .status-shipping { background: #17a2b8; }             /* Đang giao */
        .status-done { background: #28a745; }                  /* Hoàn thành */
        .status-cancel { background: #dc3545; }                /* Đã hủy */

        /* --- CSS MODAL --- */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
        .modal-content { background: white; margin: 5% auto; padding: 25px; width: 600px; border-radius: 8px; position: relative; max-height: 90vh; overflow-y: auto; }
        .close { float: right; font-size: 28px; cursor: pointer; color: #aaa; }
        .close:hover { color: #333; }
        .btn-action { padding: 5px 10px; border: none; border-radius: 4px; cursor: pointer; color: white; font-size: 13px; }
        .btn-blue { background: #007bff; }
        .btn-green { background: #28a745; }
        .btn-red { background: #dc3545; }
    </style>
</head>
<body>

    <header class="staff-header">
        <div class="container" style="display:flex; justify-content:space-between; align-items:center;">
            <h2>☕STAFF PORTAL</h2>
            <nav class="staff-nav">
                <ul>
                    <li><a onclick="showTab('pos')" id="link-pos" class="active">Quản Lý Bàn</a></li>
                    <li><a onclick="showTab('online')" id="link-online">Đơn Online</a></li>
                    <li><a href="${pageContext.request.contextPath}/logout.jsp">Đăng Xuất</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <div class="container" style="margin-top: 20px;">
        
        <div id="tab-pos" class="tab-content active">
            <h3 style="margin-bottom: 20px; color: #333; border-left: 5px solid #d35400; padding-left: 10px;">QUẢN LÝ BÀN</h3>
            
            <div class="table-grid">
                <c:forEach var="t" items="${tables}">
                    <div class="table-card ${t.status == 0 ? 'table-empty' : 'table-busy'}" 
                         onclick="handleTableClick('${t.id}', '${t.name}', ${t.status})">
                        <div class="table-name">${t.name}</div>
                        <div class="table-status">${t.status == 0 ? 'TRỐNG' : 'CÓ KHÁCH'}</div>
                    </div>
                </c:forEach>
            </div>
            
        </div>

        <div id="tab-online" class="tab-content">
            <h3 style="margin-bottom: 20px; color: #333; border-left: 5px solid #17a2b8; padding-left: 10px;">ĐƠN HÀNG ONLINE</h3>
            
            <table class="order-table">
                <thead>
                    <tr>
                        <th>Tên Khách Hàng</th>
                        <th>Ngày Đặt</th>
                        <th>Tổng Tiền</th>
                        <th>Trạng Thái</th>
                        <th>Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="o" items="${onlineOrders}">
                        <tr>
                            <td>${o.userEmail}</td> 
                            <td><fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td style="color:#d35400; font-weight:bold;"><fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/> đ</td>
                            <td>
                                <span class="status-badge 
                                    ${o.status == 'Đang xử lý' ? 'status-new' : 
                                      (o.status == 'Đã giao' ? 'status-done' : 'status-shipping')}">
                                    ${o.status}
                                </span>
                            </td>
                            <td>
                                <button class="btn-action btn-blue" onclick="viewOrderDetail('${o.id}', '${o.address}', '${o.paymentMethod}', '${o.note}')">Xem</button>
                                <c:if test="${o.status == 'Đang xử lý'}">
                                    <button class="btn-action btn-green" onclick="updateStatus('${o.id}', 'Đang vận chuyển')">Duyệt</button>
                                </c:if>
                                <c:if test="${o.status == 'Đang vận chuyển'}">
                                    <button class="btn-action btn-green" onclick="updateStatus('${o.id}', 'Đã giao')">Hoàn tất</button>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

    </div>

    <div id="tableModal" class="modal">
        <div class="modal-content">
            <%-- Đã xóa nút X ở đây theo yêu cầu --%>
            <h3 id="modalTableTitle" style="text-align:center; color:#d35400; margin-bottom:20px;">Xử Lý Bàn</h3>
            
            <div id="emptyTableAction" style="display:none; text-align:center;">
                <p style="margin-bottom: 20px;">Bàn này hiện đang trống.</p>
                <form action="staff" method="post">
                    <input type="hidden" name="action" value="open_table">
                    <input type="hidden" name="tableId" id="inputTableIdOpen">
                    <button type="submit" class="btn-action btn-green" style="padding:15px 30px; font-size:16px;">MỞ BÀN & GỌI MÓN</button>
                </form>
                
                <%-- Nút Đóng cho trường hợp bàn trống --%>
                <button type="button" class="btn-action" onclick="closeModal('tableModal')" style="width:20%; padding:12px; font-size:16px; background-color: #ca8666ff;margin-top: 15px;">ĐÓNG</button>
            </div>

            <div id="busyTableAction" style="display:none;">
                <div style="display:flex; gap:10px; margin-bottom:20px;">
                    <a href="#" id="btnOrderMore" class="btn-action btn-blue" style="flex:1; text-align:center; padding:15px; text-decoration:none;">GỌI MÓN</a>
                    
                    <button onclick="submitCheckout()" class="btn-action btn-red" style="flex:1;">THANH TOÁN</button>
                </div>
                
                <h4>Bill Thanh Toán:</h4>
                <div id="tableOrderList" style="max-height:200px; overflow-y:auto; border:1px solid #eee; padding:10px; margin-bottom:20px;">
                    Loading...
                </div>

                <form id="checkoutForm" action="staff" method="post" style="display:none;">
                    <input type="hidden" name="action" value="checkout_table">
                    <input type="hidden" name="tableId" id="inputTableIdCheckout">
                </form>

                <%-- Nút ĐÓNG MODAL --%>
                <button type="button" class="btn-action" onclick="closeModal('tableModal')" style="width:100%; padding:15px; font-size:16px; background-color: #ca8666ff;">ĐÓNG</button>
            </div>
        </div>
    </div>

    <div id="orderDetailModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('orderDetailModal')">&times;</span>
            <h3 style="text-align:center; color:#d35400; margin-bottom:15px;">Chi Tiết Đơn Hàng #<span id="modalOrderId"></span></h3>
            
            <div style="background:#f9f9f9; padding:15px; border-radius:5px; margin-bottom:15px; font-size:14px;">
                <p><strong>📍 Địa chỉ nhận:</strong> <span id="modalAddress"></span></p>
                <p><strong>💳 Thanh toán:</strong> <span id="modalPayment"></span></p>
                <p><strong>📝 Ghi chú:</strong> <span id="modalNote" style="font-style:italic;"></span></p>
            </div>

            <div id="onlineOrderDetailContent">
                <p style="text-align:center;">Đang tải dữ liệu...</p>
            </div>
        </div>
    </div>

    <script>
        // 1. CHUYỂN TAB
        function showTab(name) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.staff-nav a').forEach(el => el.classList.remove('active'));
            document.getElementById('tab-' + name).classList.add('active');
            document.getElementById('link-' + name).classList.add('active');
        }

        // 2. XỬ LÝ CLICK BÀN
        function handleTableClick(id, name, status) {
            document.getElementById('modalTableTitle').innerText = name;
            document.getElementById('tableModal').style.display = 'block';
            
            if (status == 0) {
                // Bàn trống -> Hiện nút Mở bàn
                document.getElementById('emptyTableAction').style.display = 'block';
                document.getElementById('busyTableAction').style.display = 'none';
                document.getElementById('inputTableIdOpen').value = id;
            } else {
                // Bàn có khách -> Hiện menu chức năng
                document.getElementById('emptyTableAction').style.display = 'none';
                document.getElementById('busyTableAction').style.display = 'block';
                
                // Gán tableId vào form ẩn
                document.getElementById('inputTableIdCheckout').value = id;
                
                // Link gọi món: Chuyển sang trang menu với tham số tableId
                document.getElementById('btnOrderMore').href = "${pageContext.request.contextPath}/menu?tableId=" + id;

                // Load danh sách món ăn của bàn này (Ajax)
                loadTableOrders(id);
            }
        }

        // 3. LOAD CHI TIẾT BÀN (AJAX)
        function loadTableOrders(tableId) {
            fetch('${pageContext.request.contextPath}/staff?action=get_table_detail&tableId=' + tableId)
                .then(res => res.text())
                .then(html => { document.getElementById('tableOrderList').innerHTML = html; });
        }

        // 4. XỬ LÝ THANH TOÁN (Submit form ẩn)
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
            // 1. Điền thông tin vào Modal
            document.getElementById('modalOrderId').innerText = orderId;
            document.getElementById('modalAddress').innerText = address;
            
            let payText = payment === 'banking' ? 'Chuyển khoản ngân hàng' : (payment === 'cash' ? 'Tiền mặt (COD)' : payment);
            document.getElementById('modalPayment').innerText = payText || 'Không rõ';
            
            document.getElementById('modalNote').innerText = note ? note : 'Không có';

            // 2. Hiển thị Modal
            document.getElementById('orderDetailModal').style.display = 'block';
            
            // 3. Gọi Ajax lấy danh sách món
            fetch('${pageContext.request.contextPath}/order-detail?id=' + orderId)
                .then(res => res.text())
                .then(html => { document.getElementById('onlineOrderDetailContent').innerHTML = html; });
        }

        function closeModal(id) { document.getElementById(id).style.display = 'none'; }
        // --- 6. TỰ ĐỘNG MỞ TAB TỪ URL ---
        document.addEventListener("DOMContentLoaded", function() {
            const urlParams = new URLSearchParams(window.location.search);
            const activeTab = urlParams.get('tab');
            
            if (activeTab === 'online') {
                showTab('online');
            } else {
                showTab('pos'); // Mặc định là POS nếu không có param
            }
        });
        // --- 7. AUTO RELOAD ĐƠN ONLINE (POLLING) ---
        function autoReloadOrders() {
            // Chỉ reload khi đang ở tab Online
            const onlineTab = document.getElementById('tab-online');
            if (onlineTab.style.display === 'block' || onlineTab.classList.contains('active')) {
                fetch('${pageContext.request.contextPath}/staff?action=get_online_orders_ajax')
                    .then(res => res.text())
                    .then(html => {
                        // Cập nhật tbody của bảng đơn hàng
                        const tbody = document.querySelector('#tab-online tbody');
                        if (tbody && html.trim() !== "") {
                            tbody.innerHTML = html;
                        }
                    })
                    .catch(console.error);
            }
        }

        // Gọi hàm mỗi 5 giây (5000ms)
        setInterval(autoReloadOrders, 5000);
    </script>
</body>
</html>