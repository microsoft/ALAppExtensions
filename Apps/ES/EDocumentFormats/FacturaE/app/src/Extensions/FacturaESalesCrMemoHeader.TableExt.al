// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.Sales.History;

tableextension 10772 "Factura-E Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(10772; "Factura-E Reason Code"; Enum "Factura-E Cr. Memo Reason")
        {
            Caption = 'Factura-E Reason Code';
            DataClassification = CustomerContent;
        }
    }
}