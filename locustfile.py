from locust import HttpLocust, TaskSet, task

class WebsiteTasks(TaskSet):
    #def on_start(self):
    #    self.client.post("/", {
    #        "username": "test_user",
    #        "password": ""
    #    })
    
    @task
    def index(self):
        self.client.post("/dynamic/echo", "hello!")
        
    @task
    def pid(self):
        self.client.get("/dynamic/pid")
    
    @task
    def info(self):
        self.client.get("/dynamic/info")

    @task
    def count_to_ten(self):
        self.client.get("/dynamic/count-to-ten")

    @task
    def client_ip(self):
        self.client.get("/dynamic/client-ip")

class WebsiteUser(HttpLocust):
    task_set = WebsiteTasks
    min_wait = 5
    max_wait = 15
