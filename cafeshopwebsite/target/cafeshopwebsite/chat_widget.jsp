<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- CHỈ HIỆN KHI ĐÃ ĐĂNG NHẬP --%>
<c:if test="${not empty sessionScope.userEmail}">

    <button id="globalChatBtn" class="btn btn-primary rounded-circle shadow-lg d-flex align-items-center justify-content-center" 
            style="position: fixed; bottom: 30px; right: 30px; width: 60px; height: 60px; z-index: 9999;"
            onclick="toggleGlobalChat()">
        <i class="fa-solid fa-comments fa-2x text-white"></i>
        <span id="globalChatBadge" class="position-absolute top-0 start-100 translate-middle p-2 bg-danger border border-light rounded-circle d-none"></span>
    </button>

    <div id="globalChatWindow" class="card shadow-lg d-none" 
         style="position: fixed; bottom: 100px; right: 30px; width: 360px; height: 500px; z-index: 9999; border-radius: 15px; overflow: hidden;">
        
        <%-- ================= TRƯỜNG HỢP 1: GIAO DIỆN NHÂN VIÊN ================= --%>
        <c:if test="${sessionScope.permission == 1}">
            <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
                <div class="fw-bold"><i class="fa-solid fa-users me-2"></i>Khách Hàng</div>
                <button type="button" class="btn-close btn-close-white" onclick="toggleGlobalChat()"></button>
            </div>

            <div id="staffUserListView" class="h-100 d-flex flex-column bg-white">
                <div class="list-group list-group-flush overflow-auto flex-grow-1" id="staffUserList">
                    <div class="text-center mt-5 text-muted small">Đang tải danh sách...</div>
                </div>
            </div>

            <div id="staffChatDetailView" class="h-100 flex-column bg-light d-none">
                <div class="bg-white text-dark p-2 d-flex align-items-center border-bottom shadow-sm">
                    <button class="btn btn-sm btn-light me-2 rounded-circle border" onclick="backToUserList()">
                        <i class="fa-solid fa-arrow-left text-success"></i>
                    </button>
                    <div class="fw-bold text-success text-truncate" id="staffChattingWithName">Khách hàng</div>
                </div>
                <div class="flex-grow-1 overflow-auto p-3" id="staffChatContent"></div>
                <div class="p-2 bg-white border-top">
                    <div class="input-group">
                        <input type="text" id="staffChatInput" class="form-control" placeholder="Nhập tin nhắn..." onkeypress="handleStaffEnter(event)">
                        <button class="btn btn-success" onclick="sendStaffMsgWidget()"><i class="fa-solid fa-paper-plane"></i></button>
                    </div>
                </div>
            </div>
        </c:if>

        <%-- ================= TRƯỜNG HỢP 2: GIAO DIỆN KHÁCH HÀNG ================= --%>
        <c:if test="${sessionScope.permission != 1}">
            <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                <h6 class="m-0 fw-bold"><i class="fa-solid fa-headset me-2"></i>Chat Với Quán</h6>
                <button type="button" class="btn-close btn-close-white" onclick="toggleGlobalChat()"></button>
            </div>
            <div class="card-body bg-light overflow-auto flex-grow-1" id="customerChatContent">
                <div class="text-center text-muted mt-5"><small>Đang tải tin nhắn...</small></div>
            </div>
            <div class="card-footer bg-white p-2">
                <div class="input-group">
                    <input type="text" id="customerChatInput" class="form-control border-0" placeholder="Nhập tin nhắn..." onkeypress="handleCustomerEnter(event)">
                    <button class="btn btn-primary rounded-circle ms-2" onclick="sendCustomerMsgWidget()">
                        <i class="fa-solid fa-paper-plane"></i>
                    </button>
                </div>
            </div>
        </c:if>

    </div>

    <script>
        const chatWindow = document.getElementById('globalChatWindow');
        const isStaff = ${sessionScope.permission == 1};
        let chatPollInterval;
        let globalPollInterval; // Poll check tin mới khi đóng widget
        
        let currentChatUser = null;

        // --- GLOBAL POLLING (CHẠY NGẦM ĐỂ HIỆN CHẤM ĐỎ Ở NÚT CHÍNH) ---
        function checkNewMessagesBackground() {
            // Chỉ chạy khi widget đóng
            if (!chatWindow.classList.contains('d-none')) return; 

            if (isStaff) {
                fetch('${pageContext.request.contextPath}/chat?action=get_users')
                .then(res => res.text())
                .then(html => {
                    if (html.includes('UNREAD_FLAG')) {
                        document.getElementById('globalChatBadge').classList.remove('d-none');
                    } else {
                        document.getElementById('globalChatBadge').classList.add('d-none');
                    }
                });
            } else {
                // Logic cho khách (check nếu tin cuối là của staff và chưa xem? - Ở mức độ này tạm bỏ qua hoặc poll load message)
            }
        }
        setInterval(checkNewMessagesBackground, 5000);


        function toggleGlobalChat() {
            if (chatWindow.classList.contains('d-none')) {
                chatWindow.classList.remove('d-none');
                document.getElementById('globalChatBadge').classList.add('d-none'); // Tắt chấm đỏ nút chính
                
                if (isStaff) {
                    loadWidgetUserList(); 
                    chatPollInterval = setInterval(loadWidgetUserList, 3000); 
                } else {
                    loadCustomerMessages();
                    chatPollInterval = setInterval(loadCustomerMessages, 3000);
                }
            } else {
                chatWindow.classList.add('d-none');
                clearInterval(chatPollInterval);
            }
        }

        // ================= LOGIC NHÂN VIÊN =================
        function loadWidgetUserList() {
            if(currentChatUser) return; // Đang chat thì không reload list
            
            fetch('${pageContext.request.contextPath}/chat?action=get_users')
                .then(res => res.text())
                .then(html => {
                    const fixedHtml = html.replace(/openChat/g, 'openWidgetChat');
                    document.getElementById('staffUserList').innerHTML = fixedHtml;
                });
        }

        function openWidgetChat(email, name) {
            currentChatUser = email;
            // Hiển thị Tên thay vì Email trên header chat
            document.getElementById('staffChattingWithName').innerText = name; 
            
            document.getElementById('staffUserListView').classList.add('d-none'); 
            document.getElementById('staffUserListView').classList.remove('d-flex');
            
            document.getElementById('staffChatDetailView').classList.remove('d-none'); 
            document.getElementById('staffChatDetailView').classList.add('d-flex');

            clearInterval(chatPollInterval);
            loadStaffChatMessages();
            chatPollInterval = setInterval(loadStaffChatMessages, 3000);
        }

        function backToUserList() {
            currentChatUser = null;
            document.getElementById('staffChatDetailView').classList.add('d-none');
            document.getElementById('staffChatDetailView').classList.remove('d-flex');

            document.getElementById('staffUserListView').classList.remove('d-none');
            document.getElementById('staffUserListView').classList.add('d-flex');

            clearInterval(chatPollInterval);
            loadWidgetUserList();
            chatPollInterval = setInterval(loadWidgetUserList, 3000);
        }

        function loadStaffChatMessages() {
            if(!currentChatUser) return;
            const contentDiv = document.getElementById('staffChatContent');
            
            fetch('${pageContext.request.contextPath}/chat?action=load&targetUser=' + currentChatUser)
                .then(res => res.text())
                .then(html => {
                    const isAtBottom = contentDiv.scrollHeight - contentDiv.scrollTop <= contentDiv.clientHeight + 50;
                    contentDiv.innerHTML = html;
                    if(isAtBottom) contentDiv.scrollTop = contentDiv.scrollHeight;
                });
        }

        function sendStaffMsgWidget() {
            const input = document.getElementById('staffChatInput');
            const msg = input.value.trim();
            if(!msg || !currentChatUser) return;

            fetch('${pageContext.request.contextPath}/chat?action=send', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'message=' + encodeURIComponent(msg) + '&receiver=' + currentChatUser
            }).then(() => {
                input.value = '';
                loadStaffChatMessages();
                const contentDiv = document.getElementById('staffChatContent');
                contentDiv.scrollTop = contentDiv.scrollHeight;
            });
        }
        function handleStaffEnter(e) { if(e.key === 'Enter') sendStaffMsgWidget(); }

        // ================= LOGIC KHÁCH HÀNG =================
        function loadCustomerMessages() {
            const contentDiv = document.getElementById('customerChatContent');
            fetch('${pageContext.request.contextPath}/chat?action=load')
                .then(res => res.text())
                .then(html => {
                    const isAtBottom = contentDiv.scrollHeight - contentDiv.scrollTop <= contentDiv.clientHeight + 50;
                    contentDiv.innerHTML = html;
                    if(isAtBottom) contentDiv.scrollTop = contentDiv.scrollHeight;
                });
        }

        function sendCustomerMsgWidget() {
            const input = document.getElementById('customerChatInput');
            const msg = input.value.trim();
            if(!msg) return;

            fetch('${pageContext.request.contextPath}/chat?action=send', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'message=' + encodeURIComponent(msg)
            }).then(() => {
                input.value = '';
                loadCustomerMessages();
                const contentDiv = document.getElementById('customerChatContent');
                contentDiv.scrollTop = contentDiv.scrollHeight;
            });
        }
        function handleCustomerEnter(e) { if(e.key === 'Enter') sendCustomerMsgWidget(); }

    </script>
</c:if>