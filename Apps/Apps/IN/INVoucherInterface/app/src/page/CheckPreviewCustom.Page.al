// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

page 18942 "Check Preview Custom"
{
    Caption = 'Check Preview';
    DataCaptionExpression = "Document No." + ' ' + CheckToAddr[1];
    Editable = false;
    LinksAllowed = false;
    PageType = Card;
    SourceTable = "Gen. Journal Line";

    layout
    {
        area(content)
        {
            group(Payer)
            {
                Caption = 'Payer';

                field("CompanyAddr[1]"; CompanyAddr[1])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Company Name';
                    ToolTip = 'Specifies the company name that will appear on the check.';
                }
                field("CompanyAddr[2]"; CompanyAddr[2])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Company Address';
                    ToolTip = 'Specifies the company address that will appear on the check.';
                }
                field("CompanyAddr[3]"; CompanyAddr[3])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Company Address 2';
                    ToolTip = 'Specifies the extended company address that will appear on the check.';
                }
                field("CompanyAddr[4]"; CompanyAddr[4])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Company Post Code/City';
                    ToolTip = 'Specifies the company post code and city that will appear on the check.';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number for the journal line.';
                }
                field(CheckStatusText; CheckStatusText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Status';
                    ToolTip = 'Specifies if the check is printed.';
                }
            }
            group(Amount)
            {
                Caption = 'Amount';

                group(Control30)
                {
                    ShowCaption = false;

                    label(AmountText)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Amount Text';
                        ToolTip = 'Specifies the amount in letters that will appear on the check.';
                    }
                    label("Amount Text 2")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Amount Text 2';
                        ToolTip = 'Specifies an additional part of the amount in letters that will appear on the check.';
                    }
                }
            }
            group(Payee)
            {
                Caption = 'Payee';

                fixed(Control1902115401)
                {
                    ShowCaption = false;

                    group("Pay to the order of")
                    {
                        Caption = 'Pay to the order of';

                        field("CheckToAddr[1]"; CheckToAddr[1])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pay-to Name';
                            ToolTip = 'Specifies the name of the payee that will appear on the check.';
                        }
                        field("CheckToAddr[2]"; CheckToAddr[2])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pay-to Address';
                            ToolTip = 'Specifies the address of the payee that will appear on the check.';
                        }
                        field("CheckToAddr[3]"; CheckToAddr[3])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pay-to Address 2';
                            ToolTip = 'Specifies the extended address of the payee that will appear on the check.';
                        }
                        field("CheckToAddr[4]"; CheckToAddr[4])
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Pay-to Post Code/City';
                            ToolTip = 'Specifies the post code and city of the payee that will appear on the check.';
                        }
                    }
                    group(Date)
                    {
                        Caption = 'Date';

                        field("Posting Date"; "Posting Date")
                        {
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies the posting date for the entry.';
                        }
                    }
                    group(Control1900724401)
                    {
                        Caption = 'Amount';

                        field(CheckAmount; CheckAmount)
                        {
                            ApplicationArea = Basic, Suite;
                            AutoFormatExpression = "Currency Code";
                            AutoFormatType = 1;
                            ShowCaption = false;
                            ToolTip = 'Specifies the amount that will appear on the check.';
                        }
                        field(Placeholder4; PlaceHolderLbl)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Visible = false;
                        }
                        field(Placeholder5; PlaceHolderLbl)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Visible = false;
                        }
                        field(Placeholder6; PlaceHolderLbl)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Visible = false;
                        }
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CalcCheck();
    end;

    trigger OnOpenPage()
    begin
        CompanyInfo.Get();
        FormatAddr.Company(CompanyAddr, CompanyInfo);
    end;

    var
        GenJnlLine: Record "Gen. Journal Line";
        Cust: Record Customer;
        Vend: Record Vendor;
        BankAcc: Record "Bank Account";
        CompanyInfo: Record "Company Information";
        Employee: Record Employee;
        BankAcc2: Record "Bank Account";
        FormatAddr: Codeunit "Format Address";
        CheckToAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        CheckStatusText: Text[30];
        CheckAmount: Decimal;
        UseCheckNo: Code[20];
        PlaceHolderLbl: Label 'Placeholder';
        PrintCheckLbl: Label 'Printed Check';
        NotPrintCheckMsg: Label 'Not Printed Check';

    procedure InputBankAccount()
    begin
        if BankAcc2."No." <> '' then begin
            BankAcc2.Get(BankAcc2."No.");
            BankAcc2.TestField("Last Check No.");
            UseCheckNo := BankAcc2."Last Check No.";
        end;
    end;

    local procedure CalcCheck()
    var
        TaxBaseLibrary: Codeunit "Tax Base Library";
        TDSAmount: Decimal;
    begin
        if "Check Printed" then begin
            GenJnlLine.Reset();
            GenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            GenJnlLine.SetRange("Journal Template Name", "Journal Template Name");
            GenJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
            GenJnlLine.SetRange("Posting Date", "Posting Date");
            GenJnlLine.SetRange("Document No.", "Document No.");
            if "Bal. Account No." = '' then
                GenJnlLine.SetRange("Bank Payment Type", "Bank Payment Type"::" ")
            else
                GenJnlLine.SetRange("Bank Payment Type", "Bank Payment Type"::"Computer Check");
            GenJnlLine.SetRange("Check Printed", true);
            CheckStatusText := PrintCheckLbl;
        end else begin
            GenJnlLine.Reset();
            GenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            GenJnlLine.SetRange("Journal Template Name", "Journal Template Name");
            GenJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
            GenJnlLine.SetRange("Posting Date", "Posting Date");
            GenJnlLine.SetRange("Document No.", "Document No.");
            GenJnlLine.SetRange("Account Type", "Account Type");
            GenJnlLine.SetRange("Account No.", "Account No.");
            GenJnlLine.SetRange("Bal. Account Type", "Bal. Account Type");
            GenJnlLine.SetRange("Bal. Account No.", "Bal. Account No.");
            GenJnlLine.SetRange("Bank Payment Type", "Bank Payment Type");
            CheckStatusText := NotPrintCheckMsg;
        end;

        CheckAmount := 0;
        if GenJnlLine.FindSet() then
            repeat
                TaxBaseLibrary.GetTDSAmount(GenJnlLine, TDSAmount);
                CheckAmount := CheckAmount + GenJnlLine.Amount - TDSAmount;
            until GenJnlLine.Next() = 0;

        if CheckAmount < 0 then
            CheckAmount := 0;

        case GenJnlLine."Account Type" of
            GenJnlLine."Account Type"::"G/L Account":
                begin
                    Clear(CheckToAddr);
                    CheckToAddr[1] := GenJnlLine.Description;
                end;
            GenJnlLine."Account Type"::Customer:
                begin
                    Cust.Get(GenJnlLine."Account No.");
                    Cust.Contact := '';
                    FormatAddr.Customer(CheckToAddr, Cust);
                end;
            GenJnlLine."Account Type"::Vendor:
                begin
                    Vend.Get(GenJnlLine."Account No.");
                    Vend.Contact := '';
                    FormatAddr.Vendor(CheckToAddr, Vend);
                end;
            GenJnlLine."Account Type"::"Bank Account":
                begin
                    BankAcc.Get(GenJnlLine."Account No.");
                    BankAcc.Contact := '';
                    FormatAddr.BankAcc(CheckToAddr, BankAcc);
                end;
            GenJnlLine."Account Type"::"Fixed Asset":
                GenJnlLine.FieldError("Account Type");
            GenJnlLine."Account Type"::Employee:
                begin
                    Employee.Get(GenJnlLine."Account No.");
                    FormatAddr.Employee(CheckToAddr, Employee);
                end;
        end;
    end;
}
