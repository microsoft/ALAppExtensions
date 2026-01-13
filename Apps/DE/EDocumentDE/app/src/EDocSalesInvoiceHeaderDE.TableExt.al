// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.Sales.History;

tableextension 11037 "E-Doc Sales Invoice Header DE" extends "Sales Invoice Header"
{
    fields
    {
        field(11035; "Buyer Reference"; Text[100])
        {
            Caption = 'Buyer Reference';
            DataClassification = CustomerContent;
        }
    }
}