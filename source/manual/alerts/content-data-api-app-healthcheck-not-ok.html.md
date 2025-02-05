---
owner_slack: "#govuk-platform-health"
title: content-data-api app healthcheck not ok
section: Icinga alerts
layout: manual_layout
parent: "/manual.html"
last_reviewed_on: 2020-01-13
review_in: 6 months
---

If there is a health check error showing for Content Data API, you can click on the alert to find out more details about what’s wrong.

Note that:

* The ETL process runs at 7am (UK time) in production.
* The ETL process runs at 11am (UK time) in staging.
* The ETL process runs at 1pm (UK time) in integration.
* **All dates for the rake tasks below are inclusive.** In other words, if you only need to reprocess data for a specific day, you'll need to use the same the date for both the 'from' and 'to' parameters (for example: `etl:repopulate_aggregations_month["2019-12-15","2019-12-15"]`).
* The rake task should be run on the `content-data-api` TARGET_APPLICATION and the `backend` MACHINE_CLASS.

Here are the possible problems you may see:

## ETL :: no monthly aggregations of metrics for yesterday

This means that [the ETL master process][1] that runs daily that creates aggregations of the metrics failed.

To fix this problem run the [following rake task][5]:

```bash
etl:repopulate_aggregations_month["YYYY-MM-DD","YYYY-MM-DD"]
```

## ETL :: no <range> searches updated from yesterday

This means that [the Etl process][1] that runs daily and refreshes the Materialized Views failed to update those views.

To fix this problem run the [following rake task][6]:

```bash
etl:repopulate_aggregations_search
```

## ETL :: no daily metrics for yesterday

This means that [the ETL master process][1] that runs daily to retrieve metrics for content items has failed.

To fix this problem [re-run the master process again][1]

**Note** This will first delete any metrics that had been successfully retrieved before re-running the task to regather all metrics.

## ETL :: no pviews for yesterday

This means the [the ETL master process][1] that runs daily has failed to collect `pageview` metrics from Google Analytics. The issue may originate from the [ETL processor responsible for collecting core metrics][9].

To fix this problem run the [following rake task][2]:

```bash
rake etl:repopulateviews["YYYY-MM-DD","YYYY-MM-DD"]
```

## ETL :: no upviews for yesterday

This means the [the ETL master process][1] that runs daily has failed to collect `unique pageview` metrics from Google Analytics. The issue may originate from the [ETL processor responsible for collecting core metrics][9].

To fix this problem run the [following rake task][2]:

```bash
rake etl:repopulateviews["YYYY-MM-DD","YYYY-MM-DD"]
```

## ETL :: no searches for yesterday

This means the [the ETL master process][1] that runs daily has failed to collect `number of searches` metrics from Google Analytics. The issue may originate from the [ETL processor responsible for collecting Internal Searches][10].

To fix this problem run the [following rake task][3]:

```bash
rake etl:repopulate_searches["YYYY-MM-DD","YYYY-MM-DD"]
```

## ETL :: no feedex for yesterday

This means the [the ETL master process][1] that runs daily has failed to collect `feedex` metrics from `support-api`. The issue may originate from the [ETL processor responsible for collecting Feedex comments][11].

To fix this problem run the [following rake task][4]:

```bash
rake etl:repopulate_feedex["YYYY-MM-DD","YYYY-MM-DD"]
```

## Other troubleshooting tips

For problems in the ETL process, you can check the output in [Jenkins][1].

You can also check for any errors in [Sentry][7] or the [logs in kibana][8]

[1]: https://deploy.blue.production.govuk.digital/job/content_data_api_import_etl_master_process/
[2]: https://github.com/alphagov/content-data-api/blob/master/lib/tasks/etl.rake#L32
[3]: https://github.com/alphagov/content-data-api/blob/master/lib/tasks/etl.rake#L45
[4]: https://github.com/alphagov/content-data-api/blob/master/lib/tasks/etl.rake#L71
[5]: https://github.com/alphagov/content-data-api/blob/master/lib/tasks/etl.rake#L10
[6]: https://github.com/alphagov/content-data-api/blob/master/lib/tasks/etl.rake#L25
[7]: https://sentry.io/organizations/govuk/issues/?environment=production&project=1461890
[8]: https://kibana.logit.io/s/283f08f6-d117-48df-9667-c4aa492b81f9/app/kibana#/discover?_g=()&_a=(columns:!(_source),index:'*-*',interval:auto,query:(query_string:(query:'application:%20content-data-api')),sort:!('@timestamp',desc))
[9]: https://github.com/alphagov/content-data-api/blob/master/app/domain/etl/ga/views_and_navigation_processor.rb
[10]: https://github.com/alphagov/content-data-api/blob/master/app/domain/etl/ga/internal_search_processor.rb
[11]: https://github.com/alphagov/content-data-api/blob/master/app/domain/etl/feedex/processor.rb
