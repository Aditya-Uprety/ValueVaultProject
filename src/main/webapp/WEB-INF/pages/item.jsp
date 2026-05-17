<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.valuevault.model.Item" %>
<%@ page import="com.valuevault.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Item Details - ValueVault</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%
        User loggedUser = (User) session.getAttribute("user");
        boolean isAdmin  = loggedUser != null && "admin".equals(loggedUser.getRole());
    %>
    <nav class="navbar">
        <div class="nav-left">
            <a href="${pageContext.request.contextPath}/home" style="text-decoration:none;">
                <img src="${pageContext.request.contextPath}/images/logo.png"
                     alt="ValueVault" style="height:48px;width:auto;">
            </a>
        </div>
        <div class="nav-right">
            <% if (isAdmin) { %>
                <a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a>
                <a href="${pageContext.request.contextPath}/users">Users</a>
                <a href="${pageContext.request.contextPath}/items">Items</a>
                <a href="${pageContext.request.contextPath}/bids">Bids</a>
                <a href="${pageContext.request.contextPath}/upload">Upload Item</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/home">Home</a>
                <a href="${pageContext.request.contextPath}/shop">Shop</a>
                <a href="${pageContext.request.contextPath}/my-bids">My Bids</a>
                <a href="${pageContext.request.contextPath}/about">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
            <% } %>
        </div>
    </nav>

    <div class="container">
        <%
        Item item     = (Item) request.getAttribute("item");
        Integer bidCount = (Integer) request.getAttribute("bidCount");
        if (bidCount == null) bidCount = 0;
        boolean auctionEnded = item != null && "ended".equals(item.getStatus());

        if (item != null) {
        %>
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/shop">Shop</a>
                <span class="breadcrumb-sep">›</span>
                <span><%= item.getTitle() %></span>
            </div>

            <% if (auctionEnded) { %>
                <div class="auction-ended-banner">
                    This auction has ended. The winning bid was
                    <strong>Rs <%= String.format("%,.0f", item.getCurrentBid()) %></strong>.
                </div>
            <% } %>

            <% if (request.getAttribute("error") != null) { %>
                <div class="error-msg" style="max-width:700px;margin:0 auto 16px;"><%= request.getAttribute("error") %></div>
            <% } %>

            <div class="item-detail-layout">
                <!-- Left: Image -->
                <div class="detail-image-section">
                    <div class="main-image">
                        <% if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) { %>
                            <img src="${pageContext.request.contextPath}/images/<%= item.getImageUrl() %>"
                                 alt="<%= item.getTitle() %>"
                                 style="width:100%;height:100%;object-fit:cover;border-radius:inherit;">
                        <% } else { %>
                            <div class="placeholder-img-large" style="font-size:14px;font-weight:700;color:var(--gold-dim);letter-spacing:3px;opacity:.35;">VALUEVAULT</div>
                        <% } %>
                    </div>
                </div>

                <!-- Right: Details -->
                <div class="detail-info-section">
                    <div class="detail-header">
                        <span class="lot-badge">LOT #<%= item.getId() %></span>
                        <% if (auctionEnded) { %>
                            <span class="status ended" style="margin-left:8px;">Auction Ended</span>
                        <% } else { %>
                            <span class="status active" style="margin-left:8px;">Active</span>
                        <% } %>
                        <h1><%= item.getTitle() %></h1>
                    </div>

                    <div class="bid-stats">
                        <div class="stat-box">
                            <span class="stat-label">Starting Price</span>
                            <span class="stat-value">Rs <%= String.format("%,.0f", item.getStartingPrice()) %></span>
                        </div>
                        <div class="stat-box highlight-box">
                            <span class="stat-label"><%= auctionEnded ? "Final Bid" : "Current Highest Bid" %></span>
                            <span class="stat-value">Rs <%= String.format("%,.2f", item.getCurrentBid()) %></span>
                            <span class="bid-count"><%= bidCount %> Bid<%= bidCount != 1 ? "s" : "" %></span>
                        </div>
                    </div>

                    <% if (!auctionEnded) { %>
                    <!-- Bid form — only shown while auction is active -->
                    <!-- onsubmit confirmation popup before placing bid -->
                    <div class="bid-form">
                        <h3>Place a Bid</h3>
                        <form id="bidForm" action="${pageContext.request.contextPath}/item" method="post"
                              onsubmit="return confirmBid();">
                            <input type="hidden" name="itemId" value="<%= item.getId() %>">
                            <div class="bid-input-group">
                                <input type="number" id="bidAmount" name="bidAmount" step="1"
                                       min="<%= (long)(item.getCurrentBid() + 1) %>"
                                       value="<%= (long)(item.getCurrentBid() + 100) %>" required>
                                <span class="min-bid">Min: Rs <%= String.format("%,.0f", item.getCurrentBid() + 1) %></span>
                            </div>
                            <button type="submit" class="btn-primary">Place Bid</button>
                        </form>
                        <p class="terms-note">By placing a bid, you agree to the <a href="#" onclick="showTerms(); return false;">Terms &amp; Conditions</a>.</p>
                    </div>
                    <% } else { %>
                    <!-- Ended state -->
                    <div class="bid-form" style="text-align:center;padding:28px 20px;">
                        <div style="font-size:32px;color:var(--text-muted);margin-bottom:12px;font-weight:300;">&#x2715;</div>
                        <h3 style="margin-bottom:8px;">Auction Closed</h3>
                        <p style="color:var(--text-muted);font-size:14px;">Bidding for this item has ended.</p>
                        <a href="${pageContext.request.contextPath}/shop"
                           class="btn-primary" style="margin-top:16px;display:inline-flex;width:auto;padding:10px 24px;">
                            Browse Active Auctions
                        </a>
                    </div>
                    <% } %>

                    <!-- Description -->
                    <div class="description-section" style="margin-top:16px;">
                        <h3>Item Description</h3>
                        <p><%= item.getDescription() %></p>
                    </div>
                </div>
            </div>
        <% } else { %>
            <div class="error-msg" style="max-width:500px;margin:60px auto;">Item not found.</div>
        <% } %>
    </div>

    <script>
        // Confirmation popup showing bid amount before submitting
        function confirmBid() {
            var amount = document.getElementById('bidAmount').value;
            if (!amount) return false;
            var formatted = 'Rs ' + parseFloat(amount).toLocaleString('en-IN', {maximumFractionDigits: 0});
            return confirm(
                'Confirm your bid of ' + formatted + '?\n\n' +
                'Once placed, your bid cannot be cancelled if it is accepted by the admin.'
            );
        }
    	
        function showTerms() {
            alert(
                "Terms & Conditions\n\n" +
                "By placing a bid on ValueVault, you agree to the following:\n\n" +
                "1. All bids are binding once accepted by the admin.\n" +
                "2. Bids cannot be cancelled after acceptance.\n" +
                "3. The highest accepted bid wins the auction.\n" +
                "4. Payment must be completed within 3 business days of winning.\n" +
                "5. ValueVault reserves the right to cancel any auction at any time.\n\n" +
                "A copy of the full Terms & Conditions has been sent to your registered email address."
            );
        }
    </script>
</body>
</html>
