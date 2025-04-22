package com.moviebooking.model;
import java.math.BigDecimal;

import java.time.LocalDateTime;


public class Booking extends BaseEntity {
    private Long userId;
    private Long showId;
    private BigDecimal totalAmount;
    private String bookingReference;

    public Booking(Long id, Long userId, Long showId, BigDecimal totalAmount, String bookingReference) {
        setId(id);
        this.userId = userId;
        this.showId = showId;
        this.totalAmount = totalAmount;
        this.bookingReference = bookingReference;
    }

    // Getters and Setters
    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getShowId() {
        return showId;
    }

    public void setShowId(Long showId) {
        this.showId = showId;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getBookingReference() {
        return bookingReference;
    }

    public void setBookingReference(String bookingReference) {
        this.bookingReference = bookingReference;
    }
}
