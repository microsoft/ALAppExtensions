// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

enum 10772 "Factura-E Cr. Memo Reason"
{
    value(1; "01")
    {
        Caption = '01 Número de la factura', Locked = true;
    }
    value(2; "02")
    {
        Caption = '02 Serie de la factura', Locked = true;
    }
    value(3; "03")
    {
        Caption = '03 Fecha expedición', Locked = true;
    }
    value(4; "04")
    {
        Caption = '04 Nombre y apellidos/Razón social - Emisor', Locked = true;
    }
    value(5; "05")
    {
        Caption = '05 Nombre y apellidos/Razón social - Receptor', Locked = true;
    }
    value(6; "06")
    {
        Caption = '06 Identificación fiscal Emisor/Obligado', Locked = true;
    }
    value(7; "07")
    {
        Caption = '07 Identificación fiscal Receptor', Locked = true;
    }
    value(8; "08")
    {
        Caption = '08 Domicilio Emisor/Obligado', Locked = true;
    }
    value(9; "09")
    {
        Caption = '09 Domicilio Receptor', Locked = true;
    }
    value(10; "10")
    {
        Caption = '10 Detalle Operación', Locked = true;
    }
    value(11; "11")
    {
        Caption = '11 Porcentaje impositivo a aplicar', Locked = true;
    }
    value(12; "12")
    {
        Caption = '12 Cuota tributaria a aplicar', Locked = true;
    }
    value(13; "13")
    {
        Caption = '13 Fecha/Periodo a aplicar', Locked = true;
    }
    value(14; "14")
    {
        Caption = '14 Clase de factura', Locked = true;
    }
    value(15; "15")
    {
        Caption = '15 Literales legales', Locked = true;
    }
    value(16; "16")
    {
        Caption = '16 Base imponible', Locked = true;
    }
    value(80; "80")
    {
        Caption = '80 Cálculo de cuotas repercutidas', Locked = true;
    }
    value(81; "81")
    {
        Caption = '81 Cálculo de cuotas retenidas', Locked = true;
    }
    value(82; "82")
    {
        Caption = '82 Base imponible modificada por devolución de envases/embalajes', Locked = true;
    }
    value(83; "83")
    {
        Caption = '83 Base imponible modificada por descuentos y bonificaciones', Locked = true;
    }
    value(84; "84")
    {
        Caption = '84 Base imponible modificada por resolución firme judicial o administrativa', Locked = true;
    }
    value(85; "85")
    {
        Caption = '85 Base imponible modificada cuotas repercutidas no satisfechas. Auto de declaración de concurso', Locked = true;

    }
}