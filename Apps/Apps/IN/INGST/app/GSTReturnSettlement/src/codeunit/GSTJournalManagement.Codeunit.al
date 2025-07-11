// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 18319 "GST Journal Management"
{
    var
        LastGSTJournalLine: Record "GST Journal Line";
        OpenFromBatch: Boolean;
        Text001Lbl: Label '%1 journal', Comment = '%1 = Journal Template Type';
        Text004Lbl: Label 'DEFAULT', Locked = true;
        Text005Lbl: Label 'Default Journal', Locked = true;

    procedure OpenGSTJnl(var CurrentGSTJnlBatchName: Code[10]; var GSTJnlLine: Record "GST Journal Line")
    begin
        CheckGSTTemplateName(GSTJnlLine.GetRangeMax("Journal Template Name"), CurrentGSTJnlBatchName);
        GSTJnlLine.FilterGroup := 2;
        GSTJnlLine.SetRange("Journal Batch Name", CurrentGSTJnlBatchName);
        GSTJnlLine.FilterGroup := 0;
    end;

    procedure OpenGSTJnlBatch(var GSTJournalBatch: Record "GST Journal Batch");
    var
        CopyGSTJournalBatch: Record "GST Journal Batch";
        GSTJournalTemplate: Record "GST Journal Template";
        GSTJournalLine: Record "GST Journal Line";
        JnlSelected: Boolean;
    begin
        if GSTJournalBatch.GetFilter("Journal Template Name") <> '' then
            exit;

        GSTJournalBatch.FilterGroup(2);
        if GSTJournalBatch.GetFilter("Journal Template Name") <> '' then begin
            GSTJournalBatch.FilterGroup(0);
            exit;
        end;
        GSTJournalBatch.FilterGroup(0);

        if not GSTJournalBatch.FindFirst() then
            for GSTJournalTemplate.Type := GSTJournalTemplate.Type::" " TO GSTJournalTemplate.Type::"GST Adjustment Journal" DO begin
                GSTJournalTemplate.SetRange(Type, GSTJournalTemplate.Type);
                if not GSTJournalTemplate.FindFirst() then
                    GSTTemplateSelection(0, GSTJournalTemplate.Type, GSTJournalLine, JnlSelected);
                if GSTJournalTemplate.FindFirst() then
                    CheckGSTTemplateName(GSTJournalTemplate.Name, CopyGSTJournalBatch.Name);
            end;

        GSTJournalBatch.FindFirst();
        JnlSelected := true;
        GSTJournalBatch.CalcFields("Template Type");
        GSTJournalTemplate.SetRange(Type, GSTJournalBatch."Template Type");
        if GSTJournalBatch.GetFilter("Journal Template Name") <> '' then
            GSTJournalTemplate.SetRange(Name, GSTJournalBatch.GetFilter("Journal Template Name"));
        case GSTJournalTemplate.Count of
            1:
                GSTJournalTemplate.FindFirst();
            else
                JnlSelected := Page.RunModal(0, GSTJournalTemplate) = Action::LookupOK;
        end;

        if not JnlSelected then
            Error('');

        GSTJournalBatch.FilterGroup(0);
        GSTJournalBatch.SetRange("Journal Template Name", GSTJournalTemplate.Name);
        GSTJournalBatch.FilterGroup(2);
    end;

    procedure GSTTemplateSelection(PageID: Integer; FormTemplate: Enum "GST Adjustment Journal Type"; var GSTJournalLine: Record "GST Journal Line"; var JnlSelected: Boolean);
    var
        GSTJournalTemplate: Record "GST Journal Template";
    begin
        JnlSelected := true;

        GSTJournalTemplate.Reset();
        if not OpenFromBatch then
            GSTJournalTemplate.SetRange("Page ID", PageID);
        GSTJournalTemplate.SetRange(Type, FormTemplate);
        case GSTJournalTemplate.Count of
            0:
                begin
                    GSTJournalTemplate.Init();
                    GSTJournalTemplate.Type := FormTemplate;
                    GSTJournalTemplate.Name := FORMAT(GSTJournalTemplate.Type, MAXSTRLEN(GSTJournalTemplate.Name));
                    GSTJournalTemplate.Description := STRSUBSTNO(Text001Lbl, GSTJournalTemplate.Type);
                    GSTJournalTemplate.Validate(Type);
                    GSTJournalTemplate.Insert();
                    Commit();
                end;
            1:
                GSTJournalTemplate.FindFirst();
            else
                JnlSelected := Page.RunModal(0, GSTJournalTemplate) = Action::LookupOK;
        end;
        if JnlSelected then begin
            GSTJournalLine.FilterGroup := 2;
            GSTJournalLine.SetRange("Journal Template Name", GSTJournalTemplate.Name);
            GSTJournalLine.FilterGroup := 0;
            if OpenFromBatch then begin
                GSTJournalLine."Journal Template Name" := '';
                Page.Run(GSTJournalTemplate."Page ID", GSTJournalLine);
            end;
        end;
    end;

    procedure CheckGSTTemplateName(CurrentGSTTemplateName: Code[10]; var CurrentGSTBatchName: Code[10]);
    var
        GSTJournalBatch: Record "GST Journal Batch";
    begin
        GSTJournalBatch.SetRange("Journal Template Name", CurrentGSTTemplateName);
        if GSTJournalBatch.Get(CurrentGSTTemplateName, CurrentGSTBatchName) then
            exit;

        if not GSTJournalBatch.FindFirst() then begin
            GSTJournalBatch.Init();
            GSTJournalBatch."Journal Template Name" := CurrentGSTTemplateName;
            GSTJournalBatch.SetupNewBatch();
            GSTJournalBatch.Name := Text004Lbl;
            GSTJournalBatch.Description := Text005Lbl;
            GSTJournalBatch.Insert(true);
            Commit();
        end;

        CurrentGSTBatchName := GSTJournalBatch.Name
    end;

    procedure TemplateSelectionFromGSTBatch(var GSTJournalBatch: Record "GST Journal Batch");
    var
        GSTJournalLine: Record "GST Journal Line";
        GSTJournalTemplate: Record "GST Journal Template";
    begin
        OpenFromBatch := true;
        GSTJournalTemplate.Get(GSTJournalBatch."Journal Template Name");
        GSTJournalTemplate.TestField("Page ID");
        GSTJournalTemplate.TestField(Name);

        GSTJournalLine.FilterGroup := 2;
        GSTJournalLine.SetRange("Journal Template Name", GSTJournalTemplate.Name);
        GSTJournalLine.FilterGroup := 0;

        GSTJournalLine."Journal Template Name" := '';
        GSTJournalLine."Journal Batch Name" := GSTJournalBatch.Name;
        Page.Run(GSTJournalTemplate."Page ID", GSTJournalLine);
    end;

    procedure SetNameGST(CurrentGSTJnlBatchName: Code[10]; var GSTJournalLine: Record "GST Journal Line");
    begin
        GSTJournalLine.FilterGroup := 2;
        GSTJournalLine.SetRange("Journal Batch Name", CurrentGSTJnlBatchName);
        GSTJournalLine.FilterGroup := 0;
        if GSTJournalLine.FindFirst() then;
    end;

    procedure CheckNameGST(CurrentGSTJnlBatchName: Code[10]; var GSTJournalLine: Record "GST Journal Line");
    var
        GSTJournalBatch: Record "GST Journal Batch";
    begin
        GSTJournalBatch.Get(GSTJournalLine.GetRangeMax("Journal Template Name"), CurrentGSTJnlBatchName);
    end;

    procedure LookupNameGST(var CurrentGSTJnlBatchName: Code[10]; var GSTJournalLine: Record "GST Journal Line");
    var
        GSTJournalBatch: Record "GST Journal Batch";
    begin
        Commit();
        GSTJournalBatch."Journal Template Name" := GSTJournalLine.GetRangeMax("Journal Template Name");
        GSTJournalBatch.Name := GSTJournalLine.GetRangeMax("Journal Batch Name");
        GSTJournalBatch.FilterGroup := 2;
        GSTJournalBatch.SetRange("Journal Template Name", GSTJournalBatch."Journal Template Name");
        GSTJournalBatch.FilterGroup := 0;
        if Page.RunModal(0, GSTJournalBatch) = Action::LookupOK then begin
            CurrentGSTJnlBatchName := GSTJournalBatch.Name;
            SetNameGST(CurrentGSTJnlBatchName, GSTJournalLine);
        end;
    end;

    procedure GetAccountsGST(var GSTJournalLine: Record "GST Journal Line"; var AccName: Text[100]; var BalAccName: Text[100])
    var
        GLAcc: Record "G/L Account";
        Cust: Record Customer;
        Vend: Record Vendor;
        BankAcc: Record "Bank Account";
    begin
        if (GSTJournalLine."Account Type" <> LastGSTJournalLine."Account Type") or
           (GSTJournalLine."Account No." <> LastGSTJournalLine."Account No.")
        then begin
            AccName := '';
            if GSTJournalLine."Account No." <> '' then
                case GSTJournalLine."Account Type" of
                    GSTJournalLine."Account Type"::"G/L Account":
                        if GLAcc.Get(GSTJournalLine."Account No.") then
                            AccName := GLAcc.Name;
                    GSTJournalLine."Account Type"::Customer:
                        if Cust.Get(GSTJournalLine."Account No.") then
                            AccName := Cust.Name;
                    GSTJournalLine."Account Type"::Vendor:
                        if Vend.Get(GSTJournalLine."Account No.") then
                            AccName := Vend.Name;
                    GSTJournalLine."Account Type"::"Bank Account":
                        if BankAcc.Get(GSTJournalLine."Account No.") then
                            AccName := BankAcc.Name;
                end;
        end;

        if (GSTJournalLine."Bal. Account Type" <> LastGSTJournalLine."Bal. Account Type") or
           (GSTJournalLine."Bal. Account No." <> LastGSTJournalLine."Bal. Account No.")
        then begin
            BalAccName := '';
            if GSTJournalLine."Bal. Account No." <> '' then
                case GSTJournalLine."Bal. Account Type" of
                    GSTJournalLine."Bal. Account Type"::"G/L Account":
                        if GLAcc.Get(GSTJournalLine."Bal. Account No.") then
                            BalAccName := GLAcc.Name;
                    GSTJournalLine."Bal. Account Type"::Customer:
                        if Cust.Get(GSTJournalLine."Bal. Account No.") then
                            BalAccName := Cust.Name;
                    GSTJournalLine."Bal. Account Type"::Vendor:
                        if Vend.Get(GSTJournalLine."Bal. Account No.") then
                            BalAccName := Vend.Name;
                    GSTJournalLine."Bal. Account Type"::"Bank Account":
                        if BankAcc.Get(GSTJournalLine."Bal. Account No.") then
                            BalAccName := BankAcc.Name;
                end;
        end;

        LastGSTJournalLine := GSTJournalLine;
    end;
}
