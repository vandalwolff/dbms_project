package com.moviebooking.repository;


import com.moviebooking.model.Seat;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class SeatRepositoryImpl implements SeatRepository {

    private final JdbcTemplate jdbcTemplate;

    public SeatRepositoryImpl(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<Seat> findAvailableSeats(Long showId) {
        String sql = "SELECT s.seat_id, s.screen_id, s.seat_row, s.seat_number, s.seat_type, s.status " +
                     "FROM seats s " +
                     "JOIN shows sh ON s.screen_id = sh.screen_id " +
                     "WHERE sh.show_id = ? AND s.status = 'Available' " +
                     "AND s.seat_id NOT IN (SELECT seat_id FROM booking_seats bs JOIN bookings b ON bs.booking_id = b.booking_id WHERE b.show_id = ?)";
        return jdbcTemplate.query(sql, new Object[]{showId, showId}, this::mapRowToSeat);
    }

    @Override
    public boolean lockSeat(Long seatId) {
        String sql = "UPDATE seats SET status = 'Maintenance' WHERE seat_id = ? AND status = 'Available'";
        return jdbcTemplate.update(sql, seatId) > 0;
    }

    private Seat mapRowToSeat(ResultSet rs, int rowNum) throws SQLException {
        return new Seat(
            rs.getLong("seat_id"),
            rs.getLong("screen_id"),
            rs.getString("seat_row"),
            rs.getInt("seat_number"),
            rs.getString("seat_type"),
            rs.getString("status")
        );
    }
}
