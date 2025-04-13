package com.example.demo.model;

import java.util.Date;
import org.springframework.format.annotation.DateTimeFormat;

public class Plan {
    private String id;
    private String name;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date startDate;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date endDate;

    private String content;
    private int points;
    private String status; // todo, edited, ongoing, completed, expired
    private String childId = "1"; // default childId
    private String parentId = "1"; // default parentId

    // Constructors
    public Plan() {}

    public Plan(String name, Date startDate, Date endDate, String content, int points, String status) {
        this.name = name;
        this.startDate = startDate;
        this.endDate = endDate;
        this.content = content;
        this.points = points;
        this.status = status;
    }

    // Getters and Setters
    public String getId(){
        return id;
    }

    public void setId(String id){
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public String getContent() {
        return content;
    }

    public void setContents(String content) {
        this.content = content;
    }

    public int getPoints() {
        return points;
    }

    public void setPoints(int points) {
        this.points = points;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getChildId() {
        return childId;
    }

    public void setChildId(String childId) {
        this.childId = childId;
    }

    public String getParentId() {
        return parentId;
    }

    public void setParentId(String parentId) {
        this.parentId = parentId;
    }
}
