buy a macbook pro
on your default browser, 
- set your download location to ~/Downloads
- sign in to pagerduty
make sure there you don't have an important file saved in ~/Downloads/incidents.csv.  It will be
deleted.

Setup ./config.yml with the structure

```
---
config:
  host: "your pagerduty host"
  service_names:
  - "pager duty services
  - "to report on"
```

$ bundle install
$ bundle exec rake run

tab back to terminal to see the output
the output will also be saved into incidents/formatted
