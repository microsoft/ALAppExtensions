// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

tableextension 18718 "Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(18716; "Include GST in TDS Base"; Boolean)
        {
            Caption = 'Include GST in TDS Base';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}
