<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Item - ValueVault</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-left">
            <a href="${pageContext.request.contextPath}/home" style="text-decoration:none;">
    			<img src="${pageContext.request.contextPath}/images/logo.png" 
         			alt="ValueVault" style="height:48px; width:auto;">
			</a>
        </div>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a>
            <a href="${pageContext.request.contextPath}/users">Users</a>
            <a href="${pageContext.request.contextPath}/items">Items</a>
            <a href="${pageContext.request.contextPath}/bids">Bids</a>
            <a href="${pageContext.request.contextPath}/upload" class="active">Upload Item</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="upload-container">
        <div class="upload-card">
            <div class="upload-left">
                <div style="font-size:64px;margin-bottom:20px;opacity:.6;">🛡</div>
                <h2>New Listing</h2>
                <p>Add a new high-value asset to the vault. Ensure all details are accurate for prospective bidders.</p>
            </div>

            <div class="upload-right">
                <h2>Upload Item</h2>
                <p class="subtitle">Enter the item details carefully. This information will be visible to all verified users in the auction pool.</p>

                <% if (request.getAttribute("error") != null) { %>
                    <div class="error-msg"><%= request.getAttribute("error") %></div>
                <% } %>

                <form action="${pageContext.request.contextPath}/upload" method="post"
                      enctype="multipart/form-data">
                    <div class="form-group">
                        <label>Title</label>
                        <input type="text" name="title" placeholder="e.g., Rolex Submariner 1998" required>
                    </div>

                    <div class="form-group">
                        <label>Starting Price (Rs)</label>
                        <input type="number" name="price" step="1" min="1"
                               placeholder="Enter starting price" required>
                    </div>

                    <div class="form-group">
                        <label>Description</label>
                        <textarea name="description" rows="4"
                                  placeholder="Provide a detailed description of the item's condition, history, and specifications..."
                                  required></textarea>
                    </div>

                    <div class="form-group">
                        <label>Item Image (optional)</label>
                        <div class="upload-area">
                            <span class="upload-icon">☁</span>
                            <p>Click to select or drag and drop</p>
                            <p class="small-text">PNG, JPG, GIF up to 10MB</p>
                            <input type="file" name="image" accept="image/*" style="margin-top:10px;">
                        </div>
                    </div>

                    <div class="upload-actions">
                        <a href="${pageContext.request.contextPath}/items" class="btn-cancel">Cancel</a>
                        <button type="submit" class="btn-primary">⊕ Submit to Vault</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
