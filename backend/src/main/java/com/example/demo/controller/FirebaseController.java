package com.example.demo.controller;

import com.example.demo.model.Plan;
import com.example.demo.service.FirebaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/firebase")
public class FirebaseController {

    @Autowired
    private FirebaseService firebaseService;

    // 新增 Plan 資料
    @PostMapping("/plans/add")
    public ResponseEntity<String> addPlan(@RequestBody Plan plan) {
        try {
            validatePlan(plan);
            String planId = firebaseService.addPlan(plan); // 呼叫 FirebaseService 中的 addPlan 方法
            return ResponseEntity.ok("Plan added with ID: " + planId);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error adding plan: " + e.getMessage());
        }
    }

    // 更新 Plan 資料
    @PutMapping("/plans/update/{planId}")
    public ResponseEntity<String> updatePlan(
            @PathVariable String planId,
            @RequestBody Plan plan) {
        try {
            validatePlan(plan);
            String result = firebaseService.updatePlan(planId, plan); // 呼叫 FirebaseService 中的 updatePlan 方法
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error updating plan: " + e.getMessage());
        }
    }

    // 刪除計畫
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deletePlan(@PathVariable String id){
        try {
            firebaseService.deletePlan(id);
            return ResponseEntity.ok("Plan deleted successfully");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error deleting plan: " + e.getMessage());
        }
    }

    // 根據 Date 獲取計畫
    @GetMapping("/date/{date}")
    public ResponseEntity<Object> getPlanByData(@PathVariable String date) {
        try {
            return ResponseEntity.ok(firebaseService.getPlansByDate(date));
        } catch (Exception e) {
            e.printStackTrace();  // 打印錯誤堆棧
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    private void validatePlan(Plan plan) {
        if (plan.getName().equals("") || plan.getName() == null || plan.getName().isEmpty()) {
            throw new IllegalArgumentException("Plan name cannot be empty");
        }
        if (plan.getStartDate() == null) {
            throw new IllegalArgumentException("Start date is required");
        }
        if (plan.getEndDate() == null) {
            throw new IllegalArgumentException("End date is required");
        }
        if (plan.getStartDate().after(plan.getEndDate())) {
            throw new IllegalArgumentException("Start date cannot be after end date");
        }
    }

    /* 暫未使用到
    // 獲取所有計畫
    @GetMapping
    public List<Plan> getAllPlans() throws Exception {
        return firebaseService.getAllPlans();
    }

    // 根據 ID 獲取計畫
    @GetMapping("/id/{id}")
    public ResponseEntity<Object> getPlanById(@PathVariable String id) {
        try {
            Plan plan = firebaseService.getPlanById(id);
            return ResponseEntity.ok(plan);
        } catch (Exception e) {
            // Log the error details
            e.printStackTrace();  // 打印錯誤堆疊追蹤
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }
    */
}
