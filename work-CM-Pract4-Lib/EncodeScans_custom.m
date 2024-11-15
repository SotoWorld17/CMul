function [CodedY,CodedCb,CodedCr, Y_DC_Bits, Y_DC_Huffval, Y_AC_Bits, Y_AC_Huffval, C_DC_Bits, C_DC_Huffval, C_AC_Bits, C_AC_Huffval]=EncodeScans_custom(XScan) 

% EncodeScans_custom: Codifica en binario los tres scan usando tablas a medida
% basadas en las frecuencias de los valores presentes en la imagen original

% Entradas:
%  XScan: Scans de luminancia Y y crominancia Cb y Cr: Matriz mamp x namp X 3
%  compuesta de:
%   YScan: Scan de luminancia Y: Matriz mamp x namp
%   CbScan: Scan de crominancia Cb: Matriz mamp x namp
%   CrScan: Scan de crominancia Cr: Matriz mamp x namp

% Salidas:
%   CodedY: String binario con scan Y codificado
%   CodedCb: String binario con scan Cb codificado
%   CodedCr: String binario con scan Cr codificado
%   Y_DC_Bits: Tabla de bits para DC de luminancia
%   Y_DC_Huffval: Tabla de valores Huffman para DC de luminancia
%   Y_AC_Bits: Tabla de bits para AC de luminancia
%   Y_AC_Huffval: Tabla de valores Huffman para AC de luminancia
%   C_DC_Bits: Tabla de bits para DC de crominancia 
%   C_DC_Huffval: Tabla de valores Huffman para DC de crominancia 
%   C_AC_Bits: Tabla de bits para AC de crominancia 
%   C_AC_Huffval: Tabla de valores Huffman para AC de crominancia 
% *DC: Representa el valor promedio del bloque de píxeles.
% *AC: Representa las variaciones dentro del bloque de píxeles.

disptext=1; % Flag de verbosidad
if disptext
    disp('--------------------------------------------------');
    disp('Funcion EncodeScans_custom:');
end

% Instante inicial
tc=cputime;

% Separa las matrices bidimensionales 
%  para procesar separadamente
YScan=XScan(:,:,1);
CbScan=XScan(:,:,2);
CrScan=XScan(:,:,3);

% Recolectar valores a codificar
[Y_DC_CP, Y_AC_ZCP]=CollectScan(YScan);
[Cb_DC_CP, Cb_AC_ZCP]=CollectScan(CbScan);
[Cr_DC_CP, Cr_AC_ZCP]=CollectScan(CrScan);

% Tablas de luminancia y crominancia
% Frecuencias de los valores DC y AC
Y_DC_Freq = Freq256(Y_DC_CP(:,1));
Y_AC_Freq = Freq256(Y_AC_ZCP(:,1));
C_DC_Freq = Freq256([Cb_DC_CP(:,1); Cr_DC_CP(:,1)]);
C_AC_Freq = Freq256([Cb_AC_ZCP(:,1); Cr_AC_ZCP(:,1)]);

% Generar tablas Bits y Huffval
[Y_DC_Bits, Y_DC_Huffval] = HSpecTables(Y_DC_Freq);
[Y_AC_Bits, Y_AC_Huffval] = HSpecTables(Y_AC_Freq);
[C_DC_Bits, C_DC_Huffval] = HSpecTables(C_DC_Freq);
[C_AC_Bits, C_AC_Huffval] = HSpecTables(C_AC_Freq);

% Generar tablas Huffsize y Huffcode
[Y_DC_Huffsize, Y_DC_Huffcode] = HCodeTables(Y_DC_Bits, Y_DC_Huffval);
[Y_AC_Huffsize, Y_AC_Huffcode] = HCodeTables(Y_AC_Bits, Y_AC_Huffval);
[C_DC_Huffsize, C_DC_Huffcode] = HCodeTables(C_DC_Bits, C_DC_Huffval);
[C_AC_Huffsize, C_AC_Huffcode] = HCodeTables(C_AC_Bits, C_AC_Huffval);


% Generar tablas Ehufco y Ehufsi
[ehuf_Y_DC_CO, ehuf_Y_DC_SI] = HCodingTables(Y_DC_Huffsize, Y_DC_Huffcode, Y_DC_Huffval);
[ehuf_Y_AC_CO, ehuf_Y_AC_SI] = HCodingTables(Y_AC_Huffsize, Y_AC_Huffcode, Y_AC_Huffval);
[ehuf_C_DC_CO, ehuf_C_DC_SI] = HCodingTables(C_DC_Huffsize, C_DC_Huffcode, C_DC_Huffval);
[ehuf_C_AC_CO, ehuf_C_AC_SI] = HCodingTables(C_AC_Huffsize, C_AC_Huffcode, C_AC_Huffval);

% Concatenar Ehufco y Ehufsi
ehuf_Y_DC = [ehuf_Y_DC_CO, ehuf_Y_DC_SI];
ehuf_Y_AC = [ehuf_Y_AC_CO, ehuf_Y_AC_SI];
ehuf_C_DC = [ehuf_C_DC_CO, ehuf_C_DC_SI];
ehuf_C_AC = [ehuf_C_AC_CO, ehuf_C_AC_SI];


% Codifica en binario cada Scan
% Las tablas de crominancia, ehuf_Cb_DC y ehuf_Cb_AC, se aplican, tanto a Cb, como a Cr
CodedY=EncodeSingleScan(YScan, Y_DC_CP, Y_AC_ZCP, ehuf_Y_DC, ehuf_Y_AC);
CodedCb=EncodeSingleScan(CbScan, Cb_DC_CP, Cb_AC_ZCP, ehuf_C_DC, ehuf_C_AC);
CodedCr=EncodeSingleScan(CrScan, Cr_DC_CP, Cr_AC_ZCP, ehuf_C_DC, ehuf_C_AC);

% Tiempo de ejecucion
e=cputime-tc;

if disptext
    disp('Componentes codificadas en binario');
    fprintf('Tiempo de CPU: %1.6f\n', e);
    disp('Terminado EncodeScans_custom');
end