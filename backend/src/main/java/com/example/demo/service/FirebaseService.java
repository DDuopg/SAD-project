package com.example.demo.service;

import com.example.demo.model.Plan;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.WriteResult;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.logging.Logger;
import java.util.List;
import java.util.Map;
import java.util.Date;
import java.util.HashMap;

@Service
public class FirebaseService {

    private static final Logger logger = Logger.getLogger(FirebaseService.class.getName());

    public String addPlan(Plan plan) throws Exception {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<DocumentReference> future = db.collection("plans").add(plan);
        return future.get().getId(); // 返回新文件的 ID
    }

    public String updatePlan(String planId, Plan plan) throws Exception {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection("plans").document(planId);
        


        // 使用相同的 planId 創建新的計畫
        ApiFuture<WriteResult> createFuture = docRef.set(plan);

        return "Updated at: " + createFuture.get().getUpdateTime();
    }

    public String deletePlan(String planId) throws Exception {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection("plans").document(planId);
        ApiFuture<WriteResult> future = docRef.delete();
        return "Deleted successfully.";
    }

    public Plan getPlanById(String planId) throws Exception {
        Firestore db = FirestoreClient.getFirestore();
        DocumentReference docRef = db.collection("plans").document(planId);
        ApiFuture<com.google.cloud.firestore.DocumentSnapshot> future = docRef.get();
        com.google.cloud.firestore.DocumentSnapshot document = future.get();
    
        if (document.exists()) {
            Plan plan = document.toObject(Plan.class);
            plan.setId(document.getId());
            return plan;
        } else {
            throw new Exception("Plan not found");
        }
    }

    public List<Plan> getPlansByDate(String date) throws Exception {
        Firestore db = FirestoreClient.getFirestore();
        
        ApiFuture<QuerySnapshot> future = db.collection("plans").get();
        QuerySnapshot querySnapshot = future.get();
        
        List<Plan> plans = new ArrayList<>();
        String currentDate = DateUtils.formatToDateString(new Date());

        for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
            Date startDate = document.getDate("startDate");
            Date endDate = document.getDate("endDate");
    
            // 格式化 Firestore 中的 startDate 和 endDate
            String formattedStartDate = DateUtils.formatToDateString(startDate);
            String formattedEndDate = DateUtils.formatToDateString(endDate);
            // 比對格式化後的日期
            if (date.compareTo(formattedStartDate) >= 0 && date.compareTo(formattedEndDate) <= 0) {
                Plan plan = document.toObject(Plan.class);
                plan.setId(document.getId());
                
                // 如果 endDate 已過期
                if (formattedEndDate.compareTo(currentDate) < 0 && !plan.getStatus().equals("expired")) {
                    plan.setStatus("expired"); // 修改狀態為 "expired"
                    updatePlan(plan.getId(), plan); // 同步更新 Firestore 資料庫中的 status 欄位
                }

                plans.add(plan);
            }
        }
        return plans;
    }
    

    public List<Plan> getAllPlans() throws Exception {
        Firestore db = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = db.collection("plans").get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        List<Plan> plans = new ArrayList<>();
        for (QueryDocumentSnapshot document : documents) {
            Plan plan = document.toObject(Plan.class);
            plan.setId(document.getId());
            plans.add(plan);
        }
        return plans;
    }


    public class DateUtils {
        public static String formatToDateString(Date date) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            return sdf.format(date); // 格式化為 "yyyy-MM-dd"
        }
    }
}
