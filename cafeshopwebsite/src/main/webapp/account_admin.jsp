<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Quản Trị Viên</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        body { background-color: #f8f9fa; }
        
        /* Navbar Styles */
        .navbar-admin { background-color: #212529; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        
        .navbar-nav .nav-link {
            cursor: pointer; color: rgba(255,255,255,0.7); font-weight: 500;
            padding: 10px 15px; transition: 0.3s; border-radius: 5px; margin-left: 5px;
        }
        .navbar-nav .nav-link:hover { color: #fff; background-color: rgba(255,255,255,0.1); }
        .navbar-nav .nav-link.active { color: #fff !important; background-color: #d35400; font-weight: bold; }
        
        /* Cards Thống kê */
        .stat-card {
            border: none; border-radius: 10px; color: white; position: relative;
            overflow: hidden; transition: transform 0.3s;
        }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-icon {
            position: absolute; right: 15px; top: 50%;
            transform: translateY(-50%); font-size: 3rem; opacity: 0.3;
        }
        
        /* Tab Animation */
        .tab-content-section { display: none; animation: fadeIn 0.5s; }
        .tab-content-section.active-section { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        
        .form-select-sm { width: auto; display: inline-block; }
    </style>
</head>
<body>

    <nav class="navbar navbar-expand-lg navbar-dark navbar-admin sticky-top">
        <div class="container">
            <a class="navbar-brand fw-bold text-warning" href="#">
                <i class="fa-solid fa-mug-hot me-2"></i>ADMIN CP
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNavbar">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="adminNavbar">
                <ul class="navbar-nav ms-auto mb-2 mb-lg-0 align-items-center">
                    <li class="nav-item">
                        <a class="nav-link active" onclick="showTab('accounts')" id="link-accounts">
                            <i class="fa-solid fa-users me-1"></i> Quản Lý Tài Khoản
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" onclick="showTab('revenue')" id="link-revenue">
                            <i class="fa-solid fa-chart-line me-1"></i> Thống Kê Doanh Thu
                        </a>
                    </li>
                    <li class="nav-item ms-lg-3">
                        <a href="${pageContext.request.contextPath}/logout.jsp" class="btn btn-outline-danger btn-sm fw-bold">
                            <i class="fa-solid fa-right-from-bracket me-1"></i> Đăng Xuất
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container py-4">
        
        <c:if test="${param.status == 'updated'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-check-circle me-2"></i> Cập nhật thông tin thành công!
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${param.error == 'failed'}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i> Có lỗi xảy ra, vui lòng thử lại!
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <div id="tab-accounts" class="tab-content-section active-section">
            <h3 class="mb-4 border-start border-5 border-warning ps-3 text-secondary">Quản Lý Tài Khoản</h3>

            <div class="row mb-4">
                <div class="col-md-6"> 
                    <div class="card stat-card bg-primary shadow-sm">
                        <div class="card-body">
                            <h5 class="card-title">Nhân Viên</h5>
                            <h2 class="mb-0">${staffCount}</h2>
                            <i class="fa-solid fa-user-tie stat-icon"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-6"> 
                    <div class="card stat-card bg-success shadow-sm">
                        <div class="card-body">
                            <h5 class="card-title">Khách Hàng</h5>
                            <h2 class="mb-0">${customerCount}</h2>
                            <i class="fa-solid fa-users stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3">
                    <h5 class="m-0 fw-bold text-secondary"><i class="fa-solid fa-list me-2"></i>Danh Sách Người Dùng</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover table-striped align-middle mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th>Họ Tên</th>
                                    <th>Email</th>
                                    <th>Vai Trò</th>
                                    <th class="text-center">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="u" items="${userList}">
                                    <tr>
                                        <td class="fw-bold">${u[1]}</td>
                                        <td>${u[2]}</td>
                                        <td>
                                            <span class="badge rounded-pill ${u[3]=='Chủ'?'bg-danger':(u[3]=='Nhân viên'?'bg-primary':'bg-secondary')}">
                                                ${u[3]}
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <button class="btn btn-sm btn-warning text-dark fw-bold" 
                                                    onclick="openEditModal('${u[0]}', '${u[1]}', '${u[2]}', '${u[3]}')">
                                                <i class="fa-solid fa-pen-to-square"></i> Sửa
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

        <div id="tab-revenue" class="tab-content-section">
            <h3 class="mb-4 border-start border-5 border-primary ps-3 text-secondary">Tổng Quan Kinh Doanh</h3>

            <div class="row mb-4">
                <div class="col-md-6">
                    <div class="card stat-card bg-warning text-dark shadow-sm">
                        <div class="card-body">
                            <h5 class="card-title">Tổng Doanh Thu</h5>
                            <h2 class="mb-0 fw-bold"><fmt:formatNumber value="${totalRevenue}" pattern="#,###"/> VNĐ</h2>
                            <i class="fa-solid fa-money-bill-wave stat-icon text-dark"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card stat-card bg-secondary shadow-sm">
                        <div class="card-body">
                            <h5 class="card-title">Tổng Đơn Hàng</h5>
                            <h2 class="mb-0">${totalOrders}</h2>
                            <i class="fa-solid fa-receipt stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="card shadow-sm border-0 h-100">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center">
                            <h5 class="m-0 fw-bold text-secondary">Biểu Đồ Doanh Thu</h5>
                            <select class="form-select form-select-sm" onchange="updateRevenueChart(this.value)">
                                <option value="today">Hôm nay</option>
                                <option value="week" selected>7 Ngày qua</option>
                                <option value="month">Tháng này</option>
                                <option value="year">Năm nay</option>
                            </select>
                        </div>
                        <div class="card-body">
                            <canvas id="revenueChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="card shadow-sm border-0 h-100">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center">
                            <h5 class="m-0 fw-bold text-secondary">Biểu Đồ Đơn Hàng</h5>
                            <select class="form-select form-select-sm" onchange="updateOrderChart(this.value)">
                                <option value="today">Hôm nay</option>
                                <option value="week" selected>7 Ngày qua</option>
                                <option value="month">Tháng này</option>
                                <option value="year">Năm nay</option>
                            </select>
                        </div>
                        <div class="card-body">
                            <canvas id="orderChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm border-0 mt-4">
                <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                    <h5 class="m-0 fw-bold text-secondary"><i class="fa-solid fa-table me-2"></i>Báo Cáo Chi Tiết</h5>
                    
                    <div class="btn-group" role="group">
                        <input type="radio" class="btn-check" name="reportType" id="btnRadioDay" autocomplete="off" checked onclick="loadReport('day')">
                        <label class="btn btn-outline-secondary btn-sm" for="btnRadioDay">Theo Ngày</label>
                      
                        <input type="radio" class="btn-check" name="reportType" id="btnRadioMonth" autocomplete="off" onclick="loadReport('month')">
                        <label class="btn btn-outline-secondary btn-sm" for="btnRadioMonth">Theo Tháng</label>
                      
                        <input type="radio" class="btn-check" name="reportType" id="btnRadioYear" autocomplete="off" onclick="loadReport('year')">
                        <label class="btn btn-outline-secondary btn-sm" for="btnRadioYear">Theo Năm</label>
                    </div>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover table-striped align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Thời Gian</th>
                                    <th class="text-center">Tổng Đơn Hàng</th>
                                    <th class="text-end">Doanh Thu Thực</th>
                                </tr>
                            </thead>
                            <tbody id="reportTableBody">
                                <tr><td colspan="3" class="text-center py-3"><div class="spinner-border spinner-border-sm text-warning"></div> Đang tải...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-warning">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-user-pen me-2"></i>Cập Nhật Tài Khoản</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form action="${pageContext.request.contextPath}/admin" method="post">
                        <input type="hidden" name="action" value="update_user">
                        <input type="hidden" name="userId" id="modalUserId">
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Họ Tên</label>
                            <input type="text" name="fullname" id="modalName" class="form-control" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Email</label>
                            <input type="email" name="email" id="modalEmail" class="form-control" required>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mật khẩu mới <small class="text-muted fw-normal">(Để trống nếu không đổi)</small></label>
                            <input type="password" name="newPassword" class="form-control" placeholder="********">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label fw-bold">Vai Trò</label>
                            <select name="permission" id="modalRole" class="form-select">
                                <option value="2">Khách Hàng</option>
                                <option value="1">Nhân Viên</option>
                                <option value="0">Chủ (Admin)</option>
                            </select>
                        </div>
                        
                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary fw-bold">Lưu Thay Đổi</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // --- 1. XỬ LÝ CHUYỂN TAB ---
        function showTab(tabName) {
            // Ẩn tất cả
            document.querySelectorAll('.tab-content-section').forEach(el => el.classList.remove('active-section'));
            document.querySelectorAll('.nav-link').forEach(el => el.classList.remove('active'));
            
            // Hiện cái được chọn
            document.getElementById('tab-' + tabName).classList.add('active-section');
            document.getElementById('link-' + tabName).classList.add('active');
        }

        // --- 2. XỬ LÝ MODAL ---
        const editModal = new bootstrap.Modal(document.getElementById('editModal'));

        function openEditModal(id, name, email, roleText) {
            document.getElementById('modalUserId').value = id;
            document.getElementById('modalName').value = name;
            document.getElementById('modalEmail').value = email;
            document.getElementsByName('newPassword')[0].value = "";

            const roleSelect = document.getElementById('modalRole');
            if(roleText === 'Chủ') roleSelect.value = "0";
            else if(roleText === 'Nhân viên') roleSelect.value = "1";
            else roleSelect.value = "2";
            
            editModal.show();
        }

        // --- 3. KHỞI TẠO BIỂU ĐỒ (CHART.JS) ---
        const ctxRev = document.getElementById('revenueChart').getContext('2d');
        const revenueChart = new Chart(ctxRev, {
            type: 'bar',
            data: {
                labels: [],
                datasets: [{
                    label: 'Doanh Thu (VNĐ)',
                    data: [],
                    backgroundColor: 'rgba(255, 193, 7, 0.7)',
                    borderColor: 'rgba(255, 193, 7, 1)',
                    borderWidth: 1,
                    borderRadius: 5
                }]
            },
            options: { responsive: true, plugins: { legend: { display: false } } }
        });

        const ctxOrd = document.getElementById('orderChart').getContext('2d');
        const orderChart = new Chart(ctxOrd, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Số Đơn Hàng',
                    data: [],
                    borderColor: '#0d6efd',
                    tension: 0.4,
                    fill: true,
                    backgroundColor: 'rgba(13, 110, 253, 0.1)'
                }]
            },
            options: { responsive: true, plugins: { legend: { display: false } } }
        });

        // --- 4. HÀM CẬP NHẬT BIỂU ĐỒ & BÁO CÁO ---
        function updateRevenueChart(period) {
            fetch('${pageContext.request.contextPath}/admin-chart?type=revenue&period=' + period)
                .then(response => response.json())
                .then(jsonData => {
                    revenueChart.data.labels = (jsonData.labels.length === 0) ? ["Không có dữ liệu"] : jsonData.labels;
                    revenueChart.data.datasets[0].data = (jsonData.labels.length === 0) ? [0] : jsonData.data;
                    revenueChart.update();
                })
                .catch(error => console.error('Lỗi chart revenue:', error));
        }

        function updateOrderChart(period) {
            fetch('${pageContext.request.contextPath}/admin-chart?type=order&period=' + period)
                .then(response => response.json())
                .then(jsonData => {
                    orderChart.data.labels = (jsonData.labels.length === 0) ? ["Không có dữ liệu"] : jsonData.labels;
                    orderChart.data.datasets[0].data = (jsonData.labels.length === 0) ? [0] : jsonData.data;
                    orderChart.update();
                })
                .catch(error => console.error('Lỗi chart order:', error));
        }
        
        // --- 5. LOAD BÁO CÁO DẠNG BẢNG ---
        function loadReport(type) {
            const tbody = document.getElementById('reportTableBody');
            tbody.innerHTML = '<tr><td colspan="3" class="text-center py-3"><div class="spinner-border spinner-border-sm text-secondary"></div> Đang tải dữ liệu...</td></tr>';
            
            fetch('${pageContext.request.contextPath}/admin?action=get_report&type=' + type)
                .then(res => res.text())
                .then(html => { tbody.innerHTML = html; })
                .catch(err => {
                    console.error(err);
                    tbody.innerHTML = '<tr><td colspan="3" class="text-center text-danger">Lỗi tải dữ liệu</td></tr>';
                });
        }

        // --- INIT ---
        window.addEventListener('load', function() {
            updateRevenueChart('week');
            updateOrderChart('week');
            loadReport('day'); // Mặc định load báo cáo ngày
        });

        // --- TỰ ĐỘNG ĐÓNG MENU TRÊN MOBILE KHI CHỌN TAB ---
        const navLinks = document.querySelectorAll('.navbar-nav .nav-link');
        const navbarCollapse = document.getElementById('adminNavbar');
        navLinks.forEach(link => {
            link.addEventListener('click', () => {
                if (navbarCollapse.classList.contains('show')) {
                    const bsCollapse = bootstrap.Collapse.getInstance(navbarCollapse);
                    if (bsCollapse) { bsCollapse.hide(); }
                }
            });
        });
    </script>
</body>
</html>