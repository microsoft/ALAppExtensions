// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
#if not CLEAN22
using Microsoft.Finance.VAT.Calculation;
#endif
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using System.Utilities;

report 31012 "Create Sales Adv. Letter CZZ"
{
    Caption = 'Create Sales Advance Letter';
    UsageCategory = None;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(AdvLetterCode; AdvanceLetterCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Advance Letter Code';
                        TableRelation = "Advance Letter Template CZZ" where("Sales/Purchase" = const(Sales));
                        ToolTip = 'Specifies advance letter code.';
                    }
                    field(AdvPer; AdvancePer)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Advance Letter %';
                        ToolTip = 'Specifies advance letter %.';
                        MinValue = 0;
                        MaxValue = 100;
                        DecimalPlaces = 2 : 2;

                        trigger OnValidate()
                        begin
                            AdvanceAmount := Round(TotalAmountInclVAT * AdvancePer / 100, Currency."Amount Rounding Precision");
                        end;
                    }
                    field(AdvAmount; AdvanceAmount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Advance Letter Amount';
                        ToolTip = 'Specifies advance letter amount.';
                        MinValue = 0;

                        trigger OnValidate()
                        begin
                            if AdvanceAmount > TotalAmountInclVAT then
                                Error(AmountCannotBeGreaterErr, TotalAmountInclVAT);

                            AdvancePer := Round(AdvanceAmount / TotalAmountInclVAT * 100);
                        end;
                    }
                    field(SuggByLine; SuggestByLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Suggest by Line';
                        ToolTip = 'Specifies if advance letter will by suggest by line.';
                    }
                }
            }
        }
    }

    var
        SalesHeader: Record "Sales Header";
        TempSalesLine: Record "Sales Line" temporary;
        Currency: Record Currency;
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        SalesPost: Codeunit "Sales-Post";
        AdvanceLetterCode: Code[20];
        AdvancePer: Decimal;
        AdvanceAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalAmountAdvLetter: Decimal;
        Coef: Decimal;
        SuggestByLine: Boolean;
        AdvLetterCodeEmptyErr: Label 'Advance Letter Code cannot be empty.';
        NothingToSuggestErr: Label 'Nothing to sugget.';
        AmountCannotBeGreaterErr: Label 'Amount cannot be greater than %1.', Comment = '%1 = Amount Including VAT';
        AmountExceedeErr: Label 'Sum of Advance letters exceeded.';

    trigger OnPreReport()
    begin
        if (AdvanceAmount = 0) then
            Error(NothingToSuggestErr);
        if AdvanceLetterCode = '' then
            Error(AdvLetterCodeEmptyErr);

        SalesAdvLetterHeaderCZZ.SetRange("Order No.", SalesHeader."No.");
        SalesAdvLetterHeaderCZZ.SetAutoCalcFields("Amount Including VAT");
        if SalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                TotalAmountAdvLetter += SalesAdvLetterHeaderCZZ."Amount Including VAT";
            until SalesAdvLetterHeaderCZZ.Next() = 0;

        if TotalAmountAdvLetter + AdvanceAmount > TotalAmountInclVAT then
            Error(AmountExceedeErr);

        AdvanceLetterTemplateCZZ.Get(AdvanceLetterCode);
        Coef := AdvanceAmount / TotalAmountInclVAT;
    end;

    trigger OnPostReport()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        OpenAdvanceLetterQst: Label 'Do you want to open created Advance Letter?';
    begin
        CreateAdvanceLetterHeader();

        TempSalesLine.SetFilter(Type, '>%1', TempSalesLine.Type::" ");
        TempSalesLine.SetFilter(Amount, '<>0');
        if SuggestByLine then begin
            if TempSalesLine.FindSet() then
                repeat
                    CreateAdvanceLetterLine(TempSalesLine.Description, TempSalesLine."VAT Bus. Posting Group", TempSalesLine."VAT Prod. Posting Group", TempSalesLine."Amount Including VAT");
                until TempSalesLine.Next() = 0;
        end else begin
            if TempSalesLine.FindSet() then
                repeat
                    TempAdvancePostingBufferCZZ.Init();
                    TempAdvancePostingBufferCZZ."VAT Bus. Posting Group" := TempSalesLine."VAT Bus. Posting Group";
                    TempAdvancePostingBufferCZZ."VAT Prod. Posting Group" := TempSalesLine."VAT Prod. Posting Group";
                    if TempAdvancePostingBufferCZZ.Find() then begin
                        TempAdvancePostingBufferCZZ.Amount += TempSalesLine."Amount Including VAT";
                        TempAdvancePostingBufferCZZ.Modify();
                    end else begin
                        TempAdvancePostingBufferCZZ.Amount := TempSalesLine."Amount Including VAT";
                        TempAdvancePostingBufferCZZ.Insert();
                    end;
                until TempSalesLine.Next() = 0;

            if TempAdvancePostingBufferCZZ.FindSet() then
                repeat
                    CreateAdvanceLetterLine('', TempAdvancePostingBufferCZZ."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ."VAT Prod. Posting Group", TempAdvancePostingBufferCZZ.Amount);
                until TempAdvancePostingBufferCZZ.Next() = 0;
        end;

        CreateAdvanceLetterApplication();

        if ConfirmManagement.GetResponseOrDefault(OpenAdvanceLetterQst, false) then
            if GuiAllowed() then
                Page.Run(Page::"Sales Advance Letter CZZ", SalesAdvLetterHeaderCZZ);
    end;

    local procedure CreateAdvanceLetterHeader()
#if not CLEAN22
#pragma warning disable AL0432
    var
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
#endif
    begin
        SalesAdvLetterHeaderCZZ.Init();
        SalesAdvLetterHeaderCZZ.Validate("Advance Letter Code", AdvanceLetterCode);
        SalesAdvLetterHeaderCZZ."No." := '';
        SalesAdvLetterHeaderCZZ.Insert(true);
        SalesAdvLetterHeaderCZZ."Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
        SalesAdvLetterHeaderCZZ."Bill-to Name" := SalesHeader."Bill-to Name";
        SalesAdvLetterHeaderCZZ."Bill-to Name 2" := SalesHeader."Bill-to Name 2";
        SalesAdvLetterHeaderCZZ."Bill-to Address" := SalesHeader."Bill-to Address";
        SalesAdvLetterHeaderCZZ."Bill-to Address 2" := SalesHeader."Bill-to Address 2";
        SalesAdvLetterHeaderCZZ."Bill-to City" := SalesHeader."Bill-to City";
        SalesAdvLetterHeaderCZZ."Bill-to Contact" := SalesHeader."Bill-to Contact";
        SalesAdvLetterHeaderCZZ."Bill-to Contact No." := SalesHeader."Bill-to Contact No.";
        SalesAdvLetterHeaderCZZ."Bill-to Country/Region Code" := SalesHeader."Bill-to Country/Region Code";
        SalesAdvLetterHeaderCZZ."Bill-to County" := SalesHeader."Bill-to County";
        SalesAdvLetterHeaderCZZ."Bill-to Post Code" := SalesHeader."Bill-to Post Code";
        SalesAdvLetterHeaderCZZ."Language Code" := SalesHeader."Language Code";
        SalesAdvLetterHeaderCZZ."Format Region" := SalesHeader."Format Region";
        SalesAdvLetterHeaderCZZ."Salesperson Code" := SalesHeader."Salesperson Code";
        SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
        SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
        SalesAdvLetterHeaderCZZ."Dimension Set ID" := SalesHeader."Dimension Set ID";
        SalesAdvLetterHeaderCZZ."VAT Bus. Posting Group" := SalesHeader."VAT Bus. Posting Group";
        SalesAdvLetterHeaderCZZ."Posting Date" := SalesHeader."Posting Date";
        SalesAdvLetterHeaderCZZ."Advance Due Date" := SalesHeader."Due Date";
        SalesAdvLetterHeaderCZZ."Document Date" := SalesHeader."Document Date";
#if not CLEAN22
#pragma warning disable AL0432
        if not ReplaceVATDateMgtCZL.IsEnabled() then
            SalesAdvLetterHeaderCZZ."VAT Date" := SalesHeader."VAT Date CZL"
        else
#pragma warning restore AL0432
#endif
        SalesAdvLetterHeaderCZZ."VAT Date" := SalesHeader."VAT Reporting Date";
        SalesAdvLetterHeaderCZZ."Posting Description" := SalesHeader."Posting Description";
        SalesAdvLetterHeaderCZZ."Payment Method Code" := SalesHeader."Payment Method Code";
        SalesAdvLetterHeaderCZZ."Payment Terms Code" := SalesHeader."Payment Terms Code";
        SalesAdvLetterHeaderCZZ."Registration No." := SalesHeader."Registration No. CZL";
        SalesAdvLetterHeaderCZZ."Tax Registration No." := SalesHeader."Tax Registration No. CZL";
        SalesAdvLetterHeaderCZZ."VAT Registration No." := SalesHeader."VAT Registration No.";
        SalesAdvLetterHeaderCZZ."Order No." := SalesHeader."No.";
        SalesAdvLetterHeaderCZZ."Bank Account Code" := SalesHeader."Bank Account Code CZL";
        SalesAdvLetterHeaderCZZ."Bank Account No." := SalesHeader."Bank Account No. CZL";
        SalesAdvLetterHeaderCZZ."Bank Branch No." := SalesHeader."Bank Branch No. CZL";
        SalesAdvLetterHeaderCZZ."Specific Symbol" := SalesHeader."Specific Symbol CZL";
        SalesAdvLetterHeaderCZZ."Variable Symbol" := SalesHeader."Variable Symbol CZL";
        SalesAdvLetterHeaderCZZ."Constant Symbol" := SalesHeader."Constant Symbol CZL";
        SalesAdvLetterHeaderCZZ.IBAN := SalesHeader."IBAN CZL";
        SalesAdvLetterHeaderCZZ."SWIFT Code" := SalesHeader."SWIFT Code CZL";
        SalesAdvLetterHeaderCZZ."Bank Name" := SalesHeader."Bank Name CZL";
        SalesAdvLetterHeaderCZZ."Transit No." := SalesHeader."Transit No. CZL";
        SalesAdvLetterHeaderCZZ."Responsibility Center" := SalesHeader."Responsibility Center";
        SalesAdvLetterHeaderCZZ."Currency Code" := SalesHeader."Currency Code";
        SalesAdvLetterHeaderCZZ."Currency Factor" := SalesHeader."Currency Factor";
        SalesAdvLetterHeaderCZZ."VAT Country/Region Code" := SalesHeader."VAT Country/Region Code";
        SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" := AdvanceLetterTemplateCZZ."Automatic Post VAT Document";
        OnCreateAdvanceLetterHeaderOnBeforeModifySalesAdvLetterHeaderCZZ(SalesHeader, AdvanceLetterTemplateCZZ, SalesAdvLetterHeaderCZZ);
        SalesAdvLetterHeaderCZZ.Modify(true);
    end;

    local procedure CreateAdvanceLetterLine(Description: Text[100]; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; AmountIncludingVAT: Decimal)
    begin
        SalesAdvLetterLineCZZ.Init();
        SalesAdvLetterLineCZZ."Document No." := SalesAdvLetterHeaderCZZ."No.";
        SalesAdvLetterLineCZZ."Line No." += 10000;
        SalesAdvLetterLineCZZ.Description := Description;
        SalesAdvLetterLineCZZ."VAT Bus. Posting Group" := VATBusPostingGroup;
        SalesAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        SalesAdvLetterLineCZZ.Validate("Amount Including VAT", Round(AmountIncludingVAT * Coef, Currency."Amount Rounding Precision"));
        if SalesAdvLetterLineCZZ."Amount Including VAT" <> 0 then
            SalesAdvLetterLineCZZ.Insert(true);
    end;

    local procedure CreateAdvanceLetterApplication()
    begin
        AdvanceLetterApplicationCZZ.Init();
        AdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales;
        AdvanceLetterApplicationCZZ."Advance Letter No." := SalesAdvLetterHeaderCZZ."No.";
        AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Sales Order";
        AdvanceLetterApplicationCZZ."Document No." := SalesHeader."No.";
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        AdvanceLetterApplicationCZZ.Amount := SalesAdvLetterHeaderCZZ."Amount Including VAT";
        AdvanceLetterApplicationCZZ."Amount (LCY)" := SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)";
        AdvanceLetterApplicationCZZ.Insert();
    end;

    procedure SetSalesHeader(var NewSalesHeader: Record "Sales Header")
    begin
        NewSalesHeader.TestField("Document Type", NewSalesHeader."Document Type"::Order);
        SalesHeader := NewSalesHeader;
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 0);
        TempSalesLine.CalcSums("Amount Including VAT");
        TotalAmountInclVAT := TempSalesLine."Amount Including VAT";

        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvanceLetterApplicationCZZ."Document Type"::"Sales Order");
        AdvanceLetterApplicationCZZ.SetRange("Document No.", SalesHeader."No.");
        AdvanceLetterApplicationCZZ.CalcSums(Amount);

        AdvanceAmount := TotalAmountInclVAT - AdvanceLetterApplicationCZZ.Amount;
        if AdvanceAmount > 0 then
            AdvancePer := Round(AdvanceAmount / TotalAmountInclVAT * 100)
        else
            AdvanceAmount := 0;

        if SalesHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(SalesHeader."Currency Code");
            Currency.TestField("Amount Rounding Precision");
        end;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCreateAdvanceLetterHeaderOnBeforeModifySalesAdvLetterHeaderCZZ(SalesHeader: Record "Sales Header"; AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;
}
