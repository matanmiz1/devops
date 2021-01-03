#!/bin/bash

call() {
	echo
	echo "You chose to call $1"
}

quitprogram() {
	echo
	echo "Bye Bye"
}

mainmenu () {
  echo "Press 1 to call miz"
  echo "Press 2 to call fish"
  echo "Press x to exit the script"
  read -n 1 -p "Input Selection:" mainmenuinput
  if [ "$mainmenuinput" = "1" ]; then
            call "MIZ"
        elif [ "$mainmenuinput" = "2" ]; then
            call "FISH"
        elif [ "$mainmenuinput" = "x" ];then
            quitprogram
        else
            echo "You have entered an invallid selection!"
            echo "Please try again!"
            echo ""
            echo "Press any key to continue..."
            read -n 1
            clear
            mainmenu
        fi
}

# This builds the main menu and routs the user to the function selected.
mainmenu
