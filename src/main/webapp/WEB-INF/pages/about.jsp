<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.valuevault.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - ValueVault</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .about-section { margin-bottom: 28px; }
        .about-section h2 {
            font-family: 'Cinzel', serif;
            color: var(--gold);
            font-size: 20px;
            margin-bottom: 12px;
            border-bottom: 1px solid var(--border);
            padding-bottom: 8px;
        }
        .how-it-works-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-top: 14px;
        }
        .step-card {
            background: var(--bg-mid);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 20px 16px;
            text-align: center;
        }
        .step-card .step-num {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px; height: 36px;
            background: var(--gold-soft);
            border: 1px solid rgba(250,204,21,.3);
            border-radius: 50%;
            color: var(--gold);
            font-weight: 700;
            font-size: 16px;
            margin-bottom: 10px;
        }
        .step-card h3 { font-size: 14px; font-weight: 700; margin-bottom: 6px; }
        .step-card p  { color: var(--text-muted); font-size: 13px; line-height: 1.6; }
        .values-list  { list-style: none; padding: 0; margin: 0; }
        .values-list li {
            color: var(--text-mid);
            font-size: 15px;
            padding: 8px 0;
            border-bottom: 1px solid rgba(30,45,69,.5);
            display: flex;
            align-items: flex-start;
            gap: 10px;
            line-height: 1.6;
        }
        .values-list li:last-child { border-bottom: none; }
        .values-list li span.icon { color: var(--gold); flex-shrink: 0; }
    </style>
