SELECT
  toStartOfHour (reqTimeSec) AS reqTimeSec,
  cliIP,
  asn,
  referer,
  reqPath,
  UA,
  Edge_IP,
  reqHost,
  country,
  state,
  city,
  statusCode,
  errorCode,
  rspContentType,
  cp,
  COUNT(*) AS cnt_all,
  countIf (
    statusCode > 199
    AND statusCode < 300
  ) AS cnt_2xx_status_code,
  countIf (
    statusCode > 399
    AND statusCode < 500
  ) AS cnt_4xx_status_code,
  countIf (
    statusCode > 499
    AND statusCode < 600
  ) AS cnt_5xx_status_code,
  countIf (cacheStatus = 0) as cnt_originHits,
  countIf (cacheStatus = 1) as cnt_edgeHits,
  cnt_edgeHits / count() * 100 as pct_offLoadHit,
  sum(totalBytes) as sum_totalBytes,
  sumIf (totalBytes, cacheStatus = 0) as sum_BytesOrigin,
  sumIf (totalBytes, cacheStatus = 1) as sum_BytesEdge,
  sum_BytesEdge / sum_totalBytes * 100 as pct_offLoadBytes,
  countIf (statusCode > 400) as cnt_errorHits,
  cnt_errorHits / count() * 100 as pct_errorRate,
  countIf (isNotNull (errorCode)) AS cnt_error,
  countIf (statusCode IS NOT NULL) AS cnt_status_code,
  uniq (reqPath) AS uniq_req_path,
  uniq (cliIP) AS uniq_client_ip,
  uniq (cliIP, UA) as uniq_session,
  quantiles (0.25, 0.5, 0.75, 0.9, 0.95, 0.99) (turnAroundTimeMSec) as quantiles_turnAroundTimeMSec,
  quantiles (0.25, 0.5, 0.75, 0.9, 0.95, 0.99) (transferTimeMSec) as quantiles_transferTimeMSec,
  quantilesIf (0.25, 0.5, 0.75, 0.9, 0.95, 0.99) (turnAroundTimeMSec, cacheStatus = 1) as quantiles_cached_turnAroundTimeMSec,
  quantilesIf (0.25, 0.5, 0.75, 0.9, 0.95, 0.99) (transferTimeMSec, cacheStatus = 1) as quantiles_cached_transferTimeMSec,
  quantilesIf (0.25, 0.5, 0.75, 0.9, 0.95, 0.99) (turnAroundTimeMSec, cacheStatus = 0) as quantiles_uncached_turnAroundTimeMSec,
  quantilesIf (0.25, 0.5, 0.75, 0.9, 0.95, 0.99) (transferTimeMSec, cacheStatus = 0) as quantiles_uncached_transferTimeMSec,
  avgIf (turnAroundTimeMSec, cacheStatus = 1) AS avg_cached_turnAroundTimeMSec,
  avgIf (transferTimeMSec, cacheStatus = 1) AS avg_cached_transferTimeMSec,
  avgIf (turnAroundTimeMSec, cacheStatus = 0) AS avg_uncached_turnAroundTimeMSec,
  avgIf (transferTimeMSec, cacheStatus = 0) AS avg_uncached_transferTimeMSec,
  quantiles (0.25, 0.5, 0.75, 0.9, 0.95, 0.99) (downloadTime) AS quantiles_downloadTimeMSec,
  quantiles (0.25, 0.5, 0.75, 0.9, 0.95, 0.99) (timeToFirstByte) AS quantiles_timeToFirstByteMSec
FROM
  akamai.logs
GROUP BY
  reqTimeSec,
  cliIP,
  asn,
  referer,
  reqPath,
  UA,
  Edge_IP,
  reqHost,
  country,
  state,
  city,
  statusCode,
  errorCode,
  rspContentType,
  cp SETTINGS hdx_primary_key = 'reqTimeSec'
