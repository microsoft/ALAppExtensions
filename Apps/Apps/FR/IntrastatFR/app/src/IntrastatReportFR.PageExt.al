// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 10852 "Intrastat Report FR" extends "Intrastat Report"
{
    layout
    {
        addafter("Currency Identifier")
        {
            field("Obligation Level"; Rec."Obligation Level")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the Obligation level used to filter the reported data.';
            }
            field("Transaction Specification Filter"; rec."Trans. Spec. Filter")
            {
                ApplicationArea = BasicEU;
                Caption = 'Transaction Specification Filter';
                ToolTip = 'Specifies a filter for which types of transactions on Intrastat lines that will be processed for the chosen obligation level. Leave the field blank to include all transaction specifications.';
            }
        }
    }
}