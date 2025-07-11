// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Setup;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 31253 "Bank Statement Line CZB"
{
    Caption = 'Bank Statement Line';
    DrillDownPageID = "Bank Statement Lines CZB";
    LookupPageId = "Bank Statement Lines CZB";

    fields
    {
        field(1; "Bank Statement No."; Code[20])
        {
            Caption = 'Bank Statement No.';
            TableRelation = "Bank Statement Header CZB"."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
            begin
                GetBankStatement();
                "Currency Code" := BankStatementHeaderCZB."Currency Code";
                "Bank Statement Currency Code" := BankStatementHeaderCZB."Bank Statement Currency Code";
                "Bank Statement Currency Factor" := BankStatementHeaderCZB."Bank Statement Currency Factor";
                if BankAccount.Get(BankStatementHeaderCZB."Bank Account No.") then begin
                    "Constant Symbol" := BankAccount."Default Constant Symbol CZB";
                    "Specific Symbol" := BankAccount."Default Specific Symbol CZB";
                end;
            end;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; Type; Enum "Banking Line Type CZB")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then
                    Validate("No.", '');
            end;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const(Customer)) Customer."No." else
            if (Type = const(Vendor)) Vendor."No." else
            if (Type = const("Bank Account")) "Bank Account"."No." else
            if (Type = const(Employee)) Employee."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAcc: Record "Bank Account";
                Cust: Record Customer;
                Employee: Record Employee;
                Vend: Record Vendor;
            begin
                if "No." <> xRec."No." then
                    Validate("Cust./Vendor Bank Account Code", '');
                case Type of
                    Type::"Bank Account":
                        begin
                            if not BankAcc.Get("No.") then
                                BankAcc.Init();
                            "Account No." := BankAcc."Bank Account No.";
                            Name := BankAcc.Name;
                        end;
                    Type::Customer:
                        begin
                            if not Cust.Get("No.") then
                                Cust.Init();
                            Name := Cust.Name;
                            Validate("Cust./Vendor Bank Account Code", Cust."Preferred Bank Account Code");
                        end;
                    Type::Vendor:
                        begin
                            if not Vend.Get("No.") then
                                Vend.Init();
                            Name := Vend.Name;
                            Validate("Cust./Vendor Bank Account Code", Vend."Preferred Bank Account Code");
                        end;
                    Type::Employee:
                        begin
                            if not Employee.Get("No.") then
                                Employee.Init();
                            "Account No." := Employee."Bank Account No.";
                            IBAN := Employee.IBAN;
                            "SWIFT Code" := Employee."SWIFT Code";
                            Name := Employee.FullName();
                        end;
                end;
            end;
        }
        field(5; "Cust./Vendor Bank Account Code"; Code[20])
        {
            Caption = 'Cust./Vendor Bank Account Code';
            TableRelation = if (Type = const(Customer)) "Customer Bank Account".Code where("Customer No." = field("No.")) else
            if (Type = const(Vendor)) "Vendor Bank Account".Code where("Vendor No." = field("No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                VendBankAcc: Record "Vendor Bank Account";
                CustBankAcc: Record "Customer Bank Account";
            begin
                if "Cust./Vendor Bank Account Code" <> xRec."Cust./Vendor Bank Account Code" then
                    case Type of
                        Type::Vendor:
                            begin
                                if not VendBankAcc.Get("No.", "Cust./Vendor Bank Account Code") then
                                    VendBankAcc.Init();
                                "Account No." := VendBankAcc."Bank Account No.";
                                "Transit No." := VendBankAcc."Transit No.";
                                IBAN := VendBankAcc.IBAN;
                                "SWIFT Code" := VendBankAcc."SWIFT Code";
                            end;
                        Type::Customer:
                            begin
                                if not CustBankAcc.Get("No.", "Cust./Vendor Bank Account Code") then
                                    CustBankAcc.Init();
                                "Account No." := CustBankAcc."Bank Account No.";
                                "Transit No." := CustBankAcc."Transit No.";
                                IBAN := CustBankAcc.IBAN;
                                "SWIFT Code" := CustBankAcc."SWIFT Code";
                            end
                        else
                            if "Cust./Vendor Bank Account Code" <> '' then
                                FieldError(Type);
                    end;
            end;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; "Account No."; Text[30])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankOperationsFunctionsCZB: Codeunit "Bank Operations Functions CZB";
                BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";
            begin
                BankOperationsFunctionsCZB.CheckBankAccountNoCharacters("Account No.");
                BankOperationsFunctionsCZL.CheckCzBankAccountNo("Account No.", '');

                if "Account No." <> xRec."Account No." then begin
                    Type := Type::" ";
                    "No." := '';
                    "Cust./Vendor Bank Account Code" := '';
                end;
            end;
        }
        field(8; "Variable Symbol"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(9; "Constant Symbol"; Code[10])
        {
            Caption = 'Constant Symbol';
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;
        }
        field(10; "Specific Symbol"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetBankStatement();
                if BankStatementHeaderCZB."Currency Code" <> '' then
                    "Amount (LCY)" :=
                      Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(BankStatementHeaderCZB."Document Date",
                          BankStatementHeaderCZB."Currency Code", Amount, BankStatementHeaderCZB."Currency Factor"))
                else
                    "Amount (LCY)" := Amount;

                if "Bank Statement Currency Code" <> '' then begin
                    GetBankStatementCurrency();
                    if BankStatementCurrency.Code = "Bank Statement Currency Code" then
                        "Amount (Bank Stat. Currency)" := Amount
                    else
                        "Amount (Bank Stat. Currency)" :=
                          Round(CurrencyExchangeRate.ExchangeAmtLCYToFCY(BankStatementHeaderCZB."Document Date",
                              "Bank Statement Currency Code", "Amount (LCY)",
                              "Bank Statement Currency Factor"), BankStatementCurrency."Amount Rounding Precision")
                end else
                    "Amount (Bank Stat. Currency)" := "Amount (LCY)";

                Positive := Amount > 0;
            end;
        }
        field(12; "Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetBankStatement();
                if BankStatementHeaderCZB."Currency Code" <> '' then
                    Amount :=
                      Round(CurrencyExchangeRate.ExchangeAmtLCYToFCY(BankStatementHeaderCZB."Document Date", BankStatementHeaderCZB."Currency Code",
                          "Amount (LCY)", BankStatementHeaderCZB."Currency Factor"), Currency."Amount Rounding Precision")
                else
                    Amount := "Amount (LCY)";

                if "Bank Statement Currency Code" <> '' then begin
                    GetBankStatementCurrency();
                    "Amount (Bank Stat. Currency)" :=
                      Round(CurrencyExchangeRate.ExchangeAmtLCYToFCY(BankStatementHeaderCZB."Document Date",
                          "Bank Statement Currency Code", "Amount (LCY)",
                          "Bank Statement Currency Factor"), BankStatementCurrency."Amount Rounding Precision")
                end else
                    "Amount (Bank Stat. Currency)" := "Amount (LCY)";

                Positive := "Amount (LCY)" > 0;
            end;
        }
        field(17; Positive; Boolean)
        {
            Caption = 'Positive';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18; "Transit No."; Text[20])
        {
            Caption = 'Transit No.';
            DataClassification = CustomerContent;
        }
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(25; "Bank Statement Currency Code"; Code[10])
        {
            Caption = 'Bank Statement Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CurrExchRate: Record "Currency Exchange Rate";
            begin
                GetBankStatement();
                if "Bank Statement Currency Code" <> '' then
                    Validate("Bank Statement Currency Factor",
                      CurrExchRate.ExchangeRate(BankStatementHeaderCZB."Document Date", "Bank Statement Currency Code"))
                else
                    Validate("Bank Statement Currency Factor", 0);

                Validate("Amount (LCY)");
            end;
        }
        field(26; "Amount (Bank Stat. Currency)"; Decimal)
        {
            Caption = 'Amount (Bank Statement Currency)';
            AutoFormatExpression = "Bank Statement Currency Code";
            AutoFormatType = 1;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GetBankStatement();
                if "Bank Statement Currency Code" = '' then
                    "Amount (LCY)" := "Amount (Bank Stat. Currency)"
                else begin
                    GetBankStatementCurrency();
                    "Amount (LCY)" :=
                      Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(BankStatementHeaderCZB."Document Date",
                          "Bank Statement Currency Code", "Amount (Bank Stat. Currency)", "Bank Statement Currency Factor"));
                end;

                if BankStatementHeaderCZB."Currency Code" <> '' then begin
                    GetBankStatementCurrency();
                    Amount :=
                      Round(CurrencyExchangeRate.ExchangeAmtLCYToFCY(BankStatementHeaderCZB."Document Date",
                          BankStatementHeaderCZB."Currency Code", "Amount (LCY)", BankStatementHeaderCZB."Currency Factor"), Currency."Amount Rounding Precision")
                end else
                    Amount := "Amount (LCY)";

                Positive := "Amount (Bank Stat. Currency)" > 0;
            end;
        }
        field(27; "Bank Statement Currency Factor"; Decimal)
        {
            Caption = 'Bank Statement Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Bank Statement Currency Code" <> '' then
                    Validate("Amount (Bank Stat. Currency)");
            end;
        }
        field(40; IBAN; Code[50])
        {
            Caption = 'IBAN';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CompanyInfo: Record "Company Information";
            begin
                CompanyInfo.CheckIBAN(IBAN);
            end;
        }
        field(45; "SWIFT Code"; Code[20])
        {
            Caption = 'SWIFT Code';
            TableRelation = "SWIFT Code";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(70; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Bank Statement No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Bank Statement No.", Positive)
        {
            SumIndexFields = Amount, "Amount (LCY)";
        }
    }

    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
        Currency: Record Currency;
        BankStatementCurrency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";

    procedure GetBankStatement()
    begin
        if "Bank Statement No." <> BankStatementHeaderCZB."No." then begin
            BankStatementHeaderCZB.Get("Bank Statement No.");
            if BankStatementHeaderCZB."Currency Code" = '' then
                Currency.InitRoundingPrecision()
            else begin
                BankStatementHeaderCZB.Testfield("Currency Factor");
                Currency.Get(BankStatementHeaderCZB."Currency Code");
                Currency.Testfield("Amount Rounding Precision");
            end;
        end;
    end;

    procedure GetBankStatementCurrency()
    begin
        if "Bank Statement Currency Code" <> BankStatementCurrency.Code then
            if "Bank Statement Currency Code" = '' then
                BankStatementCurrency.InitRoundingPrecision()
            else begin
                Testfield("Bank Statement Currency Factor");
                BankStatementCurrency.Get("Bank Statement Currency Code");
                BankStatementCurrency.Testfield("Amount Rounding Precision");
            end;
    end;

    procedure CopyFromBankAccReconLine(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
        Validate(Amount, BankAccReconciliationLine."Statement Amount");
        Description := BankAccReconciliationLine.Description;
        "Account No." := CopyStr(BankAccReconciliationLine."Related-Party Bank Acc. No.", 1, MaxStrLen("Account No."));
    end;
}
