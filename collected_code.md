# Code Collection Report

## Directory Structure:
```
├── app-server/
│   ├── Dockerfile
│   └── send_mail.py
├── bind/
│   ├── db.19.172.in-addr.arpa
│   ├── db.example.local
│   ├── Dockerfile
│   ├── named.conf
│   └── rndc.key
├── client/
│   ├── Dockerfile
│   └── test_mail.sh
├── etc/
│   ├── postfix/
│   │   ├── main.cf
│   │   └── master.cf
│   ├── mailname
│   └── nsswitch.conf
├── mail/
├── pop3/
│   ├── dovecot/
│   │   ├── dovecot.conf
│   │   └── users
│   └── Dockerfile
├── smtp/
│   ├── Dockerfile
│   ├── Dockerfile.manual
│   └── init.sh
├── docker-compose.yml
└── smtp_aliases

```

### File: `docker-compose.yml`

**Language:** yml

**File Size:** 2066 bytes
**Created:** 2024-12-08T20:25:28.565683
**Modified:** 2024-12-08T20:25:28.565683

```yml
services:
  dns-server:
    build:
      context: ./  # ルートディレクトリをコンテキストに設定
      dockerfile: ./bind/Dockerfile  # Dockerfileの場所を明示的に指定
    container_name: dns-server
    networks:
      mail_network:
        ipv4_address: 172.19.0.3
    ports:
      - "53:53/udp"
    volumes:
      - ./bind:/etc/bind
    restart: always



  smtp-server:
    build:
      context: ./  # ビルドのコンテキストをルートディレクトリに設定
      dockerfile: ./smtp/Dockerfile  # SMTPサーバー用Dockerfileを明示的に指定
    container_name: smtp-server
    networks:
      mail_network:
        ipv4_address: 172.19.0.4
    dns:
      - 172.19.0.3  # DNSサーバーのIPを明示
    environment:
      MAILNAME: smtp.example.local
    ports:
      - "1025:25"
    volumes:
      - ./smtp_aliases:/etc/aliases # smtp_aliases を /etc/aliases にマウント
    restart: always
    depends_on:
      - dns-server

  pop3-server:
    build:
      context: ./pop3
    container_name: pop3-server
    networks:
      mail_network:
        ipv4_address: 172.19.0.7
    ports:
      - "110:110"    # POP3ポート
    volumes:
      - ./pop3/dovecot:/etc/dovecot
      - ./mail:/var/mail
    restart: always
    depends_on:
      - smtp-server
      
  app-server:
    build: ./app-server
    container_name: app-server
    networks:
      mail_network:
        ipv4_address: 172.19.0.5
    dns:
      - 172.19.0.3
    environment:
      SMTP_SERVER: smtp.example.local
    depends_on:
      - dns-server
      - smtp-server
    command: ["sh", "-c", "python3 send_mail.py && tail -f /dev/null"]

  client:
    build: ./client
    container_name: client
    networks:
      mail_network:
        ipv4_address: 172.19.0.6
    dns:
      - 172.19.0.3
    stdin_open: true
    tty: true
    command: sleep infinity

networks:
  mail_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.19.0.0/16

```

### File: `smtp_aliases`

**Language:** 

**File Size:** 98 bytes
**Created:** 2024-12-08T19:25:26.867989
**Modified:** 2024-12-08T19:25:35.240090

```
postmaster:    root
recipient: user  # recipient@example.local を pop3-server の user に転送
```

### File: `.git\COMMIT_EDITMSG`

**Language:** 

**File Size:** 34 bytes
**Created:** 2024-12-08T15:30:56.786234
**Modified:** 2024-12-08T18:10:55.397058

```
結構いいんじゃないかな

```

### File: `.git\config`

**Language:** 

**File Size:** 294 bytes
**Created:** 2024-12-08T15:31:06.592789
**Modified:** 2024-12-08T15:31:06.592789

```
[core]
	repositoryformatversion = 0
	filemode = false
	bare = false
	logallrefupdates = true
	symlinks = false
	ignorecase = true
[remote "origin"]
	url = https://github.com/ganpare/mail.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
	remote = origin
	merge = refs/heads/main

```

### File: `.git\description`

**Language:** 

**File Size:** 73 bytes
**Created:** 2024-12-08T15:29:51.330616
**Modified:** 2024-12-08T15:29:51.331615

```
Unnamed repository; edit this file 'description' to name the repository.

```

### File: `.git\FETCH_HEAD`

**Language:** 

**File Size:** 91 bytes
**Created:** 2024-12-08T15:29:51.687836
**Modified:** 2024-12-08T20:24:54.428921

```
7c92832b99f0c7aa0d1219eecce520a679e3374c		branch 'main' of https://github.com/ganpare/mail

```

### File: `.git\HEAD`

**Language:** 

**File Size:** 21 bytes
**Created:** 2024-12-08T15:31:04.353594
**Modified:** 2024-12-08T15:31:04.353594

```
ref: refs/heads/main

```

### File: `.git\index`

**Language:** 

**File Size:** 2087 bytes
**Created:** 2024-12-08T18:10:55.280613
**Modified:** 2024-12-08T18:10:55.395962

```

```

### File: `.git\ORIG_HEAD`

**Language:** 

**File Size:** 41 bytes
**Created:** 2024-12-08T18:10:57.056853
**Modified:** 2024-12-08T18:10:57.057854

```
7c92832b99f0c7aa0d1219eecce520a679e3374c

```

### File: `.git\hooks\applypatch-msg.sample`

**Language:** sample

**File Size:** 478 bytes
**Created:** 2024-12-08T15:29:51.331615
**Modified:** 2024-12-08T15:29:51.331615

```sample
#!/bin/sh
#
# An example hook script to check the commit log message taken by
# applypatch from an e-mail message.
#
# The hook should exit with non-zero status after issuing an
# appropriate message if it wants to stop the commit.  The hook is
# allowed to edit the commit message file.
#
# To enable this hook, rename this file to "applypatch-msg".

. git-sh-setup
commitmsg="$(git rev-parse --git-path hooks/commit-msg)"
test -x "$commitmsg" && exec "$commitmsg" ${1+"$@"}
:

```

### File: `.git\hooks\commit-msg.sample`

**Language:** sample

**File Size:** 896 bytes
**Created:** 2024-12-08T15:29:51.549481
**Modified:** 2024-12-08T15:29:51.550481

```sample
#!/bin/sh
#
# An example hook script to check the commit log message.
# Called by "git commit" with one argument, the name of the file
# that has the commit message.  The hook should exit with non-zero
# status after issuing an appropriate message if it wants to stop the
# commit.  The hook is allowed to edit the commit message file.
#
# To enable this hook, rename this file to "commit-msg".

# Uncomment the below to add a Signed-off-by line to the message.
# Doing this in a hook is a bad idea in general, but the prepare-commit-msg
# hook is more suited to it.
#
# SOB=$(git var GIT_AUTHOR_IDENT | sed -n 's/^\(.*>\).*$/Signed-off-by: \1/p')
# grep -qs "^$SOB" "$1" || echo "$SOB" >> "$1"

# This example catches duplicate Signed-off-by lines.

test "" = "$(grep '^Signed-off-by: ' "$1" |
	 sort | uniq -c | sed -e '/^[ 	]*1[ 	]/d')" || {
	echo >&2 Duplicate Signed-off-by lines.
	exit 1
}

```

### File: `.git\hooks\fsmonitor-watchman.sample`

**Language:** sample

**File Size:** 4726 bytes
**Created:** 2024-12-08T15:29:51.550481
**Modified:** 2024-12-08T15:29:51.551481

