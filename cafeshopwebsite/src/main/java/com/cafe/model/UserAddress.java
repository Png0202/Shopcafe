package com.cafe.model;

public class UserAddress {
    private int id;
    private String userEmail;
    private String addressLine;
    private boolean isDefault;

    public UserAddress() {}
    
    public UserAddress(int id, String userEmail, String addressLine, boolean isDefault) {
        this.id = id;
        this.userEmail = userEmail;
        this.addressLine = addressLine;
        this.isDefault = isDefault;
    }

    // Getters và Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public String getAddressLine() { return addressLine; }
    public void setAddressLine(String addressLine) { this.addressLine = addressLine; }
    public boolean isDefault() { return isDefault; }
    public void setDefault(boolean isDefault) { this.isDefault = isDefault; }
}