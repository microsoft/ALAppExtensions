// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

tableextension 5019 "Serv. Decl. Sales Header" extends "Sales Header"
{
    fields
    {
        field(5010; "Applicable For Serv. Decl."; Boolean)
        {
            Caption = 'Applicable For Service Declaration';
            Editable = false;
        }
    }
}