```sample
#!/usr/bin/perl

use strict;
use warnings;
use IPC::Open2;

# An example hook script to integrate Watchman
# (https://facebook.github.io/watchman/) with git to speed up detecting
# new and modified files.
#
# The hook is passed a version (currently 2) and last update token
# formatted as a string and outputs to stdout a new update token and
# all files that have been modified since the update token. Paths must
# be relative to the root of the working tree and separated by a single NUL.
#
# To enable this hook, rename this file to "query-watchman" and set
# 'git config core.fsmonitor .git/hooks/query-watchman'
#
my ($version, $last_update_token) = @ARGV;

# Uncomment for debugging
# print STDERR "$0 $version $last_update_token\n";

# Check the hook interface version
if ($version ne 2) {
	die "Unsupported query-fsmonitor hook version '$version'.\n" .
	    "Falling back to scanning...\n";
}

my $git_work_tree = get_working_dir();

my $retry = 1;

my $json_pkg;
eval {
	require JSON::XS;
	$json_pkg = "JSON::XS";
	1;
} or do {
	require JSON::PP;
	$json_pkg = "JSON::PP";
};

launch_watchman();

sub launch_watchman {
	my $o = watchman_query();
	if (is_work_tree_watched($o)) {
		output_result($o->{clock}, @{$o->{files}});
	}
}

sub output_result {
	my ($clockid, @files) = @_;

	# Uncomment for debugging watchman output
	# open (my $fh, ">", ".git/watchman-output.out");
	# binmode $fh, ":utf8";
	# print $fh "$clockid\n@files\n";
	# close $fh;

	binmode STDOUT, ":utf8";
	print $clockid;
	print "\0";
	local $, = "\0";
	print @files;
}

sub watchman_clock {
	my $response = qx/watchman clock "$git_work_tree"/;
	die "Failed to get clock id on '$git_work_tree'.\n" .
		"Falling back to scanning...\n" if $? != 0;

	return $json_pkg->new->utf8->decode($response);
}

sub watchman_query {
	my $pid = open2(\*CHLD_OUT, \*CHLD_IN, 'watchman -j --no-pretty')
	or die "open2() failed: $!\n" .
	"Falling back to scanning...\n";

	# In the query expression below we're asking for names of files that
	# changed since $last_update_token but not from the .git folder.
	#
	# To accomplish this, we're using the "since" generator to use the
	# recency index to select candidate nodes and "fields" to limit the
	# output to file names only. Then we're using the "expression" term to
	# further constrain the results.
	my $last_update_line = "";
	if (substr($last_update_token, 0, 1) eq "c") {
		$last_update_token = "\"$last_update_token\"";
		$last_update_line = qq[\n"since": $last_update_token,];
	}
	my $query = <<"	END";
		["query", "$git_work_tree", {$last_update_line
			"fields": ["name"],
			"expression": ["not", ["dirname", ".git"]]
		}]
	END

	# Uncomment for debugging the watchman query
	# open (my $fh, ">", ".git/watchman-query.json");
	# print $fh $query;
	# close $fh;

	print CHLD_IN $query;
	close CHLD_IN;
	my $response = do {local $/; <CHLD_OUT>};

	# Uncomment for debugging the watch response
	# open ($fh, ">", ".git/watchman-response.json");
	# print $fh $response;
	# close $fh;

	die "Watchman: command returned no output.\n" .
	"Falling back to scanning...\n" if $response eq "";
	die "Watchman: command returned invalid output: $response\n" .
	"Falling back to scanning...\n" unless $response =~ /^\{/;

	return $json_pkg->new->utf8->decode($response);
}

sub is_work_tree_watched {
	my ($output) = @_;
	my $error = $output->{error};
	if ($retry > 0 and $error and $error =~ m/unable to resolve root .* directory (.*) is not watched/) {
		$retry--;
		my $response = qx/watchman watch "$git_work_tree"/;
		die "Failed to make watchman watch '$git_work_tree'.\n" .
		    "Falling back to scanning...\n" if $? != 0;
		$output = $json_pkg->new->utf8->decode($response);
		$error = $output->{error};
		die "Watchman: $error.\n" .
		"Falling back to scanning...\n" if $error;

		# Uncomment for debugging watchman output
		# open (my $fh, ">", ".git/watchman-output.out");
		# close $fh;

		# Watchman will always return all files on the first query so
		# return the fast "everything is dirty" flag to git and do the
		# Watchman query just to get it over with now so we won't pay
		# the cost in git to look up each individual file.
		my $o = watchman_clock();
		$error = $output->{error};

		die "Watchman: $error.\n" .
		"Falling back to scanning...\n" if $error;

		output_result($o->{clock}, ("/"));
		$last_update_token = $o->{clock};

		eval { launch_watchman() };
		return 0;
	}

	die "Watchman: $error.\n" .
	"Falling back to scanning...\n" if $error;

	return 1;
}

sub get_working_dir {
	my $working_dir;
	if ($^O =~ 'msys' || $^O =~ 'cygwin') {
		$working_dir = Win32::GetCwd();
		$working_dir =~ tr/\\/\//;
	} else {
		require Cwd;
		$working_dir = Cwd::cwd();
	}

	return $working_dir;
}

```

### File: `.git\hooks\post-update.sample`

**Language:** sample

**File Size:** 189 bytes
**Created:** 2024-12-08T15:29:51.551481
**Modified:** 2024-12-08T15:29:51.551481

```sample
#!/bin/sh
#
# An example hook script to prepare a packed repository for use over
# dumb transports.
#
# To enable this hook, rename this file to "post-update".

exec git update-server-info

```

### File: `.git\hooks\pre-applypatch.sample`

**Language:** sample

**File Size:** 424 bytes
**Created:** 2024-12-08T15:29:51.551481
**Modified:** 2024-12-08T15:29:51.551481

```sample
#!/bin/sh
#
# An example hook script to verify what is about to be committed
# by applypatch from an e-mail message.
#
# The hook should exit with non-zero status after issuing an
# appropriate message if it wants to stop the commit.
#
# To enable this hook, rename this file to "pre-applypatch".

. git-sh-setup
precommit="$(git rev-parse --git-path hooks/pre-commit)"
test -x "$precommit" && exec "$precommit" ${1+"$@"}
:

```

### File: `.git\hooks\pre-commit.sample`

**Language:** sample

**File Size:** 1649 bytes
**Created:** 2024-12-08T15:29:51.552480
**Modified:** 2024-12-08T15:29:51.552480

```sample
#!/bin/sh
#
# An example hook script to verify what is about to be committed.
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#
# To enable this hook, rename this file to "pre-commit".

if git rev-parse --verify HEAD >/dev/null 2>&1
then
	against=HEAD
else
	# Initial commit: diff against an empty tree object
	against=$(git hash-object -t tree /dev/null)
fi

# If you want to allow non-ASCII filenames set this variable to true.
allownonascii=$(git config --type=bool hooks.allownonascii)

# Redirect output to stderr.
exec 1>&2

# Cross platform projects tend to avoid non-ASCII filenames; prevent
# them from being added to the repository. We exploit the fact that the
# printable range starts at the space character and ends with tilde.
if [ "$allownonascii" != "true" ] &&
	# Note that the use of brackets around a tr range is ok here, (it's
	# even required, for portability to Solaris 10's /usr/bin/tr), since
	# the square bracket bytes happen to fall in the designated range.
	test $(git diff-index --cached --name-only --diff-filter=A -z $against |
	  LC_ALL=C tr -d '[ -~]\0' | wc -c) != 0
then
	cat <<\EOF
Error: Attempt to add a non-ASCII file name.

This can cause problems if you want to work with people on other platforms.

To be portable it is advisable to rename the file.

If you know what you are doing you can disable this check using:

  git config hooks.allownonascii true
EOF
	exit 1
fi

# If there are whitespace errors, print the offending file names and fail.
exec git diff-index --check --cached $against --

```

### File: `.git\hooks\pre-merge-commit.sample`

**Language:** sample

**File Size:** 416 bytes
**Created:** 2024-12-08T15:29:51.552480
**Modified:** 2024-12-08T15:29:51.552480

