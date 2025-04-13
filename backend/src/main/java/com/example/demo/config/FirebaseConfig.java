package com.example.demo.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.google.firebase.cloud.FirestoreClient;
import com.google.cloud.firestore.Firestore;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    public FirebaseConfig() throws IOException {
        InputStream serviceAccount = getClass().getClassLoader().getResourceAsStream("saproject-3a060-firebase-adminsdk-rh04m-fbceaa8ca1.json");
        if (serviceAccount == null) {
            throw new IOException("Firebase configuration file not found in classpath.");
        }


        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                //.setDatabaseUrl("https://saproject-3a060.firebaseio.com") // Replace with your database URL
                .build();

        if (FirebaseApp.getApps().isEmpty()) {
            FirebaseApp.initializeApp(options);
        }
    }

    // 這裡可以提供 FirestoreClient 實例給 Spring Boot 注入
    public Firestore firestoreClient() {
        return FirestoreClient.getFirestore();
    }
}
