package org.example.myproject.dao;


import jakarta.persistence.*;
import org.example.myproject.model.User;

import java.util.List;

import org.mindrot.jbcrypt.BCrypt;

public class UserDao {

    private static final EntityManagerFactory emf =
            Persistence.createEntityManagerFactory("myPU");

    // ================= SAVE =================
    public boolean saveUser(User user) {
        EntityManager em = null;

        try {
            em = emf.createEntityManager();
            em.getTransaction().begin();

            // 🔐 HASH PASSWORD BEFORE SAVING
            String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
            user.setPassword(hashedPassword);

            em.persist(user);

            em.getTransaction().commit();
            return true;

        } catch (Exception e) {
            if (em != null && em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            System.out.println("Error saving user: " + e.getMessage());
            return false;

        } finally {
            if (em != null) em.close();
        }
    }

    // ================= LOGIN =================
    public User getUser(String email, String password) {
        EntityManager em = null;

        try {
            em = emf.createEntityManager();

            // 🔥 FIND BY EMAIL ONLY
            List<User> users = em.createQuery(
                            "SELECT u FROM User u WHERE u.email = :e",
                            User.class)
                    .setParameter("e", email)
                    .getResultList();

            if (users.isEmpty()) return null;

            User user = users.get(0);

            // 🔐 CHECK HASHED PASSWORD
            if (BCrypt.checkpw(password, user.getPassword())) {
                return user;
            }

            return null;

        } catch (Exception e) {
            System.out.println("Login error: " + e.getMessage());
            return null;

        } finally {
            if (em != null) em.close();
        }
    }

    // ================= GET ALL =================
    public List<User> getAllUsers() {
        EntityManager em = emf.createEntityManager();
        List<User> list = em.createQuery("SELECT u FROM User u", User.class).getResultList();
        em.close();
        return list;
    }

    // ================= GET BY ID =================
    public User getUserById(int id) {
        EntityManager em = emf.createEntityManager();
        User user = em.find(User.class, id);
        em.close();
        return user;
    }

    // ================= UPDATE =================
    public void updateUser(User user) {

        EntityManager em = null;

        try {

            em = emf.createEntityManager();

            em.getTransaction().begin();

            // GET EXISTING USER FROM DATABASE
            User existingUser =
                    em.find(User.class, user.getId());

            if (existingUser != null) {

                // UPDATE NAME & EMAIL
                existingUser.setName(user.getName());

                existingUser.setEmail(user.getEmail());

                // UPDATE PASSWORD ONLY IF ENTERED
                if (user.getPassword() != null &&
                        !user.getPassword().trim().isEmpty()) {

                    String hashedPassword =
                            BCrypt.hashpw(
                                    user.getPassword(),
                                    BCrypt.gensalt()
                            );

                    existingUser.setPassword(hashedPassword);
                }

                em.merge(existingUser);
            }

            em.getTransaction().commit();

        } catch (Exception e) {

            if (em != null &&
                    em.getTransaction().isActive()) {

                em.getTransaction().rollback();
            }

            e.printStackTrace();

        } finally {

            if (em != null) {
                em.close();
            }
        }
    }

    // ================= EMAIL EXISTS =================
    public boolean emailExists(String email) {
        EntityManager em = null;

        try {
            em = emf.createEntityManager();

            Long count = em.createQuery(
                            "SELECT COUNT(u) FROM User u WHERE u.email = :e",
                            Long.class)
                    .setParameter("e", email)
                    .getSingleResult();

            return count > 0;

        } catch (Exception e) {
            System.out.println("Email check error: " + e.getMessage());
            return false;

        } finally {
            if (em != null) em.close();
        }
    }

    // ================= DELETE =================
    public void deleteUser(int id) {
        EntityManager em = emf.createEntityManager();
        em.getTransaction().begin();

        User user = em.find(User.class, id);
        if (user != null) {
            em.remove(user);
        }

        em.getTransaction().commit();
        em.close();
    }
}
