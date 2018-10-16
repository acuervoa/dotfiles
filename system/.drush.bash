# Include Drush bash customizations.
if [ -f "/Users/"$(whoami)"/.drush/drush.bashrc" ] ; then
  source ~/.drush/drush.bashrc
fi


# Include Drush completion.

if [ -f "/Users/"$(whoami)"/.drush/drush.complete.sh" ] ; then
  source ~/.drush/drush.complete.sh
fi


# Include Drush prompt customizations.

if [ -f "/Users/"$(whoami)"/.drush/drush.prompt.sh" ] ; then
  source ~/.drush/drush.prompt.sh
fi
