// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GST.Base;

table 18205 "GST Payment Buffer"
{
    Caption = 'GST Payment Buffer';

    fields
    {
        field(1; "GST Registration No."; Code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "GST Registration Nos.";
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(7; "Payment Liability"; Decimal)
        {
            Caption = 'Payment Liability';
            DataClassification = SystemMetadata;
            Editable = false;
            MinValue = 0;

            trigger OnValidate()
            begin
                "Net Payment Liability" := "Payment Liability";
                if "Total Credit Available" > 0 then
                    "Surplus Credit" := "Total Credit Available" - "Credit Utilized";
            end;
        }
        field(8; "GST TDS Credit Available"; Decimal)
        {
            Caption = 'GST TDS Credit Available';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; "GST TCS Credit Available"; Decimal)
        {
            Caption = 'GST TCS Credit Available';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(10; "Net Payment Liability"; Decimal)
        {
            Caption = 'Net Payment Liability';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; "Credit Availed"; Decimal)
        {
            Caption = 'Credit Availed';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                "Total Credit Available" := "Credit Availed";
                if "Total Credit Available" > 0 then
                    "Surplus Credit" := "Total Credit Available" - "Credit Utilized";
            end;
        }
        field(12; "Distributed Credit"; Decimal)
        {
            Caption = 'Distributed Credit';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(13; "Total Credit Available"; Decimal)
        {
            Caption = 'Total Credit Available';
            DataClassification = SystemMetadata;
            Editable = false;
            MinValue = 0;
        }
        field(14; "Credit Utilized"; Decimal)
        {
            Caption = 'Credit Utilized';
            DataClassification = SystemMetadata;
            MinValue = 0;

            trigger OnValidate()
            begin
                ValidateCreditUtilized();
            end;
        }
        field(15; "Payment Amount"; Decimal)
        {
            Caption = 'Payment Amount';
            DataClassification = SystemMetadata;
            MinValue = 0;

            trigger OnValidate()
            begin
                ValidatePaymentAmount();
            end;
        }
        field(16; Interest; Decimal)
        {
            Caption = 'Interest';
            DataClassification = SystemMetadata;
            MinValue = 0;

            trigger OnValidate()
            begin
                UpdateTotalPaymentAmount();
            end;
        }
        field(17; "Interest Account No."; Code[20])
        {
            Caption = 'Interest Account No.';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account" where(Blocked = const(false));

            trigger OnValidate()
            begin
                CheckGLAcc("Interest Account No.");
            end;
        }
        field(18; Penalty; Decimal)
        {
            Caption = 'Penalty';
            DataClassification = SystemMetadata;
            MinValue = 0;

            trigger OnValidate()
            begin
                UpdateTotalPaymentAmount();
            end;
        }
        field(19; "Penalty Account No."; Code[20])
        {
            Caption = 'Penalty Account No.';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account" where(Blocked = const(false));

            trigger OnValidate()
            begin
                CheckGLAcc("Penalty Account No.");
            end;
        }
        field(20; Fees; Decimal)
        {
            Caption = 'Fees';
            DataClassification = SystemMetadata;
            MinValue = 0;

            trigger OnValidate()
            begin
                UpdateTotalPaymentAmount();
            end;
        }
        field(21; "Fees Account No."; Code[20])
        {
            Caption = 'Fees Account No.';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account" where(Blocked = const(false));

            trigger OnValidate()
            begin
                CheckGLAcc("Fees Account No.");
            end;
        }
        field(22; Others; Decimal)
        {
            Caption = 'Others';
            DataClassification = SystemMetadata;
            MinValue = 0;

            trigger OnValidate()
            begin
                UpdateTotalPaymentAmount();
            end;
        }
        field(23; "Others Account No."; Code[20])
        {
            Caption = 'Others Account No.';
            DataClassification = SystemMetadata;
            TableRelation = "G/L Account" where(Blocked = const(false));

            trigger OnValidate()
            begin
                CheckGLAcc("Others Account No.");
            end;
        }
        field(24; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Account No." := '';
            end;
        }
        field(25; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
                where(Blocked = const(false))
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
                where(Blocked = const(false));

            trigger OnValidate()
            begin
                if "Account Type" = "Account Type"::"G/L Account" then
                    CheckGLAcc("Account No.")
                else
                    CheckBank("Account No.");
            end;
        }
        field(26; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = SystemMetadata;
        }
        field(27; "Surplus Credit"; Decimal)
        {
            Caption = 'Surplus Credit';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(28; "Surplus Cr. Utilized"; Decimal)
        {
            Caption = 'Surplus Cr. Utilized';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(29; "Carry Forward"; Decimal)
        {
            Caption = 'Carry Forward';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(34; "Period End Date"; Date)
        {
            Caption = 'Period End Date';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(35; "Bank Reference No."; Code[10])
        {
            Caption = 'Bank Reference No.';
            DataClassification = SystemMetadata;
        }
        field(36; "Bank Reference Date"; Date)
        {
            Caption = 'Bank Reference Date';
            DataClassification = SystemMetadata;
        }
        field(40; "GST Input Service Distribution"; Boolean)
        {
            Caption = 'GST Input Service Distribution';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(41; "Payment Liability - Rev. Chrg."; Decimal)
        {
            Caption = 'Payment Liability - Rev. Chrg.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(42; "Payment Amount - Rev. Chrg."; Decimal)
        {
            Caption = 'Payment Amount - Rev. Chrg.';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                UpdateTotalPaymentAmount();
            end;
        }
        field(43; "Unadjutsed Credit"; Decimal)
        {
            Caption = 'Unadjutsed Credit';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(45; "Unadjutsed Liability"; Decimal)
        {
            Caption = 'Unadjutsed Liability';
            DataClassification = SystemMetadata;
            Editable = false;

            trigger OnValidate()
            begin
                "Net Payment Liability" := "Payment Liability" + "Unadjutsed Liability";
            end;
        }
        field(46; "Total Payment Amount"; Decimal)
        {
            Caption = 'Total Payment Amount';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(47; "GST TDS Credit Utilized"; Decimal)
        {
            Caption = 'GST TDS Credit Utilized';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                ValidateGSTTDSCreditUtilized();
            end;
        }
        field(48; "GST TCS Credit Utilized"; Decimal)
        {
            Caption = 'GST TCS Credit Utilized';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                ValidateGSTTCSCreditUtilized();
            end;
        }
        field(49; "GST TDS Credit Unutilized"; Decimal)
        {
            Caption = 'GST TDS Credit Unutilized';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(50; "GST TCS Credit Unutilized"; Decimal)
        {
            Caption = 'GST TCS Credit Unutilized';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(51; "GST TCS Liability"; Decimal)
        {
            Caption = 'GST TCS Liability';
            Editable = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                UpdateTotalPaymentAmount();
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            DataClassification = SystemMetadata;
            TableRelation = "Dimension Set Entry";
        }
    }

    keys
    {
        key(Key1; "GST Registration No.", "Document No.", "GST Component Code")
        {
            Clustered = true;
        }
    }

    var
        CreditUtilizedErr: Label 'Credit Utilized %1 can''t exceed Payment Liability %2 for GST Compoment %3', Comment = '%1 = Credit Utilized, %2 = Payment Liability, %3 =GST Component Code.';
        SumofErr: Label 'Sum of Credit Utilized, GST TDS Credit Utilized, GST TCS Credit Utilized and Payment Amount must be equal to Net payment Liability.';
        GSTTDSTCSCreditUtilizedErr: Label '%1 cannot be more than %2.', Comment = '%1 = Field Name, %2 = Field Name';

    procedure CheckGLAcc(AccountNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if AccountNo = '' then
            exit;

        GLAccount.Get(AccountNo);
        GLAccount.CheckGLAcc();
    end;

    procedure CheckBank(BankCode: Code[20])
    var
        BankAccount: Record "Bank Account";
    begin
        if BankCode = '' then
            exit;

        BankAccount.Get(BankCode);
        BankAccount.TestField(Blocked, false);
    end;

    procedure UpdateTotalPaymentAmount()
    begin
        "Total Payment Amount" := "Payment Amount" +
            "Payment Amount - Rev. Chrg." +
            "GST TCS Liability" +
            Interest +
            Penalty +
            Fees +
            Others;
    end;

    procedure ValidatePaymentAmount()
    begin
        if "Net Payment Liability" < 0 then
            TestField("Payment Amount", 0)
        else
            if "Credit Utilized" + "Payment Amount" + "GST TDS Credit Utilized" + "GST TCS Credit Utilized" > "Net Payment Liability" then
                Error(SumofErr);
        UpdateTotalPaymentAmount();
    end;

    procedure ValidateCreditUtilized()
    begin
        if "Net Payment Liability" < 0 then
            TestField("Credit Utilized", 0)
        else
            if ("Credit Utilized" <> 0) and ("Credit Utilized" > "Net Payment Liability") then
                Error(
                        CreditUtilizedErr,
                        "Credit Utilized",
                        "Net Payment Liability",
                        "GST Component Code");

        if "Total Credit Available" > 0 then
            "Surplus Credit" := "Total Credit Available" - "Credit Utilized";

        if ("Net Payment Liability" > 0) and
            (("Credit Utilized" + "Payment Amount" + "GST TDS Credit Utilized" + "GST TCS Credit Utilized") > "Net Payment Liability")
        then
            Error(SumofErr);
    end;

    procedure ValidateGSTTDSCreditUtilized()
    begin
        if "GST TDS Credit Utilized" > "GST TDS Credit Available" then
            Error(GSTTDSTCSCreditUtilizedErr, "GST TDS Credit Utilized", "GST TDS Credit Available");

        if "Credit Utilized" + "Payment Amount" + "GST TDS Credit Utilized" + "GST TCS Credit Utilized" > "Net Payment Liability" then
            Error(SumofErr);

        if "GST TDS Credit Utilized" > 0 then
            "GST TDS Credit Unutilized" := "GST TDS Credit Available" - "GST TDS Credit Utilized";
    end;

    procedure ValidateGSTTCSCreditUtilized()
    begin
        if "GST TCS Credit Utilized" > "GST TCS Credit Available" then
            Error(GSTTDSTCSCreditUtilizedErr, "GST TCS Credit Utilized", "GST TCS Credit Available");

        if "Credit Utilized" + "Payment Amount" + "GST TDS Credit Utilized" + "GST TCS Credit Utilized" > "Net Payment Liability" then
            Error(SumofErr);

        if "GST TCS Credit Utilized" > 0 then
            "GST TCS Credit Unutilized" := "GST TCS Credit Available" - "GST TCS Credit Utilized";
    end;
}
