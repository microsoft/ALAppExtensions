// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Application;

using Microsoft.Finance.GST.Base;

page 18432 "Posted Reference Invoice No"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Reference Invoice No.";
    Caption = 'Posted Reference Invoice No.';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the document number for the reference.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies if the Source Type of the Entry is Customer,Vendor,Bank or G/L Account.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source number as per defined type in source type.';
                }
                field("Reference Invoice Nos."; Rec."Reference Invoice Nos.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the Reference Invoice number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the descriptive text that is associated with the reference document.';
                }
                field(Verified; Rec.Verified)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether the reference document is verified or not.';
                }
            }
        }
    }
}
