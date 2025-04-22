package com.moviebooking.repository;

import com.moviebooking.model.Booking;

public interface BookingRepository {
    Booking saveBooking(Booking booking);
}
