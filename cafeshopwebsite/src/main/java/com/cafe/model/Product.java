package com.cafe.model;

public class Product {
    private int id;
    private String name;
    private String description;
    private double price;
    private String category;
    private String imageUrl;
    private int status; // 1: Đang bán, 0: Tạm hết

    public Product() {}

    // Constructor cũ (6 tham số) - Có thể giữ lại hoặc xóa tùy ý
    public Product(int id, String name, String description, double price, String category, String imageUrl) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.price = price;
        this.category = category;
        this.imageUrl = imageUrl;
        this.status = 1; // Mặc định là đang bán
    }

    // --- BỔ SUNG: Constructor 7 tham số (để khớp với StaffServlet) ---
    public Product(int id, String name, String description, double price, String category, String imageUrl, int status) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.price = price;
        this.category = category;
        this.imageUrl = imageUrl;
        this.status = status;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    
    // --- BỔ SUNG: Getter/Setter cho status ---
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}