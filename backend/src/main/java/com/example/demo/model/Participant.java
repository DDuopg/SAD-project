package com.example.demo.model;

abstract class Participant {
    private String id;
    private String account;
    private String password;
    private String name;
    // Constructors
    public Participant() {}

    public Participant(String name, String account, String password) {
        this.name = name;
        this.account = account;
        this.password = password;
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

    public String getAccount() {
        return account;
    }

    public void setAccount(String account) {
        this.account = account;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.account = password;
    }
}
