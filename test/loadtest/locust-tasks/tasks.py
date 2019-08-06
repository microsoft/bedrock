#!/usr/bin/env python

from locust import HttpLocust, TaskSet, task

class ProductTaskSet(TaskSet):

    @task(1)
    def index(self):
        self.client.get("/productpage")


class ProductsLocust(HttpLocust):
    task_set = ProductTaskSet
