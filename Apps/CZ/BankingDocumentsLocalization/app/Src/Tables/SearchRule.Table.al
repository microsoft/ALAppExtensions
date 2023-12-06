// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using System.Utilities;

table 31250 "Search Rule CZB"
{
    Caption = 'Search Rule';
    DrillDownPageID = "Search Rule List CZB";
    LookupPageID = "Search Rule List CZB";

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SearchRuleCZB: Record "Search Rule CZB";
            begin
                if not Default then
                    exit;

                SearchRuleCZB.SetFilter(Code, '<>%1', Rec.Code);
                SearchRuleCZB.SetRange(Default, true);
                if not SearchRuleCZB.IsEmpty() then
                    FieldError(Default);
            end;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        SearchRuleLineCZB: Record "Search Rule Line CZB";
    begin
        SearchRuleLineCZB.SetRange("Search Rule Code", Code);
        SearchRuleLineCZB.DeleteAll(true);
    end;

    procedure CreateDefaultLinesWithConfirm()
    var
        SearchRuleLineCZB: Record "Search Rule Line CZB";
        ConfirmManagement: Codeunit "Confirm Management";
        DeleteLinesQst: Label '%1 already exists.\Do you want delete all rule lines?', Comment = '%1 = Search Rule Line TableCaption';
        CreateLinesQst: Label 'Do you want insert default search rule lines?';
    begin
        SearchRuleLineCZB.SetRange("Search Rule Code", Code);
        if GuiAllowed then begin
            if not SearchRuleLineCZB.IsEmpty() then
                if ConfirmManagement.GetResponseOrDefault(StrSubstNo(DeleteLinesQst, SearchRuleLineCZB.TableCaption()), false) then
                    SearchRuleLineCZB.DeleteAll(true)
                else
                    exit;
            if not ConfirmManagement.GetResponseOrDefault(CreateLinesQst, true) then
                exit;
        end;
        CreateDefaultLines();
    end;

    procedure CreateDefaultLines()
    var
        SearchRuleLineCZB: Record "Search Rule Line CZB";
        LineNo: Integer;
        BankAccountVariableSymbolAmountFirstTxt: Label 'Bank Account No., Variable Symbol, Amount, First';
        BankAccountVariableSymbolFirstTxt: Label 'Bank Account No., Variable Symbol, First';
        VariableSymbolFirstTxt: Label 'Variable Symbol, First';
    begin
        SearchRuleLineCZB.SetRange("Search Rule Code", Code);
        if not SearchRuleLineCZB.IsEmpty() then
            exit;

        InsertRuleLine(Code, LineNo, BankAccountVariableSymbolAmountFirstTxt, true, true);
        InsertRuleLine(Code, LineNo, BankAccountVariableSymbolFirstTxt, true, false);
        InsertRuleLine(Code, LineNo, VariableSymbolFirstTxt, false, false);

        OnAfterCreateDefaultLines(Code, LineNo);
    end;

    local procedure InsertRuleLine(Code: Code[10]; var LineNo: Integer; Description: Text; BankAccountNo: Boolean; Amount: Boolean)
    var
        SearchRuleLineCZB: Record "Search Rule Line CZB";
        DescriptionTxt: Label 'Both, Balance, %1', Comment = '%1 = Line Description';
    begin
        LineNo += 10000;
        SearchRuleLineCZB.Init();
        SearchRuleLineCZB."Search Rule Code" := Code;
        SearchRuleLineCZB."Line No." := LineNo;
        SearchRuleLineCZB.Validate(Description, CopyStr(StrSubstNo(DescriptionTxt, Description), 1, MaxStrLen(SearchRuleLineCZB.Description)));
        SearchRuleLineCZB.Validate("Banking Transaction Type", SearchRuleLineCZB."Banking Transaction Type"::Both);
        SearchRuleLineCZB.Validate("Search Scope", SearchRuleLineCZB."Search Scope"::Balance);
        SearchRuleLineCZB.Validate("Bank Account No.", BankAccountNo);
        SearchRuleLineCZB.Validate("Variable Symbol", true);
        SearchRuleLineCZB.Validate("Constant Symbol", false);
        SearchRuleLineCZB.Validate("Specific Symbol", false);
        SearchRuleLineCZB.Validate(Amount, Amount);
        SearchRuleLineCZB.Validate("Multiple Result", SearchRuleLineCZB."Multiple Result"::"First Created Entry");
        SearchRuleLineCZB.Insert(true);

        OnAfterInsertRuleLine(SearchRuleLineCZB, LineNo, Description);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDefaultLines(Code: Code[20]; var LineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRuleLine(var SearchRuleLineCZB: Record "Search Rule Line CZB"; var LineNo: Integer; Description: text)
    begin
    end;
}
