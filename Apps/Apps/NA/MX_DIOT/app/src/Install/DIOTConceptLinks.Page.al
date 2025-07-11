// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 27031 "DIOT Concept Links"
{
    PageType = List;
    Editable = true;
    Caption = 'DIOT Concept Links';
    SourceTable = "DIOT Concept Link";
    DataCaptionExpression = StrSubstNo(DataCaptionTxt, Rec."DIOT Concept No.");
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Product Posting Group';
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Business Posting Group';
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
            }
        }
    }

    var
        DataCaptionTxt: Label 'Concept No. = %1', Comment = '%1 = DIOT Concept No. Field Value';
}
