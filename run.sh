#!/bin/bash

OUT=pdf
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

# $1: Name of the test file
# $2: Name of transducer to use
Test () {
  Debug "Running test '$1'"
  Compile $1 $TEST_DIR
  Compose $1 $2 $1_composed
}

Union() {
  fstunion $BUILD_DIR/$1.fst $BUILD_DIR/$2.fst > $BUILD_DIR/$3.fst
}

Concat() {
  fstconcat $BUILD_DIR/$1.fst $BUILD_DIR/$2.fst > $BUILD_DIR/$3.fst
}

Clean

################### Tradutores de tradução ################
#
# Compila e gera a versão gráfica do transdutor que traduz letra a letra
echo "Compiling src"
Compile horas $SRC_DIR
Compile minutos $SRC_DIR
Compile separador $SRC_DIR

Compile uma_duas $SRC_DIR
Compile um_dois $SRC_DIR
Compile tres_nove $SRC_DIR
Compile dez_dezanove $SRC_DIR
Compile meio_dia $SRC_DIR
Compile vinte $SRC_DIR
Compile zero $SRC_DIR
Compile trinta_cinquenta $SRC_DIR
Compile tres_nove $SRC_DIR
Compile zero_muted $SRC_DIR
Compile duplo_zero $SRC_DIR
Compile numero_composto $SRC_DIR
Compile um_quarto $SRC_DIR

Compile horas_d $SRC_DIR

Union zero_muted um_dois zero_dois
Union zero_dois tres_nove zero_nove

Union zero_muted uma_duas zero_duas
Union zero_duas tres_nove zero_nove_f

Concat vinte numero_composto vinte_1
Concat vinte_1 zero_nove vinte_complete
Draw vinte_complete

Concat vinte numero_composto vinte_f_1
Concat vinte_f_1 zero_nove_f vinte_complete_f
Draw vinte_complete_f

Union vinte trinta_cinquenta vinte_cinquenta_1
Concat vinte_cinquenta_1 numero_composto vinte_cinquenta_2
Concat vinte_cinquenta_2 zero_nove vinte_cinquenta_complete

# Compiles minutes transducer
Union dez_dezanove um_quarto minutos_d_1
Union minutos_d_1 vinte_cinquenta_complete minutos_d_2
Union minutos_d_2 duplo_zero minutos_d_final
Draw minutos_d_final

# Compiles hours transducer
Union dez_dezanove meio_dia horas_d_1
Union horas_d_1 vinte_complete_f horas_d_2
Union horas_d_2 duplo_zero horas_d_final
Draw horas_d_final


Debug "Building final transducer"
Concat horas_d_final separador t_intermedio
Concat t_intermedio minutos_d_final trans_final
Draw trans_final

Debug "Building inverted transducer"
fstinvert $BUILD_DIR/trans_final.fst > $BUILD_DIR/trans_final_i.fst
Draw trans_final_i

################### Testa os tradutores ################
#
# Compila e gera a versão gráfica do transdutor que traduz Inglês em Português
echo "Applying tests"
Test 11_29 trans_final
Test 12_30 trans_final
Test 18_15 trans_final
Test 6_3 trans_final
Test 06_03 trans_final
Test 00_56 trans_final
Test 0_48 trans_final
Test nove_e_trinta_e_seis trans_final_i
