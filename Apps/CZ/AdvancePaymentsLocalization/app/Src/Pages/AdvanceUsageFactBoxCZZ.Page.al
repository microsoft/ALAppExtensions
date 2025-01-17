// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

page 31216 "Advance Usage FactBox CZZ"
{
    Caption = 'Advance Usage';
    PageType = CardPart;
    Editable = false;

    layout
    {
        area(Content)
        {
            field(Advances; GetAdvancesCount())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances';
                ToolTip = 'Specifies number of advances assigned to the document.';
                DrillDown = true;

                trigger OnDrillDown()
                begin
                    Page.RunModal(Page::"Advance Letter Application CZZ", TempAdvanceLetterApplicationCZZ)
                end;
            }
            field(AmountToUse; GetAmountToUse())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Amount to Use';
                ToolTip = 'Specifies amount to use of assigned advances.';
                Visible = AmountToUseVisible;
            }
            field(AmountToUseLCY; GetAmountToUseLCY())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Amount to Use (LCY)';
                ToolTip = 'Specifies amount to use (LCY) of assigned advances.';
                Visible = AmountToUseLCYVisible;
            }
            field(AmountUsed; GetAmountUsed())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Amount Used';
                ToolTip = 'Specifies amount used by the document.';
                Visible = AmountUsedVisible;
            }
            field(AmountUsedLCY; GetAmountUsedLCY())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Amount Used (LCY)';
                ToolTip = 'Specifies amount (LCY) used by the document.';
                Visible = AmountUsedLCYVisible;
            }
            field(TotalAfterDeduction; GetTotalAfterDeduction())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Total after Deduction';
                ToolTip = 'Specifies total document amount after deduction of used advances.';
                Style = Strong;
                Visible = TotalAfterDeductionVisible;
            }
            field(TotalAfterDeductionLCY; GetTotalAfterDeductionLCY())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Total after Deduction (LCY)';
                ToolTip = 'Specifies total document amount (LCY) after deduction of used advances.';
                Style = Strong;
                Visible = TotalAfterDeductionLCYVisible;
            }
            field(AdvanceEntries; GetAdvanceEntriesCount())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advance Entries';
                ToolTip = 'Specifies number of advance entries.';
                DrillDown = true;
                Visible = AdvanceEntriesVisible;

                trigger OnDrillDown()
                begin
                    if not TempPurchAdvLetterEntryCZZ.IsEmpty() then
                        Page.Run(0, TempPurchAdvLetterEntryCZZ);
                    if not TempSalesAdvLetterEntryCZZ.IsEmpty() then
                        Page.Run(0, TempSalesAdvLetterEntryCZZ);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetControlAppearance();
    end;

    var
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        TempPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ" temporary;
        DocumentTotalAmount, DocumentTotalAmountLCY : Decimal;
        AmountToUseVisible, AmountToUseLCYVisible : Boolean;
        AmountUsedVisible, AmountUsedLCYVisible : Boolean;
        TotalAfterDeductionVisible, TotalAfterDeductionLCYVisible : Boolean;
        AdvanceEntriesVisible: Boolean;
        JobInLCY: Boolean;
        IsJob: Boolean;

    procedure SetDocument(PurchaseHeader: Record "Purchase Header")
    begin
        ClearBuffers();
        DocumentTotalAmount := CalcDocumentTotalAmount(PurchaseHeader);
        DocumentTotalAmountLCY := CalcDocumentTotalAmountLCY(PurchaseHeader);
        CollectAssignedAdvances(PurchaseHeader.GetAdvLetterUsageDocTypeCZZ(), PurchaseHeader."No.");
        CollectPurchAdvLetterEntries(PurchaseHeader);
        CurrPage.Update();
    end;

    procedure SetDocument(SalesHeader: Record "Sales Header")
    begin
        ClearBuffers();
        DocumentTotalAmount := CalcDocumentTotalAmount(SalesHeader);
        DocumentTotalAmountLCY := CalcDocumentTotalAmountLCY(SalesHeader);
        CollectAssignedAdvances(SalesHeader.GetAdvLetterUsageDocTypeCZZ(), SalesHeader."No.");
        CollectSalesAdvLetterEntries(SalesHeader);
        CurrPage.Update();
    end;

    procedure SetDocument(PurchInvHeader: Record "Purch. Inv. Header")
    begin
        ClearBuffers();
        DocumentTotalAmount := CalcDocumentTotalAmount(PurchInvHeader);
        DocumentTotalAmountLCY := CalcDocumentTotalAmountLCY(PurchInvHeader);
        CollectAssignedAdvances("Adv. Letter Usage Doc.Type CZZ"::"Posted Purchase Invoice", PurchInvHeader."No.");
        CollectPurchAdvLetterEntries(PurchInvHeader);
        CurrPage.Update();
    end;

    procedure SetDocument(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        ClearBuffers();
        DocumentTotalAmount := CalcDocumentTotalAmount(SalesInvoiceHeader);
        DocumentTotalAmountLCY := CalcDocumentTotalAmountLCY(SalesInvoiceHeader);
        CollectAssignedAdvances("Adv. Letter Usage Doc.Type CZZ"::"Posted Sales Invoice", SalesInvoiceHeader."No.");
        CollectSalesAdvLetterEntries(SalesInvoiceHeader);
        CurrPage.Update();
    end;

    procedure SetDocument(Job: Record Job)
    begin
        ClearBuffers();
        DocumentTotalAmount := CalcDocumentTotalAmount(Job);
        CollectAssignedAdvances(Job."No.");
        JobInLCY := Job."Currency Code" = '';
        IsJob := true;
        CurrPage.Update();
    end;

    local procedure SetControlAppearance()
    begin
        AmountToUseVisible := true;
        AmountToUseLCYVisible := false;
        AmountUsedVisible := true;
        AmountUsedLCYVisible := false;
        TotalAfterDeductionVisible := true;
        TotalAfterDeductionLCYVisible := false;
        AdvanceEntriesVisible := true;

        if IsJob then begin
            AmountToUseVisible := not JobInLCY;
            AmountToUseLCYVisible := JobInLCY;
            AmountUsedVisible := not JobInLCY;
            AmountUsedLCYVisible := JobInLCY;
            TotalAfterDeductionVisible := not JobInLCY;
            TotalAfterDeductionLCYVisible := JobInLCY;
            AdvanceEntriesVisible := false;
        end;
    end;

    local procedure CollectAssignedAdvances(DocumentType: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20])
    begin
        TempAdvanceLetterApplicationCZZ.GetAssignedAdvance(DocumentType, DocumentNo, TempAdvanceLetterApplicationCZZ);
    end;

    local procedure CollectAssignedAdvances(JobNo: Code[20])
    begin
        TempAdvanceLetterApplicationCZZ.GetAssignedAdvance(JobNo, TempAdvanceLetterApplicationCZZ);
    end;

    local procedure CollectPurchAdvLetterEntries(PurchaseHeader: Record "Purchase Header")
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        PurchAdvLetterManagementCZZ.PostAdvancePaymentUsagePreview(
            PurchaseHeader,
            GetAmountUsed(),
            GetAmountUsedLCY(),
            TempPurchAdvLetterEntryCZZ);
        TempPurchAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1&<>%2&<>%3',
            TempPurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage",
            TempPurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate",
            TempPurchAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
        TempPurchAdvLetterEntryCZZ.DeleteAll();
        TempPurchAdvLetterEntryCZZ.Reset();
    end;

    local procedure CollectPurchAdvLetterEntries(PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if PurchAdvLetterEntryCZZ.FindSet() then
            repeat
                TempPurchAdvLetterEntryCZZ.Init();
                TempPurchAdvLetterEntryCZZ := PurchAdvLetterEntryCZZ;
                TempPurchAdvLetterEntryCZZ.Insert();
            until PurchAdvLetterEntryCZZ.Next() = 0;
    end;

    local procedure CollectSalesAdvLetterEntries(SalesHeader: Record "Sales Header")
    var
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
    begin
        SalesAdvLetterManagementCZZ.PostAdvancePaymentUsagePreview(
            SalesHeader,
            GetAmountUsed(),
            GetAmountUsedLCY(),
            TempSalesAdvLetterEntryCZZ);
        TempSalesAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1&<>%2&<>%3',
            TempSalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage",
            TempSalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate",
            TempSalesAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
        TempSalesAdvLetterEntryCZZ.DeleteAll();
        TempSalesAdvLetterEntryCZZ.Reset();
    end;

    local procedure CollectSalesAdvLetterEntries(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if SalesAdvLetterEntryCZZ.FindSet() then
            repeat
                TempSalesAdvLetterEntryCZZ.Init();
                TempSalesAdvLetterEntryCZZ := SalesAdvLetterEntryCZZ;
                TempSalesAdvLetterEntryCZZ.Insert();
            until SalesAdvLetterEntryCZZ.Next() = 0;
    end;

    local procedure CalcDocumentTotalAmount(PurchaseHeader: Record "Purchase Header"): Decimal
    var
        TempPurchaseLine: Record "Purchase Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        PurchPost: Codeunit "Purch.-Post";
    begin
        PurchPost.GetPurchLines(PurchaseHeader, TempPurchaseLine, 1);
        TempPurchaseLine.CalcVATAmountLines(1, PurchaseHeader, TempPurchaseLine, TempVATAmountLine);
        TempPurchaseLine.UpdateVATOnLines(1, PurchaseHeader, TempPurchaseLine, TempVATAmountLine);
        exit(TempVATAmountLine.GetTotalAmountInclVAT());
    end;

    local procedure CalcDocumentTotalAmountLCY(PurchaseHeader: Record "Purchase Header"): Decimal
    begin
        exit(CalcAmountLCY(DocumentTotalAmount, PurchaseHeader."Currency Factor"))
    end;

    local procedure CalcDocumentTotalAmount(SalesHeader: Record "Sales Header"): Decimal
    var
        TempSalesLine: Record "Sales Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 1);
        TempSalesLine.CalcVATAmountLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        exit(TempVATAmountLine.GetTotalAmountInclVAT());
    end;

    local procedure CalcDocumentTotalAmountLCY(SalesHeader: Record "Sales Header"): Decimal
    begin
        exit(CalcAmountLCY(DocumentTotalAmount, SalesHeader."Currency Factor"))
    end;

    local procedure CalcDocumentTotalAmount(PurchInvHeader: Record "Purch. Inv. Header"): Decimal
    begin
        PurchInvHeader.CalcFields("Amount Including VAT");
        exit(PurchInvHeader."Amount Including VAT");
    end;

    local procedure CalcDocumentTotalAmountLCY(PurchInvHeader: Record "Purch. Inv. Header"): Decimal
    begin
        exit(CalcAmountLCY(DocumentTotalAmount, PurchInvHeader."Currency Factor"))
    end;

    local procedure CalcDocumentTotalAmount(SalesInvoiceHeader: Record "Sales Invoice Header"): Decimal
    begin
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        exit(SalesInvoiceHeader."Amount Including VAT");
    end;

    local procedure CalcDocumentTotalAmountLCY(SalesInvoiceHeader: Record "Sales Invoice Header"): Decimal
    begin
        exit(CalcAmountLCY(DocumentTotalAmount, SalesInvoiceHeader."Currency Factor"))
    end;

    local procedure CalcDocumentTotalAmount(Job: Record Job) TotalAmount: Decimal
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.SetRange("Contract Line", true);
        JobPlanningLine.SetFilter(Type, '<>%1', JobPlanningLine.Type::Text);
        JobPlanningLine.SetFilter("Line Amount", '<>%1', 0);
        if JobPlanningLine.FindSet() then
            repeat
                TotalAmount += JobPlanningLine.CalcLineAmountIncludingVAT();
            until JobPlanningLine.Next() = 0;
    end;

    local procedure CalcAmountLCY(Amount: Decimal; CurrencyFactor: Decimal): Decimal
    begin
        if CurrencyFactor = 0 then
            CurrencyFactor := 1;
        exit(Amount / CurrencyFactor);
    end;

    local procedure ClearBuffers()
    begin
        TempAdvanceLetterApplicationCZZ.Reset();
        TempAdvanceLetterApplicationCZZ.DeleteAll();
        TempPurchAdvLetterEntryCZZ.Reset();
        TempPurchAdvLetterEntryCZZ.DeleteAll();
        TempSalesAdvLetterEntryCZZ.Reset();
        TempSalesAdvLetterEntryCZZ.DeleteAll();
    end;

    local procedure GetAdvanceEntriesCount(): Integer
    begin
        // one of the following buffers must be empty
        exit(TempPurchAdvLetterEntryCZZ.Count() + TempSalesAdvLetterEntryCZZ.Count());
    end;

    local procedure GetAdvancesCount(): Integer
    begin
        exit(TempAdvanceLetterApplicationCZZ.Count());
    end;

    local procedure GetAmountToUse(): Decimal
    begin
        TempAdvanceLetterApplicationCZZ.CalcSums("Amount to Use");
        exit(TempAdvanceLetterApplicationCZZ."Amount to Use");
    end;

    local procedure GetAmountToUseLCY(): Decimal
    begin
        TempAdvanceLetterApplicationCZZ.CalcSums("Amount to Use (LCY)");
        exit(TempAdvanceLetterApplicationCZZ."Amount to Use (LCY)");
    end;

    local procedure GetAmountUsed(): Decimal
    begin
        TempAdvanceLetterApplicationCZZ.CalcSums(Amount);
        if DocumentTotalAmount <= TempAdvanceLetterApplicationCZZ.Amount then
            exit(DocumentTotalAmount);
        exit(TempAdvanceLetterApplicationCZZ.Amount);
    end;

    local procedure GetAmountUsedLCY(): Decimal
    begin
        TempAdvanceLetterApplicationCZZ.CalcSums("Amount (LCY)");
        if DocumentTotalAmountLCY <= TempAdvanceLetterApplicationCZZ."Amount (LCY)" then
            exit(DocumentTotalAmountLCY);
        exit(TempAdvanceLetterApplicationCZZ."Amount (LCY)");
    end;

    local procedure GetTotalAfterDeduction(): Decimal
    begin
        exit(DocumentTotalAmount - GetAmountUsed());
    end;

    local procedure GetTotalAfterDeductionLCY(): Decimal
    begin
        exit(DocumentTotalAmount - GetAmountUsedLCY());
    end;
}