</head>
<body>
    <%
        User loggedUser = (User) session.getAttribute("user");
        boolean isAdmin = loggedUser != null && "admin".equals(loggedUser.getRole());
    %>
    <nav class="navbar">
        <div class="nav-left">
            <a href="${pageContext.request.contextPath}/home" style="text-decoration:none;">
                <img src="${pageContext.request.contextPath}/images/logo.png"
                     alt="ValueVault" style="height:48px; width:auto;">
            </a>
        </div>
        <div class="nav-right">
            <% if (loggedUser != null && isAdmin) { %>
                <a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a>
                <a href="${pageContext.request.contextPath}/users">Users</a>
                <a href="${pageContext.request.contextPath}/items">Items</a>
                <a href="${pageContext.request.contextPath}/bids">Bids</a>
                <a href="${pageContext.request.contextPath}/upload">Upload Item</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
            <% } else if (loggedUser != null) { %>
                <a href="${pageContext.request.contextPath}/home">Home</a>
                <a href="${pageContext.request.contextPath}/shop">Shop</a>
                <a href="${pageContext.request.contextPath}/my-bids">My Bids</a>
                <a href="${pageContext.request.contextPath}/about" class="active">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/home">Home</a>
                <a href="${pageContext.request.contextPath}/about" class="active">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
                <a href="${pageContext.request.contextPath}/login" class="btn-login">Login</a>
            <% } %>
        </div>
    </nav>

    <div class="about-container" style="max-width:900px;">

        <div style="text-align:center;margin-bottom:36px;">
            <img src="${pageContext.request.contextPath}/images/logo.png"
                 alt="ValueVault" style="height:72px;width:auto;margin-bottom:14px;opacity:.9;">
            <h1 style="margin-bottom:8px;">About ValueVault</h1>
            <p style="color:var(--text-muted);font-size:15px;max-width:560px;margin:0 auto;">
                Nepal's premier platform for authenticated, transparent high-value asset auctions — built on trust, powered by technology.
            </p>
        </div>

        <%-- Who We Are --%>
        <div class="about-section">
            <h2>Who We Are</h2>
            <p>ValueVault is an online auction platform specialising in high-value assets. From vintage watches and fine jewellery to rare collectibles and luxury electronics, we connect discerning buyers with exclusive sellers in a secure, transparent environment. Founded in 2026 and headquartered in Kathmandu, Nepal, ValueVault has quickly become the go-to destination for collectors and enthusiasts across the region.</p>
            <p style="margin-top:12px;">Our mission is simple: provide a trusted marketplace where every item is carefully listed, every bid is validated in real time, and every transaction is handled with integrity. We believe that buying and selling premium assets should be exciting — not stressful.</p>
        </div>

        <%-- How It Works --%>
        <div class="about-section">
            <h2>How ValueVault Works</h2>
            <p style="color:var(--text-muted);font-size:14px;margin-bottom:4px;">The entire auction process is straightforward and transparent — here's how it works from start to finish:</p>
            <div class="how-it-works-grid">
                <div class="step-card">
                    <div class="step-num">1</div>
                    <h3>Create an Account</h3>
                    <p>Register for free with your name, email, and a secure password. Set up a security question for account recovery.</p>
                </div>
                <div class="step-card">
                    <div class="step-num">2</div>
                    <h3>Browse the Vault</h3>
                    <p>Explore active auction listings on the Shop page. Each listing shows the current highest bid and full item details.</p>
                </div>
                <div class="step-card">
                    <div class="step-num">3</div>
                    <h3>Place Your Bid</h3>
                    <p>Click on any item and enter a bid amount higher than the current highest bid. You can update your bid at any time while the auction is active.</p>
                </div>
                <div class="step-card">
                    <div class="step-num">4</div>
                    <h3>Track Your Bids</h3>
                    <p>Visit "My Bids" to monitor all your active bids in real time. You'll see whether you are Winning, Outbid, or have already Won.</p>
                </div>
                <div class="step-card">
                    <div class="step-num">5</div>
                    <h3>Admin Review</h3>
                    <p>Our admin team reviews all bids and accepts the most suitable offer. When a bid is accepted, all other bids for that item are automatically rejected and the auction closes.</p>
                </div>
                <div class="step-card">
                    <div class="step-num">6</div>
                    <h3>Win &amp; Collect</h3>
                    <p>If your bid is accepted, your "My Bids" page will show a 🏆 Won status. Our team will reach out to arrange payment and collection of your item.</p>
                </div>
            </div>
        </div>

        <%-- Bidding Rules --%>
        <div class="about-section">
            <h2>Bidding Rules &amp; Guidelines</h2>
            <ul class="values-list">
                <li><span class="icon" style="color:var(--gold-dim);font-size:12px;">—</span>Each bid must be strictly higher than the current highest bid for that item.</li>
                <li><span class="icon" style="color:var(--gold-dim);font-size:12px;">—</span>You may update your existing pending bid on an item by placing a new higher amount — your previous bid will be replaced.</li>
                <li><span class="icon" style="color:var(--gold-dim);font-size:12px;">—</span>You can cancel a pending bid on an active auction at any time from the "My Bids" page, as long as the bid has not yet been accepted.</li>
                <li><span class="icon" style="color:var(--gold-dim);font-size:12px;">—</span>Once a bid is accepted by the admin, it cannot be cancelled. The auction closes and all other bids are automatically rejected.</li>
                <li><span class="icon" style="color:var(--gold-dim);font-size:12px;">—</span>Administrators do not participate in bidding. Admin accounts are restricted from accessing the shop or placing bids.</li>
                <li><span class="icon" style="color:var(--gold-dim);font-size:12px;">—</span>All bids and transactions are logged securely for full transparency.</li>
            </ul>
        </div>

        <%-- Our Values --%>
        <div class="about-section">
            <h2>Our Values</h2>
            <ul class="values-list">
                <li><span class="icon" style="color:var(--gold-dim);font-size:12px;">—</span><div><strong style="color:var(--text-white);">Security First</strong> — All passwords are stored using SHA-256 hashing. Sessions are strictly managed and role-based access control ensures that only authorised users reach the right parts of the platform.</div></li>
                <li><span class="icon" style="color:var(--gold-dim);font-size:12px;">—</span><div><strong style="color:var(--text-white);">Transparency</strong> — Every bid is visible to the admin, and bidders can see current highest bids in real time. There are no hidden fees or surprise outcomes.</div></li>
                <li><span class="icon" style="color:var(--gold-dim);font-size:12px;">—</span><div><strong style="color:var(--text-white);">Fairness</strong> — When a winning bid is accepted, all competing bids are automatically and immediately rejected. No bid can be accepted twice on the same item.</div></li>
                <li><span class="icon" style="color:var(--gold-dim);font-size:12px;">—</span><div><strong style="color:var(--text-white);">Trust</strong> — We only list verified, genuine assets. Our admin team personally reviews every listing before it goes live in the auction pool.</div></li>
            </ul>
        </div>

        <%-- Contact CTA --%>
        <div style="text-align:center;padding:28px 20px;background:var(--bg-mid);border:1px solid var(--border);border-radius:var(--radius-md);">
            <p style="color:var(--text-mid);font-size:15px;margin-bottom:14px;">Have a question or want to list a high-value asset? Get in touch with our team.</p>
            <a href="${pageContext.request.contextPath}/contact" class="btn-primary" style="width:auto;padding:10px 28px;display:inline-flex;">Contact Us</a>
        </div>

    </div>
</body>
</html>
