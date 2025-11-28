package com.cafe.model;

public class CartItem {
    private int id;
    private int productId;
    private String productName;
    private double price;
    private String imageUrl;
    private int quantity;
    private String note;

    // Constructor rỗng (Bắt buộc phải có để dùng Setter)
    public CartItem() {}

    // Constructor đầy đủ (Tùy chọn)
    public CartItem(int id, int productId, String productName, double price, String imageUrl, int quantity, String note) {
        this.id = id;
        this.productId = productId;
        this.productName = productName;
        this.price = price;
        this.imageUrl = imageUrl;
        this.quantity = quantity;
        this.note = note;
    }

    // --- GETTERS AND SETTERS (Rất quan trọng) ---
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    // Phương thức tính tổng tiền (Quan trọng để hiển thị Thành tiền)
    public double getTotalPrice() {
        return this.price * this.quantity;
    }
}