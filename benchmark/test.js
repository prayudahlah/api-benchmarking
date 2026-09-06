import http from 'k6/http';
import { check } from 'k6';
import { Trend, Counter } from 'k6/metrics';

const fileLatency = new Trend('file_download_latency', true);
const successCounter = new Counter('successful_downloads');
const failCounter = new Counter('failed_downloads');
const bytesReceived = new Counter('total_bytes_received');

const FILE_SIZE = __ENV.FILE_SIZE || '1kb';
const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';
const VUS = parseInt(__ENV.VUS) || 100;
const DURATION = __ENV.DURATION || '5m';
const RAMP_UP = __ENV.RAMP_UP || '15s';
const RAMP_DOWN = __ENV.RAMP_DOWN || '10s';

export const options = {
    scenarios: {
        steady_load: {
            executor: 'ramping-vus',
            startVUs: 0,
            stages: [
                { duration: RAMP_UP, target: VUS },
                { duration: DURATION, target: VUS },
                { duration: RAMP_DOWN, target: 0 },
            ],
            gracefulRampDown: '10s',
        },
    },
};

export default function() {
    const url = `${BASE_URL}/files/${FILE_SIZE}`;
    const res = http.get(url, {
        timeout: '120s',
        responseType: 'none',
    });

    const ok = check(res, {
        'status is 200': (r) => r.status === 200,
    });

    if (ok) {
        successCounter.add(1);
        fileLatency.add(res.timings.duration);
        const len = parseInt(res.headers['Content-Length'] || '0', 10);
        bytesReceived.add(len);
    } else {
        failCounter.add(1);
    }
}

export function handleSummary(data) {
    const filename = `results/result_${FILE_SIZE}_${VUS}vu_${__ENV.SCENARIO_LABEL || 'single'}.json`;
    return {
        [filename]: JSON.stringify(data, null, 2),
        stdout: '',
    };
}
