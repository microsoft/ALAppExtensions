// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;

tableextension 31285 "Gen. Journal Line CZB" extends "Gen. Journal Line"
{
    fields
    {
        field(11710; "Search Rule Code CZB"; Code[10])
        {
            Caption = 'Search Rule Code';
            TableRelation = "Search Rule CZB";
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11711; "Search Rule Line No. CZB"; Integer)
        {
            Caption = 'Search Rule Line Code';
            TableRelation = "Search Rule Line CZB"."Line No." where("Search Rule Code" = field("Search Rule Code CZB"));
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11714; "Variable S. to Description CZB"; Boolean)
        {
            Caption = 'Variable Symbol to Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11715; "Variable S. to Variable S. CZB"; Boolean)
        {
            Caption = 'Variable Symbol to Variable Symbol';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11716; "Variable S. to Ext.Doc.No. CZB"; Boolean)
        {
            Caption = 'Variable Symbol to External Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11730; "Bank Statement No. CZB"; Code[20])
        {
            Caption = 'Bank Statement No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    var
        GeneralLedgerSetup: Record "General Ledger Setup";

    procedure IsLocalCurrencyCZB(): Boolean
    begin
        GeneralLedgerSetup.Get();
        exit(("Currency Code" = '') or ("Currency Code" = GeneralLedgerSetup."LCY Code"));
    end;

    procedure SetVariableSymbolCZB(VariableSymbol: Code[10]; ToDescription: Boolean; ToVariableSymbol: Boolean; ToExtDocNo: Boolean)
    begin
        "Variable S. to Description CZB" := ToDescription;
        "Variable S. to Variable S. CZB" := ToVariableSymbol;
        "Variable S. to Ext.Doc.No. CZB" := ToExtDocNo;

        if "Variable S. to Description CZB" and (VariableSymbol <> '') then
            Description := VariableSymbol;
        if "Variable S. to Variable S. CZB" then
            "Variable Symbol CZL" := VariableSymbol;
        if "Variable S. to Ext.Doc.No. CZB" then
            "External Document No." := VariableSymbol;
    end;

    procedure GetVariableSymbolCZB(): Code[10]
    begin
        if "Variable S. to Variable S. CZB" then
            exit("Variable Symbol CZL");
        if "Variable S. to Ext.Doc.No. CZB" then
            exit(CopyStr("External Document No.", 1, MaxStrLen("Variable Symbol CZL")));
        if "Variable S. to Description CZB" then
            exit(CopyStr(Description, 1, MaxStrLen("Variable Symbol CZL")));
    end;

    procedure SendToMatchingCZB() IsSuccess: Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessageHandler: Codeunit "Error Message Handler";
    begin
        Commit();
        ErrorMessageMgt.Activate(ErrorMessageHandler);
        IsSuccess := true;
        GenJournalLine.Copy(Rec);
        if GenJournalLine.FindSet() then
            repeat
                ErrorMessageMgt.PushContext(ErrorContextElement, GenJournalLine.RecordId(), 0, '');
                if not Codeunit.Run(Codeunit::"Match Bank Payment CZB", GenJournalLine) then begin
                    ErrorMessageMgt.LogLastError();
                    IsSuccess := false;
                end;
                ErrorMessageMgt.PopContext(ErrorContextElement);
            until GenJournalLine.Next() = 0;

        if not IsSuccess then
            ErrorMessageHandler.ShowErrors();
    end;

    procedure IsDimensionFromApplyEntryEnabledCZB(): Boolean
    var
        BankAccount: Record "Bank Account";
    begin
        if ("Bal. Account Type" <> "Bal. Account Type"::"Bank Account") or
           ("Bal. Account No." = '')
        then
            exit(false);
        if not BankAccount.Get("Bal. Account No.") then
            exit(false);
        exit(BankAccount."Dimension from Apply Entry CZB");
    end;
}
