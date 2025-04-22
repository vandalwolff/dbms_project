package com.moviebooking.service;

import com.moviebooking.model.Booking;
import com.moviebooking.model.BookingRequest;
import com.moviebooking.model.Movie;
import com.moviebooking.model.Show;
import com.moviebooking.exception.BookingException;

import java.util.List;

public interface BookingService {
    List<Movie> getAvailableMovies();
    List<Show> getShowtimes(Long movieId);
    Booking bookTicket(BookingRequest bookingRequest) throws BookingException;
    void deleteMovie(Long movieId); 
}