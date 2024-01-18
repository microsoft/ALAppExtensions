// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Calendar;
using Microsoft.Foundation.NoSeries;
using System.Reflection;

tableextension 31286 "Bank Account CZB" extends "Bank Account"
{
    fields
    {
        field(11702; "Default Constant Symbol CZB"; Code[10])
        {
            Caption = 'Default Constant Symbol';
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;
        }
        field(11704; "Default Specific Symbol CZB"; Code[10])
        {
            Caption = 'Default Specific Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11745; "Domestic Payment Order ID CZB"; Integer)
        {
            BlankZero = true;
            Caption = 'Domestic Payment Order ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            DataClassification = CustomerContent;
        }
        field(11746; "Foreign Payment Order ID CZB"; Integer)
        {
            BlankZero = true;
            Caption = 'Foreign Payment Order ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            DataClassification = CustomerContent;
        }
        field(11752; "Dimension from Apply Entry CZB"; Boolean)
        {
            Caption = 'Dimension from Apply Entry';
            DataClassification = CustomerContent;
        }
        field(11753; "Check Ext. No. Curr. Year CZB"; Boolean)
        {
            Caption = 'Check External No. by Current Year';
            DataClassification = CustomerContent;
        }
        field(11754; "Check CZ Format on Issue CZB"; Boolean)
        {
            Caption = 'Check Czech Format on Issue';
            DataClassification = CustomerContent;
        }
        field(11755; "Variable S. to Description CZB"; Boolean)
        {
            Caption = 'Variable Symbol to Description';
            DataClassification = CustomerContent;
        }
        field(11756; "Variable S. to Variable S. CZB"; Boolean)
        {
            Caption = 'Variable Symbol to Variable Symbol';
            DataClassification = CustomerContent;
        }
        field(11757; "Variable S. to Ext.Doc.No. CZB"; Boolean)
        {
            Caption = 'Variable Symbol to External Document No.';
            DataClassification = CustomerContent;
        }
        field(11758; "Foreign Payment Orders CZB"; Boolean)
        {
            Caption = 'Foreign Payment Orders';
            DataClassification = CustomerContent;
        }
        field(11759; "Post Per Line CZB"; Boolean)
        {
            Caption = 'Post Per Line';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(11071; "Payment Partial Suggestion CZB"; Boolean)
        {
            Caption = 'Payment Partial Suggestion';
            DataClassification = CustomerContent;
        }
        field(11072; "Payment Order Line Descr. CZB"; Text[50])
        {
            Caption = 'Payment Order Line Description';
            DataClassification = CustomerContent;
        }
        field(11073; "Non Assoc. Payment Account CZB"; Code[20])
        {
            Caption = 'Non Associated Payment Account';
            TableRelation = "G/L Account" where("Direct Posting" = const(true));
            DataClassification = CustomerContent;
        }
        field(11074; "Base Calendar Code CZB"; Code[10])
        {
            Caption = 'Base Calendar Code';
            TableRelation = "Base Calendar";
            DataClassification = CustomerContent;
        }
        field(11075; "Payment Jnl. Template Name CZB"; Code[10])
        {
            Caption = 'Payment Jnl. Template Name - Statement';
            TableRelation = "Gen. Journal Template" where(Type = const(Payments));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Payment Jnl. Template Name CZB" <> xRec."Payment Jnl. Template Name CZB" then
                    "Payment Jnl. Batch Name CZB" := '';
            end;
        }
        field(11076; "Payment Jnl. Batch Name CZB"; Code[10])
        {
            Caption = 'Payment Jnl. Batch Name - Statement';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Payment Jnl. Template Name CZB"),
                                                             "Bal. Account Type" = const("Bank Account"),
                                                             "Bal. Account No." = field("No."),
                                                             "Allow Payment Export" = const(true));
            DataClassification = CustomerContent;
        }
        field(11077; "Foreign Payment Ex. Format CZB"; Code[20])
        {
            Caption = 'Foreign Payment Export Format';
            TableRelation = "Bank Export/Import Setup".Code where(Direction = const(Export));
            DataClassification = CustomerContent;
        }
        field(11078; "Payment Import Format CZB"; Code[20])
        {
            Caption = 'Payment Import Format';
            TableRelation = "Bank Export/Import Setup".Code where(Direction = const(Import));
            DataClassification = CustomerContent;
        }

        field(11790; "Payment Order Nos. CZB"; Code[20])
        {
            Caption = 'Payment Order Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(11791; "Issued Payment Order Nos. CZB"; Code[20])
        {
            Caption = 'Issued Payment Order Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(11792; "Bank Statement Nos. CZB"; Code[20])
        {
            Caption = 'Bank Statement Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(11793; "Issued Bank Statement Nos. CZB"; Code[20])
        {
            Caption = 'Issued Bank Statement Nos.';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(11795; "Search Rule Code CZB"; Code[10])
        {
            Caption = 'Search Rule Code';
            TableRelation = "Search Rule CZB";
            DataClassification = CustomerContent;
        }
        field(11796; "Pmt.Jnl. Templ. Name Order CZB"; Code[10])
        {
            Caption = 'Payment Jnl. Template Name - Order';
            TableRelation = "Gen. Journal Template" where(Type = const(Payments));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Pmt.Jnl. Templ. Name Order CZB" <> xRec."Pmt.Jnl. Templ. Name Order CZB" then
                    "Pmt. Jnl. Batch Name Order CZB" := '';
            end;
        }
        field(11797; "Pmt. Jnl. Batch Name Order CZB"; Code[10])
        {
            Caption = 'Payment Jnl. Batch Name - Order';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Pmt.Jnl. Templ. Name Order CZB"),
                                                             "Bal. Account Type" = const("Bank Account"),
                                                             "Bal. Account No." = field("No."),
                                                             "Allow Payment Export" = const(true));
            DataClassification = CustomerContent;
        }
    }

    procedure GetBankStatementImportCodeunitIdCZB(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        Testfield("Bank Statement Import Format");
        BankExportImportSetup.Get("Bank Statement Import Format");
        exit(BankExportImportSetup."Processing Codeunit ID");
    end;

    procedure GetForeignPaymentExportCodeunitIdCZB(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        Testfield("Foreign Payment Ex. Format CZB");
        BankExportImportSetup.Get("Foreign Payment Ex. Format CZB");
        exit(BankExportImportSetup."Processing Codeunit ID");
    end;

    procedure GetPaymentImportCodeunitIdCZB(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        Testfield("Payment Import Format CZB");
        BankExportImportSetup.Get("Payment Import Format CZB");
        exit(BankExportImportSetup."Processing Codeunit ID");
    end;

    procedure CheckCurrExchRateExistCZB(Date: Date)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CurrExchRateIsEmptyErr: Label 'There is no Currency Exchange Rate within the filter. Filters: %1.', Comment = '%1 = filters';
    begin
        if IsInLocalCurrency() then
            exit;

        CurrencyExchangeRate.SetRange("Currency Code", "Currency Code");
        CurrencyExchangeRate.SetRange("Starting Date", 0D, Date);
        if CurrencyExchangeRate.IsEmpty() then
            Error(CurrExchRateIsEmptyErr, CurrencyExchangeRate.GetFilters());
    end;
}
