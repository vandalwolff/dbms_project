package com.moviebooking.repository;
import com.moviebooking.model.Show;

import java.util.List;

public interface ShowRepository {
    List<Show> findShowsByMovieId(Long movieId);
}
