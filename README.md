## structure
  - frontend(flutter)
    - lib(code that we need to write) 
  - backend(Java)
    - src
      - main
        - java(code that we need to write)

## what do we need to build and run
- install docker
- in root of the project
  - cd frontend
    - docker build -t flutter-app .
    - docker run -p 3000:3000 flutter-app
  - cd backend
    - docker build -t your-spring-boot-app .
    - docker run -p 8080:8080 your-spring-boot-app 

you will see your web at localhost:3000
