#!/bin/sh

#________________________________________________________________________________________________
#
#Projet Bourne Shell : Logiciel de versionnage de fichiers.
#@Author : Maxime Martin
#
#Le projet n'est pas totalement terminé (il ne prend pas en compte dans toutes les fonctions les 
#chemins de fichiers) je n'ai pas réussi à y arriver en étant seul.
#
#________________________________________________________________________________________________

#Fonction permettant de savoir si un dossier existe.
test_dir(){
	if [ -d ./.version ]
	then return 1
	else return 0
	fi
}

#Fonction permettant de savoir si le dossier est vide.
dossier_vide(){
	result=$(ls ./.version/)
	if test -n "$result"
	then return 1
	else return 0
	fi
}


if [ $# -le 1 ]
then 
	echo "Usage: version.sh <cmd> <file> [option]"
	echo "where <cmd> can be: add checkout commit diff log revert rm"
	
else
	DIR=$(dirname $2)
	FIC=$(basename $2)
	
	#Si le fichier n'éxiste pas : erreur.
	if [ ! -f $2 ]
	then 
		echo "Error ! ’$FIC’ is not a file."
	else
	
	#Je teste le dossier pour m'y rendre et le créer si nécessaire.
	if test_dir
	then
		cd $DIR
		mkdir .version
	else
		cd $DIR
	fi
	
			case $1 in
				
				#Le add permet d'ajouter un nouveau fichier au versioning, et le copie en .1 et .latest
				add)					
					if [ ! -f .version/$FIC.1 ]
					then 
						cd ./.version
						cp ../$FIC $FIC.1
						cp ../$FIC $FIC.latest
						echo "Added a new file under versioning: '$FIC'"
					else
						echo "'$FIC' is already under versioning."
					fi
				;;
				
				#Je n'ai pas réussi à faire fonctionner checkout correctement.
				checkout)
					if [ $3 ]
					then
						nCheck=$3
						if [ -f ./.version/$FIC."$nCheck" ]
						then 
							i=0
							cp ./.version/$FIC.1 $2
							while [ $i -lt $nCheck ]
							do
								i=$[i + 1]
								patch -us ../$2 ./.version/$FIC."$i"
							done
						else echo "Error ! '$FIC.$nCheck' doesn't exist."
						fi
					else echo "Please enter a number for checkout."
					fi
				;;
				
				#J'ai préferé utiliser une commande plus exotique que 'ls | grep "..." -c', c'était plus drôle à faire.
				commit)
					cd ./.version
					nCommit=$(ls | grep "\b$FIC\b" | cut -d. -f2 | sort -gr | head -n 1)
					
					#Je regarde ici pour voir si les deux fichiers sont différents.
					if ! cmp -s ../$2 $FIC.latest
					then
						nCommit=$[nCommit + 1]
						diff -u ../$2 $FIC.latest > $FIC."$nCommit"
						echo "Committed a new version : $nCommit"
						cp ../$2 $FIC.latest
					else
						echo "No changes since last time"
					fi
				;;
				
				#Diff sert seulement à montrer la différence entre le fichier actuel et la dernière version versionnée.
				diff)
					diff -u $2 ./.version/$FIC.latest
				;;
				
				#Pour connaître le nombre de versions, je compte le nombre de fichiers et enlève 1 pour le .latest.
				#Les caractères '\b' permettent de différencier toto de tototo par exemple.
				log)
					cd ./.version
					nLog=$(ls | grep "\b$FIC\b" -c)
					nLog=$[nLog - 1]
					echo "Already commited $nLog versions"					
				;;
				
				#Revert permet de revenir à la dernière version enregistrée, soit .latest.
				revert)
					cp ./.version/$FIC.latest $2
					echo "Reverted to the latest version."
				;;
				
				#Rm me permet de supprimer toutes les versions d'un fichier.
				#Le read permet de pouvoir choisir un caractère sur le clavier.
				rm)
					echo "Are you sure you want to delete '$FIC' from versioning ? : (y/N)"
					read CHOIX_SUPPR
					
					if [ "$CHOIX_SUPPR" = "Y" ] || [ "$CHOIX_SUPPR" = "y" ]
					then 
						rm ./.version/$FIC.*
						if dossier_vide
						then
							rmdir ./.version/
						fi
						echo "'$FIC' is not under versioning anymore."
					else echo "Delete cancelled."
					fi
				;;
				
				#Si la commande n'est pas dans la liste de choix, affichage de cette erreur.
				*)
					echo "Error! This command name does not exist: '$1'"
				;;
			esac
		fi
	fi

