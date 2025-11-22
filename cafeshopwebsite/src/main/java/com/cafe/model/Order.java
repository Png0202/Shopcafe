package com.cafe.model;

import java.sql.Timestamp;

public class Order {
    private int id;
    private String userEmail;
    private Timestamp orderDate;
    private String address;
    private double totalPrice;
    private String status;

    // Constructor không tham số
    public Order() {}

    // Constructor đầy đủ
    public Order(int id, String userEmail, Timestamp orderDate, String address, double totalPrice, String status) {
        this.id = id;
        this.userEmail = userEmail;
        this.orderDate = orderDate;
        this.address = address;
        this.totalPrice = totalPrice;
        this.status = status;
    }

    // Getters và Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public Timestamp getOrderDate() { return orderDate; }
    public void setOrderDate(Timestamp orderDate) { this.orderDate = orderDate; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}