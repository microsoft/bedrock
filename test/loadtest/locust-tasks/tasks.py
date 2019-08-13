#!/usr/bin/env python

from locust import HttpLocust, TaskSet, task

class HomeTaskSet(TaskSet):

    @task(1)
    def index(self):
        self.client.get("/")


class HomeLocust(HttpLocust):
    task_set = HomeTaskSet
