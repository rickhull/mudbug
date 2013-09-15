mb
==

Today:
```
mb config host 10.0.0.1
mb config method get
mb config path /foo
mb

# or

mb config host 10.0.0.1
mb get /foo
```

Tomorrow:
```
mb config --host 10.0.0.1 --method get --path /foo
mb config --host=10.0.0.1 --method=get --path=/foo
mb config -h 10.0.0.1 -m get -p /foo
mb config -h10.0.0.1 -mget -p/foo
```
If `mb config` can do it, then `mb` can do it.
`mb config` is for storing a persistent default via `dotcfg`
