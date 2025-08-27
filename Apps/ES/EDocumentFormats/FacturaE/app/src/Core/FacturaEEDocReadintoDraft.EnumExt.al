namespace Microsoft.eServices.EDocument.Format.FacturaE;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;

enumextension 10773 "Factura-E EDoc Read into Draft" extends "E-Doc. Read into Draft"
{
    value(10773; "Factura-E")
    {
        Caption = 'Factura-E';
        Implementation = IStructuredFormatReader = "E-Document Factura-E Handler";
    }
}