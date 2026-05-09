package org.example.myproject.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.myproject.dao.ExpenseDao;
import org.example.myproject.model.Expense;
import org.example.myproject.model.User;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/api/expenses/*")
public class ExpenseServlet extends HttpServlet {

    private ExpenseDao dao;

    @Override
    public void init() {
        dao = new ExpenseDao();
    }

    // ========== GET: list all ==========
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getSessionUser(req, resp);
        if (user == null) return;

        List<Expense> expenses = dao.getExpensesByUser(user.getId());

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < expenses.size(); i++) {
            Expense e = expenses.get(i);
            if (i > 0) json.append(",");
            json.append("{")
                    .append("\"id\":").append(e.getId()).append(",")
                    .append("\"description\":\"").append(escJson(e.getDescription())).append("\",")
                    .append("\"amount\":").append(e.getAmount()).append(",")
                    .append("\"category\":\"").append(escJson(e.getCategory())).append("\",")
                    .append("\"type\":\"").append(escJson(e.getType())).append("\",")
                    .append("\"date\":\"").append(e.getDate() != null ? e.getDate().toString() : "").append("\"")
                    .append("}");
        }
        json.append("]");

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(json.toString());
    }

    // ========== POST: add ==========
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getSessionUser(req, resp);
        if (user == null) return;

        String description = req.getParameter("description");
        String amountStr   = req.getParameter("amount");
        String category    = req.getParameter("category");
        String type        = req.getParameter("type");
        String dateStr     = req.getParameter("date");

        if (description == null || amountStr == null || category == null
                || type == null || dateStr == null) {
            resp.setStatus(400);
            resp.getWriter().write("All fields required");
            return;
        }

        try {
            Expense expense = new Expense();
            expense.setDescription(description.trim());
            expense.setAmount(Double.parseDouble(amountStr));
            expense.setCategory(category.trim());
            expense.setType(type.trim());
            expense.setDate(LocalDate.parse(dateStr));
            expense.setUser(user);

            boolean saved = dao.addExpense(expense);
            resp.setContentType("text/plain");
            resp.getWriter().write(saved ? "success" : "error");

        } catch (Exception e) {
            resp.setStatus(400);
            resp.getWriter().write("Invalid data: " + e.getMessage());
        }
    }

    // ========== DELETE ==========
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getSessionUser(req, resp);
        if (user == null) return;

        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 1) {
            resp.setStatus(400);
            resp.getWriter().write("Missing id");
            return;
        }

        int id = Integer.parseInt(pathInfo.substring(1));
        boolean deleted = dao.deleteExpense(id, user.getId());
        resp.setContentType("text/plain");
        resp.getWriter().write(deleted ? "success" : "error");
    }

    // ========== PUT: update ==========
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getSessionUser(req, resp);
        if (user == null) return;

        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 1) {
            resp.setStatus(400); return;
        }

        int expenseId = Integer.parseInt(pathInfo.substring(1));

        String body = new String(req.getInputStream().readAllBytes());
        java.util.Map<String, String> params = parseBody(body);

        try {
            Expense expense = new Expense();
            expense.setId(expenseId);
            expense.setDescription(params.get("description"));
            expense.setAmount(Double.parseDouble(params.get("amount")));
            expense.setCategory(params.get("category"));
            expense.setType(params.get("type"));
            expense.setDate(LocalDate.parse(params.get("date")));
            expense.setUser(user);

            boolean updated = dao.updateExpense(expense);
            resp.setContentType("text/plain");
            resp.getWriter().write(updated ? "success" : "error");

        } catch (Exception e) {
            resp.setStatus(400);
            resp.getWriter().write("Invalid data: " + e.getMessage());
        }
    }

    // ========== HELPERS ==========
    private User getSessionUser(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("Not logged in");
            return null;
        }
        return (User) session.getAttribute("user");
    }

    private java.util.Map<String, String> parseBody(String body) {
        java.util.Map<String, String> map = new java.util.HashMap<>();
        for (String pair : body.split("&")) {
            String[] kv = pair.split("=", 2);
            if (kv.length == 2) {
                try {
                    map.put(java.net.URLDecoder.decode(kv[0], "UTF-8"),
                            java.net.URLDecoder.decode(kv[1], "UTF-8"));
                } catch (Exception ignored) {}
            }
        }
        return map;
    }

    private String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}