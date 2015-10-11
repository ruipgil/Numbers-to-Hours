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

echo "Compiling src"
for file in $SRC_DIR/*.txt; do
  name=${file##*/}
  base=${name%.txt}
  Compile $base $SRC_DIR
done


echo "Making unions and concatenations"
Union zero_muted um_dois zero_dois
Union zero_dois tres_nove zero_nove

Union zero_muted uma_duas zero_duas
Union zero_duas tres_nove zero_nove_f

Union um_dois tres_nove um_nove
Union um_nove zero_muted zero_nove
Concat numero_composto zero_nove zero_nove_ncomposto

Union uma_duas tres_nove uma_nove
Union uma_nove zero_muted zero_nove_f
Concat numero_composto uma_nove zero_nove_ncomposto_f

Union um_nove zero zero_nove_unmuted
Union uma_nove zero zero_nove_unmuted_f

Concat zero_optional zero_nove_unmuted um_digito
Concat zero_optional zero_nove_unmuted_f um_digito_f

#Concat vinte zero_nove_ncomposto vinte_complete
Concat vinte zero_nove_ncomposto_f vinte_complete_f

Union vinte trinta_cinquenta vinte_cinquenta
Concat vinte_cinquenta zero_nove_ncomposto vinte_cinquenta_complete

# Compiles minutes transducer
Union dez_dezanove um_quarto minutos_d_1
Union minutos_d_1 vinte_cinquenta_complete minutos_d_2
Union minutos_d_2 um_digito_f minutos
rm $BUILD_DIR/minutos_d_1.fst $BUILD_DIR/minutos_d_2.fst
Draw minutos

# Compiles hours transducer
Union dez_dezanove meio_dia horas_d_1
Union horas_d_1 vinte_complete_f horas_d_2
Union horas_d_2 um_digito horas
rm $BUILD_DIR/horas_d_1.fst $BUILD_DIR/horas_d_2.fst
Draw horas


echo "Building final transducer"
Concat horas separador t_intermedio
Concat t_intermedio minutos trans_final
rm $BUILD_DIR/t_intermedio.fst
Draw trans_final

echo "Building inverted transducer"
fstinvert $BUILD_DIR/trans_final.fst > $BUILD_DIR/trans_final_i.fst
Draw trans_final_i

# Tests
echo "Applying tests"
Test 11_29 trans_final
Test 12_30 trans_final
Test 18_15 trans_final
Test 6_3 trans_final
Test 06_03 trans_final
Test 00_56 trans_final
Test 0_48 trans_final
Test nove_e_trinta_e_seis trans_final_i