```sample
#!/bin/sh
#
# An example hook script to verify what is about to be committed.
# Called by "git merge" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message to
# stderr if it wants to stop the merge commit.
#
# To enable this hook, rename this file to "pre-merge-commit".

. git-sh-setup
test -x "$GIT_DIR/hooks/pre-commit" &&
        exec "$GIT_DIR/hooks/pre-commit"
:

```

### File: `.git\hooks\pre-push.sample`

**Language:** sample

**File Size:** 1374 bytes
**Created:** 2024-12-08T15:29:51.553481
**Modified:** 2024-12-08T15:29:51.553481

```sample
#!/bin/sh

# An example hook script to verify what is about to be pushed.  Called by "git
# push" after it has checked the remote status, but before anything has been
# pushed.  If this script exits with a non-zero status nothing will be pushed.
#
# This hook is called with the following parameters:
#
# $1 -- Name of the remote to which the push is being done
# $2 -- URL to which the push is being done
#
# If pushing without using a named remote those arguments will be equal.
#
# Information about the commits which are being pushed is supplied as lines to
# the standard input in the form:
#
#   <local ref> <local oid> <remote ref> <remote oid>
#
# This sample shows how to prevent push of commits where the log message starts
# with "WIP" (work in progress).

remote="$1"
url="$2"

zero=$(git hash-object --stdin </dev/null | tr '[0-9a-f]' '0')

while read local_ref local_oid remote_ref remote_oid
do
	if test "$local_oid" = "$zero"
	then
		# Handle delete
		:
	else
		if test "$remote_oid" = "$zero"
		then
			# New branch, examine all commits
			range="$local_oid"
		else
			# Update to existing branch, examine new commits
			range="$remote_oid..$local_oid"
		fi

		# Check for WIP commit
		commit=$(git rev-list -n 1 --grep '^WIP' "$range")
		if test -n "$commit"
		then
			echo >&2 "Found WIP commit in $local_ref, not pushing"
			exit 1
		fi
	fi
done

exit 0

```

### File: `.git\hooks\pre-rebase.sample`

**Language:** sample

**File Size:** 4898 bytes
**Created:** 2024-12-08T15:29:51.553481
**Modified:** 2024-12-08T15:29:51.554482

```sample
#!/bin/sh
#
# Copyright (c) 2006, 2008 Junio C Hamano
#
# The "pre-rebase" hook is run just before "git rebase" starts doing
# its job, and can prevent the command from running by exiting with
# non-zero status.
#
# The hook is called with the following parameters:
#
# $1 -- the upstream the series was forked from.
# $2 -- the branch being rebased (or empty when rebasing the current branch).
#
# This sample shows how to prevent topic branches that are already
# merged to 'next' branch from getting rebased, because allowing it
# would result in rebasing already published history.

publish=next
basebranch="$1"
if test "$#" = 2
then
	topic="refs/heads/$2"
else
	topic=`git symbolic-ref HEAD` ||
	exit 0 ;# we do not interrupt rebasing detached HEAD
fi

case "$topic" in
refs/heads/??/*)
	;;
*)
	exit 0 ;# we do not interrupt others.
	;;
esac

# Now we are dealing with a topic branch being rebased
# on top of master.  Is it OK to rebase it?

# Does the topic really exist?
git show-ref -q "$topic" || {
	echo >&2 "No such branch $topic"
	exit 1
}

# Is topic fully merged to master?
not_in_master=`git rev-list --pretty=oneline ^master "$topic"`
if test -z "$not_in_master"
then
	echo >&2 "$topic is fully merged to master; better remove it."
	exit 1 ;# we could allow it, but there is no point.
fi

# Is topic ever merged to next?  If so you should not be rebasing it.
only_next_1=`git rev-list ^master "^$topic" ${publish} | sort`
only_next_2=`git rev-list ^master           ${publish} | sort`
if test "$only_next_1" = "$only_next_2"
then
	not_in_topic=`git rev-list "^$topic" master`
	if test -z "$not_in_topic"
	then
		echo >&2 "$topic is already up to date with master"
		exit 1 ;# we could allow it, but there is no point.
	else
		exit 0
	fi
else
	not_in_next=`git rev-list --pretty=oneline ^${publish} "$topic"`
	/usr/bin/perl -e '
		my $topic = $ARGV[0];
		my $msg = "* $topic has commits already merged to public branch:\n";
		my (%not_in_next) = map {
			/^([0-9a-f]+) /;
			($1 => 1);
		} split(/\n/, $ARGV[1]);
		for my $elem (map {
				/^([0-9a-f]+) (.*)$/;
				[$1 => $2];
			} split(/\n/, $ARGV[2])) {
			if (!exists $not_in_next{$elem->[0]}) {
				if ($msg) {
					print STDERR $msg;
					undef $msg;
				}
				print STDERR " $elem->[1]\n";
			}
		}
	' "$topic" "$not_in_next" "$not_in_master"
	exit 1
fi

<<\DOC_END

This sample hook safeguards topic branches that have been
published from being rewound.

The workflow assumed here is:

 * Once a topic branch forks from "master", "master" is never
   merged into it again (either directly or indirectly).

 * Once a topic branch is fully cooked and merged into "master",
   it is deleted.  If you need to build on top of it to correct
   earlier mistakes, a new topic branch is created by forking at
   the tip of the "master".  This is not strictly necessary, but
   it makes it easier to keep your history simple.

 * Whenever you need to test or publish your changes to topic
   branches, merge them into "next" branch.

The script, being an example, hardcodes the publish branch name
to be "next", but it is trivial to make it configurable via
$GIT_DIR/config mechanism.

With this workflow, you would want to know:

(1) ... if a topic branch has ever been merged to "next".  Young
    topic branches can have stupid mistakes you would rather
    clean up before publishing, and things that have not been
    merged into other branches can be easily rebased without
    affecting other people.  But once it is published, you would
    not want to rewind it.

(2) ... if a topic branch has been fully merged to "master".
    Then you can delete it.  More importantly, you should not
    build on top of it -- other people may already want to
    change things related to the topic as patches against your
    "master", so if you need further changes, it is better to
    fork the topic (perhaps with the same name) afresh from the
    tip of "master".

Let's look at this example:

		   o---o---o---o---o---o---o---o---o---o "next"
		  /       /           /           /
		 /   a---a---b A     /           /
		/   /               /           /
	       /   /   c---c---c---c B         /
	      /   /   /             \         /
	     /   /   /   b---b C     \       /
	    /   /   /   /             \     /
    ---o---o---o---o---o---o---o---o---o---o---o "master"


A, B and C are topic branches.

 * A has one fix since it was merged up to "next".

 * B has finished.  It has been fully merged up to "master" and "next",
   and is ready to be deleted.

 * C has not merged to "next" at all.

We would want to allow C to be rebased, refuse A, and encourage
B to be deleted.

To compute (1):

	git rev-list ^master ^topic next
	git rev-list ^master        next

	if these match, topic has not merged in next at all.

To compute (2):

	git rev-list master..topic

	if this is empty, it is fully merged to "master".

DOC_END

```

### File: `.git\hooks\pre-receive.sample`

**Language:** sample

**File Size:** 544 bytes
**Created:** 2024-12-08T15:29:51.554482
**Modified:** 2024-12-08T15:29:51.554482

```sample
#!/bin/sh
#
# An example hook script to make use of push options.
# The example simply echoes all push options that start with 'echoback='
# and rejects all pushes when the "reject" push option is used.
#
# To enable this hook, rename this file to "pre-receive".

if test -n "$GIT_PUSH_OPTION_COUNT"
then
	i=0
	while test "$i" -lt "$GIT_PUSH_OPTION_COUNT"
	do
		eval "value=\$GIT_PUSH_OPTION_$i"
		case "$value" in
		echoback=*)
			echo "echo from the pre-receive-hook: ${value#*=}" >&2
			;;
		reject)
			exit 1
		esac
		i=$((i + 1))
	done
fi

```

