# Seven Segment Display Test

Proyecto simple para probar los displays de 7 segmentos de la FPGA.

## Funcionalidad

Muestra el valor de los switches SW[4:0] en formato hexadecimal en los displays HEX1-HEX0.

### Ejemplos:

| Switches (Binario) | Valor Decimal | Display (Hex) |
|-------------------|---------------|---------------|
| 00000             | 0             | 00            |
| 00001             | 1             | 01            |
| 01010             | 10            | 0A            |
| 01111             | 15            | 0F            |
| 10000             | 16            | 10            |
| 11111             | 31            | 1F            |

## Instrucciones de uso

### 1. Abrir el proyecto en Quartus

```bash
cd I_O_Implementation/7_segments_test
# Abrir SevenSegTest.qpf en Quartus Prime
```

### 2. Compilar el proyecto

- En Quartus: `Processing → Start Compilation`
- O presiona `Ctrl + L`

### 3. Cargar en la FPGA

- `Tools → Programmer`
- Selecciona el archivo `.sof` generado
- Click en `Start` para programar la FPGA

### 4. Probar

- Mueve los switches SW[4:0]
- Los displays HEX1-HEX0 mostrarán el valor en hexadecimal
- HEX2-HEX5 permanecerán apagados

## Archivos del proyecto

- `SevenSegTest.sv` - Módulo principal
- `SevenSegTest.qsf` - Configuración de Quartus (pines, dispositivo)
- `SevenSegTest.qpf` - Archivo de proyecto de Quartus
- `README.md` - Este archivo

## Hardware requerido

- FPGA DE1-SoC (Cyclone V 5CSEMA5F31C6)
- 5 switches (SW[4:0])
- 6 displays de 7 segmentos (solo se usan HEX1-HEX0)

## Notas

- Los displays son **activo bajo** (0 = segmento encendido, 1 = apagado)
- Solo se usan 2 displays (HEX1, HEX0) para mostrar valores 0-31 (0x00-0x1F)
- Los displays restantes se mantienen apagados (7'b1111111)
