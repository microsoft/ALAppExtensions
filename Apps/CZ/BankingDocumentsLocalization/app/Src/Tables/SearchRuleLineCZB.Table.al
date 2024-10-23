// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Reflection;

table 31251 "Search Rule Line CZB"
{
    Caption = 'Search Rule Line';
    LookupPageId = "Search Rule Line Lookup CZB";

    fields
    {
        field(1; "Search Rule Code"; Code[10])
        {
            Caption = 'Search Rule Code';
            NotBlank = true;
            TableRelation = "Search Rule CZB";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(22; "Banking Transaction Type"; Enum "Banking Transaction Type CZB")
        {
            Caption = 'Banking Transaction Type';
            DataClassification = CustomerContent;
        }
        field(24; "Search Scope"; Enum "Search Scope CZB")
        {
            Caption = 'Search Scope';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "Search Scope" = "Search Scope"::"Account Mapping" then
                    CheckFilterRule()
                else
                    CheckSearchRule();
            end;
        }
        field(30; "Bank Account No."; Boolean)
        {
            Caption = 'Bank Account No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Bank Account No." then
                    CheckSearchRule();
            end;
        }
        field(31; "Specific Symbol"; Boolean)
        {
            Caption = 'Specific Symbol';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Specific Symbol" then
                    CheckSearchRule();
            end;
        }
        field(32; "Variable Symbol"; Boolean)
        {
            Caption = 'Variable Symbol';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Variable Symbol" then
                    CheckSearchRule();
            end;
        }
        field(33; "Constant Symbol"; Boolean)
        {
            Caption = 'Constant Symbol';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Constant Symbol" then
                    CheckSearchRule();
            end;
        }
        field(34; Amount; Boolean)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Amount then
                    CheckSearchRule();
            end;
        }
        field(35; "Multiple Result"; Enum "Multiple Search Result CZB")
        {
            Caption = 'Multiple Result';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Multiple Result" <> "Multiple Result"::" " then
                    CheckSearchRule();
            end;
        }
        field(36; "Match Related Party Only"; Boolean)
        {
            Caption = 'Match Related Party Only';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Search Scope");
            end;
        }
        field(40; "Description Filter"; Text[100])
        {
            Caption = 'Description Filter';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Description Filter" <> '' then
                    CheckFilterRule();
            end;
        }
        field(41; "Specific Symbol Filter"; Text[100])
        {
            Caption = 'Specific Symbol Filter';
            DataClassification = CustomerContent;
            CharAllowed = '&&**..09??||';

            trigger OnValidate()
            begin
                if "Specific Symbol Filter" <> '' then
                    CheckFilterRule();
            end;
        }
        field(421; "Variable Symbol Filter"; Text[100])
        {
            Caption = 'Variable Symbol Filter';
            DataClassification = CustomerContent;
            CharAllowed = '&&**..09??||';

            trigger OnValidate()
            begin
                if "Variable Symbol Filter" <> '' then
                    CheckFilterRule();
            end;
        }
        field(43; "Constant Symbol Filter"; Text[100])
        {
            Caption = 'Constant Symbol Filter';
            DataClassification = CustomerContent;
            CharAllowed = '&&**..09??||';

            trigger OnValidate()
            begin
                if "Constant Symbol Filter" <> '' then
                    CheckFilterRule();
            end;
        }
        field(44; "Bank Account Filter"; Text[100])
        {
            Caption = 'Bank Account Filter';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Constant Symbol Filter" <> '' then
                    CheckFilterRule();
            end;
        }
        field(45; "IBAN Filter"; Text[100])
        {
            Caption = 'IBAN Filter';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Constant Symbol Filter" <> '' then
                    CheckFilterRule();
            end;
        }
        field(50; "Account Type"; Enum "Search Rule Account Type CZB")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Search Scope", "Search Scope"::"Account Mapping");
                if "Account Type" <> xRec."Account Type" then
                    "Account No." := '';
            end;
        }
        field(51; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account" else
            if ("Account Type" = const(Customer)) Customer else
            if ("Account Type" = const(Vendor)) Vendor else
            if ("Account Type" = const("Bank Account")) "Bank Account" else
            if ("Account Type" = const(Employee)) Employee;

            trigger OnValidate()
            begin
                TestField("Search Scope", "Search Scope"::"Account Mapping");
            end;
        }
    }

    keys
    {
        key(Key1; "Search Rule Code", "Line No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(Brick; "Search Rule Code", "Line No.", Description, "Match Related Party Only")
        {
        }
    }

    trigger OnInsert()
    begin
        if Description = '' then
            Description := BuildDescription();
    end;

    local procedure CheckSearchRule()
    begin
        if ("Search Scope" = "Search Scope"::"Account Mapping") then
            FieldError("Search Scope");
        TestField("Description Filter", '');
        TestField("Specific Symbol Filter", '');
        TestField("Variable Symbol Filter", '');
        TestField("Constant Symbol Filter", '');
    end;

    local procedure CheckFilterRule()
    begin
        TestField("Search Scope", "Search Scope"::"Account Mapping");
        TestField("Bank Account No.", false);
        TestField(Amount, false);
        TestField("Specific Symbol", false);
        TestField("Variable Symbol", false);
        TestField("Constant Symbol", false);
        TestField("Multiple Result", "Multiple Result"::" ");
    end;

    procedure MoveUp()
    var
        SearchRuleLine: Record "Search Rule Line CZB";
        OldLineNo, NewLineNo : Integer;
    begin
        SearchRuleLine := Rec;
        SearchRuleLine.SetRange("Search Rule Code", "Search Rule Code");
        if SearchRuleLine.Next(-1) = 0 then
            exit;

        OldLineNo := Rec."Line No.";
        NewLineNo := SearchRuleLine."Line No.";
        Rec.Rename("Search Rule Code", -1);
        SearchRuleLine.Rename("Search Rule Code", OldLineNo);
        Rec.Rename("Search Rule Code", NewLineNo);
    end;

    procedure MoveDown()
    var
        SearchRuleLine: Record "Search Rule Line CZB";
        OldLineNo, NewLineNo : Integer;
    begin
        SearchRuleLine := Rec;
        SearchRuleLine.SetRange("Search Rule Code", "Search Rule Code");
        if SearchRuleLine.Next() = 0 then
            exit;

        OldLineNo := Rec."Line No.";
        NewLineNo := SearchRuleLine."Line No.";
        Rec.Rename("Search Rule Code", -1);
        SearchRuleLine.Rename("Search Rule Code", OldLineNo);
        Rec.Rename("Search Rule Code", NewLineNo);
    end;

    local procedure BuildDescription(): Text[100]
    var
        TypeHelper: Codeunit "Type Helper";
        DescriptionBuilder: TextBuilder;
        BankAccountNoTxt: Label 'Bank Account No.';
        VariableSymbolTxt: Label 'Variable Symbol';
        ConstantSymbolTxt: Label 'Constant Symbol';
        SpecificSymbolTxt: Label 'Specific Symbol';
        AmountTxt: Label 'Amount';
        FirstTxt: Label 'First';
        SeparatorTok: Label ', ', Locked = true;
    begin
        DescriptionBuilder.AppendLine(Format("Banking Transaction Type"));
        DescriptionBuilder.AppendLine(Format("Search Scope"));
        if "Bank Account No." then
            DescriptionBuilder.AppendLine(BankAccountNoTxt);
        if "Variable Symbol" then
            DescriptionBuilder.AppendLine(VariableSymbolTxt);
        if "Constant Symbol" then
            DescriptionBuilder.AppendLine(ConstantSymbolTxt);
        if "Specific Symbol" then
            DescriptionBuilder.AppendLine(SpecificSymbolTxt);
        if Amount then
            DescriptionBuilder.AppendLine(AmountTxt);
        if "Multiple Result" = "Multiple Result"::"First Created Entry" then
            DescriptionBuilder.AppendLine(FirstTxt);
        exit(CopyStr(DescriptionBuilder.ToText().Replace(TypeHelper.CRLFSeparator(), SeparatorTok).TrimEnd(SeparatorTok), 1, 100));
    end;
}
