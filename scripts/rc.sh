DIR="$HOME/.rcs"
HOST=`echo $HOSTNAME | awk -F'[.]' '{print $2}'`
RCDIFF=`diff $HOME/.vimrc $DIR/vimrc`;

if [ ! -d "$DIR" ]; then
    echo "It doesn't look like you have ~/.rcs/ cloning git repo";
    git clone https://github.com/cygnusone/.rcs.git;
fi

if [ ! -z $RCDIFF ]; then
echo "would have got a new .rcs";
    rm -rf $DIR;
    git clone https://github.com/cygnusone/.rcs.git;
fi


if [ $HOST != 'employee-macbook' ]; then
    cd /var/hp/;
else
    cd $HOME;
fi
