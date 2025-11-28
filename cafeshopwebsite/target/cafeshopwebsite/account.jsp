<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tài Khoản - Quán Cà Phê</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

    <style>
        /* --- CSS CƠ BẢN --- */
        body { background-color: #f5f5f5; }
        .breadcrumb { padding: 15px 0; font-size: 14px; color: #666; }
        .breadcrumb a { text-decoration: none; color: #333; }
        
        /* Layout Flexbox cho PC */
        .account-layout { display: flex; gap: 30px; margin-bottom: 50px; align-items: flex-start; }
        
        /* Sidebar */
        .sidebar { flex: 0 0 250px; }
        .sidebar h3 { font-size: 18px; margin-bottom: 10px; color: #333; }
        .sidebar-menu { list-style: none; padding: 0; background: #fff; border: 1px solid #eee; border-radius: 4px;}
        .sidebar-menu li { border-bottom: 1px solid #eee; }
        .sidebar-menu a { text-decoration: none; color: #555; display: block; padding: 12px 15px; font-size: 14px; cursor: pointer; transition: 0.3s; }
        .sidebar-menu a:hover, .sidebar-menu a.active { background-color: #f9f9f9; color: #d35400; font-weight: bold; }

        /* Content Main */
        .account-content { 
            flex: 1; /* Tự động chiếm hết chỗ còn lại */
            background: #fff; 
            padding: 25px; 
            border: 1px solid #eee; 
            border-radius: 4px; 
            min-height: 400px; 
            box-sizing: border-box; /* Quan trọng để padding không làm vỡ khung */
        }
        
        /* Tiêu đề Section (Đã căn giữa) */
        .section-title { 
            font-size: 20px; 
            text-transform: uppercase; 
            margin-bottom: 20px; 
            padding-bottom: 10px; 
            border-bottom: 1px solid #eee; 
            text-align: center; /* CĂN GIỮA */
            color: #d35400;
            font-weight: bold;
        }
        
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        /* Thông báo Alert */
        .alert { padding: 10px; margin-bottom: 20px; border-radius: 5px; font-size: 14px; text-align: center; font-weight: bold; }
        .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }

        /* Form & Inputs */
        .info-group { margin-bottom: 15px; position: relative; }
        .info-group label { display: block; margin-bottom: 5px; font-weight: bold; color: #555; }
        .info-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        .btn-save { background-color: #d35400; color: white; border: none; padding: 10px 25px; cursor: pointer; border-radius: 4px; width: 100%; }
        .btn-delete { background: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; float: right; margin-left: 10px;}
        .btn-edit { background: #17a2b8; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; }

        /* Address Item */
        .address-item { border: 1px solid #ddd; padding: 15px; margin-bottom: 15px; border-radius: 4px; position: relative; background: #fff; }
        .address-default-badge { display: inline-block; background: #28a745; color: white; padding: 2px 6px; font-size: 11px; border-radius: 3px; margin-left: 10px; vertical-align: middle;}

        /* Status Badge */
        .status-badge { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; color: white; white-space: nowrap; }
        .status-success { background-color: #28a745; }
        .status-pending { background-color: #ffc107; color: #333; }
        .status-shipping { background-color: #17a2b8; }
        .status-cancel  { background-color: #dc3545; }

        /* Map & Autocomplete */
        #map { height: 300px; width: 100%; margin-top: 10px; border: 1px solid #ddd; z-index: 0; }
        .suggestions-list { position: absolute; top: 100%; left: 0; right: 0; background: white; border: 1px solid #ddd; border-top: none; border-radius: 0 0 4px 4px; max-height: 200px; overflow-y: auto; z-index: 1000; list-style: none; padding: 0; margin: 0; display: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .suggestions-list li { padding: 10px; cursor: pointer; border-bottom: 1px solid #eee; font-size: 13px; color: #333; }
        .suggestions-list li:hover { background-color: #f9f9f9; color: #d35400; }

        /* Table Styles */
        .order-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .order-table th { background: #f4f4f4; padding: 10px; text-align: left; white-space: nowrap; }
        .order-table td { padding: 12px 10px; border-bottom: 1px solid #eee; vertical-align: middle; }

        /* Modal */
        .modal { display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
        .modal-content { background: white; margin: 5% auto; padding: 20px; border-radius: 8px; position: relative; max-height: 90vh; overflow-y: auto; width: 600px; }
        .close { float: right; font-size: 28px; cursor: pointer; }

        /* --- RESPONSIVE (MOBILE & TABLET) --- */
        @media (max-width: 992px) {
            .account-layout {
                flex-direction: column; /* Xếp dọc */
            }
            .sidebar {
                width: 100%; 
                margin-bottom: 20px;
            }
            .account-content {
                width: 100%;
                padding: 15px; /* Giảm padding */
            }
            
            /* Bảng cuộn ngang */
            .table-responsive {
                width: 100%;
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
                border: 1px solid #eee;
                margin-bottom: 15px;
            }
            .order-table {
                min-width: 700px; /* Giữ bảng rộng để không bị méo */
            }
            
            /* Modal full màn hình trên mobile */
            .modal-content {
                width: 90%;
                margin: 20% auto;
            }
        }
        /* --- RESPONSIVE (MOBILE & TABLET) --- */
        @media (max-width: 992px) {
            /* ... (Code cũ giữ nguyên) ... */
            
            /* Modal full màn hình, căn giữa tốt hơn */
            .modal-content {
                width: 90% !important; /* Chiếm 90% chiều ngang */
                max-width: 90% !important; 
                margin: 15% auto; /* Cách trên 15% */
                padding: 15px;
                max-height: 80vh; /* Giới hạn chiều cao để không mất nút đóng */
                box-sizing: border-box;     /* Tính cả padding vào độ rộng */
                overflow-x: hidden;         /* Khóa kéo ngang của khung Modal */
            }

            /* Bảng chi tiết bên trong Modal cũng cần cuộn ngang */
            #modalOrderItems table {
                display: block;
                width: 100%;
                overflow-x: auto;
                white-space: nowrap; /* Giữ nội dung trên 1 dòng để bảng đẹp hơn */
            }
            
            /* Hoặc chuyển bảng chi tiết thành dạng thẻ dọc (như bảng đơn hàng bên ngoài) nếu muốn */
            /* Ở đây ta chọn cách cuộn ngang cho đơn giản và dễ nhìn số liệu */
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
                            <c:choose>
                                <c:when test="${sessionScope.permission == 0}">
                                    <li><a href="${pageContext.request.contextPath}/admin" style="color:red;font-weight:bold;">QUẢN TRỊ</a></li>
                                </c:when>
                                <c:when test="${sessionScope.permission == 1}">
                                    <li><a href="${pageContext.request.contextPath}/staff" style="color:blue;font-weight:bold;">NHÂN VIÊN</a></li>
                                </c:when>
                                <c:otherwise>
                                    <li><a href="${pageContext.request.contextPath}/cart">Giỏ Hàng</a></li>
                                    <li><a href="${pageContext.request.contextPath}/profile" class="active" style="font-weight: bold; color: #d35400;">Tài Khoản (${sessionScope.userName})</a></li>
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

    <div class="container">
        <div class="breadcrumb"><a href="home">Trang chủ</a> <span>/</span> Trang khách hàng</div>
    </div>

    <div class="container account-layout">
        
        <%-- SIDEBAR MENU --%>
        <aside class="sidebar">
            <h3>TÀI KHOẢN</h3>
            <p class="greeting">Xin chào, <strong>${requestScope.fullname}</strong></p>
            <ul class="sidebar-menu">
                <li><a onclick="handleTabClick('info')" id="nav-info" class="active">Thông tin tài khoản</a></li>
                <li><a onclick="handleTabClick('addresses')" id="nav-addresses">Sổ địa chỉ (${empty requestScope.addressCount ? 0 : requestScope.addressCount})</a></li>
                <li><a onclick="handleTabClick('orders')" id="nav-orders">Đơn hàng của bạn</a></li>
                <li><a onclick="handleTabClick('password')" id="nav-password">Đổi mật khẩu</a></li>
                <li><a href="${pageContext.request.contextPath}/logout.jsp" style="color: red;">Đăng xuất</a></li>
            </ul>
        </aside>

        <%-- MAIN CONTENT --%>
        <main class="account-content">
            
            <div id="notification-area">
                <c:if test="${param.status == 'success'}"><div class="alert alert-success alert-notification">✅ Thao tác thành công!</div></c:if>
                <c:if test="${param.status == 'deleted'}"><div class="alert alert-success alert-notification">✅ Đã xóa địa chỉ thành công!</div></c:if>
                <c:if test="${param.status == 'updated'}"><div class="alert alert-success alert-notification">✅ Cập nhật thành công!</div></c:if>
                <c:if test="${param.status == 'error'}"><div class="alert alert-danger alert-notification">⚠️ Có lỗi xảy ra, vui lòng thử lại!</div></c:if>
                <c:if test="${param.error == 'wrong_pass'}"><div class="alert alert-danger alert-notification">❌ Mật khẩu cũ không đúng!</div></c:if>
                <c:if test="${param.error == 'mismatch'}"><div class="alert alert-danger alert-notification">❌ Mật khẩu xác nhận không khớp!</div></c:if>
            </div>
            
            <%-- TAB 1: THÔNG TIN TÀI KHOẢN --%>
            <div id="tab-info" class="tab-content active">
                <h3 class="section-title">Thông Tin Tài Khoản</h3>
                <div class="info-group"><label>Họ và tên</label><input type="text" value="${requestScope.fullname}" class="info-control" disabled style="background: #f9f9f9;"></div>
                <div class="info-group"><label>Email</label><input type="text" value="${requestScope.email}" class="info-control" disabled style="background: #f9f9f9;"></div>
                <div class="info-group"><label>Số điện thoại</label><input type="text" value="${requestScope.phone}" class="info-control" disabled style="background: #f9f9f9;"></div>
                <div style="margin-top: 20px;">
                    <a onclick="handleTabClick('addresses')" style="color: #d35400; text-decoration: underline; cursor: pointer;">Quản lý sổ địa chỉ &rarr;</a>
                </div>
            </div>

            <%-- TAB 2: SỔ ĐỊA CHỈ --%>
            <div id="tab-addresses" class="tab-content">
                <h3 class="section-title">Sổ Địa Chỉ Nhận Hàng</h3>
                <div class="address-list">
                    <c:choose>
                        <c:when test="${empty requestScope.addressList}">
                            <p style="color: #666; font-style: italic; text-align: center;">Bạn chưa lưu địa chỉ nào.</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="addr" items="${requestScope.addressList}">
                                <div class="address-item" style="${addr['default'] ? 'border-color: #28a745; background: #f9fff9;' : ''}">
                                    <div style="float: right; display: flex; gap: 10px; align-items: center;">
                                        <c:if test="${!addr['default']}">
                                            <form action="${pageContext.request.contextPath}/profile" method="post" style="margin:0;">
                                                <input type="hidden" name="action" value="set_default">
                                                <input type="hidden" name="id" value="${addr.id}">
                                                <button type="submit" style="background: none; border: none; color: #007bff; cursor: pointer; font-size: 13px; text-decoration: underline;">Đặt làm mặc định</button>
                                            </form>
                                            <span style="color: #ddd;">|</span>
                                        </c:if>
                                        <form action="${pageContext.request.contextPath}/profile" method="post" onsubmit="return confirm('Bạn chắc chắn muốn xóa địa chỉ này?')" style="margin:0;">
                                            <input type="hidden" name="action" value="delete_address">
                                            <input type="hidden" name="id" value="${addr.id}">
                                            <button class="btn-delete">Xóa</button>
                                        </form>
                                    </div>
                                    <div>
                                        <div style="font-size: 15px; margin-bottom: 5px; padding-right: 150px;"><strong>Địa chỉ:</strong> ${addr.addressLine}</div>
                                        <c:if test="${addr['default']}"><span class="address-default-badge">✔ Mặc định</span></c:if>
                                    </div>
                                    <div style="clear: both;"></div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
                
                <hr style="margin: 30px 0; border: 0; border-top: 1px dashed #ddd;">
                
                <h4 style="margin-bottom: 15px; text-align: center;">➕ Thêm địa chỉ mới</h4>
                <form action="${pageContext.request.contextPath}/profile" method="post">
                    <input type="hidden" name="action" value="add_address">
                    <div class="info-group">
                        <label>Tìm kiếm địa chỉ</label>
                        <textarea name="address" id="addressInput" rows="2" class="info-control" placeholder="Nhập tên đường, phường/xã để tìm kiếm..." required autocomplete="off"></textarea>
                        <ul id="suggestions" class="suggestions-list"></ul>
                    </div>
                    <div id="map"></div>
                    <p style="font-size: 12px; color: #666; margin-top: 5px; font-style: italic;">* Chọn địa chỉ từ danh sách gợi ý hoặc nhấn vào bản đồ để xác nhận vị trí.</p>
                    <br>
                    <button type="submit" class="btn-save">Lưu Địa Chỉ Mới</button>
                </form>
            </div>

            <%-- TAB 3: ĐƠN HÀNG (ĐÃ THÊM SCROLL TABLE) --%>
            <div id="tab-orders" class="tab-content">
                <h3 class="section-title">Đơn Hàng Của Bạn</h3>
                <c:choose>
                    <c:when test="${empty requestScope.orderList}"><p style="text-align:center; padding:20px; color:#666;">Chưa có đơn hàng nào.</p></c:when>
                    <c:otherwise>
                        
                        <%-- Div bọc table để cuộn ngang --%>
                        <div class="table-responsive">
                            <table class="order-table">
                                <thead>
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
                                            <td><strong>#${o.id}</strong></td>
                                            <td><fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy"/></td>
                                            <td style="color:#d35400; font-weight:bold;"><fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/> đ</td>
                                            <td>
                                                <span class="status-badge ${o.status == 'Đã giao' ? 'status-success' : 
                                                                                (o.status == 'Đang vận chuyển' ? 'status-shipping' : 
                                                                                (o.status == 'Đã hủy' ? 'status-cancel' : 'status-pending'))}">
                                                        ${o.status}
                                                    </span>
                                            </td>
                                            <td>
                                                <button class="btn-edit" onclick="viewOrderDetails('${o.id}', '${o.address}', '${o.paymentMethod}', '${o.note}')">Chi tiết</button>
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
            <div id="tab-password" class="tab-content">
                <h3 class="section-title">Đổi Mật Khẩu</h3>
                <form action="${pageContext.request.contextPath}/changePassword" method="post">
                    <div class="info-group"><label>Mật khẩu cũ</label><input type="password" name="oldPass" class="info-control" required></div>
                    <div class="info-group"><label>Mật khẩu mới</label><input type="password" name="newPass" class="info-control" required minlength="6"></div>
                    <div class="info-group"><label>Nhập lại mới</label><input type="password" name="confirmPass" class="info-control" required></div>
                    <button class="btn-save">Đổi Mật Khẩu</button>
                </form>
            </div>
        </main>
    </div>

    <div id="orderModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeOrderModal()">&times;</span>
            <h3 style="text-align:center; color:#d35400; margin-bottom:15px;">Chi Tiết Đơn Hàng #<span id="modalOrderId"></span></h3>
            <div style="background:#f9f9f9; padding:15px; border-radius:5px; margin-bottom:15px; font-size:14px;">
                <p><strong>📍 Địa chỉ nhận:</strong> <span id="modalAddress"></span></p>
                <p><strong>💳 Thanh toán:</strong> <span id="modalPayment"></span></p>
                <p><strong>📝 Ghi chú:</strong> <span id="modalNote" style="font-style:italic;"></span></p>
            </div>
            <div id="modalOrderItems"><p style="text-align:center;">Đang tải dữ liệu...</p></div>
        </div>
    </div>

    <footer>
        <div class="container">
            <p>&copy; 2025 Quán Cà Phê Vĩnh Long. Đồ án môn học Công Nghệ Thông Tin 1.</p>
            <p>Sinh viên thực hiện: Phan Tuấn Cảnh - Võ Phúc Nguyên</p>
        </div>
    </footer>

    <script>
        function handleTabClick(tabName) {
            document.querySelectorAll('.alert-notification').forEach(el => el.style.display = 'none');
            showTab(tabName);
        }

        function showTab(name) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.sidebar-menu a').forEach(el => el.classList.remove('active'));
            document.getElementById('tab-' + name).classList.add('active');
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
        function viewOrderDetails(id, address, payment, note) {
            document.getElementById('modalOrderId').innerText = id;
            document.getElementById('modalAddress').innerText = address;
            document.getElementById('modalPayment').innerText = payment === 'banking' ? 'Chuyển khoản ngân hàng' : 'Tiền mặt (COD)';
            document.getElementById('modalNote').innerText = note ? note : 'Không có';
            document.getElementById('orderModal').style.display = 'block';
            fetch('${pageContext.request.contextPath}/order-detail?id=' + id)
                .then(res => res.text())
                .then(html => { document.getElementById('modalOrderItems').innerHTML = html; })
                .catch(() => { document.getElementById('modalOrderItems').innerHTML = '<p style="color:red;">Lỗi tải dữ liệu!</p>'; });
        }
        function closeOrderModal() { document.getElementById('orderModal').style.display = 'none'; }
        window.onclick = function(event) { if (event.target == document.getElementById('orderModal')) closeOrderModal(); }

        const params = new URLSearchParams(window.location.search);
        if(params.get('tab')) showTab(params.get('tab'));
    </script>
</body>
</html>