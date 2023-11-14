// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

page 11753 "Unreliable Payer Entries CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Unreliable Payer Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Unreliable Payer Entry CZL";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of vendor.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of vendor.';
                    Visible = false;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT registration number. The field will be used when you do business with partners from EU countries/regions.';
                }
                field("Unreliable Payer"; Rec."Unreliable Payer")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if vendor is unreliable payer.';
                }
                field("Check Date"; Rec."Check Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when unreliable payer report was checked.';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the entry.';
                }
                field("Public Date"; Rec."Public Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account public date (if entry type = bank account) or date when vendor was registered as unreliable payer (if entry type = payer).';
                }
                field("End Public Date"; Rec."End Public Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account end public date (if entry type = bank account) or date when vendor was registered as certainty payer (if entry type = payer).';
                }
                field("Full Bank Account No."; Rec."Full Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the full bank account number.';
                }
                field("Bank Account No. Type"; Rec."Bank Account No. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies type of bank account. Option: standard (if bank account number is standard account) or No standard (if bank account is IBAN).';
                }
                field("Tax Office Number"; Rec."Tax Office Number")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the tax office number for reporting.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number that is assigned to the entry.';
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CreateVendorBankAccountCZL)
            {
                Caption = 'Create Vendor Bank Account';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Create the account as a vendor''s bank account (if does not exists).';
                Image = BankAccount;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = New;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.CreateVendorBankAccountCZL(UnreliablePayerNoCZL);
                end;
            }
        }
    }

    var
        UnreliablePayerNoCZL: Code[20];

    procedure SetUnreliablePayerNoCZL(NewUnreliablePayerNoCZL: Code[20])
    begin
        UnreliablePayerNoCZL := NewUnreliablePayerNoCZL;
    end;
}
