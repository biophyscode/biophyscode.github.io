---
layout: page
hide_title: true
hide_main_links: true
permalink: /validation/
order: 4
---

## Validated Codes

<ol>
{% for report in site.data.validations %}
<li><a href="#{{ report.short }}">{{ report.name | capitalize }}</a></li>
{% endfor %}
</ol>

## How to read the validation list

Each item on the validation list corresponds to a tested use-case or implemented feature in our codes. Many of the unit tests are logged on the **[tests reports]({{site.baseurl}}/reports)** page, which provides a full record of all commit hashes for the time of the completed test. The following list is meant to serve as a guide for running the tests, particularly since some require the use of the interface, and hence cannot be automatically tested at the command line.

{% for report in site.data.validations %}
{% include validation_report.html report=report %}
{% endfor %}
