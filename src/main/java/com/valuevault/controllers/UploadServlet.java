package com.valuevault.controllers;

import com.valuevault.model.Item;
import com.valuevault.model.ItemDAO;
import com.valuevault.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.*;

@WebServlet("/upload")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize       = 1024 * 1024 * 10, // 10 MB
    maxRequestSize    = 1024 * 1024 * 15  // 15 MB
)
public class UploadServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        User currentUser = (User) session.getAttribute("user");
        if (!"admin".equals(currentUser.getRole())) {
            response.sendRedirect("home");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/pages/upload.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        User currentUser = (User) session.getAttribute("user");
        if (!"admin".equals(currentUser.getRole())) {
            response.sendRedirect("home");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String title       = request.getParameter("title");
        String description = request.getParameter("description");
        String price       = request.getParameter("price");

        // Validation
        if (title == null || title.trim().isEmpty() ||
            description == null || description.trim().isEmpty() ||
            price == null || price.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("/WEB-INF/pages/upload.jsp").forward(request, response);
            return;
        }

        double priceValue;
        try {
            priceValue = Double.parseDouble(price);
            if (priceValue <= 0) {
                request.setAttribute("error", "Price must be greater than 0.");
                request.getRequestDispatcher("/WEB-INF/pages/upload.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price format.");
            request.getRequestDispatcher("/WEB-INF/pages/upload.jsp").forward(request, response);
            return;
        }

        // Handle image upload
        String savedFileName = null;
        Part filePart = request.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = originalName.contains(".")
                ? originalName.substring(originalName.lastIndexOf('.'))
                : ".jpg";
            savedFileName = System.currentTimeMillis() + ext;

            // Save to <webapp-root>/images/
            String uploadDir = getServletContext().getRealPath("") + File.separator + "images";
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            try (InputStream in = filePart.getInputStream();
                 OutputStream out = new FileOutputStream(new File(dir, savedFileName))) {
                byte[] buf = new byte[8192];
                int len;
                while ((len = in.read(buf)) != -1) out.write(buf, 0, len);
            }
        }

        Item item = new Item();
        item.setTitle(title.trim());
        item.setDescription(description.trim());
        item.setStartingPrice(priceValue);
        item.setCurrentBid(priceValue);
        item.setImageUrl(savedFileName); // null if no image uploaded
        item.setStatus("active");

        ItemDAO itemDAO = new ItemDAO();
        if (itemDAO.addItem(item)) {
            response.sendRedirect("items");
        } else {
            request.setAttribute("error", "Failed to upload item. Please try again.");
            request.getRequestDispatcher("/WEB-INF/pages/upload.jsp").forward(request, response);
        }
    }
}
