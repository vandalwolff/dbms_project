package com.moviebooking.controller;

     import com.moviebooking.model.Movie;
     import com.moviebooking.model.Booking;
     import com.moviebooking.model.BookingRequest;
     import com.moviebooking.model.Show;
     import com.moviebooking.service.BookingService;
     import com.moviebooking.exception.BookingException;
     import org.springframework.beans.factory.annotation.Autowired;
     import org.springframework.http.ResponseEntity;
     import org.springframework.stereotype.Controller;
     import org.springframework.ui.Model;
     import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

     @Controller
     @RequestMapping("/api/bookings")
     public class BookingController {
         @Autowired
         private BookingService bookingService;

         @GetMapping("/")
public String getHomePage(Model model) {
    List<Movie> movies = bookingService.getAvailableMovies();
    model.addAttribute("movies", movies != null ? movies : new ArrayList<>());
    model.addAttribute("bookingRequest", new BookingRequest());
    return "views/index";
}

         @GetMapping("/movies")
         public ResponseEntity<List<Movie>> getAvailableMovies() {
             List<Movie> movies = bookingService.getAvailableMovies();
             return ResponseEntity.ok(movies);
         }

         @GetMapping("/showtimes/{movieId}")
         public ResponseEntity<List<Show>> getShowtimes(@PathVariable Long movieId) {
             List<Show> shows = bookingService.getShowtimes(movieId);
             return ResponseEntity.ok(shows);
         }

         @PostMapping("/tickets")
         public ResponseEntity<Booking> bookTicket(@ModelAttribute BookingRequest bookingRequest) throws BookingException {
             Booking booking = bookingService.bookTicket(bookingRequest);
             return ResponseEntity.ok(booking);
         }

         @DeleteMapping("/movies/{movieId}")
         public ResponseEntity<String> deleteMovie(@PathVariable Long movieId) {
             bookingService.deleteMovie(movieId);
             return ResponseEntity.ok("Movie with ID " + movieId + " deleted successfully");
         }
     }