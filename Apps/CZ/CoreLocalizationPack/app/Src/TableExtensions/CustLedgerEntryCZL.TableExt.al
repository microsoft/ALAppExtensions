// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Receivables;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Sales.Customer;

tableextension 11720 "Cust. Ledger Entry CZL" extends "Cust. Ledger Entry"
{
    fields
    {
        field(11717; "Specific Symbol CZL"; Code[10])
        {
            Caption = 'Specific Symbol';
            OptimizeForTextSearch = true;
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11718; "Variable Symbol CZL"; Code[10])
        {
            Caption = 'Variable Symbol';
            OptimizeForTextSearch = true;
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11719; "Constant Symbol CZL"; Code[10])
        {
            Caption = 'Constant Symbol';
            OptimizeForTextSearch = true;
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;
        }
        field(11720; "Bank Account Code CZL"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = if ("Document Type" = filter(Refund | Invoice | "Finance Charge Memo" | Reminder)) "Bank Account" else
            if ("Document Type" = filter("Credit Memo" | Payment)) "Customer Bank Account".Code where("Customer No." = field("Customer No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
                CustomerBankAccount: Record "Customer Bank Account";
            begin
                if "Bank Account Code CZL" = '' then begin
                    UpdateBankInfoCZL('', '', '', '', '');
                    exit;
                end;
                case "Document Type" of
                    "Document Type"::Refund, "Document Type"::"Finance Charge Memo",
                    "Document Type"::Invoice, "Document Type"::Reminder:
                        begin
                            BankAccount.Get("Bank Account Code CZL");
                            UpdateBankInfoCZL(
                              BankAccount."No.",
                              BankAccount."Bank Account No.",
                              BankAccount."Transit No.",
                              BankAccount.IBAN,
                              BankAccount."SWIFT Code");
                        end;
                    "Document Type"::"Credit Memo", "Document Type"::Payment:
                        begin
                            TestField("Customer No.");
                            CustomerBankAccount.Get("Customer No.", "Bank Account Code CZL");
                            UpdateBankInfoCZL(
                              CustomerBankAccount.Code,
                              CustomerBankAccount."Bank Account No.",
                              CustomerBankAccount."Transit No.",
                              CustomerBankAccount.IBAN,
                              CustomerBankAccount."SWIFT Code");
                        end;
                end;
            end;
        }
        field(11721; "Bank Account No. CZL"; Text[30])
        {
            Caption = 'Bank Account No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11724; "Transit No. CZL"; Text[20])
        {
            Caption = 'Transit No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11725; "IBAN CZL"; Code[50])
        {
            Caption = 'IBAN';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11726; "SWIFT Code CZL"; Code[20])
        {
            Caption = 'SWIFT Code';
            Editable = false;
            TableRelation = "SWIFT Code";
            DataClassification = CustomerContent;
        }
        field(11780; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    procedure GetTransactionNoCZL(EntryNo: Integer): Integer
    begin
        Rec.Get(EntryNo);
        exit(Rec."Transaction No.");
    end;

    local procedure UpdateBankInfoCZL(BankAccountCode: Code[20]; BankAccountNo: Text[30]; TransitNo: Text[20]; IBANCode: Code[50]; SWIFTCode: Code[20])
    begin
        "Bank Account Code CZL" := BankAccountCode;
        "Bank Account No. CZL" := BankAccountNo;
        "Transit No. CZL" := TransitNo;
        "IBAN CZL" := IBANCode;
        "SWIFT Code CZL" := SWIFTCode;
        OnAfterUpdateBankInfoCZL(Rec);
    end;

    procedure CollectSuggestedApplicationCZL(var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL"): Boolean
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        exit(CrossApplicationMgtCZL.CollectSuggestedApplication(Rec, CrossApplicationBufferCZL));
    end;

    procedure CollectSuggestedApplicationCZL(CalledFrom: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL"): Boolean
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        exit(CrossApplicationMgtCZL.CollectSuggestedApplication(Rec, CalledFrom, CrossApplicationBufferCZL));
    end;

    procedure CalcSuggestedAmountToApplyCZL(): Decimal
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        exit(CrossApplicationMgtCZL.CalcSuggestedAmountToApply(Rec));
    end;

    procedure DrillDownSuggestedAmountToApplyCZL()
    var
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        CrossApplicationMgtCZL.DrillDownSuggestedAmountToApply(Rec);
    end;

    procedure RelatedToAdvanceLetterCZL() IsRelatedToAdvanceLetter: Boolean
    begin
        IsRelatedToAdvanceLetter := false;
        OnIsRelatedToAdvanceLetterCZL(Rec, IsRelatedToAdvanceLetter);
    end;

    procedure GetReceivablesAccNoCZL(): Code[20]
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        GLAccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetReceivablesAccountNoCZL(Rec, GLAccountNo, IsHandled);
        if IsHandled then
            exit(GLAccountNo);

        TestField("Customer Posting Group");
        CustomerPostingGroup.Get("Customer Posting Group");
        CustomerPostingGroup.TestField("Receivables Account");
        exit(CustomerPostingGroup.GetReceivablesAccount());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsRelatedToAdvanceLetterCZL(CustLedgerEntry: Record "Cust. Ledger Entry"; var IsRelatedToAdvanceLetter: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBankInfoCZL(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetReceivablesAccountNoCZL(CustLedgerEntry: Record "Cust. Ledger Entry"; var GLAccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}