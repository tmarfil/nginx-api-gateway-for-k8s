The get-job REST api is running as a nodeport service:
http://jobs.local:30020/

The main HTML site is running as a nodeport service:
http://jobs.local:30010/

The main HTML site has embedded JavaScript to fetch a random job from the get-job REST api endpoint.
The endpoint has not been published yet and so this part will fail with "Error fetching job title"
