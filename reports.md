---
layout: page
hide_title: true
hide_main_links: true
permalink: /reports/
order: 4
---

<h1>Test Reports</h1>

{% assign latest = site.data.reports.last %}

This page lists the unit tests, many of which are described on the **[validation page]({{ site.baseurl}}/validation/)**, according to when they were last tested. Use the following links to jump to a specific report, which will explain what was tested on that date as well as the commit hashes and location on disk for the associated codes.

<a class="bubble_light" href="#{{ latest.when }}">
latest: {{ latest.when }}</a>
{% for report in site.data.reports %}<a class="bubble_light" href="#{{ report.when }}">{{ report.when }}</a> {% endfor %}

## How to read the test reports

Whenever we test the code, we add it to the [list below](#reports_start). Each test date includes a link to a full report of the commit hashes and timestamps for each component of the code that was used for the test. There are three kinds of tests.

1. Automacs **experiment tests** include the name of a particular experiment and the name of the kickstarter required to get the codes, however this information is apparent from the full text report as well. The [section below](#automacs_tests) explains the testing method.
2. The **automatic tests** are more general to the factory codes, and correspond to unit tests that can be completed directly from the command line without any other user intervention. 
3. The **interface tests** require you to follow a guide and interact with the web interface.

The full report will contain a listing of all repositories used for a particular test. It will often contain a separate testing factory which was used to run the tests according to the [Docker quickstart guide]({{ site.baseurl}}/#docker). You can tell which factory was used for testing 

## Automacs tests {#automacs_tests}

Testing is typically completed inside a separate copy of the factory. As we have explained in the [Docker quickstart guide]({{ site.baseurl}}/#docker), most unit tests and associated docker files are written to the [factory-testset repository](https://github.com/bradleyrp/factory-testset). The following excerpt from one of its key files, [`testset.py`](https://github.com/bradleyrp/factory-testset/blob/master/testset.py), is responsible for running all of the automacs unit tests. It receives an `experiment`, `docker`, and `kickstarter` key from Python when it runs. These are each noted in the report for the unit test.

{% highlight bash %}
amx %(experiment)s:
  docker: %(docker)s
  where: DOCKER_SPOT
  collect files: 
    automacs.py: ".automacs.py"
  script: |
    set -e
    cd host
    source /usr/local/gromacs/bin/GMXRC.bash
    source factory/env/bin/activate py2
    mv ~/host/.automacs.py ~/
    # make folder
    spot=amx-test-$(date +"%%Y.%%m.%%d.%%H%%M")-%(experiment)s
    mkdir $spot
    cd $spot
    # run the test
    git clone http://github.com/biophyscode/automacs
    cd automacs
    make setup %(kickstarter)s
    make go lipidome clean
    make go bilayer_control_flat clean 
{% endhighlight %}

Any tested automacs experiment can typically be run from the command line using the following commands. For this example, we are using the `proteins` kickstarter, and the `protein` experiment.

{% highlight bash %}

sim_name=sim-v001
git clone http://github.com/biophyscode/automacs $sim_name
cd $sim_name
make gromacs_config local
make prep v
make setup proteins
make go protein clean 

{% endhighlight %}

Knowing that an experiment has passed a unit test means it is likely that the above sequence will work for new users, however we must caution you that running such a [standalone automacs]({{ site.baseurl}}/#automacs) experiment is best done after you source the environment [provided by the factory]({{ site.baseurl}}/#factory).

<h1 id="reports_start"><a name="reports_start"></a>Test Reports Listing</h1>
{% for report in site.data.reports %}
{% include test_report.html report=report %}
{% endfor %}
<br>
