package com.valuevault.controllers;

import com.valuevault.model.User;
import com.valuevault.model.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name            = request.getParameter("name");
        String email           = request.getParameter("email");
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String secQuestion     = request.getParameter("securityQuestion");
        String secAnswer       = request.getParameter("securityAnswer");

        // Validate name: letters and spaces only
        if (name == null || name.trim().isEmpty() || !name.trim().matches("[a-zA-Z ]+")) {
            request.setAttribute("error", "Name must contain letters only.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Validate email format
        if (email == null || !email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            request.setAttribute("error", "Please enter a valid email address.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Validate password length
        if (password == null || password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Validate passwords match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Validate security question selected
        if (secQuestion == null || secQuestion.trim().isEmpty()) {
            request.setAttribute("error", "Please select a security question.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Validate security answer provided
        if (secAnswer == null || secAnswer.trim().isEmpty()) {
            request.setAttribute("error", "Please provide an answer to the security question.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        User user = new User(name.trim(), email.trim(), password, "user");
        user.setSecurityQuestion(secQuestion.trim());
        user.setSecurityAnswer(secAnswer.trim());

        UserDAO userDAO = new UserDAO();

        if (userDAO.registerUser(user)) {
            response.sendRedirect("login?registered=true");
        } else {
            request.setAttribute("error", "Registration failed. That email may already be registered.");
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
        }
    }
}
