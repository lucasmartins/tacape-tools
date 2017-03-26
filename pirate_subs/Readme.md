DNS Tool
============

This is a work in progrees, I would wait until I have the testing suite implemented to publish this but time is slipping away from me, maybe you can help!

This tool checks for DNS names (Domain names) availability. Pretty useful when you're trying to name your Startup.

The first time you run this tool you will be asked to set some preferences. For changing which domain suffixes you want to check, you will be asked to input like this: `.com,.com.br,.io,.cc`

The simplest way to use this tool is creating a file called 'names.txt' on your HOME with one name per line like this:

```
google
facebook
mycoolname
```

Run `tacape dns check_names` to get the results in the stdout and into a file called 'output.txt'.