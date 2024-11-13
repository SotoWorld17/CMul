function RC=jcom_custom(fname,caliQ)

% jcom_custom: Compresion de imagenes aplicando tablas a medida

% Entradas:
%  fname: Un string con nombre de archivo, incluido sufijo
%         Admite BMP y JPEG, indexado y truecolor
%  caliQ: Factor de calidad (entero positivo >= 1)
%         100: calidad estándar
%         >100: menor calidad (más compresión)
%         <100: mayor calidad (menos compresión)
% Salidas:
%  RC: La relación de compresión

disptext=1; % Flag de verbosidad
if disptext
    disp('--------------------------------------------------');
    disp('Funcion jcom_custom:');
end

% Instante inicial
tc=cputime;

% Lee archivo de imagen
% Convierte a espacio de color YCbCr
% Amplia dimensiones a multiplos de 8
%  X: Matriz original de la imagen en espacio RGB
%  Xamp: Matriz ampliada de la imagen en espacio YCbCr
[X, Xamp, tipo, m, n, mamp, namp, TO]=imlee(fname);

% Preparar datos
caliQ_prep = uint32(caliQ);
m_prep = uint32(m);
n_prep = uint32(n);
mamp_prep = uint32(mamp);
namp_prep = uint32(namp);

% Calcula DCT bidimensional en bloques de 8 x 8 pixeles
Xtrans = imdct(Xamp);

% Cuantizacion de coeficientes
Xlab=quantmat(Xtrans, caliQ);

% Genera un scan por cada componente de color
%  Cada scan es una matriz mamp x namp
%  Cada bloque se reordena en zigzag
XScan=scan(Xlab);

% Codifica los tres scans, usando Huffman por defecto
[CodedY,CodedCb,CodedCr, Y_DC_Bits, Y_DC_Huffval, Y_AC_Bits, Y_AC_Huffval, Cb_DC_Bits, Cb_DC_Huffval, Cb_AC_Bits, Cb_AC_Huffval, Cr_DC_Bits, Cr_DC_Huffval, Cr_AC_Bits, Cr_AC_Huffval]=EncodeScans_custom(XScan); 

[CodedY_Bytes, CodedY_Long] = bits2bytes(CodedY);
[CodedCb_Bytes, CodedCb_Long] = bits2bytes(CodedCb);
[CodedCr_Bytes, CodedCr_Long] = bits2bytes(CodedCr);

uCodedY_Bytes = uint32(CodedY_Bytes);
uCodedCb_Bytes = uint32(CodedCb_Bytes);
uCodedCr_Bytes = uint32(CodedCr_Bytes);

uLengthBytesY = uint32(length(CodedY_Bytes));
uLengthBytesCb = uint32(length(CodedCb_Bytes));
uLengthBytesCr = uint32(length(CodedCr_Bytes));

uLongBitsY = uint32(CodedY_Long);
uLongBitsCb = uint32(CodedCb_Long);
uLongBitsCr = uint32(CodedCr_Long);

uY_DC_Bits = uint32(Y_DC_Bits);
uCb_DC_Bits = uint32(Cb_DC_Bits);
uCr_DC_Bits = uint32(Cr_DC_Bits);

uY_DC_Huffval = uint32(Y_DC_Huffval);
uCb_DC_Huffval = uint32(Cb_DC_Huffval);
uCr_DC_Huffval = uint32(Cr_DC_Huffval);

uY_AC_Bits = uint32(Y_AC_Bits);
uCb_AC_Bits = uint32(Cb_AC_Bits);
uCr_AC_Bits = uint32(Cr_AC_Bits);

uY_AC_Huffval = uint32(Y_AC_Huffval);
uCr_AC_Huffval = uint32(Cr_AC_Huffval);
uCb_AC_Huffval = uint32(Cb_AC_Huffval);

% Length de luminancia y crominancia
uLengthY_DC_Bits = uint32(length(Y_DC_Bits));
uLengthCb_DC_Bits = uint32(length(Cb_DC_Bits));
uLengthCr_DC_Bits = uint32(length(Cr_DC_Bits));

uLengthY_DC_Huffval = uint32(length(Y_DC_Huffval));
uLengthCb_DC_Huffval = uint32(length(Cb_DC_Huffval));
uLengthCr_DC_Huffval = uint32(length(Cr_DC_Huffval));

uLengthY_AC_Bits = uint32(length(Y_AC_Bits));
uLengthCb_AC_Bits = uint32(length(Cb_AC_Bits));
uLengthCr_AC_Bits = uint32(length(Cr_AC_Bits));

uLengthY_AC_Huffval = uint32(length(Y_AC_Huffval));
uLengthCr_AC_Huffval = uint32(length(Cr_AC_Huffval));
uLengthCb_AC_Huffval = uint32(length(Cb_AC_Huffval));


% Relación de compresión de la imagen
cabecera = length(caliQ_prep) + length(m_prep) + length(n_prep) + length(mamp_prep) + length(namp_prep);
cabecera = cabecera + length(uLengthBytesY) + length(uLengthBytesCb) + length(uLengthBytesCr);
cabecera = cabecera + length(uLongBitsY) + length(uLongBitsCb) + length(uLongBitsCr);

