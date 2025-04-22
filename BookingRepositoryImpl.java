package com.moviebooking.repository;

import com.moviebooking.model.Booking;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;

@Repository
public class BookingRepositoryImpl implements BookingRepository {

    private final JdbcTemplate jdbcTemplate;

    public BookingRepositoryImpl(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public Booking saveBooking(Booking booking) {
        String sql = "INSERT INTO bookings (user_id, show_id, booking_date, payment_status, booking_status, total_amount, final_amount, booking_reference) " +
                     "VALUES (?, ?, NOW(), 'Pending', 'Confirmed', ?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setLong(1, booking.getUserId());
            ps.setLong(2, booking.getShowId());
            ps.setBigDecimal(3, booking.getTotalAmount());
            ps.setBigDecimal(4, booking.getTotalAmount());
            ps.setString(5, booking.getBookingReference());
            return ps;
        }, keyHolder);

        @SuppressWarnings("null")
        Long newId = keyHolder.getKey().longValue();
        booking.setId(newId);
        return booking;
    }
}
