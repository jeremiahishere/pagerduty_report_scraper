buy a macbook pro running osx

on your default browser, 
- set your download location to ~/Downloads
- sign in to pagerduty

make sure there you don't have an important file saved in ~/Downloads/incidents.csv.  It will be
deleted.

Setup ./config.yml with the structure

```
---
config:
  # your pagerduty subdomain
  host: "your-company.pagerduty.com"

  # how many days to lookback in the pagerduty incident history
  lookback_window: 30

  # Group incidents by looking at similar names.
  # 1.00 allows exact matches only
  # 0.99 will separate incidents by ip address
  # 0.97 something in between
  # 0.90 will group similarly named incidents that only differ by ip address and application name
  fuzzy_match_threshold: 0.97
  service_names:
  - "pager duty services"
  - "to report on"
```

Run:
```
$ bundle install
$ bundle exec rake run
```

tab back to terminal to see the output

the output will also be saved into incidents/formatted
