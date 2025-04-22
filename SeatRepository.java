package com.moviebooking.repository;

import com.moviebooking.model.Seat;

import java.util.List;

public interface SeatRepository {
    List<Seat> findAvailableSeats(Long showId);
    boolean lockSeat(Long seatId);
}
