#!/bin/bash

OUT=png
BUILD_DIR=./build
SRC_DIR=./src
TEST_DIR=./test
SYMB=$SRC_DIR/data.sym
USE_DEBUG=false

Debug () {
  if [ $USE_DEBUG = true ] ; then
    echo "\t$1"
  fi
}

Clean () {
  rm $BUILD_DIR/*.fst $BUILD_DIR/*.$OUT
}

Draw () {
  Debug "Drawing '$1' as a $OUT : '$BUILD_DIR/$1.$OUT'"
  fstdraw --isymbols=$SYMB --osymbols=$SYMB -portrait $BUILD_DIR/$1.fst | dot -T$OUT > $BUILD_DIR/$1.$OUT
}

Compile () {
  Debug "Compiling '$1' from '$2' : '$2/$1.txt' to '$BUILD_DIR/$1.fst'"
  fstcompile --isymbols=$SYMB --osymbols=$SYMB $2/$1.txt  > $BUILD_DIR/$1.fst
  Draw $1
}

Compose () {
  Debug "Composing $1 with $2 to $3"
  fstcompose $BUILD_DIR/$1.fst $BUILD_DIR/$2.fst > $BUILD_DIR/$3.fst
  Draw $3
}

Clean

################### letras ################
echo "Compiling tests"
Compile vinte $TEST_DIR
Compile doze $TEST_DIR
Compile quinze $TEST_DIR
Compile quarenta_e_cinco $TEST_DIR

################### Tradutores de tradução ################
#
# Compila e gera a versão gráfica do transdutor que traduz letra a letra
echo "Compiling src"
Compile horas $SRC_DIR
Compile minutos $SRC_DIR
Compile separador $SRC_DIR

Debug "Building final transducer"
fstconcat $BUILD_DIR/horas.fst $BUILD_DIR/separador.fst > $BUILD_DIR/t_intermedio.fst
fstconcat $BUILD_DIR/t_intermedio.fst $BUILD_DIR/minutos.fst > $BUILD_DIR/trans_final.fst
Draw trans_final

Debug "Building inverted transducer"
fstinvert $BUILD_DIR/trans_final.fst > $BUILD_DIR/trans_final_i.fst
Draw trans_final_i

################### Testa os tradutores ################
#
# Compila e gera a versão gráfica do transdutor que traduz Inglês em Português
echo "Applying tests"
Compose vinte horas vinte_t
Compose doze horas doze_t
Compose quarenta_e_cinco minutos quarenta_e_cinco_t
Compose quinze minutos quinze_t