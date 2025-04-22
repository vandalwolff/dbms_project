package com.moviebooking.service;

import com.moviebooking.exception.BookingException;
import com.moviebooking.model.Booking;
import com.moviebooking.model.BookingRequest;
import com.moviebooking.model.Movie;
import com.moviebooking.model.Seat;
import com.moviebooking.model.Show;
import com.moviebooking.repository.BookingRepository;
import com.moviebooking.repository.MovieRepository;
import com.moviebooking.repository.SeatRepository;
import com.moviebooking.repository.ShowRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class BookingServiceImpl implements BookingService {
    private final MovieRepository movieRepository;
    private final ShowRepository showRepository;
    private final BookingRepository bookingRepository;
    private final SeatRepository seatRepository;
    private final JdbcTemplate jdbcTemplate;

    public BookingServiceImpl(MovieRepository movieRepository, ShowRepository showRepository,
                              BookingRepository bookingRepository, SeatRepository seatRepository,
                              JdbcTemplate jdbcTemplate) {
        this.movieRepository = movieRepository;
        this.showRepository = showRepository;
        this.bookingRepository = bookingRepository;
        this.seatRepository = seatRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<Movie> getAvailableMovies() {
        return movieRepository.findAvailableMovies();
    }

    @Override
    public List<Show> getShowtimes(Long movieId) {
        return showRepository.findShowsByMovieId(movieId);
    }

    @Override
    @Transactional
    public Booking bookTicket(BookingRequest bookingRequest) throws BookingException {
        // Existing booking logic (unchanged)
        List<Show> shows = showRepository.findShowsByMovieId(bookingRequest.getShowId());
        if (shows.isEmpty()) {
            throw new BookingException("Invalid show ID");
        }

        List<Seat> availableSeats = seatRepository.findAvailableSeats(bookingRequest.getShowId());
        for (Long seatId : bookingRequest.getSeatIds()) {
            boolean isAvailable = availableSeats.stream().anyMatch(seat -> seat.getId().equals(seatId));
            if (!isAvailable || !seatRepository.lockSeat(seatId)) {
                throw new BookingException("Seat " + seatId + " is not available");
            }
        }

        String bookingRef = "BK" + UUID.randomUUID().toString().substring(0, 8);
        Booking booking = new Booking(null, bookingRequest.getUserId(), bookingRequest.getShowId(),
                                     bookingRequest.getTotalAmount(), bookingRef);

        booking = bookingRepository.saveBooking(booking);

        for (Long seatId : bookingRequest.getSeatIds()) {
            String sql = "INSERT INTO booking_seats (booking_id, seat_id, price) VALUES (?, ?, ?)";
            jdbcTemplate.update(sql, booking.getId(), seatId,
                    bookingRequest.getTotalAmount().divide(BigDecimal.valueOf(bookingRequest.getSeatIds().size())));
        }

        return booking;
    }

    @Override
    public void deleteMovie(Long movieId) {
        movieRepository.deleteMovie(movieId);
    }
}