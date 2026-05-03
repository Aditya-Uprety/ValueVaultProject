package com.valuevault.model;

import java.sql.Timestamp;

public class Bid {
    private int id;
    private int userId;
    private int itemId;
    private double bidAmount;
    private String status; // pending, accepted, rejected
    private Timestamp createdAt;

    public Bid() {}

    public Bid(int userId, int itemId, double bidAmount, String status) {
        this.userId = userId;
        this.itemId = itemId;
        this.bidAmount = bidAmount;
        this.status = status;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }
    
    public double getBidAmount() { return bidAmount; }
    public void setBidAmount(double bidAmount) { this.bidAmount = bidAmount; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}