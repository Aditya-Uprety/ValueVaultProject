package com.valuevault.controllers;

import com.valuevault.model.Item;
import com.valuevault.model.ItemDAO;
import com.valuevault.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/shop")
public class ShopServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        // Admins have no business on the shop page
        User user = (User) session.getAttribute("user");
        if ("admin".equals(user.getRole())) {
            response.sendRedirect("admin-dashboard");
            return;
        }

        String search = request.getParameter("search");
        ItemDAO itemDAO = new ItemDAO();
        List<Item> items;

        if (search != null && !search.isEmpty()) {
            items = itemDAO.searchItems(search);
        } else {
            items = itemDAO.getAllActiveItems();
        }

        request.setAttribute("items", items);
        request.getRequestDispatcher("/WEB-INF/pages/shop.jsp").forward(request, response);
    }
}
