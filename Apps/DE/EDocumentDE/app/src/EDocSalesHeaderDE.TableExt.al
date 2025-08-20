// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.Sales.Document;

tableextension 11036 "E-Doc Sales Header DE" extends "Sales Header"
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