### File: `.git\hooks\prepare-commit-msg.sample`

**Language:** sample

**File Size:** 1492 bytes
**Created:** 2024-12-08T15:29:51.555480
**Modified:** 2024-12-08T15:29:51.555480

```sample
#!/bin/sh
#
# An example hook script to prepare the commit log message.
# Called by "git commit" with the name of the file that has the
# commit message, followed by the description of the commit
# message's source.  The hook's purpose is to edit the commit
# message file.  If the hook fails with a non-zero status,
# the commit is aborted.
#
# To enable this hook, rename this file to "prepare-commit-msg".

# This hook includes three examples. The first one removes the
# "# Please enter the commit message..." help message.
#
# The second includes the output of "git diff --name-status -r"
# into the message, just before the "git status" output.  It is
# commented because it doesn't cope with --amend or with squashed
# commits.
#
# The third example adds a Signed-off-by line to the message, that can
# still be edited.  This is rarely a good idea.

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2
SHA1=$3

/usr/bin/perl -i.bak -ne 'print unless(m/^. Please enter the commit message/..m/^#$/)' "$COMMIT_MSG_FILE"

# case "$COMMIT_SOURCE,$SHA1" in
#  ,|template,)
#    /usr/bin/perl -i.bak -pe '
#       print "\n" . `git diff --cached --name-status -r`
# 	 if /^#/ && $first++ == 0' "$COMMIT_MSG_FILE" ;;
#  *) ;;
# esac

# SOB=$(git var GIT_COMMITTER_IDENT | sed -n 's/^\(.*>\).*$/Signed-off-by: \1/p')
# git interpret-trailers --in-place --trailer "$SOB" "$COMMIT_MSG_FILE"
# if test -z "$COMMIT_SOURCE"
# then
#   /usr/bin/perl -i.bak -pe 'print "\n" if !$first_line++' "$COMMIT_MSG_FILE"
# fi

```

### File: `.git\hooks\push-to-checkout.sample`

**Language:** sample

**File Size:** 2783 bytes
**Created:** 2024-12-08T15:29:51.555480
**Modified:** 2024-12-08T15:29:51.556482

```sample
#!/bin/sh

# An example hook script to update a checked-out tree on a git push.
#
# This hook is invoked by git-receive-pack(1) when it reacts to git
# push and updates reference(s) in its repository, and when the push
# tries to update the branch that is currently checked out and the
# receive.denyCurrentBranch configuration variable is set to
# updateInstead.
#
# By default, such a push is refused if the working tree and the index
# of the remote repository has any difference from the currently
# checked out commit; when both the working tree and the index match
# the current commit, they are updated to match the newly pushed tip
# of the branch. This hook is to be used to override the default
# behaviour; however the code below reimplements the default behaviour
# as a starting point for convenient modification.
#
# The hook receives the commit with which the tip of the current
# branch is going to be updated:
commit=$1

# It can exit with a non-zero status to refuse the push (when it does
# so, it must not modify the index or the working tree).
die () {
	echo >&2 "$*"
	exit 1
}

# Or it can make any necessary changes to the working tree and to the
# index to bring them to the desired state when the tip of the current
# branch is updated to the new commit, and exit with a zero status.
#
# For example, the hook can simply run git read-tree -u -m HEAD "$1"
# in order to emulate git fetch that is run in the reverse direction
# with git push, as the two-tree form of git read-tree -u -m is
# essentially the same as git switch or git checkout that switches
# branches while keeping the local changes in the working tree that do
# not interfere with the difference between the branches.

# The below is a more-or-less exact translation to shell of the C code
# for the default behaviour for git's push-to-checkout hook defined in
# the push_to_deploy() function in builtin/receive-pack.c.
#
# Note that the hook will be executed from the repository directory,
# not from the working tree, so if you want to perform operations on
# the working tree, you will have to adapt your code accordingly, e.g.
# by adding "cd .." or using relative paths.

if ! git update-index -q --ignore-submodules --refresh
then
	die "Up-to-date check failed"
fi

if ! git diff-files --quiet --ignore-submodules --
then
	die "Working directory has unstaged changes"
fi

# This is a rough translation of:
#
#   head_has_history() ? "HEAD" : EMPTY_TREE_SHA1_HEX
if git cat-file -e HEAD 2>/dev/null
then
	head=HEAD
else
	head=$(git hash-object -t tree --stdin </dev/null)
fi

if ! git diff-index --quiet --cached --ignore-submodules $head --
then
	die "Working directory has staged changes"
fi

if ! git read-tree -u -m "$commit"
then
	die "Could not update working tree to new HEAD"
fi

```

### File: `.git\hooks\sendemail-validate.sample`

**Language:** sample

**File Size:** 2308 bytes
**Created:** 2024-12-08T15:29:51.556482
**Modified:** 2024-12-08T15:29:51.557480

```sample
#!/bin/sh

# An example hook script to validate a patch (and/or patch series) before
# sending it via email.
#
# The hook should exit with non-zero status after issuing an appropriate
# message if it wants to prevent the email(s) from being sent.
#
# To enable this hook, rename this file to "sendemail-validate".
#
# By default, it will only check that the patch(es) can be applied on top of
# the default upstream branch without conflicts in a secondary worktree. After
# validation (successful or not) of the last patch of a series, the worktree
# will be deleted.
#
# The following config variables can be set to change the default remote and
# remote ref that are used to apply the patches against:
#
#   sendemail.validateRemote (default: origin)
#   sendemail.validateRemoteRef (default: HEAD)
#
# Replace the TODO placeholders with appropriate checks according to your
# needs.

validate_cover_letter () {
	file="$1"
	# TODO: Replace with appropriate checks (e.g. spell checking).
	true
}

validate_patch () {
	file="$1"
	# Ensure that the patch applies without conflicts.
	git am -3 "$file" || return
	# TODO: Replace with appropriate checks for this patch
	# (e.g. checkpatch.pl).
	true
}

validate_series () {
	# TODO: Replace with appropriate checks for the whole series
	# (e.g. quick build, coding style checks, etc.).
	true
}

# main -------------------------------------------------------------------------

if test "$GIT_SENDEMAIL_FILE_COUNTER" = 1
then
	remote=$(git config --default origin --get sendemail.validateRemote) &&
	ref=$(git config --default HEAD --get sendemail.validateRemoteRef) &&
	worktree=$(mktemp --tmpdir -d sendemail-validate.XXXXXXX) &&
	git worktree add -fd --checkout "$worktree" "refs/remotes/$remote/$ref" &&
	git config --replace-all sendemail.validateWorktree "$worktree"
else
	worktree=$(git config --get sendemail.validateWorktree)
fi || {
	echo "sendemail-validate: error: failed to prepare worktree" >&2
	exit 1
}

unset GIT_DIR GIT_WORK_TREE
cd "$worktree" &&

if grep -q "^diff --git " "$1"
then
	validate_patch "$1"
else
	validate_cover_letter "$1"
fi &&

if test "$GIT_SENDEMAIL_FILE_COUNTER" = "$GIT_SENDEMAIL_FILE_TOTAL"
then
	git config --unset-all sendemail.validateWorktree &&
	trap 'git worktree remove -ff "$worktree"' EXIT &&
	validate_series
fi

```

### File: `.git\hooks\update.sample`

**Language:** sample

**File Size:** 3650 bytes
**Created:** 2024-12-08T15:29:51.557480
**Modified:** 2024-12-08T15:29:51.557480

