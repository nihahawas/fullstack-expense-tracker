package org.example.myproject.web;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

import org.example.myproject.dao.UserDao;
import org.example.myproject.model.User;

@WebServlet({"/users", "/delete", "/edit", "/update", "/insert", "/new"})
public class UserServlet extends HttpServlet {

    private UserDao dao;

    public void init() {
        dao = new UserDao();
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getServletPath();

        try {
            switch (action) {

                case "/new":
                    showForm(req, resp);
                    break;

                case "/insert":
                    insertUser(req, resp);
                    break;

                case "/delete":
                    deleteUser(req, resp);
                    break;

                case "/edit":
                    editUser(req, resp);
                    break;

                case "/update":
                    updateUser(req, resp);
                    break;

                default:
                    listUsers(req, resp);
                    break;
            }

        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("error.jsp").forward(req, resp);
        }
    }

    // ================= LIST =================
    private void listUsers(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<User> users = dao.getAllUsers();

        req.setAttribute("users", users);
        req.getRequestDispatcher("user-list.jsp").forward(req, resp);
    }

    // ================= NEW =================
    private void showForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.getRequestDispatcher("user-form.jsp").forward(req, resp);
    }

    // ================= INSERT =================
    private void insertUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        // 🔥 VALIDATION
        if (name == null || name.isEmpty() ||
                email == null || email.isEmpty() ||
                password == null || password.isEmpty()) {

            req.setAttribute("error", "All fields are required!");
            req.getRequestDispatcher("user-form.jsp").forward(req, resp);
            return;
        }

        // 🔥 CHECK DUPLICATE EMAIL
        if (dao.emailExists(email)) {
            req.setAttribute("error", "Email already exists!");
            req.getRequestDispatcher("user-form.jsp").forward(req, resp);
            return;
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(password); // hashed in DAO

        dao.saveUser(user);

        resp.sendRedirect("users");
    }

    // ================= DELETE =================
    private void deleteUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        int id = Integer.parseInt(req.getParameter("id"));

        dao.deleteUser(id);

        resp.sendRedirect("users");
    }

    // ================= EDIT =================
    private void editUser(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = Integer.parseInt(req.getParameter("id"));

        User user = dao.getUserById(id);

        if (user == null) {
            req.setAttribute("error", "User not found");
            req.getRequestDispatcher("error.jsp").forward(req, resp);
            return;
        }

        // 🔥 DO NOT SEND PASSWORD TO JSP
        user.setPassword("");

        req.setAttribute("user", user);
        req.getRequestDispatcher("user-form.jsp").forward(req, resp);
    }

    // ================= UPDATE =================
    private void updateUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        int id = Integer.parseInt(req.getParameter("id"));
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (name.isEmpty() || email.isEmpty()) {
            req.setAttribute("error", "Name and Email required!");
            req.getRequestDispatcher("user-form.jsp").forward(req, resp);
            return;
        }

        User user = new User();
        user.setId(id);
        user.setName(name);
        user.setEmail(email);

        // 🔥 ONLY UPDATE PASSWORD IF PROVIDED
        if (password != null && !password.isEmpty()) {
            user.setPassword(password);
        }

        dao.updateUser(user);

        resp.sendRedirect("users");
    }
}