// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Document;

tableextension 6242 "Sust. Production Order" extends "Production Order"
{
    fields
    {
        field(6210; "Sustainability Lines Exist"; Boolean)
        {
            Caption = 'Sustainability Lines Exist';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Prod. Order Line" where(Status = field(Status),
                                                   "Prod. Order No." = field("No."),
                                                   "Sust. Account No." = filter('<>''''')));
        }
    }
}