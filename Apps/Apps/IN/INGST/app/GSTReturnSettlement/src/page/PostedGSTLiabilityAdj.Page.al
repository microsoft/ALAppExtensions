// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

page 18325 "Posted GST Liability Adj."
{
    Caption = 'Posted GST Liability Adj.';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Posted GST Liability Adj.";
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entrys posting date.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the transaction is a sale or purchase.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entrys document number';
                }
                field("Adjusted Doc. Entry Type"; Rec."Adjusted Doc. Entry Type")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry type of the adjusted document.';
                }
                field("Adjusted Doc. Posting Date"; Rec."Adjusted Doc. Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the posting date of adjusted document number.';
                }
                field(Type; Rec.Type)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the type is G/L Account, Item, Resource, Fixed Asset or Charge (Item).';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Item No., G/L Account No. etc.';
                }

                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies  if the Source Type of the Entry is Customer, Vendor, Bank or G/L Account.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source number as per defined type in source type.';
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
                }
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST component code with which the entry was posted.';
                }
                field("GST Base Amount"; Rec."GST Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base amount on which GST percentage is applied.';
                }
                field("GST Amount"; Rec."GST Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculated GST amount calculated for the particular combination of GST group and state.';
                }
                field("Adjustment Amount"; Rec."Adjustment Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjustment amount.';
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies GST group code of the transaction.';
                }
                field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
                }
                field("GST %"; Rec."GST %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST rate applied on the GST ledger entry.';
                }
                field("GST Credit"; Rec."GST Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction is related GST credit availment or non-availment.';
                }
            }
        }
    }

    actions
    {
    }
}

