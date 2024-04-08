// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Purchases.Setup;
pageextension 6162 "E-Doc. Purch. Payables Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Document Default Line Type")
        {
            field("E-Document Matching Difference"; Rec."E-Document Matching Difference")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the maximum allowed percentage of cost differece when matching incoming E-Document line with Purchase Order line';
            }
        }
    }
}