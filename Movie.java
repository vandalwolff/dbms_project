package com.moviebooking.model;
public class Movie extends BaseEntity {
    private String title;
    private String genre;
    private String status;
    private Double averageRating;

    public Movie(Long id, String title, String genre, String status, Double averageRating) {
        setId(id);
        this.title = title;
        this.genre = genre;
        this.status = status;
        this.averageRating = averageRating;
    }

    // Getters and Setters
    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(Double averageRating) {
        this.averageRating = averageRating;
    }
}