```sample
#!/bin/sh
#
# An example hook script to block unannotated tags from entering.
# Called by "git receive-pack" with arguments: refname sha1-old sha1-new
#
# To enable this hook, rename this file to "update".
#
# Config
# ------
# hooks.allowunannotated
#   This boolean sets whether unannotated tags will be allowed into the
#   repository.  By default they won't be.
# hooks.allowdeletetag
#   This boolean sets whether deleting tags will be allowed in the
#   repository.  By default they won't be.
# hooks.allowmodifytag
#   This boolean sets whether a tag may be modified after creation. By default
#   it won't be.
# hooks.allowdeletebranch
#   This boolean sets whether deleting branches will be allowed in the
#   repository.  By default they won't be.
# hooks.denycreatebranch
#   This boolean sets whether remotely creating branches will be denied
#   in the repository.  By default this is allowed.
#

# --- Command line
refname="$1"
oldrev="$2"
newrev="$3"

# --- Safety check
if [ -z "$GIT_DIR" ]; then
	echo "Don't run this script from the command line." >&2
	echo " (if you want, you could supply GIT_DIR then run" >&2
	echo "  $0 <ref> <oldrev> <newrev>)" >&2
	exit 1
fi

if [ -z "$refname" -o -z "$oldrev" -o -z "$newrev" ]; then
	echo "usage: $0 <ref> <oldrev> <newrev>" >&2
	exit 1
fi

# --- Config
allowunannotated=$(git config --type=bool hooks.allowunannotated)
allowdeletebranch=$(git config --type=bool hooks.allowdeletebranch)
denycreatebranch=$(git config --type=bool hooks.denycreatebranch)
allowdeletetag=$(git config --type=bool hooks.allowdeletetag)
allowmodifytag=$(git config --type=bool hooks.allowmodifytag)

# check for no description
projectdesc=$(sed -e '1q' "$GIT_DIR/description")
case "$projectdesc" in
"Unnamed repository"* | "")
	echo "*** Project description file hasn't been set" >&2
	exit 1
	;;
esac

# --- Check types
# if $newrev is 0000...0000, it's a commit to delete a ref.
zero=$(git hash-object --stdin </dev/null | tr '[0-9a-f]' '0')
if [ "$newrev" = "$zero" ]; then
	newrev_type=delete
else
	newrev_type=$(git cat-file -t $newrev)
fi

case "$refname","$newrev_type" in
	refs/tags/*,commit)
		# un-annotated tag
		short_refname=${refname##refs/tags/}
		if [ "$allowunannotated" != "true" ]; then
			echo "*** The un-annotated tag, $short_refname, is not allowed in this repository" >&2
			echo "*** Use 'git tag [ -a | -s ]' for tags you want to propagate." >&2
			exit 1
		fi
		;;
	refs/tags/*,delete)
		# delete tag
		if [ "$allowdeletetag" != "true" ]; then
			echo "*** Deleting a tag is not allowed in this repository" >&2
			exit 1
		fi
		;;
	refs/tags/*,tag)
		# annotated tag
		if [ "$allowmodifytag" != "true" ] && git rev-parse $refname > /dev/null 2>&1
		then
			echo "*** Tag '$refname' already exists." >&2
			echo "*** Modifying a tag is not allowed in this repository." >&2
			exit 1
		fi
		;;
	refs/heads/*,commit)
		# branch
		if [ "$oldrev" = "$zero" -a "$denycreatebranch" = "true" ]; then
			echo "*** Creating a branch is not allowed in this repository" >&2
			exit 1
		fi
		;;
	refs/heads/*,delete)
		# delete branch
		if [ "$allowdeletebranch" != "true" ]; then
			echo "*** Deleting a branch is not allowed in this repository" >&2
			exit 1
		fi
		;;
	refs/remotes/*,commit)
		# tracking branch
		;;
	refs/remotes/*,delete)
		# delete tracking branch
		if [ "$allowdeletebranch" != "true" ]; then
			echo "*** Deleting a tracking branch is not allowed in this repository" >&2
			exit 1
		fi
		;;
	*)
		# Anything else (is there anything else?)
		echo "*** Update hook: unknown type of update to ref $refname of type $newrev_type" >&2
		exit 1
		;;
esac

# --- Finished
exit 0

```

### File: `.git\info\exclude`

**Language:** 

**File Size:** 240 bytes
**Created:** 2024-12-08T15:29:51.558481
**Modified:** 2024-12-08T15:29:51.558481

```
# git ls-files --others --exclude-from=.git/info/exclude
# Lines that start with '#' are comments.
# For a project mostly in C, the following would be a good set of
# exclude patterns (uncomment them if you want to use them):
# *.[oa]
# *~

```

### File: `.git\logs\HEAD`

**Language:** 

**File Size:** 701 bytes
**Created:** 2024-12-08T15:30:56.846210
**Modified:** 2024-12-08T18:10:55.447012

```
0000000000000000000000000000000000000000 d09f1d6f6677932f1a423b5c18ac5d5140a65c7f nobu007 <contact645@gmail.com> 1733639456 +0900	commit (initial): Initial commit
d09f1d6f6677932f1a423b5c18ac5d5140a65c7f 0000000000000000000000000000000000000000 nobu007 <contact645@gmail.com> 1733639464 +0900	Branch: renamed refs/heads/master to refs/heads/main
0000000000000000000000000000000000000000 d09f1d6f6677932f1a423b5c18ac5d5140a65c7f nobu007 <contact645@gmail.com> 1733639464 +0900	Branch: renamed refs/heads/master to refs/heads/main
d09f1d6f6677932f1a423b5c18ac5d5140a65c7f 7c92832b99f0c7aa0d1219eecce520a679e3374c nobu007 <contact645@gmail.com> 1733649055 +0900	commit: 結構いいんじゃないかな

```

### File: `.git\logs\refs\heads\main`

**Language:** 

**File Size:** 518 bytes
**Created:** 2024-12-08T15:30:56.847211
**Modified:** 2024-12-08T18:10:55.447012

```
0000000000000000000000000000000000000000 d09f1d6f6677932f1a423b5c18ac5d5140a65c7f nobu007 <contact645@gmail.com> 1733639456 +0900	commit (initial): Initial commit
d09f1d6f6677932f1a423b5c18ac5d5140a65c7f d09f1d6f6677932f1a423b5c18ac5d5140a65c7f nobu007 <contact645@gmail.com> 1733639464 +0900	Branch: renamed refs/heads/master to refs/heads/main
d09f1d6f6677932f1a423b5c18ac5d5140a65c7f 7c92832b99f0c7aa0d1219eecce520a679e3374c nobu007 <contact645@gmail.com> 1733649055 +0900	commit: 結構いいんじゃないかな

```

### File: `.git\logs\refs\remotes\origin\main`

**Language:** 

**File Size:** 290 bytes
**Created:** 2024-12-08T15:31:06.731570
**Modified:** 2024-12-08T18:10:58.831632

```
0000000000000000000000000000000000000000 d09f1d6f6677932f1a423b5c18ac5d5140a65c7f nobu007 <contact645@gmail.com> 1733639466 +0900	update by push
d09f1d6f6677932f1a423b5c18ac5d5140a65c7f 7c92832b99f0c7aa0d1219eecce520a679e3374c nobu007 <contact645@gmail.com> 1733649058 +0900	update by push

```

### File: `.git\objects\06\65bca793f699ffd1247db9d6ba03d29695c2b6`

**Language:** 

**File Size:** 218 bytes
**Created:** 2024-12-08T15:30:53.639080
**Modified:** 2024-12-08T15:30:53.639080

```

```

### File: `.git\objects\16\ca831e597b8317fb0230ebacf491f2ca348601`

**Language:** 

**File Size:** 245 bytes
**Created:** 2024-12-08T15:30:53.278644
**Modified:** 2024-12-08T15:30:53.278644

```

```

### File: `.git\objects\17\2d646beab41f0acf7c35502e9f2100257a42e1`

**Language:** 

**File Size:** 91 bytes
**Created:** 2024-12-08T15:30:56.461390
**Modified:** 2024-12-08T15:30:56.461390

```

```

### File: `.git\objects\1e\ebbc9e69d4301b24b1968aa2f02a7a8b48b2f3`

**Language:** 

**File Size:** 498 bytes
**Created:** 2024-12-08T15:30:53.404093
**Modified:** 2024-12-08T15:30:53.404093

