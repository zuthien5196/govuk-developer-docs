---
owner_slack: "#govuk-2ndline"
title: Process file handle count exceedes
parent: "/manual.html"
layout: manual_layout
section: Icinga alerts
last_reviewed_on: 2019-11-11
review_in: 6 months
---

This check fails when the monitored processes use more file handles
than the configured limit. The default limit is 500.

This is problematic as there are limits to how many file handles a
process may have, and if these limits are hit, the process may stop
working.

If this check has failed, it could be that the limit is too low, or
that a problem with the processes is causing excessive file handles to
be held.

As a temporary mitigation, restarting the process may reduce the count
of held file handles.
