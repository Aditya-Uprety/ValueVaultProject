<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - ValueVault</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* ── Confirmation Modal ── */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,.65);
            z-index: 999;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.active { display: flex; }

        .modal-box {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 36px 32px;
            max-width: 420px;
            width: 92vw;
            box-shadow: 0 8px 40px rgba(0,0,0,.6);
            text-align: center;
        }

        .modal-icon { font-size: 42px; margin-bottom: 14px; }

        .modal-box h3 {
            font-family: 'Cinzel', serif;
            font-size: 20px;
            margin-bottom: 10px;
            color: var(--text-white);
        }

        .modal-box p {
            color: var(--text-muted);
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 24px;
        }

        .modal-box p strong { color: var(--gold); }

        .modal-actions { display: flex; gap: 12px; justify-content: center; }

        .modal-actions .btn-cancel-modal {
            flex: 1;
            padding: 10px;
            background: var(--bg-mid);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            color: var(--text-mid);
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
            font-size: 14px;
            font-weight: 500;
            transition: border-color .2s, color .2s;
        }
        .modal-actions .btn-cancel-modal:hover { border-color: var(--text-mid); color: var(--text-white); }

        .modal-actions .btn-confirm-delete {
            flex: 1;
            padding: 10px;
            background: var(--red);
            border: none;
            border-radius: var(--radius-sm);
            color: white;
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
            font-size: 14px;
            font-weight: 700;
            transition: opacity .2s;
        }
        .modal-actions .btn-confirm-delete:hover { opacity: .85; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-left">
            <a href="${pageContext.request.contextPath}/admin-dashboard" style="text-decoration:none;">
                <img src="${pageContext.request.contextPath}/images/logo.png"
                     alt="ValueVault" style="height:48px;width:auto;">
            </a>
        </div>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a>
            <a href="${pageContext.request.contextPath}/users" class="active">Users</a>
            <a href="${pageContext.request.contextPath}/items">Items</a>
            <a href="${pageContext.request.contextPath}/bids">Bids</a>
            <a href="${pageContext.request.contextPath}/upload">Upload Item</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <!-- Delete User Confirmation Modal -->
    <div class="modal-overlay" id="deleteUserModal">
        <div class="modal-box">
            <div class="modal-icon">⚠️</div>
            <h3>Delete User Account</h3>
            <p>You are about to permanently delete <strong id="modalUserName"></strong>'s account.<br>
               All their bids will also be removed. This action cannot be undone.</p>
            <div class="modal-actions">
                <button class="btn-cancel-modal" onclick="closeModal()">Cancel</button>
                <button class="btn-confirm-delete" onclick="submitDelete()">Yes, Delete</button>
            </div>
        </div>
    </div>

    <!-- Hidden delete form — submitted by JS -->
    <form id="deleteUserForm" action="${pageContext.request.contextPath}/users" method="post" style="display:none;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="userId" id="deleteUserId" value="">
    </form>

    <div class="container">
        <div class="page-header">
            <div>
                <h1>User Management</h1>
                <p>View and manage registered users, purchase history, and account status.</p>
            </div>
        </div>

        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>User Profile</th>
                        <th>Total Bids Placed</th>
                        <th>Total Spending (Accepted)</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    List<Map<String, Object>> users = (List<Map<String, Object>>) request.getAttribute("users");
                    if (users != null && !users.isEmpty()) {
                        for (Map<String, Object> user : users) {
                            String statusVal = user.get("status") != null
                                               ? user.get("status").toString().toLowerCase() : "active";
                    %>
                        <tr>
                            <td class="user-cell">
                                <div class="user-avatar">
                                    <%= ((String) user.get("name")).substring(0, 1).toUpperCase() %>
                                </div>
                                <div>
                                    <strong><%= user.get("name") %></strong>
                                    <div class="user-email"><%= user.get("email") %></div>
                                </div>
                            </td>
                            <td><%= user.get("total_purchases") %></td>
                            <td class="highlight">Rs <%= String.format("%,.2f", user.get("total_spending")) %></td>
                            <td>
                                <span class="status <%= statusVal %>"><%= user.get("status") %></span>
                            </td>
                            <td>
                                <!-- Styled modal trigger instead of plain confirm() -->
                                <button class="btn-delete"
                                        onclick="openDeleteModal(<%= user.get("id") %>, '<%= ((String)user.get("name")).replace("'", "\\'") %>')">
                                    🗑 Delete
                                </button>
                            </td>
                        </tr>
                    <%
                        }
                    } else {
                    %>
                        <tr>
                            <td colspan="5" class="no-data">No users found.</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        function openDeleteModal(userId, userName) {
            document.getElementById('deleteUserId').value = userId;
            document.getElementById('modalUserName').textContent = userName;
            document.getElementById('deleteUserModal').classList.add('active');
        }

        function closeModal() {
            document.getElementById('deleteUserModal').classList.remove('active');
            document.getElementById('deleteUserId').value = '';
        }

        function submitDelete() {
            document.getElementById('deleteUserForm').submit();
        }

        // Close modal if clicking outside the box
        document.getElementById('deleteUserModal').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
    </script>
</body>
</html>
