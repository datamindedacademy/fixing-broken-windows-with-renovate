---
layout: default
label: 4 · Taming the noise
---

# 30 PRs on day one, bot <span class="dm-accent">disabled on day two</span>

<table class="dm-table">
<tbody>
<tr><th style="width: 16%">Lever</th><th style="width: 34%">Option</th><th>Effect</th></tr>
<tr><td>When</td><td><code>schedule</code>, <code>timezone</code></td><td>Only open PRs in a window</td></tr>
<tr><td>How many</td><td><code>prHourlyLimit</code>, <code>prConcurrentLimit</code></td><td>Cap the rate and the open PRs</td></tr>
<tr><td>Together</td><td><code>groupName</code> in a package rule</td><td>One PR for related packages</td></tr>
<tr><td>Wait</td><td><code>minimumReleaseAge</code></td><td>Skip yanked releases and most supply-chain attacks</td></tr>
<tr><td>Ask first</td><td><code>dependencyDashboardApproval</code></td><td>PR only after someone ticks a box</td></tr>
<tr><td>Overview</td><td>Dependency Dashboard</td><td>One issue with everything pending, blocked or failing</td></tr>
</tbody>
</table>

---
layout: statement
---

# Exercise 4

<div class="ex-grid ex-grid--single">
<div class="ex-item">
<p class="ex-name">4 · Taming the noise</p>
<p class="ex-desc">Weekday-morning schedule in Brussels time, PR limits, three groups and labels. Watch Renovate close the superseded PRs.</p>
<p class="exercise-path"><code>session/04-taming-the-noise.md</code></p>
</div>
</div>
