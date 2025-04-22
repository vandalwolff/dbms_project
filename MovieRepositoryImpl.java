package com.moviebooking.repository;

import com.moviebooking.model.Movie;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class MovieRepositoryImpl implements MovieRepository {
    private static final Logger logger = LoggerFactory.getLogger(MovieRepositoryImpl.class);
    private final JdbcTemplate jdbcTemplate;

    public MovieRepositoryImpl(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        logger.info("Datasource: {}", jdbcTemplate.getDataSource());
    }

    @Override
    public List<Movie> findAvailableMovies() {
        String sql = "SELECT m.movie_id, m.title, m.genre, m.status, COALESCE(AVG(r.rating), 0) as average_rating " +
                     "FROM movies m " +
                     "LEFT JOIN reviews r ON m.movie_id = r.movie_id " +
                     "WHERE m.status = 'No Longer Showing' " + // Your current filter
                     "GROUP BY m.movie_id, m.title, m.genre, m.status " +
                     "ORDER BY average_rating DESC";
        logger.info("Executing query: {}", sql);
        try {
            List<Movie> movies = jdbcTemplate.query(sql, this::mapRowToMovie);
            logger.info("Found {} movies", movies.size());
            return movies;
        } catch (Exception e) {
            logger.error("Error executing query: {}", e.getMessage(), e);
            throw e;
        }
    }

    @Override
    public void deleteMovie(Long movieId) {
        String sql = "DELETE FROM movies WHERE movie_id = ?";
        logger.info("Executing delete query: {} with movieId: {}", sql, movieId);
        try {
            int rowsAffected = jdbcTemplate.update(sql, movieId);
            logger.info("Deleted {} movie(s) with movieId: {}", rowsAffected, movieId);
            if (rowsAffected == 0) {
                logger.warn("No movie found with movieId: {}", movieId);
            }
        } catch (Exception e) {
            logger.error("Error deleting movie with movieId: {}: {}", movieId, e.getMessage(), e);
            throw e;
        }
    }

    private Movie mapRowToMovie(ResultSet rs, int rowNum) throws SQLException {
        Movie movie = new Movie(
            rs.getLong("movie_id"),
            rs.getString("title"),
            rs.getString("genre"),
            rs.getString("status"),
            rs.getDouble("average_rating")
        );
        logger.debug("Mapped movie: {}", movie);
        return movie;
    }
}