function XScanrec=DecodeScans_custom(CodedY,CodedCb,CodedCr,tam,Y_DC_Bits, Y_DC_Huffval, Y_AC_Bits, Y_AC_Huffval, C_DC_Bits, C_DC_Huffval, C_AC_Bits, C_AC_Huffval)

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
%   C_DC_Bits: Tabla de bits para DC de crominancia 
%   C_DC_Huffval: Tabla de valores Huffman para DC de crominancia 
%   C_AC_Bits: Tabla de bits para AC de crominancia 
%   C_AC_Huffval: Tabla de valores Huffman para AC de crominancia 

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
[C_DC_Huffsize, C_DC_Huffcode] = HCodeTables(C_DC_Bits, C_DC_Huffval);
[C_AC_Huffsize, C_AC_Huffcode] = HCodeTables(C_AC_Bits, C_AC_Huffval);

% Generar tablas Mincode, Maxcode y Valptr
[Mincode_Y_DC, Maxcode_Y_DC, Valptr_Y_DC] = HDecodingTables(Y_DC_Bits, Y_DC_Huffcode);
[Mincode_Y_AC, Maxcode_Y_AC, Valptr_Y_AC] = HDecodingTables(Y_AC_Bits, Y_AC_Huffcode);
[Mincode_C_DC, Maxcode_C_DC, Valptr_C_DC] = HDecodingTables(C_DC_Bits, C_DC_Huffcode);
[Mincode_C_AC, Maxcode_C_AC, Valptr_C_AC] = HDecodingTables(C_AC_Bits, C_AC_Huffcode);

% Decodificar cada scan
YScanrec = DecodeSingleScan(CodedY, Mincode_Y_DC, Maxcode_Y_DC, Valptr_Y_DC, Y_DC_Huffval, Mincode_Y_AC, Maxcode_Y_AC, Valptr_Y_AC, Y_AC_Huffval, tam);
CbScanrec = DecodeSingleScan(CodedCb, Mincode_Cb_DC, Maxcode_Cb_DC, Valptr_C_DC, C_DC_Huffval, Mincode_C_AC, Maxcode_C_AC, Valptr_C_AC, C_AC_Huffval, tam);
CrScanrec = DecodeSingleScan(CodedCr, Mincode_Cr_DC, Maxcode_Cr_DC, Valptr_C_DC, C_DC_Huffval, Mincode_C_AC, Maxcode_C_AC, Valptr_C_AC, C_AC_Huffval, tam);

% Reconstruir matriz 3-D
XScanrec = cat(3, YScanrec, CbScanrec, CrScanrec);

% Tiempo de ejecucion
e=cputime-tc;

if disptext
    disp('Scans decodificados');
    fprintf('Tiempo de CPU: %1.6f\n', e);
    disp('Terminado DecodeScans_custom');
end