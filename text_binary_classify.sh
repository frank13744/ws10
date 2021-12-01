#!/bin/bash
# Author: Frank Cai
# Creation Date: 11/30/2021
#
# Usage: This script takes the following two parameters to train two classes using weka
#       Parameter 1: The absolute path to weka installation.
#       Parameter 2: The absolute path to the directory with classes and files to train up on,
#                    which should have the following tree structure.
#                      |
#                      +- train_directory
#                         |
#                         +- class1
#                         |  |
#                         |  +- c1_file1.txt
#                         |  |
#                         |  +- c1_file2.txt
#                         |  |
#                         |  ...
#                         +- class2
#                         |  |
#                         |  +- c2_file1.txt
#                         |  |
#                         |  +- c2_file2.txt
#                         |  |
#                         |  ...
#

# checks number of arguments
if [ "$#" -ne 2 ]; then
        echo "Needs 2 arguments to run script"
        exit
fi

weka_path=$1
train_path=$2

# check weka path
if [ ! -d "$weka_path" ]; then
	echo "Directory $weka_path does not exists."
	exit
fi

# check train path
if [ ! -d "$train_path" ]; then
	echo "Directory $train_path does not exists."
	exit
fi

# update CLASSPATH and PATH
export CLASSPATH=${CLASSPATH}:$weka_path/weka.jar:$weka_path/libsvm.jar
export PATH=${PATH}:$weka_path

# get the base name from the train path
train_file=`basename $train_path`

echo $weka_path
echo $train_path
echo $train_file

# convert the the text files to an .arff file
java weka.core.converters.TextDirectoryLoader -dir "$train_path" > "$train_file".arff

# convert the .arff file to a word vector
java -Xmx1024m weka.filters.unsupervised.attribute.StringToWordVector -i "$train_file".arff -o "$train_file"_training.arff -M 2

# run weka classifier
java -Xmx1024m  weka.classifiers.meta.ClassificationViaRegression -W weka.classifiers.trees.M5P -num-decimal-places 4  -t  "$train_file"_training.arff -d "$train_file"_training.model -c 1

