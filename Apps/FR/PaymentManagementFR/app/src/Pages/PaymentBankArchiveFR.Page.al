// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 10832 "Payment Bank Archive FR"
{
    Caption = 'Bank Account Card';
    Editable = false;
    PageType = Card;
    SourceTable = "Payment Header Archive FR";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the name of your bank.';
                }
                field("Bank Address"; Rec."Bank Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of your bank.';
                }
                field("Bank Address 2"; Rec."Bank Address 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an additional part of the address of your bank.';
                }
                field("Bank Post Code"; Rec."Bank Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Code/City';
                    ToolTip = 'Specifies the postal code of your bank.';
                }
                field("Bank City"; Rec."Bank City")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the city of your bank.';
                }
                field("Bank Country/Region Code"; Rec."Bank Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of your bank.';
                }
                field("Bank Contact"; Rec."Bank Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact of your bank.';
                }
                field("Bank Branch No."; Rec."Bank Branch No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the branch number of your bank.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s account number at your bank.';
                }
                field(IBAN; Rec.IBAN)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the international bank account number (IBAN) for the payment slip.';
                }
                field("SWIFT Code"; Rec."SWIFT Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the international bank identification code for the payment slip.';
                }
            }
            group("R.I.B.")
            {
                Caption = 'R.I.B.';
                field("Bank Branch No.2"; Rec."Bank Branch No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the branch number of your bank.';
                }
                field("Agency Code"; Rec."Agency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the agency code of your bank.';
                }
                field("Bank Account No.2"; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company''s account number at your bank.';
                }
                field("RIB Key"; Rec."RIB Key")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the two-digit RIB key associated with the Bank Account No. RIB key value in range from 01 to 09 is represented in the single-digit form, without leading zero digit.';
                }
                field("RIB Checked"; Rec."RIB Checked")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the key entered in the RIB Key field is correct.';
                }
                field("National Issuer No."; Rec."National Issuer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment authorization number.';
                }
            }
        }
    }

    actions
    {
    }
}

