#!/bin/bash
MAILDIR=/var/mail/working
DESTINATION=/output
DEBUG=0

echo "== $(date -Is) =="

# retrieve
fetchmail

# shuffle around some files to the working directory
mv $MAILDIR/new/* $MAILDIR/landing/
cd $MAILDIR/landing/

# process each message in a loop
shopt -s nullglob
for i in *
do
	echo "[$(date '+%T')] Backing up $i and processing..."
	cp $i $MAILDIR/cur/
	mkdir -p $MAILDIR/extracted/$i
	mv $i $MAILDIR/extracted/$i/

	ripmime -q --no-nameless -d $MAILDIR/extracted/$i -i $MAILDIR/extracted/$i/$i

	if [ -f /config/custom-handler ]; then
		# allow custom handler script to do something here
		exec /config/custom-handler "$MAILDIR/extracted/$i/"
	fi

	echo "[$(date '+%T')] Copying extracted attachments, if any..."
	# need to extract date from email header
	MSGTIMESTAMP=$(cat $MAILDIR/extracted/$i/$i | sed -n 's/^Date: *\([^\n]*\)/\1/p')
	MSGDATE=$(date --date="$MSGTIMESTAMP" '+%F')
	MSGTIME=$(date --date="$MSGTIMESTAMP" '+%H%M%S')
	mkdir -p $DESTINATION/$MSGDATE/$MSGTIME
	rm $MAILDIR/extracted/$i/$i
    find $MAILDIR/extracted/$i/ -type f \
	  -execdir cp -v --no-preserve=mode,ownership "{}" "$DESTINATION/" \; \
	  -exec rm "{}" \;

	if [[ $DEBUG -eq 0 ]]; then
		rm -fr $MAILDIR/extracted/$i/
	fi
done

shopt -u nullglob

echo "[$(date '+%T')] Done!"
