<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        /* Layout Sidebar & Content */
        body { background-color: #f5f5f5; display: flex; min-height: 100vh; margin: 0;}
        
        /* Sidebar */
        .admin-sidebar { width: 250px; background: #333; color: white; padding: 20px; display: flex; flex-direction: column; }
        .admin-sidebar h2 { margin-bottom: 30px; font-size: 22px; text-align: center; color: #d35400; border-bottom: 1px solid #555; padding-bottom: 10px; }
        .admin-menu { list-style: none; padding: 0; }
        .admin-menu li { margin-bottom: 10px; }
        .admin-menu a { color: #ccc; text-decoration: none; display: block; padding: 12px 15px; border-radius: 4px; transition: 0.3s; cursor: pointer; }
        .admin-menu a:hover, .admin-menu a.active { background: #d35400; color: white; font-weight: bold; }
        
        /* Content Area */
        .admin-content { flex: 1; padding: 30px; overflow-y: auto; }
        .tab-section { display: none; } 
        .tab-section.active { display: block; animation: fadeIn 0.5s; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        /* Cards Thống kê */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); text-align: center; }
        .card h3 { font-size: 14px; color: #666; margin-bottom: 10px; text-transform: uppercase; }
        .card .value { font-size: 24px; font-weight: bold; color: #333; }
        .card.orange .value { color: #d35400; }
        .card.green .value { color: #28a745; }
        .card.blue .value { color: #007bff; }

        /* Table */
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; font-weight: bold; color: #555; }
        
        /* Charts Container */
        .charts-wrapper { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px; }
        .chart-box { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .chart-select { padding: 5px; border-radius: 4px; border: 1px solid #ddd; cursor: pointer;}

        /* Modal & Button */
        .btn-edit { background: #28a745; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
        .modal-content { background: white; margin: 10% auto; padding: 20px; width: 400px; border-radius: 8px; position: relative; }
        .close { float: right; font-size: 28px; cursor: pointer; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input, .form-group select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        .btn-save { background: #d35400; color: white; width: 100%; padding: 10px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
    </style>
</head>
<body>

    <div class="admin-sidebar">
        <h2>☕ ADMIN CP</h2>
        <ul class="admin-menu">
            <li><a onclick="showTab('accounts')" id="link-accounts" class="active">👥 Quản Lý Tài Khoản</a></li>
            <li><a onclick="showTab('revenue')" id="link-revenue">📊 Thống Kê Doanh Thu</a></li>
            <li><a href="${pageContext.request.contextPath}/logout.jsp" style="color: #ff6b6b;">🚪 Đăng Xuất</a></li>
        </ul>
    </div>

    <div class="admin-content">
        
        <div id="tab-accounts" class="tab-section active">
            <h2 style="margin-bottom: 20px; color: #333;">Quản Lý Tài Khoản</h2>
            
            <div class="stats-grid">
                <div class="card blue">
                    <h3>Tổng Nhân Viên</h3>
                    <div class="value">${staffCount}</div>
                </div>
                <div class="card green">
                    <h3>Tổng Khách Hàng</h3>
                    <div class="value">${customerCount}</div>
                </div>
            </div>

            <c:if test="${param.status == 'updated'}">
                <div style="background:#d4edda; color:#155724; padding:10px; margin-bottom:15px; border-radius:4px;">✅ Cập nhật quyền thành công!</div>
            </c:if>

            <table>
                <thead>
                    <tr>
                        <th>Họ Tên</th>
                        <th>Email</th>
                        <th>Vai Trò</th>
                        <th>Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="u" items="${userList}">
                        <tr>
                            <td>${u[1]}</td>
                            <td>${u[2]}</td>
                            <td>
                                <span style="font-weight:bold; color: ${u[3]=='Chủ'?'red':(u[3]=='Nhân viên'?'blue':'green')}">
                                    ${u[3]}
                                </span>
                            </td>
                            <td>
                                <button class="btn-edit" onclick="openEditModal('${u[0]}', '${u[1]}', '${u[2]}', '${u[3]}')">Sửa</button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div id="tab-revenue" class="tab-section">
            <h2 style="margin-bottom: 20px; color: #333;">Tổng Quan Doanh Thu</h2>
            
            <div class="stats-grid">
                <div class="card orange">
                    <h3>Tổng Doanh Thu (Thực tế)</h3>
                    <div class="value"><fmt:formatNumber value="${totalRevenue}" pattern="#,###"/> VNĐ</div>
                </div>
                <div class="card blue">
                    <h3>Tổng Đơn Hàng</h3>
                    <div class="value">${totalOrders}</div>
                </div>
            </div>

            <div class="charts-wrapper">
                <div class="chart-box">
                    <div class="chart-header">
                        <h3 style="margin:0">Biểu Đồ Doanh Thu</h3>
                        <select class="chart-select" onchange="updateRevenueChart(this.value)">
                            <option value="today">Hôm nay</option> <option value="week" selected>7 Ngày qua</option>
                            <option value="month">Tháng này</option>
                            <option value="year">Năm nay</option>
                        </select>
                    </div>
                    <canvas id="revenueChart"></canvas>
                </div>

                <div class="chart-box">
                    <div class="chart-header">
                        <h3 style="margin:0">Biểu Đồ Đơn Hàng</h3>
                        <select class="chart-select" onchange="updateOrderChart(this.value)">
                            <option value="today">Hôm nay</option> <option value="week" selected>7 Ngày qua</option>
                            <option value="month">Tháng này</option>
                        </select>
                    </div>
                    <canvas id="orderChart"></canvas>
                </div>
            </div>
        </div>

    </div>

    <div id="editModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h3 style="text-align:center; margin-bottom: 15px;">Cập Nhật Tài Khoản</h3>
            
            <form action="${pageContext.request.contextPath}/admin" method="post">
                <%-- Đổi tên action thành update_user --%>
                <input type="hidden" name="action" value="update_user">
                <input type="hidden" name="userId" id="modalUserId">
                
                <div class="form-group">
                    <label>Họ Tên</label>
                    <%-- Bỏ disabled để cho phép sửa --%>
                    <input type="text" name="fullname" id="modalName" required>
                </div>
                
                <div class="form-group">
                    <label>Email</label>
                    <%-- Bỏ disabled để cho phép sửa --%>
                    <input type="email" name="email" id="modalEmail" required>
                </div>
                
                <div class="form-group">
                    <label>Mật khẩu mới (Để trống nếu không đổi)</label>
                    <input type="password" name="newPassword" placeholder="Nhập mật khẩu mới...">
                </div>
                
                <div class="form-group">
                    <label>Vai Trò</label>
                    <select name="permission" id="modalRole">
                        <option value="2">Khách Hàng</option>
                        <option value="1">Nhân Viên</option>
                        <option value="0">Chủ</option>
                    </select>
                </div>
                
                <button type="submit" class="btn-save">Lưu Thay Đổi</button>
            </form>
        </div>
    </div>

    <script>
        // --- 1. XỬ LÝ CHUYỂN TAB ---
        function showTab(tabName) {
            document.querySelectorAll('.tab-section').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.admin-menu a').forEach(el => el.classList.remove('active'));
            document.getElementById('tab-' + tabName).classList.add('active');
            document.getElementById('link-' + tabName).classList.add('active');
        }

        // --- 2. XỬ LÝ MODAL ---
        function openEditModal(id, name, email, roleText) {
            document.getElementById('modalUserId').value = id;
            document.getElementById('modalName').value = name;
            document.getElementById('modalEmail').value = email;
            
            // Reset ô mật khẩu về trống mỗi khi mở modal
            document.getElementsByName('newPassword')[0].value = "";

            const roleSelect = document.getElementById('modalRole');
            if(roleText === 'Chủ') roleSelect.value = "0";
            else if(roleText === 'Nhân viên') roleSelect.value = "1";
            else roleSelect.value = "2";
            
            document.getElementById('editModal').style.display = "block";
        }
        
        function closeModal() { document.getElementById('editModal').style.display = "none"; }
        window.onclick = function(event) { if (event.target == document.getElementById('editModal')) closeModal(); }


        // --- 3. KHỞI TẠO BIỂU ĐỒ (CHART.JS) ---
        
        // A. Config Revenue Chart
        const ctxRev = document.getElementById('revenueChart').getContext('2d');
        const revenueChart = new Chart(ctxRev, {
            type: 'bar',
            data: {
                labels: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
                datasets: [{
                    label: 'Doanh Thu (VNĐ)',
                    data: [150000, 200000, 180000, 220000, 300000, 450000, 400000],
                    backgroundColor: 'rgba(211, 84, 0, 0.7)',
                    borderColor: 'rgba(211, 84, 0, 1)',
                    borderWidth: 1
                }]
            },
            options: { responsive: true }
        });

        // B. Config Order Chart
        const ctxOrd = document.getElementById('orderChart').getContext('2d');
        const orderChart = new Chart(ctxOrd, {
            type: 'line',
            data: {
                labels: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
                datasets: [{
                    label: 'Số Đơn Hàng',
                    data: [5, 8, 6, 9, 12, 15, 14],
                    borderColor: '#007bff',
                    tension: 0.4,
                    fill: true,
                    backgroundColor: 'rgba(0, 123, 255, 0.2)'
                }]
            },
            options: { responsive: true }
        });

        // --- 4. HÀM CẬP NHẬT BIỂU ĐỒ (DỮ LIỆU THẬT TỪ DATABASE) ---
        
        function updateRevenueChart(period) {
            // Gọi Servlet qua Fetch API
            fetch('${pageContext.request.contextPath}/admin-chart?type=revenue&period=' + period)
                .then(response => response.json())
                .then(jsonData => {
                    // Nếu không có dữ liệu, hiển thị mảng rỗng để reset biểu đồ
                    if (jsonData.labels.length === 0) {
                        revenueChart.data.labels = ["Không có dữ liệu"];
                        revenueChart.data.datasets[0].data = [0];
                    } else {
                        revenueChart.data.labels = jsonData.labels;
                        revenueChart.data.datasets[0].data = jsonData.data;
                    }
                    revenueChart.update();
                })
                .catch(error => console.error('Lỗi tải biểu đồ doanh thu:', error));
        }

        function updateOrderChart(period) {
            fetch('${pageContext.request.contextPath}/admin-chart?type=order&period=' + period)
                .then(response => response.json())
                .then(jsonData => {
                    if (jsonData.labels.length === 0) {
                        orderChart.data.labels = ["Không có dữ liệu"];
                        orderChart.data.datasets[0].data = [0];
                    } else {
                        orderChart.data.labels = jsonData.labels;
                        orderChart.data.datasets[0].data = jsonData.data;
                    }
                    orderChart.update();
                })
                .catch(error => console.error('Lỗi tải biểu đồ đơn hàng:', error));
        }

        // --- 5. KHỞI TẠO DỮ LIỆU MẶC ĐỊNH KHI LOAD TRANG ---
        window.addEventListener('load', function() {
            // Mặc định load dữ liệu tuần
            updateRevenueChart('week');
            updateOrderChart('week');
        });
    </script>
</body>
</html>