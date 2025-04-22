package com.moviebooking.repository;


import com.moviebooking.model.Show;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class ShowRepositoryImpl implements ShowRepository {

    private final JdbcTemplate jdbcTemplate;

    public ShowRepositoryImpl(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<Show> findShowsByMovieId(Long movieId) {
        String sql = "SELECT show_id, movie_id, screen_id, show_date, start_time, end_time " +
                     "FROM shows WHERE movie_id = ? AND show_date >= CURDATE()";
        return jdbcTemplate.query(sql, new Object[]{movieId}, this::mapRowToShow);
    }

    private Show mapRowToShow(ResultSet rs, int rowNum) throws SQLException {
        return new Show(
            rs.getLong("show_id"),
            rs.getLong("movie_id"),
            rs.getLong("screen_id"),
            rs.getDate("show_date").toLocalDate(),
            rs.getTime("start_time").toLocalTime(),
            rs.getTime("end_time").toLocalTime()
        );
    }
}
