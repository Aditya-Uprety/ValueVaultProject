package com.valuevault.controllers;

import com.valuevault.model.Item;
import com.valuevault.model.ItemDAO;
import com.valuevault.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // If admin visits /home, send them to their dashboard
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            if ("admin".equals(user.getRole())) {
                response.sendRedirect("admin-dashboard");
                return;
            }
        }

        ItemDAO itemDAO = new ItemDAO();
        List<Item> items = itemDAO.getAllActiveItems();
        request.setAttribute("items", items);
        request.getRequestDispatcher("/WEB-INF/pages/home.jsp").forward(request, response);
    }
}
