function XScanrec=DecodeScans_custom(CodedY,CodedCb,CodedCr,tam,Y_DC_Bits, Y_DC_Huffval, Y_AC_Bits, Y_AC_Huffval, Cb_DC_Bits, Cb_DC_Huffval, Cb_AC_Bits, Cb_AC_Huffval, Cr_DC_Bits, Cr_DC_Huffval, Cr_AC_Bits, Cr_AC_Huffval)

% DecodeScans_custom: Decodifica los tres scans binarios usando tablas a medida

% Entradas:
%   CodedY: String binario con scan Y codificado
%   CodedCb: String binario con scan Cb codificado
%   CodedCr: String binario con scan Cr codificado
%   tam: Tamaño del scan a devolver [mamp namp]
%   Y_DC_Bits: Tabla de bits para DC de luminancia
%   Y_DC_Huffval: Tabla de valores Huffman para DC de luminancia
%   Y_AC_Bits: Tabla de bits para AC de luminancia
%   Y_AC_Huffval: Tabla de valores Huffman para AC de luminancia
%   Cb_DC_Bits: Tabla de bits para DC de crominancia Cb
%   Cb_DC_Huffval: Tabla de valores Huffman para DC de crominancia Cb
%   Cb_AC_Bits: Tabla de bits para AC de crominancia Cb
%   Cb_AC_Huffval: Tabla de valores Huffman para AC de crominancia Cb
%   Cr_DC_Bits: Tabla de bits para DC de crominancia Cr
%   Cr_DC_Huffval: Tabla de valores Huffman para DC de crominancia Cr
%   Cr_AC_Bits: Tabla de bits para AC de crominancia Cr
%   Cr_AC_Huffval: Tabla de valores Huffman para AC de crominancia Cr

% Salidas:
%  XScanrec: Scans reconstruidos de luminancia Y y crominancia Cb y Cr: Matriz mamp x namp X 3

disptext=1; % Flag de verbosidad
if disptext
    disp('--------------------------------------------------');
    disp('Funcion DecodeScans_custom:');
end

% Instante inicial
tc=cputime;

% Construir tablas Huffman para Luminancia y Crominancia usando tablas a medida

% Generar tablas Huffsize y Huffcode
[Y_DC_Huffsize, Y_DC_Huffcode] = HCodeTables(Y_DC_Bits, Y_DC_Huffval);
[Y_AC_Huffsize, Y_AC_Huffcode] = HCodeTables(Y_AC_Bits, Y_AC_Huffval);
[Cb_DC_Huffsize, Cb_DC_Huffcode] = HCodeTables(Cb_DC_Bits, Cb_DC_Huffval);
[Cb_AC_Huffsize, Cb_AC_Huffcode] = HCodeTables(Cb_AC_Bits, Cb_AC_Huffval);
[Cr_DC_Huffsize, Cr_DC_Huffcode] = HCodeTables(Cr_DC_Bits, Cr_DC_Huffval);
[Cr_AC_Huffsize, Cr_AC_Huffcode] = HCodeTables(Cr_AC_Bits, Cr_AC_Huffval);

% Generar tablas Mincode, Maxcode y Valptr
[Mincode_Y_DC, Maxcode_Y_DC, Valptr_Y_DC] = HDecodingTables(Y_DC_Bits, Y_DC_Huffcode);
[Mincode_Y_AC, Maxcode_Y_AC, Valptr_Y_AC] = HDecodingTables(Y_AC_Bits, Y_AC_Huffcode);
[Mincode_Cb_DC, Maxcode_Cb_DC, Valptr_Cb_DC] = HDecodingTables(Cb_DC_Bits, Cb_DC_Huffcode);
[Mincode_Cb_AC, Maxcode_Cb_AC, Valptr_Cb_AC] = HDecodingTables(Cb_AC_Bits, Cb_AC_Huffcode);
[Mincode_Cr_DC, Maxcode_Cr_DC, Valptr_Cr_DC] = HDecodingTables(Cr_DC_Bits, Cr_DC_Huffcode);
[Mincode_Cr_AC, Maxcode_Cr_AC, Valptr_Cr_AC] = HDecodingTables(Cr_AC_Bits, Cr_AC_Huffcode);

disp('Verificando tamaños de tablas Huffman en DecodeScans_custom:');
disp(['Tamaño de Mincode_Y_DC: ', num2str(length(Mincode_Y_DC))]);
disp(['Tamaño de Maxcode_Y_DC: ', num2str(length(Maxcode_Y_DC))]);
disp(['Tamaño de Valptr_Y_DC: ', num2str(length(Valptr_Y_DC))]);

disp('Valores de Mincode_Y_DC:');
disp(Mincode_Y_DC);
disp('Valores de Maxcode_Y_DC:');
disp(Maxcode_Y_DC);
disp('Valores de Valptr_Y_DC:');
disp(Valptr_Y_DC);

% Decodificar cada scan
YScanrec = DecodeSingleScan(CodedY, Mincode_Y_DC, Maxcode_Y_DC, Valptr_Y_DC, Y_DC_Huffval, Mincode_Y_AC, Maxcode_Y_AC, Valptr_Y_AC, Y_AC_Huffval, tam);
CbScanrec = DecodeSingleScan(CodedCb, Mincode_Cb_DC, Maxcode_Cb_DC, Valptr_Cb_DC, Cb_DC_Huffval, Mincode_Cb_AC, Maxcode_Cb_AC, Valptr_Cb_AC, Cb_AC_Huffval, tam);
CrScanrec = DecodeSingleScan(CodedCr, Mincode_Cr_DC, Maxcode_Cr_DC, Valptr_Cr_DC, Cr_DC_Huffval, Mincode_Cr_AC, Maxcode_Cr_AC, Valptr_Cr_AC, Cr_AC_Huffval, tam);

% Reconstruir matriz 3-D
XScanrec = cat(3, YScanrec, CbScanrec, CrScanrec);

% Tiempo de ejecucion
e=cputime-tc;

if disptext
    disp('Scans decodificados');
    fprintf('Tiempo de CPU: %1.6f\n', e);
    disp('Terminado DecodeScans_custom');
end