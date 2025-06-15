# Proyecto Final – Image Compression Based on DCT

## English

This repository contains the final degree project on multimedia image compression for the Computer Engineering program at the University of Murcia. It implements and evaluates JPEG compression based on the Discrete Cosine Transform (DCT), comparing default and custom Huffman coding tables across a dataset of 12 BMP images. :contentReference[oaicite:3]{index=3}

**Key Features:**
- Conversion from RGB to YCbCr colour space and 8×8 block DCT transform.  
- Quantisation with adjustable quality factors: 1, 25, 50, 100, 250, 500, 1000.  
- Entropy coding with both default and custom Huffman tables.  
- Decompression and image reconstruction via inverse DCT.  
- Experimental evaluation on 12 images grouped by characteristics: colour charts, grayscale portraits, logos, real scenes, and animation frames.  
- Quantitative metrics: Mean Squared Error (MSE) and Compression Ratio (CR) for each factor and coding configuration.  
- Qualitative analysis with visual comparisons, tables, and semilogarithmic plots.  

## Español

Este repositorio contiene el proyecto final de Compresión Multimedia para el Grado en Ingeniería Informática de la Universidad de Murcia. Implementa y evalúa la compresión de imágenes JPEG basada en la Transformada Discreta del Coseno (DCT), comparando tablas de Huffman por defecto y personalizadas en un conjunto de 12 imágenes BMP. :contentReference[oaicite:4]{index=4}

**Características principales:**
- Conversión de RGB a espacio YCbCr y transformada DCT por bloques de 8×8 píxeles.  
- Cuantización con factores de calidad ajustables: 1, 25, 50, 100, 250, 500, 1000.  
- Codificación de entropía con tablas de Huffman por defecto y personalizadas.  
- Descompresión y reconstrucción de imagen mediante DCT inversa.  
- Evaluación experimental en 12 imágenes agrupadas por características: diagramas de color, retratos en escala de grises, logotipos, escenas reales y fotogramas de animación.  
- Métricas cuantitativas: Error Cuadrático Medio (MSE) y Relación de Compresión (RC) para cada factor y configuración.  
- Análisis cualitativo con comparaciones visuales, tablas y gráficos semilogarítmicos.  
