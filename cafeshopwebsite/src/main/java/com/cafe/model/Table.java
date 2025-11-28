package com.cafe.model;
public class Table {
    private int id;
    private String name;
    private int status; // 0: Empty, 1: Occupied

    public Table(int id, String name, int status) {
        this.id = id;
        this.name = name;
        this.status = status;
    }
    // Getters & Setters...
    public int getId() { return id; }
    public String getName() { return name; }
    public int getStatus() { return status; }
}