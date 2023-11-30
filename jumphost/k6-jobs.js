import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
    vus: 10,
    duration: '30s',
};

let rateLimitReached = false;

export default function () {
    if (rateLimitReached) {
        sleep(0.5); // Slow down if rate limit is reached
    }

    // Setting request parameters, including the Authorization header and the option to ignore TLS certificate validation
    const params = {
        headers: {
            "Authorization": "Bearer..." 
            },
        insecureSkipTLSVerify: true
    };

    let res = http.get('https://jobs.local/get-job', params);

    if (res.status === 429) {
        rateLimitReached = true;
        sleep(1); // Increase sleep time or implement other logic
    }

    check(res, {
        'is status 200': (r) => r.status === 200,
    });
}