```

```

### File: `.git\objects\1e\f1f5cd044d420f365c8c7c37da2562fc1d4c2a`

**Language:** 

**File Size:** 226 bytes
**Created:** 2024-12-08T18:10:55.280613
**Modified:** 2024-12-08T18:10:55.281612

```

```

### File: `.git\objects\1f\259462c77fa3721a116433c9a039df282c86ac`

**Language:** 

**File Size:** 1904 bytes
**Created:** 2024-12-08T18:10:55.096895
**Modified:** 2024-12-08T18:10:55.096895

```

```

### File: `.git\objects\25\3b8dfb73344f5c6a4d94e4156946a5efb11d5e`

**Language:** 

**File Size:** 131 bytes
**Created:** 2024-12-08T15:30:56.511436
**Modified:** 2024-12-08T15:30:56.511436

```

```

### File: `.git\objects\2b\044c88b190f40129867d000e7f6693e93e03d7`

**Language:** 

**File Size:** 121 bytes
**Created:** 2024-12-08T15:30:53.045755
**Modified:** 2024-12-08T15:30:53.046755

```

```

### File: `.git\objects\30\f8d5bbbdb976b3ca14f1b3d70de6dafcae81d0`

**Language:** 

**File Size:** 92 bytes
**Created:** 2024-12-08T15:30:56.569763
**Modified:** 2024-12-08T15:30:56.569763

```

```

### File: `.git\objects\33\4da0ca5e7a0029f7d8ebcb402a82a02b5570a1`

**Language:** 

**File Size:** 304 bytes
**Created:** 2024-12-08T18:10:55.329375
**Modified:** 2024-12-08T18:10:55.330412

```

```

### File: `.git\objects\49\848733c3412cf73933eefb6ae7550d48256779`

**Language:** 

**File Size:** 1547 bytes
**Created:** 2024-12-08T18:10:55.054798
**Modified:** 2024-12-08T18:10:55.055800

```

```

### File: `.git\objects\4f\95d882242f5a07aa6ce050659e0ce1dde173f5`

**Language:** 

**File Size:** 617 bytes
**Created:** 2024-12-08T15:30:53.462354
**Modified:** 2024-12-08T15:30:53.462354

```

```

### File: `.git\objects\62\13802639bdcdc17b06aa863ff7156b4ede7558`

**Language:** 

**File Size:** 91 bytes
**Created:** 2024-12-08T15:30:56.618707
**Modified:** 2024-12-08T15:30:56.618707

```

```

### File: `.git\objects\67\9e88ef7d6594d1796473d05957ed047ba3ae8a`

**Language:** 

**File Size:** 228 bytes
**Created:** 2024-12-08T15:30:52.785692
**Modified:** 2024-12-08T15:30:52.786692

```

```

### File: `.git\objects\7c\92832b99f0c7aa0d1219eecce520a679e3374c`

**Language:** 

**File Size:** 264 bytes
**Created:** 2024-12-08T18:10:55.398059
**Modified:** 2024-12-08T18:10:55.398059

```

```

### File: `.git\objects\87\a8f450c51633a9fc1d7c6619bac83f4076bdd3`

**Language:** 

**File Size:** 97 bytes
**Created:** 2024-12-08T15:30:56.402349
**Modified:** 2024-12-08T15:30:56.402349

```

```

### File: `.git\objects\8b\98d5704bd75d3c17ed9848009a4822d884bca2`

**Language:** 

**File Size:** 908 bytes
**Created:** 2024-12-08T18:10:55.011928
**Modified:** 2024-12-08T18:10:55.011928

```

```

### File: `.git\objects\91\92a97c4c3119a070a2e9745e98e1b689d15992`

**Language:** 

**File Size:** 304 bytes
**Created:** 2024-12-08T15:30:56.735763
**Modified:** 2024-12-08T15:30:56.736762

```

```

### File: `.git\objects\92\6bfa96742e6e6653901ae95bbfdd696685a296`

**Language:** 

**File Size:** 515 bytes
**Created:** 2024-12-08T15:30:52.912602
**Modified:** 2024-12-08T15:30:52.912602

```

```

### File: `.git\objects\95\559d9d765342292123d43c78341464fc928155`

**Language:** 

**File Size:** 120 bytes
**Created:** 2024-12-08T18:10:55.163549
**Modified:** 2024-12-08T18:10:55.163549

```

```

### File: `.git\objects\96\f6864a0e9873e37a8856e886750db5fdf7cfc3`

**Language:** 

**File Size:** 842 bytes
**Created:** 2024-12-08T15:30:53.595877
**Modified:** 2024-12-08T15:30:53.595877

```

```

### File: `.git\objects\9c\797e9d0b5797ac9c378c60183c4e294f089441`

**Language:** 

**File Size:** 10780 bytes
**Created:** 2024-12-08T15:30:53.162178
**Modified:** 2024-12-08T15:30:53.162178

```

```

### File: `.git\objects\9c\8814993408795b621ddb64671858bc49f5b003`

**Language:** 

**File Size:** 152 bytes
**Created:** 2024-12-08T15:30:56.343767
**Modified:** 2024-12-08T15:30:56.343767

```

```

### File: `.git\objects\a2\3fd7a0c4cdd091499dc066fc4a3833b12655a6`

**Language:** 

**File Size:** 875 bytes
**Created:** 2024-12-08T15:30:52.878906
**Modified:** 2024-12-08T15:30:52.878906

```

```

### File: `.git\objects\ad\f220eebf8c0f9e3e6efca85f33d5adb275e61b`

**Language:** 

**File Size:** 38 bytes
**Created:** 2024-12-08T15:30:53.220938
**Modified:** 2024-12-08T15:30:53.220938

```

```

### File: `.git\objects\ad\f6432ecebaba1a4ee9ed1b0f73ae74b22089c6`

**Language:** 

**File Size:** 844 bytes
**Created:** 2024-12-08T18:10:55.128922
**Modified:** 2024-12-08T18:10:55.128922

```

```

### File: `.git\objects\b0\5588bbfb317cf67a9c7b5746f4145d85f3f4d7`

**Language:** 

**File Size:** 133 bytes
**Created:** 2024-12-08T15:30:53.104205
**Modified:** 2024-12-08T15:30:53.104205

```

```

### File: `.git\objects\bd\d8a0075af378071207fa52c8e8dd4c0741924c`

**Language:** 

**File Size:** 79 bytes
**Created:** 2024-12-08T15:30:53.519946
**Modified:** 2024-12-08T15:30:53.519946

```

```

### File: `.git\objects\bf\5d0a18b51fed81c261e3044c0c890c7f17fd05`

**Language:** 

**File Size:** 843 bytes
**Created:** 2024-12-08T15:30:53.371412
**Modified:** 2024-12-08T15:30:53.371412

```

```

### File: `.git\objects\d0\9f1d6f6677932f1a423b5c18ac5d5140a65c7f`

**Language:** 

**File Size:** 197 bytes
**Created:** 2024-12-08T15:30:56.787201
**Modified:** 2024-12-08T15:30:56.787201

```

```

### File: `.git\objects\d6\4e1b2765b7332f6c9043626bebb2732215e8bc`

**Language:** 

**File Size:** 882 bytes
**Created:** 2024-12-08T15:30:53.344740
**Modified:** 2024-12-08T15:30:53.345747

```

```

### File: `.git\objects\d7\e4d94ee208ae1286aba4ecc533666313809a9a`

**Language:** 

**File Size:** 1256 bytes
**Created:** 2024-12-08T15:30:52.970598
**Modified:** 2024-12-08T15:30:52.971102

```

```

### File: `.git\objects\da\b2c3c704e9ec0243e35e595f5270d568fcc4db`

**Language:** 

**File Size:** 1661 bytes
**Created:** 2024-12-08T15:30:53.187490
**Modified:** 2024-12-08T15:30:53.187490

```

```

