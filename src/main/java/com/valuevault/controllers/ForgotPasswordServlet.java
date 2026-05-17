package com.valuevault.controllers;

import com.valuevault.model.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Handles the 3-step forgot password flow:
 *  Step 1 (GET /forgot-password)         → show email entry form
 *  Step 1 (POST, action=lookup)           → look up email, show security question
 *  Step 2 (POST, action=verify)           → verify answer, show new password form
 *  Step 3 (POST, action=reset)            → save new password, redirect to login
 */
@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Clear any previous session data for this flow
        HttpSession session = request.getSession();
        session.removeAttribute("fp_email");
        session.removeAttribute("fp_verified");
        request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        UserDAO userDAO = new UserDAO();
        HttpSession session = request.getSession();

        // user submitted email 
        if ("lookup".equals(action)) {
            String email = request.getParameter("email");
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Please enter your email address.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp").forward(request, response);
                return;
            }

            String question = userDAO.getSecurityQuestion(email.trim());
            if (question == null) {
                // Do not reveal whether email exists — show generic message
                request.setAttribute("error", "No account found with that email address.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp").forward(request, response);
                return;
            }

            // Store email in session temporarily for this flow
            session.setAttribute("fp_email", email.trim());
            request.setAttribute("step", "question");
            request.setAttribute("securityQuestion", question);
            request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp").forward(request, response);
            return;
        }

        // user submitted security answer 
        if ("verify".equals(action)) {
            String email = (String) session.getAttribute("fp_email");
            if (email == null) {
                response.sendRedirect("forgot-password");
                return;
            }

            String answer = request.getParameter("securityAnswer");
            if (answer == null || answer.trim().isEmpty()) {
                String question = userDAO.getSecurityQuestion(email);
                request.setAttribute("step", "question");
                request.setAttribute("securityQuestion", question);
                request.setAttribute("error", "Please enter your answer.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp").forward(request, response);
                return;
            }

            boolean correct = userDAO.verifySecurityAnswer(email, answer.trim());
            if (!correct) {
                String question = userDAO.getSecurityQuestion(email);
                request.setAttribute("step", "question");
                request.setAttribute("securityQuestion", question);
                request.setAttribute("error", "Incorrect answer. Please try again.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp").forward(request, response);
                return;
            }

            // Mark as verified 
            session.setAttribute("fp_verified", true);
            request.setAttribute("step", "reset");
            request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp").forward(request, response);
            return;
        }

        // user submitted new password 
        if ("reset".equals(action)) {
            String email    = (String) session.getAttribute("fp_email");
            Boolean verified = (Boolean) session.getAttribute("fp_verified");
            if (email == null || !Boolean.TRUE.equals(verified)) {
                response.sendRedirect("forgot-password");
                return;
            }

            String newPassword     = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (newPassword == null || newPassword.length() < 6) {
                request.setAttribute("step", "reset");
                request.setAttribute("error", "Password must be at least 6 characters.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("step", "reset");
                request.setAttribute("error", "Passwords do not match.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp").forward(request, response);
                return;
            }

            boolean ok = userDAO.resetPassword(email, newPassword);
            // Clean up session
            session.removeAttribute("fp_email");
            session.removeAttribute("fp_verified");

            if (ok) {
                response.sendRedirect("login?reset=true");
            } else {
                request.setAttribute("error", "Something went wrong. Please try again.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp").forward(request, response);
            }
        }
    }
}
