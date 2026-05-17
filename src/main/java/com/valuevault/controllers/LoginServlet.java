package com.valuevault.controllers;

import com.valuevault.model.User;
import com.valuevault.model.UserDAO;
import com.valuevault.model.UserDAO.LoginResult;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email");
        String password = request.getParameter("password");

        UserDAO     userDAO = new UserDAO();
        LoginResult result  = userDAO.loginUser(email, password);

        if (result.isSuccess()) {
            User user = result.getUser();
            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            if ("admin".equals(user.getRole())) {
                response.sendRedirect("admin-dashboard");
            } else {
                response.sendRedirect("home");
            }
        } else {
            // Pass the specific error message (wrong password, locked, system error)
            request.setAttribute("error", result.getErrorMessage());
            // Preserve the email so the user doesn't have to retype it
            request.setAttribute("emailValue", email);
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
        }
    }
}
