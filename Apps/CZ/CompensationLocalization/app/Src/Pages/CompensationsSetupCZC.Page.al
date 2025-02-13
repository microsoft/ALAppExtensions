// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

page 31270 "Compensations Setup CZC"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Compensations Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Compensations Setup CZC";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Compensation Bal. Account No."; Rec."Compensation Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number for compensations posting.';
                }
                field("Debit Rounding Account"; Rec."Debit Rounding Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the debit rounding account for compensation posting.';
                }
                field("Credit Rounding Account"; Rec."Credit Rounding Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the credit rounding account for compensation posting.';
                }
                field("Max. Rounding Amount"; Rec."Max. Rounding Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum amount by which compensation entries can be automatically applie.';
                }
                field("Compensation Proposal Method"; Rec."Compensation Proposal Method")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the compensation Entries will be proposed according Registration No. or Bussiness Relation.';
                }
                field("Show Empty when not Found"; Rec."Show Empty when not Found")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which customer/vendor entries to display if the system does not find any. If the value in the field is set to "NO", the entries of all other partners will be displayed, if set to "YES", the page will be blank.';
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Compensation Nos."; Rec."Compensation Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series for compensations numbering.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
