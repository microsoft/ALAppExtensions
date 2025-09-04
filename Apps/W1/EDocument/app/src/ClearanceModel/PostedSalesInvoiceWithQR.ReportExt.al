// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Sales.History;

reportextension 6166 "PostedSalesInvoiceWithQR" extends "Standard Sales - Invoice"
{

    dataset
    {
        add(Header)
        {
            column(QR_Code_Image; "QR Code Image")
            {
            }
            column(QR_Code_Image_Lbl; FieldCaption("QR Code Image"))
            {
            }
        }
    }

    rendering
    {
        layout("StandardSalesInvoice.docx")
        {
            Type = Word;
            LayoutFile = './src/ClearanceModel/StandardSalesInvoicewithQR.docx';
            Caption = 'Standard Sales Invoice - E-Document (Word)';
            Summary = 'The Standard Sales Invoice - E-Document (Word) provides the layout including E-Document QR code support.';
        }
    }
}
