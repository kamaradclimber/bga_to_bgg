# BgaToBgg

This project allows to synchronize all my plays from boardgamearena website to [BBG](https://boardgamegeek.com/).

There are a few hardcoded things (list of game ids and my BBG id) but it should be adaptable to others.

### To use this

Set environment variables used in bin/sync then:

```
bundle install
bundle exec bin/sync
```

This script aims to be idempotent and should be runnable once per ~day.
