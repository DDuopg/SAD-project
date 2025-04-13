package com.example.demo.model;

public class Child extends Participant{
    private int accumulatedPoints;
    private String parentId;

    // Constructors
    public Child() {
        this.accumulatedPoints = 0;
    }

    public Child(String name, String account, String password) {
        super( name, account, password );
        accumulatedPoints = 0;
    }

    // Getters and Setters
    public int getAccumulatedPoints(){
        return accumulatedPoints;
    }

    public void setAccumulatedPoints(int accumulatedPoints){
        this.accumulatedPoints = accumulatedPoints;
    }
    public String getParentId(){
        return parentId;
    }

    public void setId(String parentId){
        this.parentId = parentId;
    }
}
