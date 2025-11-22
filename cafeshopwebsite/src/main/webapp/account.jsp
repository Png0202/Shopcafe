<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

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
        /* CSS Layout */
        body { background-color: #f5f5f5; }
        .breadcrumb { padding: 15px 0; font-size: 14px; color: #666; }
        .breadcrumb a { text-decoration: none; color: #333; }
        .account-layout { display: flex; gap: 30px; margin-bottom: 50px; align-items: flex-start; }
        
        /* Sidebar */
        .sidebar { flex: 0 0 250px; }
        .sidebar h3 { font-size: 18px; margin-bottom: 10px; color: #333; }
        .sidebar-menu { list-style: none; padding: 0; background: #fff; border: 1px solid #eee; border-radius: 4px;}
        .sidebar-menu li { border-bottom: 1px solid #eee; }
        .sidebar-menu a { text-decoration: none; color: #555; display: block; padding: 12px 15px; font-size: 14px; cursor: pointer; transition: 0.3s; }
        .sidebar-menu a:hover, .sidebar-menu a.active { background-color: #f9f9f9; color: #d35400; font-weight: bold; }

        /* Content */
        .account-content { flex: 1; background: #fff; padding: 25px; border: 1px solid #eee; border-radius: 4px; min-height: 400px; }
        .section-title { font-size: 20px; text-transform: uppercase; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #eee; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        /* CSS THÔNG BÁO */
        .alert { padding: 10px; margin-bottom: 20px; border-radius: 5px; font-size: 14px; text-align: center; font-weight: bold; }
        .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }

        /* Address Box Style */
        .address-item { border: 1px solid #ddd; padding: 15px; margin-bottom: 15px; border-radius: 4px; position: relative; background: #fff; }
        .address-default-badge { display: inline-block; background: #28a745; color: white; padding: 2px 6px; font-size: 11px; border-radius: 3px; margin-left: 10px; vertical-align: middle;}
        .btn-delete { background: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; float: right; margin-left: 10px;}
        
        /* CSS STATUS BADGE */
        .status-badge { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; color: white; white-space: nowrap; }
        .status-success { background-color: #28a745; }
        .status-pending { background-color: #ffc107; color: #333; }
        .status-shipping { background-color: #17a2b8; }
        .status-cancel  { background-color: #dc3545; }

        /* Map & Form */
        #map { height: 300px; width: 100%; margin-top: 10px; border: 1px solid #ddd; z-index: 0; }
        .info-group { margin-bottom: 15px; position: relative; /* Quan trọng cho danh sách gợi ý */ }
        .info-group label { display: block; margin-bottom: 5px; font-weight: bold; color: #555; }
        .info-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
        .btn-save { background-color: #d35400; color: white; border: none; padding: 10px 25px; cursor: pointer; border-radius: 4px; }
        
        /* --- CSS DANH SÁCH GỢI Ý ĐỊA CHỈ (AUTOCOMPLETE) --- */
        .suggestions-list {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: white;
            border: 1px solid #ddd;
            border-top: none;
            border-radius: 0 0 4px 4px;
            max-height: 200px;
            overflow-y: auto;
            z-index: 1000;
            list-style: none;
            padding: 0;
            margin: 0;
            display: none; /* Ẩn mặc định */
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .suggestions-list li {
            padding: 10px;
            cursor: pointer;
            border-bottom: 1px solid #eee;
            font-size: 13px;
            color: #333;
        }
        .suggestions-list li:hover {
            background-color: #f9f9f9;
            color: #d35400;
        }

        /* Table Order */
        .order-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .order-table th { background: #f4f4f4; padding: 10px; text-align: left; }
        .order-table td { padding: 12px 10px; border-bottom: 1px solid #eee; vertical-align: middle; }

        @media (max-width: 768px) { .account-layout { flex-direction: column; } .sidebar { width: 100%; } }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>☕ Quán Cà Phê Vĩnh Long</h1>
            <nav>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/index.jsp">Trang Chủ</a></li>
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

    <div class="container">
        <div class="breadcrumb"><a href="index.jsp">Trang chủ</a> <span>/</span> Trang khách hàng</div>
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
                <c:if test="${param.status == 'success'}"><div class="alert alert-success alert-notification">✅ Đặt hàng thành công!</div></c:if>
                <c:if test="${param.status == 'deleted'}"><div class="alert alert-success alert-notification">✅ Đã xóa địa chỉ thành công!</div></c:if>
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
                            <p style="color: #666; font-style: italic;">Bạn chưa lưu địa chỉ nào.</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="addr" items="${requestScope.addressList}">
                                <div class="address-item" style="${addr['default'] ? 'border-color: #28a745; background: #f9fff9;' : ''}">
                                    
                                    <%-- Các nút hành động (Để bên phải) --%>
                                    <div style="float: right; display: flex; gap: 10px; align-items: center;">
                                        
                                        <%-- Nút Set Default (Chỉ hiện nếu chưa phải mặc định) --%>
                                        <c:if test="${!addr['default']}">
                                            <form action="${pageContext.request.contextPath}/profile" method="post">
                                                <input type="hidden" name="action" value="set_default">
                                                <input type="hidden" name="id" value="${addr.id}">
                                                <button type="submit" style="background: none; border: none; color: #007bff; cursor: pointer; font-size: 13px; text-decoration: underline;">
                                                    Đặt làm mặc định
                                                </button>
                                            </form>
                                            <span style="color: #ddd;">|</span>
                                        </c:if>

                                        <%-- Nút Xóa --%>
                                        <form action="${pageContext.request.contextPath}/profile" method="post" onsubmit="return confirm('Bạn chắc chắn muốn xóa địa chỉ này?')">
                                            <input type="hidden" name="action" value="delete_address">
                                            <input type="hidden" name="id" value="${addr.id}">
                                            <button class="btn-delete">Xóa</button>
                                        </form>
                                    </div>
                                    
                                    <%-- Nội dung địa chỉ --%>
                                    <div>
                                        <div style="font-size: 15px; margin-bottom: 5px;">${addr.addressLine}</div>
                                        <c:if test="${addr['default']}">
                                            <span class="address-default-badge">✔ Mặc định</span>
                                        </c:if>
                                    </div>
                                    <div style="clear: both;"></div> <%-- Clear float --%>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
                <hr style="margin: 30px 0; border: 0; border-top: 1px dashed #ddd;">
                
                <h4 style="margin-bottom: 15px;">➕ Thêm địa chỉ mới</h4>
                <form action="${pageContext.request.contextPath}/profile" method="post">
                    <input type="hidden" name="action" value="add_address">
                    
                    <%-- Ô NHẬP ĐỊA CHỈ CÓ GỢI Ý --%>
                    <div class="info-group">
                        <label>Tìm kiếm địa chỉ</label>
                        <input type="text" name="address" id="addressInput" rows="2" class="info-control" placeholder="Nhập tên đường, phường/xã để tìm kiếm..." required autocomplete="off">
                        
                        <ul id="suggestions" class="suggestions-list"></ul>
                    </div>

                    <div id="map"></div>
                    <p style="font-size: 12px; color: #666; margin-top: 5px; font-style: italic;">* Chọn địa chỉ từ danh sách gợi ý hoặc nhấn vào bản đồ để xác nhận vị trí.</p>
                    <br>
                    <button type="submit" class="btn-save">Lưu Địa Chỉ Mới</button>
                </form>
            </div>

            <%-- TAB 3: ĐƠN HÀNG --%>
            <div id="tab-orders" class="tab-content">
                <h3 class="section-title">Đơn Hàng Của Bạn</h3>
                <c:choose>
                    <c:when test="${empty requestScope.orderList}"><p style="text-align:center; padding:20px; color:#666;">Chưa có đơn hàng nào.</p></c:when>
                    <c:otherwise>
                        <div style="overflow-x:auto;">
                            <table class="order-table">
                                <thead><tr><th>Mã ĐH</th><th>Ngày đặt</th><th>Địa chỉ</th><th>Tổng tiền</th><th>Trạng thái</th></tr></thead>
                                <tbody>
                                    <c:forEach var="o" items="${requestScope.orderList}">
                                        <tr>
                                            <td><strong>#${o.id}</strong></td>
                                            <td><fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy"/></td>
                                            <td style="max-width:200px;">${o.address}</td>
                                            <td style="color:#d35400; font-weight:bold;"><fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/> đ</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${o.status == 'Đã giao'}"><span class="status-badge status-success">${o.status}</span></c:when>
                                                    <c:when test="${o.status == 'Đang xử lý'}"><span class="status-badge status-pending">${o.status}</span></c:when>
                                                    <c:when test="${o.status == 'Đang vận chuyển'}"><span class="status-badge status-shipping">${o.status}</span></c:when>
                                                    <c:when test="${o.status == 'Đã hủy'}"><span class="status-badge status-cancel">${o.status}</span></c:when>
                                                    <c:otherwise><span class="status-badge status-pending">${o.status}</span></c:otherwise>
                                                </c:choose>
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

    <footer>
        <div class="container">
            <p>&copy; 2025 Quán Cà Phê Vĩnh Long</p>
        </div>
    </footer>

    <script>
        function handleTabClick(tabName) {
            const notifications = document.querySelectorAll('.alert-notification');
            notifications.forEach(el => el.style.display = 'none');
            showTab(tabName);
        }

        function showTab(name) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.sidebar-menu a').forEach(el => el.classList.remove('active'));
            document.getElementById('tab-' + name).classList.add('active');
            document.getElementById('nav-' + name).classList.add('active');
            if(name === 'addresses' && map) { setTimeout(() => { map.invalidateSize(); }, 200); }
        }

        // --- CẤU HÌNH BẢN ĐỒ ---
        const defaultLat = 10.253698, defaultLng = 105.972298;
        var map = L.map('map').setView([defaultLat, defaultLng], 14);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: '© OpenStreetMap' }).addTo(map);
        
        var marker;

        // Hàm cập nhật Marker và Map View
        function updateMap(lat, lng) {
            const newLatLng = new L.LatLng(lat, lng);
            if (marker) marker.setLatLng(newLatLng);
            else marker = L.marker(newLatLng).addTo(map);
            map.setView(newLatLng, 16); // Zoom vào vị trí mới
        }

        // --- XỬ LÝ GỢI Ý ĐỊA CHỈ (AUTOCOMPLETE) ---
        const addressInput = document.getElementById('addressInput');
        const suggestionsList = document.getElementById('suggestions');
        let debounceTimer;

        addressInput.addEventListener('input', function() {
            const query = this.value;
            clearTimeout(debounceTimer); // Xóa timer cũ
            
            if (query.length < 3) {
                suggestionsList.style.display = 'none';
                return;
            }

            // Debounce: Chỉ gọi API sau khi ngừng gõ 500ms
            debounceTimer = setTimeout(() => {
                // Gọi API Nominatim (giới hạn Việt Nam & tối đa 5 kết quả)
                fetch(`https://nominatim.openstreetmap.org/search?format=json&q=\${encodeURIComponent(query)}&countrycodes=vn&limit=5`)
                    .then(res => res.json())
                    .then(data => {
                        suggestionsList.innerHTML = '';
                        if (data.length > 0) {
                            suggestionsList.style.display = 'block';
                            data.forEach(place => {
                                const li = document.createElement('li');
                                li.textContent = place.display_name;
                                // Khi click vào gợi ý
                                li.addEventListener('click', () => {
                                    addressInput.value = place.display_name;
                                    suggestionsList.style.display = 'none';
                                    // Cập nhật bản đồ theo tọa độ của địa chỉ đã chọn
                                    updateMap(parseFloat(place.lat), parseFloat(place.lon));
                                });
                                suggestionsList.appendChild(li);
                            });
                        } else {
                            suggestionsList.style.display = 'none';
                        }
                    })
                    .catch(err => console.error(err));
            }, 500);
        });

        // Ẩn danh sách gợi ý khi click ra ngoài
        document.addEventListener('click', function(e) {
            if (!addressInput.contains(e.target) && !suggestionsList.contains(e.target)) {
                suggestionsList.style.display = 'none';
            }
        });

        // Giữ lại sự kiện click vào bản đồ (Dự phòng)
        map.on('click', function(e) {
            updateMap(e.latlng.lat, e.latlng.lng);
            document.getElementById('addressInput').value = "Đang tải địa chỉ...";
            fetch(`https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=\${e.latlng.lat}&lon=\${e.latlng.lng}`)
                .then(res => res.json())
                .then(data => {
                    document.getElementById('addressInput').value = data.display_name || `\${e.latlng.lat}, \${e.latlng.lng}`;
                });
        });

        const params = new URLSearchParams(window.location.search);
        if(params.get('tab')) showTab(params.get('tab'));
    </script>
</body>
</html>