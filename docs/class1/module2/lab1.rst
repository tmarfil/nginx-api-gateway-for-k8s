Task 01: Create API Service in Kubernetes
=========================================

Change to the task_01 directory.

.. code-block:: bash

   cd task_01

There are two K8s manifests in this directory.

- The `jobs.yaml` manifest is for the jobs-api service. This is our toy API to demonstrate NGINX Plus App Protect as an API Gateway.
- The `main.yaml` manifest is for the  jobs.local web application. This application will call the jobs-api service from the client browser and render the results in the client browser.

View the service manifests.

.. code-block:: bash

   bat jobs.yaml
   bat main.yaml

Apply the manifests to create the NodePort services.

.. code-block:: bash

   k apply -f jobs.yaml
   k apply -f main.yaml

Confirm the NodePort services were created.

.. code-block:: bash

   k get svc

From the URL bar of the web browser, connect to the "eclectic-jobs" NodePort service API: ``http://job.local:30020``.
Press the [F5] key to make new requests to the "ecletic-jobs" API.
The eclectic-jobs API returns a random job title in JSON format.

.. image:: images/01_eclectic-jobs_browser.jpg
  :scale: 50%

From the URL bar of the web browser, connect to the "myapp" NodePort service web application: ``http://jobs.local:30010``.
Press the [F5] key to make new requests of the "myapp" web application.
The "myapp" web application is attempting to fetch a random job title from the (non-existant) ``https://jobs.local/get-job`` API endpoint.

.. image:: images/02_error_fetching_browser.jpg
  :scale: 50%

To fix the broken HTTP route, we need to add TLS (changing the HTTP scheme from HTTP to HTTPS) and route ``/get-job`` to the "ecelctic-jobs" API.

