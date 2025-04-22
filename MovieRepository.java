package com.moviebooking.repository;

import com.moviebooking.model.Movie;
import java.util.List;

public interface MovieRepository {
    List<Movie> findAvailableMovies();
    void deleteMovie(Long movieId); 
}