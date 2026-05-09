package org.example.myproject.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import org.example.myproject.dao.UserDao;
import org.example.myproject.model.User;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req,
                          HttpServletResponse resp)
            throws ServletException, IOException {

        // ===== GET PARAMETERS =====
        String name =
                req.getParameter("name");

        String email =
                req.getParameter("email");

        String password =
                req.getParameter("password");

        String confirmPassword =
                req.getParameter("confirmPassword");

        // ===== VALIDATION =====
        if (name == null || email == null ||
                password == null ||

                name.trim().isEmpty() ||
                email.trim().isEmpty() ||
                password.trim().isEmpty()) {

            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);

            resp.setContentType("text/plain");

            resp.getWriter().write(
                    "All fields are required!"
            );

            return;
        }

        // ===== PASSWORD MATCH =====
        if (!password.equals(confirmPassword)) {

            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);

            resp.setContentType("text/plain");

            resp.getWriter().write(
                    "Passwords do not match!"
            );

            return;
        }

        // ===== DAO =====
        UserDao dao = new UserDao();

        // ===== CHECK EMAIL =====
        if (dao.emailExists(email)) {

            resp.setStatus(HttpServletResponse.SC_CONFLICT);

            resp.setContentType("text/plain");

            resp.getWriter().write(
                    "Email already registered!"
            );

            return;
        }

        // ===== CREATE USER =====
        User user = new User();

        user.setName(name);

        user.setEmail(email);

        user.setPassword(password);

        // ===== SAVE USER =====
        boolean isSaved = dao.saveUser(user);

        // ===== RESPONSE =====
        if (isSaved) {

            // IMPORTANT:
            // RETURN TEXT RESPONSE FOR FETCH API
            resp.setStatus(HttpServletResponse.SC_OK);

            resp.setContentType("text/plain");

            resp.getWriter().write("success");

        } else {

            resp.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            resp.setContentType("text/plain");

            resp.getWriter().write(
                    "Registration failed. Please try again."
            );
        }
    }
}