// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

page 18873 "TCS Journal Templates"
{
    Caption = 'TCS Journal Templates';
    PageType = List;
    SourceTable = "TCS Journal Template";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    Caption = 'Name';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the journal template you are creating.';
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a brief description of the journal template you are creating.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    Caption = 'Source Code';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Source Code of the journal template you are creating.';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    Caption = 'Bal. Account Type';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account that a balancing entry is posted to, such as Bank or a Cash account.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    Caption = 'Bal. Account No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the general ledger, customer, vendor, or bank account that the balancing entry is posted to, such as a Cash account.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    Caption = 'No. Series';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series from which entry or record numbers are assigned to new entries or records.';
                }
                field("Posting No. Series"; Rec."Posting No. Series")
                {
                    Caption = 'Posting No. Series';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the number series that will be used to assign document numbers to ledger entries that are posted from this journal batch.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Te&mplate")
            {
                Caption = 'Te&mplate';
                Image = Template;

                action(Batches)
                {
                    Caption = 'Batches';
                    ApplicationArea = Basic, Suite;
                    Image = Description;
                    RunObject = Page "TCS Journal Batches";
                    RunPageLink = "Journal Template Name" = field(Name);
                    ToolTip = 'View or edit multiple journals for a specific template.';
                }
            }
        }
    }
}
