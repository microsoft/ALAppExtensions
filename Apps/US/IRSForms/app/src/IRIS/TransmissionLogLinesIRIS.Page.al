// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10069 "Transmission Log Lines IRIS"
{
    PageType = List;
    ApplicationArea = BasicUS;
    Caption = 'Transmission History Lines';
    SourceTable = "Transmission Log Line IRIS";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Groupings)
            {
                field(ID; Rec."Line ID")
                {
                }
                field("IRS 1099 Form Document ID"; Rec."IRS 1099 Form Document ID")
                {
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                }
                field("Vendor Federal ID No."; Rec."Vendor Federal ID No.")
                {
                }
                field("Form No."; Rec."Form No.")
                {
                }
                field("Submission Status Text"; Rec."Submission Status Text")
                {
                }
                field("Correction to Zeros"; Rec."Correction to Zeros")
                {
                }
            }
        }
    }
}