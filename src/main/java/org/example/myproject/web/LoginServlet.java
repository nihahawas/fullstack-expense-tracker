package org.example.myproject.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;


import org.example.myproject.dao.UserDao;
import org.example.myproject.model.User;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserDao dao;

    @Override
    public void init() {
        dao = new UserDao();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        // DEBUGGING
        System.out.println("========== LOGIN DEBUG ==========");
        System.out.println("EMAIL ENTERED: " + email);
        System.out.println("PASSWORD ENTERED: " + password);

        // Validation
        if (email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {

            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("text/plain");
            resp.getWriter().write("Email and password are required.");

            return;
        }

        // Check user from database
        User user = dao.getUser(email, password);

        System.out.println("USER FOUND: " + user);

        if (user != null) {

            System.out.println("LOGIN SUCCESSFUL");

            HttpSession session = req.getSession();
            session.setAttribute("user", user);

            // Redirect to dashboard
            resp.sendRedirect("dashboard.jsp");

        } else {

            System.out.println("LOGIN FAILED");

            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("text/plain");
            resp.getWriter().write("Invalid email or password.");
        }

        System.out.println("================================");
    }
}