### File: `.git\objects\e1\bec57b23002780247a0136e6ca3d8eba72392e`

**Language:** 

**File Size:** 138 bytes
**Created:** 2024-12-08T15:30:56.685796
**Modified:** 2024-12-08T15:30:56.686786

```

```

### File: `.git\objects\e5\410902dbb773ff98ccb164ee1ea54afddc3892`

**Language:** 

**File Size:** 791 bytes
**Created:** 2024-12-08T15:30:52.995589
**Modified:** 2024-12-08T15:30:52.995589

```

```

### File: `.git\objects\f5\8b3083544cd4ccf7bcb527028c0e9aaefd5373`

**Language:** 

**File Size:** 97 bytes
**Created:** 2024-12-08T15:30:56.291654
**Modified:** 2024-12-08T15:30:56.292658

```

```

### File: `.git\objects\f7\a690cd8b3b5d8ba505b65c21e8146d84085dc9`

**Language:** 

**File Size:** 996 bytes
**Created:** 2024-12-08T15:30:53.570564
**Modified:** 2024-12-08T15:30:53.570564

```

```

### File: `.git\refs\heads\main`

**Language:** 

**File Size:** 41 bytes
**Created:** 2024-12-08T18:10:55.447012
**Modified:** 2024-12-08T18:10:55.447012

```
7c92832b99f0c7aa0d1219eecce520a679e3374c

```

### File: `.git\refs\remotes\origin\main`

**Language:** 

**File Size:** 41 bytes
**Created:** 2024-12-08T18:10:58.830632
**Modified:** 2024-12-08T18:10:58.830632

```
7c92832b99f0c7aa0d1219eecce520a679e3374c

```

### File: `app-server\Dockerfile`

**Language:** 

**File Size:** 219 bytes
**Created:** 2024-12-07T09:44:08.388088
**Modified:** 2024-12-08T09:24:44.349179

```
FROM python:3.9-slim

WORKDIR /app

COPY send_mail.py ./

RUN apt-get update && apt-get install -y \
    iputils-ping \
    telnet \
    dnsutils

CMD ["sh", "-c", "python3 send_mail.py && tail -f /dev/null"]
```

### File: `app-server\send_mail.py`

**Language:** py

**File Size:** 883 bytes
**Created:** 2024-12-07T09:44:20.362875
**Modified:** 2024-12-08T14:11:22.240700

```py
import smtplib
import os

# デバッグログ
print("Starting email sending script...")

# SMTPサーバ情報
smtp_server = os.environ.get('SMTP_SERVER', 'smtp.example.local')
smtp_port = 25
print(f"Connecting to SMTP server: {smtp_server}:{smtp_port}")

# メール送信設定
from_email = "test@example.local"
to_email = "recipient@example.local"
subject = "Test Mail from App Server"
body = "This is a test email sent from app-server via dockerized SMTP server."

# メールフォーマット
message = f"Subject: {subject}\n\n{body}"

try:
    # SMTPサーバ接続とメール送信
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        print("Connected to SMTP server.")
        server.sendmail(from_email, to_email, message)
        print("Email sent successfully.")
except Exception as e:
    print("Error while sending email:", e)

```

### File: `bind\db.19.172.in-addr.arpa`

**Language:** arpa

**File Size:** 901 bytes
**Created:** 2024-12-08T14:06:27.894878
**Modified:** 2024-12-08T17:17:06.384528

```arpa
$TTL    86400
@       IN      SOA     example.local. root.example.local. (
                            2         ; Serial        ; シリアル番号を更新
                        604800         ; Refresh
                         86400         ; Retry
                       2419200         ; Expire
                         604800 )      ; Negative TTL
        IN      NS      ns.example.local.             ; ネームサーバーの指定
3       IN      PTR     ns.example.local.             ; ns のリバースエントリ
4       IN      PTR     smtp.example.local.           ; smtp のリバースエントリ
5       IN      PTR     app.example.local.            ; app のリバースエントリ
6       IN      PTR     client.example.local.         ; client のリバースエントリ
7       IN      PTR     pop3.example.local.           ; pop3 のリバースエントリ

```

### File: `bind\db.example.local`

**Language:** local

**File Size:** 1547 bytes
**Created:** 2024-12-06T22:23:27.786121
**Modified:** 2024-12-08T17:16:19.066592

```local
$TTL    86400                    ; デフォルトのキャッシュ期間（秒単位）
@       IN      SOA     example.local. root.example.local. (
                            4         ; Serial        ; ゾーンファイルのバージョン番号を更新
                        604800         ; Refresh      ; セカンダリDNSがデータを更新する間隔
                         86400         ; Retry        ; セカンダリDNSが再試行する間隔
                       2419200         ; Expire       ; データが無効になるまでの期間
                         604800 )      ; Negative TTL ; クエリが失敗した場合のキャッシュ期間
        IN      NS      ns.example.local.             ; このゾーンのネームサーバ
ns      IN      A       172.19.0.3  ; DNSサーバのIPアドレス
example.local.  IN      A       172.19.0.3  ; ドメイン自身のAレコード
smtp    IN      A       172.19.0.4  ; SMTPサーバのIPアドレス
app     IN      A       172.19.0.5  ; アプリサーバのIPアドレス
client  IN      A       172.19.0.6  ; クライアントのIPアドレス
pop3    IN      A       172.19.0.7  ; POP3サーバのIPアドレス

; リバースDNSエントリ
3       IN      PTR     ns.example.local.  ; ns のリバースエントリ
4       IN      PTR     smtp.example.local. ; smtp のリバースエントリ
5       IN      PTR     app.example.local.
6       IN      PTR     client.example.local.
7       IN      PTR     pop3.example.local.

```

### File: `bind\Dockerfile`

**Language:** 

**File Size:** 851 bytes
**Created:** 2024-12-08T15:49:58.772798
**Modified:** 2024-12-08T17:55:02.412019

```
FROM ubuntu/bind9:latest

# 必要なツールをインストール
RUN apt-get update && apt-get install -y \
    dnsutils \
    && apt-get clean

# rndc 設定を生成
RUN rndc-confgen -a -c /etc/bind/rndc.key && \
    chown bind:bind /etc/bind/rndc.key && \
    chmod 600 /etc/bind/rndc.key

# named.conf に controls セクションを追加
RUN echo 'controls { \
    inet 127.0.0.1 allow { any; } keys { "rndc-key"; }; \
};' >> /etc/bind/named.conf

# 必要な設定ファイルをコピー
COPY ./bind/named.conf /etc/bind/named.conf
COPY ./bind/db.example.local /etc/bind/db.example.local
COPY ./bind/db.19.172.in-addr.arpa /etc/bind/db.19.172.in-addr.arpa

# ディレクトリの権限を調整
RUN chown -R bind:bind /etc/bind

# デフォルトの BIND サーバー実行コマンド
CMD ["named", "-g", "-4"]

```

### File: `bind\named.conf`

**Language:** conf

**File Size:** 786 bytes
**Created:** 2024-12-06T22:20:36.676701
**Modified:** 2024-12-08T14:06:00.964918

```conf
options { 
    directory "/var/cache/bind";  // BINDがキャッシュデータを保存するディレクトリ
    listen-on { any; };           // すべてのインターフェースでDNSクエリを受け付ける
    allow-query { any; };         // すべてのクライアントからのクエリを許可する
};

zone "example.local" {
    type master;                  // このサーバがこのゾーンのマスターサーバであることを指定
    file "/etc/bind/db.example.local"; // ゾーンデータの設定ファイルを指定
};

zone "19.172.in-addr.arpa" {
    type master;                  // リバースゾーンのマスター設定
    file "/etc/bind/db.19.172.in-addr.arpa"; // リバースゾーン用のデータファイル
};

```

### File: `bind\rndc.key`

**Language:** key

**File Size:** 100 bytes
**Created:** 2024-12-08T15:47:06.149972
**Modified:** 2024-12-08T15:47:06.151009

