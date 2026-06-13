package com.academy.model;

public class Student {

    private int studentId;
    private String usn;
    private String fullName;
    private String email;
    private int age;
    private int deptId;
    private int currentSem;
    private double cgpa;

    // ── Constructors ──────────────────────────────────────
    public Student() {}

    public Student(int studentId, String usn, String fullName,
                   String email, int age, int deptId,
                   int currentSem, double cgpa) {
        this.studentId  = studentId;
        this.usn        = usn;
        this.fullName   = fullName;
        this.email      = email;
        this.age        = age;
        this.deptId     = deptId;
        this.currentSem = currentSem;
        this.cgpa       = cgpa;
    }

    // ── Getters and Setters ───────────────────────────────
    public int getStudentId()          { return studentId; }
    public void setStudentId(int id)   { this.studentId = id; }

    public String getUsn()             { return usn; }
    public void setUsn(String usn)     { this.usn = usn; }

    public String getFullName()        { return fullName; }
    public void setFullName(String n)  { this.fullName = n; }

    public String getEmail()           { return email; }
    public void setEmail(String e)     { this.email = e; }

    public int getAge()                { return age; }
    public void setAge(int age)        { this.age = age; }

    public int getDeptId()             { return deptId; }
    public void setDeptId(int d)       { this.deptId = d; }

    public int getCurrentSem()         { return currentSem; }
    public void setCurrentSem(int s)   { this.currentSem = s; }

    public double getCgpa()            { return cgpa; }
    public void setCgpa(double cgpa)   { this.cgpa = cgpa; }
}