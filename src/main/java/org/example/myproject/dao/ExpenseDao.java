package org.example.myproject.dao;

import jakarta.persistence.*;
import org.example.myproject.model.Expense;
import org.example.myproject.model.User;

import java.util.List;

public class ExpenseDao {

    private static final EntityManagerFactory emf =
            Persistence.createEntityManagerFactory("myPU");

    // ========== ADD ==========
    public boolean addExpense(Expense expense) {
        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            em.getTransaction().begin();
            em.persist(expense);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em != null && em.getTransaction().isActive())
                em.getTransaction().rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null) em.close();
        }
    }

    // ========== GET ALL BY USER ==========
    public List<Expense> getExpensesByUser(int userId) {
        EntityManager em = emf.createEntityManager();
        List<Expense> list = em.createQuery(
                        "SELECT e FROM Expense e WHERE e.user.id = :uid ORDER BY e.date DESC",
                        Expense.class)
                .setParameter("uid", userId)
                .getResultList();
        em.close();
        return list;
    }

    // ========== DELETE ==========
    public boolean deleteExpense(int expenseId, int userId) {
        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            em.getTransaction().begin();
            Expense e = em.find(Expense.class, expenseId);
            if (e != null && e.getUser().getId() == userId) {
                em.remove(e);
                em.getTransaction().commit();
                return true;
            }
            em.getTransaction().rollback();
            return false;
        } catch (Exception e) {
            if (em != null && em.getTransaction().isActive())
                em.getTransaction().rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null) em.close();
        }
    }

    // ========== GET BY ID ==========
    public Expense getExpenseById(int id) {
        EntityManager em = emf.createEntityManager();
        Expense e = em.find(Expense.class, id);
        em.close();
        return e;
    }

    // ========== UPDATE ==========
    public boolean updateExpense(Expense expense) {
        EntityManager em = null;
        try {
            em = emf.createEntityManager();
            em.getTransaction().begin();
            Expense existing = em.find(Expense.class, expense.getId());
            if (existing != null) {
                existing.setDescription(expense.getDescription());
                existing.setAmount(expense.getAmount());
                existing.setCategory(expense.getCategory());
                existing.setType(expense.getType());
                existing.setDate(expense.getDate());
                em.merge(existing);
            }
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em != null && em.getTransaction().isActive())
                em.getTransaction().rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (em != null) em.close();
        }
    }
}