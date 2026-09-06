#!/bin/bash
set -e

# Config
FILE_SIZES=("1kb" "100kb" "1mb" "100mb")
VU_LEVELS=(10 100 1000)
REPETITIONS=3
DURATION="30s"
RAMP_UP="15s"
RAMP_DOWN="10s"
COOLDOWN=10

SINGLE_URL="http://localhost:8000"
DIST_URL="http://localhost:8001"

RESULTS_DIR="results"
LOGS_DIR="logs"

mkdir -p "$RESULTS_DIR"
mkdir -p "$LOGS_DIR"

LOG_FILE="$LOGS_DIR/run_log_$(date +%Y%m%d_%H%M%S).txt"

warm_up() {
    local url=$1
    for i in {1..5}; do
        curl -s -o /dev/null "$url" || true
    done
}

run_scenario() {
    local label=$1
    local base_url=$2

    for size in "${FILE_SIZES[@]}"; do
        for vu in "${VU_LEVELS[@]}"; do
            for rep in $(seq 1 $REPETITIONS); do

                echo "==============================================" | tee -a "$LOG_FILE"
                echo ">>> [$label] size=$size vus=$vu rep=$rep/$REPETITIONS" | tee -a "$LOG_FILE"
                echo "Waktu mulai: $(date)" | tee -a "$LOG_FILE"

                warm_up "${base_url}/files/${size}"

                k6 run \
                    -e FILE_SIZE="$size" \
                    -e VUS="$vu" \
                    -e BASE_URL="$base_url" \
                    -e DURATION="$DURATION" \
                    -e RAMP_UP="$RAMP_UP" \
                    -e RAMP_DOWN="$RAMP_DOWN" \
                    -e SCENARIO_LABEL="${label}_rep${rep}" \
                    test.js 2>&1 | tee -a "$LOG_FILE"

                echo "Waktu selesai: $(date)" | tee -a "$LOG_FILE"
                echo "Cooldown ${COOLDOWN}s sebelum lanjut..." | tee -a "$LOG_FILE"
                sleep "$COOLDOWN"

            done
        done
    done
}

echo "MULAI EKSPERIMEN: $(date)" | tee -a "$LOG_FILE"

echo "[STANDALONE]" | tee -a "$LOG_FILE"
run_scenario "single" "$SINGLE_URL"

echo "[DISTRIBUTED]" | tee -a "$LOG_FILE"
run_scenario "distributed" "$DIST_URL"

echo "SEMUA TEST SELESAI: $(date)" | tee -a "$LOG_FILE"
echo "Hasil tersimpan di folder: $RESULTS_DIR" | tee -a "$LOG_FILE"
echo "Log lengkap: $LOG_FILE" | tee -a "$LOG_FILE"
