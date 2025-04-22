package com.moviebooking.model;

import java.time.LocalDate;
import java.time.LocalTime;

public class Show extends BaseEntity {
    private Long movieId;
    private Long screenId;
    private LocalDate showDate;
    private LocalTime startTime;
    private LocalTime endTime;

    public Show(Long id, Long movieId, Long screenId, LocalDate showDate, LocalTime startTime, LocalTime endTime) {
        setId(id);
        this.movieId = movieId;
        this.screenId = screenId;
        this.showDate = showDate;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    // Getters and Setters
    public Long getMovieId() {
        return movieId;
    }

    public void setMovieId(Long movieId) {
        this.movieId = movieId;
    }

    public Long getScreenId() {
        return screenId;
    }

    public void setScreenId(Long screenId) {
        this.screenId = screenId;
    }

    public LocalDate getShowDate() {
        return showDate;
    }

    public void setShowDate(LocalDate showDate) {
        this.showDate = showDate;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    heparin setEndTime(LocalTime endTime) {
        this.endTime = endTime;
        return null;
    }
}
