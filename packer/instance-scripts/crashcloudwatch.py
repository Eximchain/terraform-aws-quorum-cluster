#!/usr/bin/python -u

##############################################################################
# This software was originally sourced from:
# https://github.com/Supervisor/superlance/blob/master/superlance/crashmail.py
#
# It was copied and modified on 02/02/2018 by the GitHub user committing this message
# The original Copyright notice is reproduced below
##############################################################################

##############################################################################
#
# Copyright (c) 2007 Agendaless Consulting and Contributors.
# All Rights Reserved.
#
# This software is subject to the provisions of the BSD-like license at
# http://www.repoze.org/LICENSE.txt.  A copy of the license should accompany
# this distribution.  THIS SOFTWARE IS PROVIDED "AS IS" AND ANY AND ALL
# EXPRESS OR IMPLIED WARRANTIES ARE DISCLAIMED, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF TITLE, MERCHANTABILITY, AGAINST INFRINGEMENT, AND
# FITNESS FOR A PARTICULAR PURPOSE
#
##############################################################################

# A event listener meant to be subscribed to PROCESS_STATE_CHANGE
# events.  It will emit a cloudwatch metric when processes that are children of
# supervisord transition unexpectedly to the EXITED state.

# A supervisor config snippet that tells supervisor to use this script
# as a listener is below.
#
# [eventlistener:crashmail]
# command =
#     /usr/bin/crashcloudwatch
#         -a -m MyCustomMetric
# events=PROCESS_STATE

doc = """\
crashcloudwatch.py [-p processname] [-a]
Options:
-p -- specify a supervisor process_name.  Send mail when this process
      transitions to the EXITED state unexpectedly. If this process is
      part of a group, it can be specified using the
      'group_name:process_name' syntax.
-a -- Send mail when any child of the supervisord transitions
      unexpectedly to the EXITED state unexpectedly.  Overrides any -p
      parameters passed in the same crashmail process invocation.
-m -- The name of the CloudWatch metric to be emitted
The -p option may be specified more than once, allowing for
specification of multiple processes.  Specifying -a overrides any
selection of -p.
A sample invocation:
crashcloudwatch.py -p program1 -p group1:program2
"""

import getopt
import os
import sys
import boto3

from datetime import datetime
from supervisor import childutils


def usage(exitstatus=255):
    print(doc)
    sys.exit(exitstatus)

def read_data_file(filename):
    with open(filename, 'r') as f:
        return f.readline().strip()

def read_region():
    return read_data_file("/opt/quorum/info/aws-region.txt")

def read_primary_region():
    return read_data_file("/opt/quorum/info/primary-region.txt")

def read_network_id():
    return read_data_file("/opt/quorum/info/network-id.txt")

class CrashCloudWatch:

    def __init__(self, programs, any, metric):
        self.programs = programs
        self.any = any
        self.metric = metric
        self.region = read_region()
        self.network_id = read_network_id()
        self.stdin = sys.stdin
        self.stdout = sys.stdout
        self.stderr = sys.stderr
        self.client = boto3.client('cloudwatch', region_name=read_primary_region())

    def runforever(self, test=False):
        YMDHMS = "%Y-%m-%d_%H:%M:%S"
        while 1:
            # we explicitly use self.stdin, self.stdout, and self.stderr
            # instead of sys.* so we can unit test this code
            headers, payload = childutils.listener.wait(
                self.stdin, self.stdout)

            if not headers['eventname'] == 'PROCESS_STATE_EXITED':
                # do nothing with non-TICK events
                childutils.listener.ok(self.stdout)
                if test:
                    self.stderr.write(datetime.now().strftime(YMDHMS) + ' non-exited event\n')
                    self.stderr.flush()
                    break
                continue

            pheaders, pdata = childutils.eventdata(payload+'\n')

            if int(pheaders['expected']):
                childutils.listener.ok(self.stdout)
                if test:
                    self.stderr.write(datetime.now().strftime(YMDHMS) + ' expected exit\n')
                    self.stderr.flush()
                    break
                continue

            self.stderr.write(datetime.now().strftime(YMDHMS) + ' unexpected exit, emitting cloudwatch metric\n')
            self.stderr.flush()

            self.emit_metric(self.metric)

            childutils.listener.ok(self.stdout)
            if test:
                break

    def emit_metric(self, metric):
        namespace = 'Quorum'
        metric_data = [{
            'MetricName': metric,
            'Value': 1,
            'Dimensions': [{
                'Name': 'NetworkID',
                'Value': self.network_id
            }]
        }]
        self.client.put_metric_data(Namespace=namespace, MetricData=metric_data)

def main(argv=sys.argv):
    short_args = "hp:am:"
    long_args = [
        "help",
        "program=",
        "any",
        "metric=",
        ]
    arguments = argv[1:]
    try:
        opts, args = getopt.getopt(arguments, short_args, long_args)
    except:
        usage()

    programs = []
    any = False
    metric = None

    for option, value in opts:

        if option in ('-h', '--help'):
            usage(exitstatus=0)

        if option in ('-p', '--program'):
            programs.append(value)

        if option in ('-a', '--any'):
            any = True

        if option in ('-m', '--metric'):
            metric = value

    if not 'SUPERVISOR_SERVER_URL' in os.environ:
        sys.stderr.write('crashcloudwatch must be run as a supervisor event '
                         'listener\n')
        sys.stderr.flush()
        return

    prog = CrashCloudWatch(programs, any, metric)
    prog.runforever()


if __name__ == '__main__':
    main()
