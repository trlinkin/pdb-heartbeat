# PuppetDB Heartbeat Check

This repository contains a VERY simple script to be run via Cron in order to
tell if the server running the Puppet Enterprise Console can successfully reach
the PuppetDB server. This check run a very simple query and logs the results.

## Usage

Ensure the script in this repository, `heartbeat.rb`, is executable. It will
use the Ruby distributed alongside Puppet Enterprise.

Setup a Cron job on whatever interval is desired. It is suggested that this
check run no more frequently than once per minute.

This check script requires one argument, the hostname of the PuppetDB server.
Use the hostname that was originally provided to the Puppet Enterprise console
upon it's configuration.

## Results

The execution of this check will result in a very simple log file being
populated with the results. The location of the log file is
`/var/log/puppetlabs/pdb-heartbeat.log`.

It is important to recognize that this file is not a standard log file for a
Puppet Enterprise installation. **It will not be automatically rotated or
purged.** The data in the file is minimal and should not fill the disk, but do
be aware!

## Understanding the Log

The log file will simply contain lines like the following:

```
[2017-02-10 22:48:49 +0000 -- 23728] - Starting Heartbeat Check
[2017-02-10 22:48:49 +0000 -- 23728] - Alive (0.096790051s)
```

They are fairly simple lines overall, the basic breakdown is this:

```
[<WALL CLOCK TIME> -- <CURRENT PID OF EXECUTION>] - <MESSAGE>
```
There are two messages you should ever see:
* `Starting Heartbeat Check`
* Result (either _Alive_ or _Dead_) with duration

Result lines will always include how long it took to get a result from the PuppetDB
server.

## Other Points of Interest

This check is dead simple. It runs a simple query asking the PuppetDB server to
list all known Facter fact names. This query should not be so intense that it
will grind the PuppetDB server to halt, but let not take that risk. Don't run
this more than once a minute.

[fact-names API endpoint](https://docs.puppet.com/puppetdb/4.1/api/query/v4/fact-names.html#pdbqueryv4fact-names)

The check waits for up to 120 seconds before timeout. This is similar to the
default timeout used by internally by the PE console.

This check looks for a 200 response from the PuppetDB server, anything else is
considered a failure.
