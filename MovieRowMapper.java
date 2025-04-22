package com.moviebooking.repository;

import com.moviebooking.model.Movie;
import org.springframework.jdbc.core.RowMapper;
import java.sql.ResultSet;
import java.sql.SQLException;

public class MovieRowMapper implements RowMapper<Movie> {
    @Override
    public Movie mapRow(ResultSet rs, int rowNum) throws SQLException {
        Movie movie = new Movie(null, null, null, null, null);
        movie.setId(rs.getLong("movie_id"));
        movie.setTitle(rs.getString("title"));
        movie.setGenre(rs.getString("genre"));
        movie.setStatus(rs.getString("status"));
        movie.setAverageRating(rs.getDouble("average_rating"));
        return movie;
    }
}