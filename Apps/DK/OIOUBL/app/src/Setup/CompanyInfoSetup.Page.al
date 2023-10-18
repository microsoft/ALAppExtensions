// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.Company;

page 13647 "OIOUBL-Company Info. Setup"
{
    PageType = Card;
    SourceTable = "Company Information";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("OIOUBL-VAT Registration No."; "VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the company''s VAT registration number.';
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the company''s name and corporate form such as Aps. or A/S.';
                }
                field(Address; Address)
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the company''s address.';
                }
                field(City; City)
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the company''s city.';
                }
                field("OIOUBL-Post Code"; "Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the postal code.';
                }
                field("OIOUBL-Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the country/region of the address.';
                }
            }
            group("Account Details")
            {
                Caption = 'Account details';

                group("Fill in either")
                {
                    Caption = 'Fill in either', Comment = 'Part of: Fill in either <some fields> or <other fields>';
                    field("OIOUBL-Bank Branch No."; "Bank Branch No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Tooltip = 'Specifies the bank''s branch number.';
                    }
                    field("OIOUBL-Bank Account No."; "Bank Account No.")
                    {
                        ApplicationArea = Basic, Suite;
                        Tooltip = 'Specifies the company''s bank account number.';
                    }
                }
                group("OR")
                {
                    Caption = 'or', Comment = 'Part of: Fill in either <some fields> or <other fields>';
                    field("OIOUBL-SWIFT Code"; "SWIFT Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Tooltip = 'Specifies the SWIFT code (international bank identifier code) of your primary bank.';
                    }
                    field(IBAN; IBAN)
                    {
                        ApplicationArea = Basic, Suite;
                        Tooltip = 'Specifies the international bank account number of your primary bank account.';
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnClosePage();
    var
        BankAccount: Record "Bank Account";
        MiniCompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        MiniCompanyInformationMgt.UpdateCompanyBankAccount(Rec, MiniCompanyInformationMgt.GetCompanyBankAccountPostingGroup(), BankAccount);
    end;
}
