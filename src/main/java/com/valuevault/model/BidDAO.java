package com.valuevault.model;

import com.valuevault.config.DBConfig;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BidDAO {
    
    // Place a new bid
    public boolean placeBid(Bid bid) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "INSERT INTO bids (user_id, item_id, bid_amount, status) VALUES (?, ?, ?, 'pending')";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, bid.getUserId());
            ps.setInt(2, bid.getItemId());
            ps.setDouble(3, bid.getBidAmount());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all bids for a specific user
    public List<Bid> getBidsByUserId(int userId) {
        List<Bid> bids = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT * FROM bids WHERE user_id = ? ORDER BY created_at DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Bid bid = mapRowToBid(rs);
                bids.add(bid);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bids;
    }

    // Get all bids for a specific item (Admin)
    public List<Bid> getBidsByItemId(int itemId) {
        List<Bid> bids = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT * FROM bids WHERE item_id = ? ORDER BY created_at DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Bid bid = mapRowToBid(rs);
                bids.add(bid);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bids;
    }

    // Get all bids (Admin)
    public List<Bid> getAllBids() {
        List<Bid> bids = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT * FROM bids ORDER BY created_at DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Bid bid = mapRowToBid(rs);
                bids.add(bid);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bids;
    }

    // Get bid count for an item
    public int getBidCount(int itemId) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT COUNT(*) as count FROM bids WHERE item_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Accept bid (Admin)
    public boolean acceptBid(int bidId) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "UPDATE bids SET status = 'accepted' WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, bidId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Reject bid (Admin)
    public boolean rejectBid(int bidId) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "UPDATE bids SET status = 'rejected' WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, bidId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Helper method to map ResultSet to Bid
    private Bid mapRowToBid(ResultSet rs) throws SQLException {
        Bid bid = new Bid();
        bid.setId(rs.getInt("id"));
        bid.setUserId(rs.getInt("user_id"));
        bid.setItemId(rs.getInt("item_id"));
        bid.setBidAmount(rs.getDouble("bid_amount"));
        bid.setStatus(rs.getString("status"));
        bid.setCreatedAt(rs.getTimestamp("created_at"));
        return bid;
    }
}