cabecera = cabecera + length(uY_DC_Bits) + length(uCb_DC_Bits) + length(uCr_DC_Bits);
cabecera = cabecera + length(uY_DC_Huffval) + length(uCb_DC_Huffval) + length(uCr_DC_Huffval);
cabecera = cabecera + length(uY_AC_Bits) + length(uCb_AC_Bits) + length(uCr_AC_Bits);
cabecera = cabecera + length(uY_AC_Huffval) + length(uCr_AC_Huffval) + length(uCb_AC_Huffval);

cabecera = cabecera + length(uLengthY_DC_Bits) + length(uLengthCb_DC_Bits) + length(uLengthCr_DC_Bits);
cabecera = cabecera + length(uLengthY_DC_Huffval) + length(uLengthCb_DC_Huffval) + length(uLengthCr_DC_Huffval);
cabecera = cabecera + length(uLengthY_AC_Bits) + length(uLengthCb_AC_Bits) + length(uLengthCr_AC_Bits);
cabecera = cabecera + length(uLengthY_AC_Huffval) + length(uLengthCr_AC_Huffval) + length(uLengthCb_AC_Huffval);

datos = length(uCodedY_Bytes) + length(uCodedCb_Bytes) + length(uCodedCr_Bytes); % tamaño en bytes de los datos
TF = cabecera + datos;

RC = (TO-TF)/TO*100;

% Archivo comprimido
[filepath,name,ext] = fileparts(fname);
archivo = strcat(filepath, name,'.hud');
fileID = fopen(archivo, 'w');

fwrite(fileID, [m_prep, n_prep, mamp_prep, namp_prep, caliQ_prep], 'uint32');

% Guardar datos comprimidos
fwrite(fileID, uLengthBytesY, 'uint32');
fwrite(fileID, uLengthBytesCb, 'uint32');
fwrite(fileID, uLengthBytesCr, 'uint32');

fwrite(fileID, uLongBitsY, 'uint32');
fwrite(fileID, uLongBitsCb, 'uint32');
fwrite(fileID, uLongBitsCr, 'uint32');

fwrite(fileID, uCodedY_Bytes, 'uint32');
fwrite(fileID, uCodedCb_Bytes, 'uint32');
fwrite(fileID, uCodedCr_Bytes, 'uint32');

% Guardar longitudes de cromancia y luminancia
fwrite(fileID, uLengthY_DC_Bits, 'uint32');
fwrite(fileID, uLengthCb_DC_Bits, 'uint32');
fwrite(fileID, uLengthCr_DC_Bits, 'uint32');
fwrite(fileID, uLengthY_DC_Huffval, 'uint32');
fwrite(fileID, uLengthCb_DC_Huffval, 'uint32');
fwrite(fileID, uLengthCr_DC_Huffval, 'uint32');
fwrite(fileID, uLengthY_AC_Bits, 'uint32');
fwrite(fileID, uLengthCb_AC_Bits, 'uint32');
fwrite(fileID, uLengthCr_AC_Bits, 'uint32');
fwrite(fileID, uLengthY_AC_Huffval, 'uint32');
fwrite(fileID, uLengthCr_AC_Huffval, 'uint32');
fwrite(fileID, uLengthCb_AC_Huffval, 'uint32');

% Guardar tablas Huffman
fwrite(fileID, uY_DC_Bits, 'uint32');
fwrite(fileID, uY_DC_Huffval, 'uint32');
fwrite(fileID, uY_AC_Bits, 'uint32');
fwrite(fileID, uY_AC_Huffval, 'uint32');
fwrite(fileID, uCb_DC_Bits, 'uint32');
fwrite(fileID, uCb_DC_Huffval, 'uint32');
fwrite(fileID, uCb_AC_Bits, 'uint32');
fwrite(fileID, uCb_AC_Huffval, 'uint32');
fwrite(fileID, uCr_DC_Bits, 'uint32');
fwrite(fileID, uCr_DC_Huffval, 'uint32');
fwrite(fileID, uCr_AC_Bits, 'uint32');
fwrite(fileID, uCr_AC_Huffval, 'uint32');


fclose(fileID);

% Tiempo de ejecucion
e=cputime-tc;

if disptext
    disp('--------------------------------------------------');
    disp('COMPRESION TERMINADA');
    disp('--------------------------------------------------');
    
    fprintf('%s %s\n', 'Archivo: ', archivo);
    fprintf('%s %1.6f\n', 'Tiempo total de CPU:', e);
    fprintf('%s %d %s %d\n', 'Tamaño original = ', TO, 'Tamaño tras la compresión: ', TF);
    fprintf('%s %2.5f %s\n', 'Relación de compresión (RC) = ', RC, '%');
        
    fprintf('%s %d %s\n', 'CodedY -> ', length(CodedY), ' bytes');
    fprintf('%s %d %s\n', 'CodedCb -> ', length(CodedCb), ' bytes');
    fprintf('%s %d %s\n', 'CodedCr -> ', length(CodedCr), ' bytes');

    fprintf('%s %d %s\n', 'sbytesY -> ', length(uCodedY_Bytes), ' bytes');
    fprintf('%s %d %s\n', 'sbytesCb -> ', length(uCodedCb_Bytes), ' bytes');
    fprintf('%s %d %s\n', 'sbytesCr -> ', length(uCodedCr_Bytes), ' bytes');

    disp('Terminado jcom_custom');
    disp('--------------------------------------------------');
end
end


