// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
#if not CLEAN22
using Microsoft.Finance.VAT.Calculation;
#endif
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using System.Utilities;

report 31029 "Create Purch. Adv. Letter CZZ"
{
    Caption = 'Create Purchase Advance Letter';
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
                        TableRelation = "Advance Letter Template CZZ" where("Sales/Purchase" = const(Purchase));
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
        PurchaseHeader: Record "Purchase Header";
        TempPurchaseLine: Record "Purchase Line" temporary;
        Currency: Record Currency;
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
#if not CLEAN22
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
#endif
        PurchPost: Codeunit "Purch.-Post";
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

        PurchAdvLetterHeaderCZZ.SetRange("Order No.", PurchaseHeader."No.");
        PurchAdvLetterHeaderCZZ.SetAutoCalcFields("Amount Including VAT");
        if PurchAdvLetterHeaderCZZ.FindSet() then
            repeat
                TotalAmountAdvLetter += PurchAdvLetterHeaderCZZ."Amount Including VAT";
            until PurchAdvLetterHeaderCZZ.Next() = 0;

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

        TempPurchaseLine.SetFilter(Type, '>%1', TempPurchaseLine.Type::" ");
        TempPurchaseLine.SetFilter(Amount, '<>0');
        if SuggestByLine then begin
            if TempPurchaseLine.FindSet() then
                repeat
                    CreateAdvanceLetterLine(TempPurchaseLine.Description, TempPurchaseLine."VAT Bus. Posting Group", TempPurchaseLine."VAT Prod. Posting Group", TempPurchaseLine."Amount Including VAT");
                until TempPurchaseLine.Next() = 0;
        end else begin
            if TempPurchaseLine.FindSet() then
                repeat
                    TempAdvancePostingBufferCZZ.Init();
                    TempAdvancePostingBufferCZZ."VAT Bus. Posting Group" := TempPurchaseLine."VAT Bus. Posting Group";
                    TempAdvancePostingBufferCZZ."VAT Prod. Posting Group" := TempPurchaseLine."VAT Prod. Posting Group";
                    if TempAdvancePostingBufferCZZ.Find() then begin
                        TempAdvancePostingBufferCZZ.Amount += TempPurchaseLine."Amount Including VAT";
                        TempAdvancePostingBufferCZZ.Modify();
                    end else begin
                        TempAdvancePostingBufferCZZ.Amount := TempPurchaseLine."Amount Including VAT";
                        TempAdvancePostingBufferCZZ.Insert();
                    end;
                until TempPurchaseLine.Next() = 0;

            if TempAdvancePostingBufferCZZ.FindSet() then
                repeat
                    CreateAdvanceLetterLine('', TempAdvancePostingBufferCZZ."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ."VAT Prod. Posting Group", TempAdvancePostingBufferCZZ.Amount);
                until TempAdvancePostingBufferCZZ.Next() = 0;
        end;

        CreateAdvanceLetterApplication();

        if ConfirmManagement.GetResponseOrDefault(OpenAdvanceLetterQst, false) then
            if GuiAllowed() then
                Page.Run(Page::"Purch. Advance Letter CZZ", PurchAdvLetterHeaderCZZ);
    end;

    local procedure CreateAdvanceLetterHeader()
    begin
        PurchAdvLetterHeaderCZZ.Init();
        PurchAdvLetterHeaderCZZ.Validate("Advance Letter Code", AdvanceLetterCode);
        PurchAdvLetterHeaderCZZ."No." := '';
        PurchAdvLetterHeaderCZZ.Insert(true);
        PurchAdvLetterHeaderCZZ."Pay-to Vendor No." := PurchaseHeader."Pay-to Vendor No.";
        PurchAdvLetterHeaderCZZ."Pay-to Name" := PurchaseHeader."Pay-to Name";
        PurchAdvLetterHeaderCZZ."Pay-to Name 2" := PurchaseHeader."Pay-to Name 2";
        PurchAdvLetterHeaderCZZ."Pay-to Address" := PurchaseHeader."Pay-to Address";
        PurchAdvLetterHeaderCZZ."Pay-to Address 2" := PurchaseHeader."Pay-to Address 2";
        PurchAdvLetterHeaderCZZ."Pay-to City" := PurchaseHeader."Pay-to City";
        PurchAdvLetterHeaderCZZ."Pay-to Contact" := PurchaseHeader."Pay-to Contact";
        PurchAdvLetterHeaderCZZ."Pay-to Contact No." := PurchaseHeader."Pay-to Contact No.";
        PurchAdvLetterHeaderCZZ."Pay-to Country/Region Code" := PurchaseHeader."Pay-to Country/Region Code";
        PurchAdvLetterHeaderCZZ."Pay-to County" := PurchaseHeader."Pay-to County";
        PurchAdvLetterHeaderCZZ."Pay-to Post Code" := PurchaseHeader."Pay-to Post Code";
        PurchAdvLetterHeaderCZZ."Language Code" := PurchaseHeader."Language Code";
        PurchAdvLetterHeaderCZZ."Format Region" := PurchaseHeader."Format Region";
        PurchAdvLetterHeaderCZZ."Purchaser Code" := PurchaseHeader."Purchaser Code";
        PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code" := PurchaseHeader."Shortcut Dimension 1 Code";
        PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code" := PurchaseHeader."Shortcut Dimension 2 Code";
        PurchAdvLetterHeaderCZZ."Dimension Set ID" := PurchaseHeader."Dimension Set ID";
        PurchAdvLetterHeaderCZZ."VAT Bus. Posting Group" := PurchaseHeader."VAT Bus. Posting Group";
        PurchAdvLetterHeaderCZZ."Posting Date" := PurchaseHeader."Posting Date";
        PurchAdvLetterHeaderCZZ."Advance Due Date" := PurchaseHeader."Due Date";
        PurchAdvLetterHeaderCZZ."Document Date" := PurchaseHeader."Document Date";
#if not CLEAN22
#pragma warning disable AL0432
        if not ReplaceVATDateMgtCZL.IsEnabled() then
            PurchAdvLetterHeaderCZZ."VAT Date" := PurchaseHeader."VAT Date CZL"
        else
#pragma warning restore AL0432
#endif
        PurchAdvLetterHeaderCZZ."VAT Date" := PurchaseHeader."VAT Reporting Date";
        PurchAdvLetterHeaderCZZ."Posting Description" := PurchaseHeader."Posting Description";
        PurchAdvLetterHeaderCZZ."Payment Method Code" := PurchaseHeader."Payment Method Code";
        PurchAdvLetterHeaderCZZ."Payment Terms Code" := PurchaseHeader."Payment Terms Code";
        PurchAdvLetterHeaderCZZ."Registration No." := PurchaseHeader."Registration No. CZL";
        PurchAdvLetterHeaderCZZ."Tax Registration No." := PurchaseHeader."Tax Registration No. CZL";
        PurchAdvLetterHeaderCZZ."VAT Registration No." := PurchaseHeader."VAT Registration No.";
        PurchAdvLetterHeaderCZZ."Order No." := PurchaseHeader."No.";
        PurchAdvLetterHeaderCZZ."Bank Account Code" := PurchaseHeader."Bank Account Code CZL";
        PurchAdvLetterHeaderCZZ."Bank Account No." := PurchaseHeader."Bank Account No. CZL";
        PurchAdvLetterHeaderCZZ."Bank Branch No." := PurchaseHeader."Bank Branch No. CZL";
        PurchAdvLetterHeaderCZZ."Specific Symbol" := PurchaseHeader."Specific Symbol CZL";
        PurchAdvLetterHeaderCZZ."Variable Symbol" := PurchaseHeader."Variable Symbol CZL";
        PurchAdvLetterHeaderCZZ."Constant Symbol" := PurchaseHeader."Constant Symbol CZL";
        PurchAdvLetterHeaderCZZ.IBAN := PurchaseHeader."IBAN CZL";
        PurchAdvLetterHeaderCZZ."SWIFT Code" := PurchaseHeader."SWIFT Code CZL";
        PurchAdvLetterHeaderCZZ."Bank Name" := PurchaseHeader."Bank Name CZL";
        PurchAdvLetterHeaderCZZ."Transit No." := PurchaseHeader."Transit No. CZL";
        PurchAdvLetterHeaderCZZ."Responsibility Center" := PurchaseHeader."Responsibility Center";
        PurchAdvLetterHeaderCZZ."Currency Code" := PurchaseHeader."Currency Code";
        PurchAdvLetterHeaderCZZ."Currency Factor" := PurchaseHeader."Currency Factor";
        PurchAdvLetterHeaderCZZ."VAT Country/Region Code" := PurchaseHeader."VAT Country/Region Code";
        PurchAdvLetterHeaderCZZ."Automatic Post VAT Usage" := AdvanceLetterTemplateCZZ."Automatic Post VAT Document";
        OnCreateAdvanceLetterHeaderOnBeforeModifyPurchAdvLetterHeaderCZZ(PurchaseHeader, AdvanceLetterTemplateCZZ, PurchAdvLetterHeaderCZZ);
        PurchAdvLetterHeaderCZZ.Modify(true);
    end;

    local procedure CreateAdvanceLetterLine(Description: Text[100]; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; AmountIncludingVAT: Decimal)
    begin
        PurchAdvLetterLineCZZ.Init();
        PurchAdvLetterLineCZZ."Document No." := PurchAdvLetterHeaderCZZ."No.";
        PurchAdvLetterLineCZZ."Line No." += 10000;
        PurchAdvLetterLineCZZ.Description := Description;
        PurchAdvLetterLineCZZ."VAT Bus. Posting Group" := VATBusPostingGroup;
        PurchAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        PurchAdvLetterLineCZZ.Validate("Amount Including VAT", Round(AmountIncludingVAT * Coef, Currency."Amount Rounding Precision"));
        if PurchAdvLetterLineCZZ."Amount Including VAT" <> 0 then
            PurchAdvLetterLineCZZ.Insert(true);
    end;

    local procedure CreateAdvanceLetterApplication()
    begin
        AdvanceLetterApplicationCZZ.Init();
        AdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase;
        AdvanceLetterApplicationCZZ."Advance Letter No." := PurchAdvLetterHeaderCZZ."No.";
        AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Purchase Order";
        AdvanceLetterApplicationCZZ."Document No." := PurchaseHeader."No.";
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        AdvanceLetterApplicationCZZ.Amount := PurchAdvLetterHeaderCZZ."Amount Including VAT";
        AdvanceLetterApplicationCZZ."Amount (LCY)" := PurchAdvLetterHeaderCZZ."Amount Including VAT (LCY)";
        AdvanceLetterApplicationCZZ.Insert();
    end;

    procedure SetPurchHeader(var NewPurchaseHeader: Record "Purchase Header")
    begin
        NewPurchaseHeader.TestField("Document Type", NewPurchaseHeader."Document Type"::Order);
        PurchaseHeader := NewPurchaseHeader;
        PurchPost.GetPurchLines(PurchaseHeader, TempPurchaseLine, 0);
        TempPurchaseLine.CalcSums("Amount Including VAT");
        TotalAmountInclVAT := TempPurchaseLine."Amount Including VAT";

        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvanceLetterApplicationCZZ."Document Type"::"Purchase Order");
        AdvanceLetterApplicationCZZ.SetRange("Document No.", PurchaseHeader."No.");
        AdvanceLetterApplicationCZZ.CalcSums(Amount);

        AdvanceAmount := TotalAmountInclVAT - AdvanceLetterApplicationCZZ.Amount;
        if AdvanceAmount > 0 then
            AdvancePer := Round(AdvanceAmount / TotalAmountInclVAT * 100)
        else
            AdvanceAmount := 0;

        if PurchaseHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(PurchaseHeader."Currency Code");
            Currency.TestField("Amount Rounding Precision");
        end;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCreateAdvanceLetterHeaderOnBeforeModifyPurchAdvLetterHeaderCZZ(PurchaseHeader: Record "Purchase Header"; AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;
}
