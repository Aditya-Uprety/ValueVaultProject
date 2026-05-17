<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Management - ValueVault</title>
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
            <a href="${pageContext.request.contextPath}/users">Users</a>
            <a href="${pageContext.request.contextPath}/items" class="active">Items</a>
            <a href="${pageContext.request.contextPath}/bids">Bids</a>
            <a href="${pageContext.request.contextPath}/upload">Upload Item</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <!-- Delete Item Confirmation Modal -->
    <div class="modal-overlay" id="deleteItemModal">
        <div class="modal-box">
            <div class="modal-icon" style="font-size:32px;color:var(--red);font-weight:300;">&#x2715;</div>
            <h3>Remove Item</h3>
            <p>Are you sure you want to permanently remove <strong id="modalItemName"></strong> from the vault?<br>
               All pending bids on this item will also be deleted. This cannot be undone.</p>
            <div class="modal-actions">
                <button class="btn-cancel-modal" onclick="closeModal()">Cancel</button>
                <button class="btn-confirm-delete" onclick="submitDelete()">Yes, Remove</button>
            </div>
        </div>
    </div>

    <!-- Hidden delete form — submitted by JS -->
    <form id="deleteItemForm" action="${pageContext.request.contextPath}/items" method="post" style="display:none;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="itemId" id="deleteItemId" value="">
    </form>

    <div class="container">
        <div class="page-header">
            <div>
                <h1>Inventory Management</h1>
                <p>Manage auction assets and view current statuses.</p>
            </div>
            <a href="${pageContext.request.contextPath}/upload" class="btn-primary"
               style="width:auto;padding:10px 20px;">Add New Item</a>
        </div>

        <% if ("sold".equals(request.getParameter("error"))) { %>
            <div class="error-msg" style="margin-bottom:20px;">
                This item cannot be removed because it has already been sold (an accepted bid exists).
            </div>
        <% } %>

        <div class="table-container">
            <div style="padding:16px 20px;border-bottom:1px solid var(--border);
                        display:flex;justify-content:space-between;align-items:center;">
                <h3 style="font-size:15px;font-weight:600;">All Listings</h3>
                <form action="${pageContext.request.contextPath}/items" method="get"
                      style="display:flex;gap:8px;">
                    <div class="search-box">
                        <input type="text" name="search" placeholder="Search items..."
                               style="width:220px;"
                               value="<%= request.getAttribute("search") != null ? request.getAttribute("search") : "" %>">
                    </div>
                    <button type="submit" class="btn-search" style="border-radius:var(--radius-sm);">🔍</button>
                </form>
            </div>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Item Name</th>
                        <th>Current Bid</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    List<Map<String, Object>> items = (List<Map<String, Object>>) request.getAttribute("items");
                    if (items != null && !items.isEmpty()) {
                        for (Map<String, Object> item : items) {
                            String st = (String) item.get("status");
                    %>
                        <tr>
                            <td><strong><%= item.get("title") %></strong></td>
                            <td class="highlight">Rs <%= String.format("%,.0f", item.get("current_price")) %></td>
                            <td><span class="status <%= st %>"><%= st %></span></td>
                            <td>
                                <div style="display:flex;gap:8px;align-items:center;">
                                    <a href="${pageContext.request.contextPath}/bids?itemId=<%= item.get("id") %>"
                                       class="btn-primary small">View Bids</a>
                                    <%-- Only allow delete if item is not already sold --%>
                                    <% if (!"ended".equals(st)) { %>
                                        <button class="btn-delete"
                                                onclick="openDeleteModal(<%= item.get("id") %>, '<%= ((String)item.get("title")).replace("'", "\\'") %>')">
                                            Remove
                                        </button>
                                    <% } else { %>
                                        <span style="font-size:12px;color:var(--text-muted);">Sold — cannot remove</span>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <%
                        }
                    } else {
                    %>
                        <tr>
                            <td colspan="4" class="no-data">
                                No items found.
                                <% if (request.getAttribute("search") != null) { %>
                                    <a href="${pageContext.request.contextPath}/items"
                                       style="color:var(--gold);margin-left:8px;">Clear search</a>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        function openDeleteModal(itemId, itemName) {
            document.getElementById('deleteItemId').value = itemId;
            document.getElementById('modalItemName').textContent = '"' + itemName + '"';
            document.getElementById('deleteItemModal').classList.add('active');
        }

        function closeModal() {
            document.getElementById('deleteItemModal').classList.remove('active');
            document.getElementById('deleteItemId').value = '';
        }

        function submitDelete() {
            document.getElementById('deleteItemForm').submit();
        }

        // Close modal if clicking outside the box
        document.getElementById('deleteItemModal').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
    </script>
</body>
</html>
