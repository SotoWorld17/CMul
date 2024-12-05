function [MSE,RC]=jdes_dflt(fname) 
% jdes_dflt: Descompresion de imagenes aplicando tablas de Huffman

% Entradas:
%  fname: Un string con nombre de archivo, incluido sufijo
%
% Salidas:
%  MSE: El error cuadrático medio
%  RC: La relación de compresión

disptext=1; % Flag de verbosidad
if disptext
    disp('--------------------------------------------------');
    disp('Funcion jdes_dflt:');
end

% Leer archivo comprimido
fileID = fopen(fname, 'r');

% Leer argumentos para la descompresión
% fwrite(fileID, [m_prep, n_prep, mamp_prep, namp_prep, caliQ_prep], 'uint32');
m = double(fread(fileID, 1, 'uint32')); 
n = double(fread(fileID, 1, 'uint32')); 
mamp = double(fread(fileID, 1, 'uint32')); 
namp = double(fread(fileID, 1, 'uint32'));  
caliQ = double(fread(fileID, 1, 'uint32'));

lengthBytesY = double(fread(fileID, 1, 'uint32'));
lengthBytesCb = double(fread(fileID, 1, 'uint32'));
lengthBytesCr = double(fread(fileID, 1, 'uint32'));

longBitsY = double(fread(fileID, 1, 'uint32'));
longBitsCb = double(fread(fileID, 1, 'uint32'));
longBitsCr = double(fread(fileID, 1, 'uint32'));

uCodedY_Bytes = fread(fileID, lengthBytesY, 'uint32');
uCodedCb_Bytes = fread(fileID, lengthBytesCb, 'uint32');
uCodedCr_Bytes = fread(fileID, lengthBytesCr, 'uint32');

CodedY_Bytes = double(uCodedY_Bytes);
CodedCb_Bytes = double(uCodedCb_Bytes);
CodedCr_Bytes = double(uCodedCr_Bytes);

CodedY = bytes2bits(CodedY_Bytes, longBitsY);
CodedCb = bytes2bits(CodedCb_Bytes, longBitsCb);
CodedCr = bytes2bits(CodedCr_Bytes, longBitsCr);

fclose(fileID);

% Archivo descomprimido
[filepath,name,ext] = fileparts(fname);
outputFile = strcat('imagenes/default/', name,'_des_def.bmp');

% Decodifica los tres Scans a partir de strings binarios
XScanrec=DecodeScans_dflt(CodedY,CodedCb,CodedCr,[mamp namp]);

% Recupera matrices de etiquetas en orden natural a partir de orden zigzag
Xlabrec=invscan(XScanrec);

% Descuantizacion
Xtransrec=desquantmat(Xlabrec, caliQ);

% Calcula iDCT 
Xamprec = imidct(Xtransrec,m, n);

% Convierte a espacio de color RGB
rgbImage=round(ycbcr2rgb(Xamprec/255)*255);
Xrec=uint8(rgbImage);

% Repone el tamaño original
Xrec=Xrec(1:m,1:n, 1:3);

% Guardar la imagen descomprimida
imwrite(Xrec, outputFile);

% Relación de compresión de la imagen
cabecera = 4 * 5; % caliQ, m, n, mamp, namp con 4 bytes
datos = length(uCodedY_Bytes) + length(uCodedCb_Bytes) + length(uCodedCr_Bytes); % tamaño en bytes de los datos
TF = cabecera + datos;

originalImagePath = strcat('imagenes/', name, '.bmp');
[X, Xamp, tipo, m, n, mamp, namp, TO]=imlee(originalImagePath);

RC = (TO-TF)/TO*100;
diff = double(X(:)) - double(Xrec(:));
squaredDiff = diff.^2;
MSE = sum(squaredDiff) / numel(X);

if disptext
    disp('--------------------------------------------------');
    disp('DESCOMPRESION TERMINADA');
    subplot(1, 2, 1);
    imshow(X);
    title('Imagen Original');
    subplot(1, 2, 2);
    imshow(Xrec);
    title('Imagen Reconstruida');
    imshow(Xrec);
    title('Imagen Reconstruida');

    fprintf('%s %d %s %d\n', 'Tamaño original = ', TO, 'Tamaño tras la compresión: ', TF);
    fprintf('%s %2.5f %s\n', 'Relación de compresión (RC) = ', RC, '%');
    fprintf('%s %2.5f\n', 'Error Cuadrático Medio (MSE) = ', MSE);

    % Mostrar tamaños de componentes
    fprintf('%s %d %s\n', 'CodedY -> ', length(CodedY), ' bytes');
    fprintf('%s %d %s\n', 'CodedCb -> ', length(CodedCb), ' bytes');
    fprintf('%s %d %s\n', 'CodedCr -> ', length(CodedCr), ' bytes');

    % Mostrar tamaños de bytes usados por cada componente 
    fprintf('%s %d %s\n', 'sbytesY -> ', length(uCodedY_Bytes), ' bytes');
    fprintf('%s %d %s\n', 'sbytesCb -> ', length(uCodedCb_Bytes), ' bytes');
    fprintf('%s %d %s\n', 'sbytesCr -> ', length(uCodedCr_Bytes), ' bytes');

   
    disp('Terminado jdes_dftl');
    disp('--------------------------------------------------');
end
end
