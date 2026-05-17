package com.valuevault.model;

import com.valuevault.config.DBConfig;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ItemDAO {

    // Get all active items for Shop/Home
    public List<Item> getAllActiveItems() {
        List<Item> items = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT * FROM items WHERE status = 'active' ORDER BY created_at DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) items.add(mapRowToItem(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    // Search items by title or description (active only)
    public List<Item> searchItems(String keyword) {
        List<Item> items = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT * FROM items WHERE status = 'active' " +
                         "AND (title LIKE ? OR description LIKE ?) ORDER BY created_at DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) items.add(mapRowToItem(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    // Get single item by ID (any status)
    public Item getItemById(int id) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT * FROM items WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRowToItem(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Add new item (Admin) — stores image filename correctly
    public boolean addItem(Item item) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "INSERT INTO items (title, description, starting_price, current_bid, image_url, status) " +
                         "VALUES (?, ?, ?, ?, ?, 'active')";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, item.getTitle());
            ps.setString(2, item.getDescription());
            ps.setDouble(3, item.getStartingPrice());
            ps.setDouble(4, item.getStartingPrice()); // current_bid starts as starting_price
            ps.setString(5, item.getImageUrl());      // may be null 
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update current bid
    public boolean updateCurrentBid(int itemId, double newBid) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "UPDATE items SET current_bid = ? WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setDouble(1, newBid);
            ps.setInt(2, itemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Mark item as ended (called when admin accepts a bid)
    public boolean endItem(int itemId) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "UPDATE items SET status = 'ended' WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all items for Admin (all statuses)
    public List<Item> getAllItems() {
        List<Item> items = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT * FROM items ORDER BY created_at DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) items.add(mapRowToItem(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    // Helper: map ResultSet row → Item
    private Item mapRowToItem(ResultSet rs) throws SQLException {
        Item item = new Item();
        item.setId(rs.getInt("id"));
        item.setTitle(rs.getString("title"));
        item.setDescription(rs.getString("description"));
        item.setStartingPrice(rs.getDouble("starting_price"));
        item.setCurrentBid(rs.getDouble("current_bid"));
        item.setImageUrl(rs.getString("image_url"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }
}