```key
key "rndc-key" {
	algorithm hmac-sha256;
	secret "3W5wf5gQh2cXrPXCg9RpkeokDMLs84NbDRjGKWbSqrU=";
};

```

### File: `client\Dockerfile`

**Language:** 

**File Size:** 104 bytes
**Created:** 2024-12-07T09:46:59.189902
**Modified:** 2024-12-07T09:55:57.055548

```
FROM alpine:3.18
RUN apk update && apk add --no-cache bind-tools curl busybox-extras
CMD ["/bin/sh"]

```

### File: `client\test_mail.sh`

**Language:** sh

**File Size:** 113 bytes
**Created:** 2024-12-07T09:47:15.796411
**Modified:** 2024-12-07T09:47:20.197907

```sh
#!/bin/sh
# DNS解決テスト
nslookup smtp.example.local
# SMTPポートテスト
telnet smtp.example.local 25

```

### File: `etc\mailname`

**Language:** 

**File Size:** 20 bytes
**Created:** 2024-12-08T13:39:11.037933
**Modified:** 2024-12-08T13:39:20.542638

```
smtp.example.local

```

### File: `etc\nsswitch.conf`

**Language:** conf

**File Size:** 235 bytes
**Created:** 2024-12-07T22:04:27.047751
**Modified:** 2024-12-07T22:05:22.548125

```conf
passwd:         files
group:          files
shadow:         files
hosts:          files dns
networks:       files
protocols:      db files
services:       files
ethers:         files
rpc:            files
netgroup:       nis

```

### File: `etc\postfix\main.cf`

**Language:** cf

**File Size:** 873 bytes
**Created:** 2024-12-07T11:40:37.585436
**Modified:** 2024-12-08T20:14:09.662399

```cf
# サーバ設定
myhostname = smtp.example.local
mydomain = example.local
myorigin = $mydomain

# ネットワーク設定
inet_interfaces = all
mynetworks = 127.0.0.0/8 [::1]/128 172.19.0.0/16

# メールリレー制限（必須設定）
smtpd_relay_restrictions = permit_mynetworks, reject_unauth_destination

# メール配送設定
mydestination = $myhostname, localhost.$mydomain, localhost, example.local

# その他
smtpd_banner = $myhostname ESMTP $mail_name

# デバッグ用設定
debug_peer_level = 2
debug_peer_list = 127.0.0.1
debugger_command =
    PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
    ddd $daemon_directory/$process_name $process_id & sleep 5

compatibility_level = 2
# TLSの設定
smtpd_tls_security_level = none
smtp_tls_security_level = may

# 接続タイムアウトの設定
smtpd_helo_required = yes
```

### File: `etc\postfix\master.cf`

**Language:** cf

**File Size:** 836 bytes
**Created:** 2024-12-07T22:02:14.202922
**Modified:** 2024-12-08T15:22:52.310384

```cf
smtp      inet  n       -       n       -       -       smtpd
  -o debug_peer_list=smtp.example.local
  -o debug_peer_level=3
proxymap  unix  -       -       n       -       -       proxymap
rewrite   unix  -       -       n       -       -       trivial-rewrite
cleanup   unix  n       -       n       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
tlsmgr    unix  -       -       n       1000?   1       tlsmgr
bounce    unix  -       -       n       -       0       bounce
defer     unix  -       -       n       -       0       bounce
verify    unix  -       -       n       -       1       verify
relay     unix  -       -       n       -       -       smtp
smtp      unix  -       -       n       -       -       smtp
retry     unix  -       -       n       -       -       error
```

### File: `pop3\Dockerfile`

**Language:** 

**File Size:** 496 bytes
**Created:** 2024-12-07T14:16:55.544774
**Modified:** 2024-12-07T14:17:00.944796

```
FROM debian:bullseye-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    dovecot-pop3d \
    dovecot-core \
    && apt-get clean

# Dovecotの設定ファイルをコピー
COPY dovecot/dovecot.conf /etc/dovecot/dovecot.conf

# メールスプールディレクトリを作成
RUN mkdir -p /var/mail && \
    chmod -R 755 /var/mail && \
    chown -R dovecot:dovecot /var/mail

# デフォルトコマンド
CMD ["dovecot", "-F"]

```

### File: `pop3\dovecot\dovecot.conf`

**Language:** conf

**File Size:** 619 bytes
**Created:** 2024-12-07T14:17:38.497898
**Modified:** 2024-12-07T14:17:43.729303

```conf
disable_plaintext_auth = no   # 平文認証を許可（テスト用）
listen = *                   # 全てのインターフェースでリッスン
mail_location = mbox:/var/mail/%u   # 各ユーザーのメールスプール

protocols = pop3             # POP3プロトコルを有効化

service pop3-login {
  inet_listener pop3 {
    port = 110               # POP3のデフォルトポート
  }
}

passdb {
  driver = passwd-file       # ユーザー認証にファイルを使用
  args = /etc/dovecot/users
}

userdb {
  driver = passwd
}

auth_mechanisms = plain      # 認証方式

```

### File: `pop3\dovecot\users`

**Language:** 

**File Size:** 61 bytes
**Created:** 2024-12-07T14:17:59.085351
**Modified:** 2024-12-07T14:18:05.981058

```
user:{PLAIN}password:1000:1000::/var/mail/user::userdb_mail

```

### File: `smtp\Dockerfile`

**Language:** 

**File Size:** 1066 bytes
**Created:** 2024-12-07T11:17:12.979747
**Modified:** 2024-12-08T19:33:17.380066

```
FROM debian:bullseye-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    postfix \
    rsyslog \
    nano \
    iproute2 \
    dnsutils \
    procps \
    tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

# Postfixの設定ファイルをコピー
COPY etc/postfix/main.cf /etc/postfix/main.cf
COPY etc/postfix/master.cf /etc/postfix/master.cf

# /etc/aliases ファイルの作成（ただし newaliases は後で実行）
RUN echo "root: postmaster" > /etc/aliases

# 必要なソケットディレクトリを作成し、所有権を設定
RUN mkdir -p /var/spool/postfix/private && \
    chown -R postfix:postfix /var/spool/postfix/private

    # エイリアスマップを更新
RUN newaliases

# ログの設定
RUN echo "*.* /var/log/mail.log" > /etc/rsyslog.d/50-default.conf


# コンテナ起動時のコマンド
CMD ["sh", "-c", "service rsyslog start && postfix start-fg"]

```

### File: `smtp\Dockerfile.manual`

**Language:** manual

**File Size:** 842 bytes
**Created:** 2024-12-08T10:37:37.270757
**Modified:** 2024-12-08T10:45:23.257718

```manual
FROM debian:bullseye-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    postfix \
    rsyslog \
    iproute2 \
    dnsutils \
    procps \
    tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean

# ログの設定 (rsyslogの設定ファイルを /etc/rsyslog.d/ 配下に配置)
RUN echo "*.* /var/log/postfix.log" > /etc/rsyslog.d/50-default.conf
RUN sed -i 's/^\$ModLoad imklog/#\$ModLoad imklog/g' /etc/rsyslog.conf # imklogを読み込まないようにする
RUN sed -i 's/^\$ModLoad imuxsock/\#\$ModLoad imuxsock/g' /etc/rsyslog.conf
RUN sed -i 's/^#\$ModLoad imuxsock/\$ModLoad imuxsock/g' /etc/rsyslog.conf

CMD ["service", "rsyslog", "start", "&&", "postfix", "start-fg"]
```

### File: `smtp\init.sh`

**Language:** sh

**File Size:** 198 bytes
**Created:** 2024-12-08T13:25:54.924092
**Modified:** 2024-12-08T13:26:00.039844

```sh
#!/bin/bash

# エイリアスマップを更新
echo "Updating aliases..."
newaliases

# rsyslog と Postfix の起動
echo "Starting rsyslog and postfix..."
service rsyslog start
postfix start-fg

```

