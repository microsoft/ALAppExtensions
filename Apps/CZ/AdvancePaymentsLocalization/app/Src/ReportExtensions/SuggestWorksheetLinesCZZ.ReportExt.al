// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.CashFlow.Setup;
using Microsoft.CashFlow.Worksheet;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

reportextension 31001 "Suggest Worksheet Lines CZZ" extends "Suggest Worksheet Lines"
{
    dataset
    {
        addafter("Cash Flow Azure AI Buffer")
        {
            dataitem("Sales Adv. Letter Header CZZ"; "Sales Adv. Letter Header CZZ")
            {
                DataItemTableView = sorting("No.") where(Status = const("To Pay"));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, SalesAdvancesCZZMsg);
                    Window.Update(3, "No.");

                    if "Bill-to Customer No." <> '' then
                        CustomerCZZ.Get("Bill-to Customer No.")
                    else
                        CustomerCZZ.Init();

                    InsertCFLineForSalesAdvanceLetterHeader();
                end;

                trigger OnPreDataItem()
                begin
                    if not IsSalesAdvanceLettersConsideredCZZ then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;
            }
            dataitem("Purch. Adv. Letter Header CZZ"; "Purch. Adv. Letter Header CZZ")
            {
                DataItemTableView = sorting("No.") where(Status = const("To Pay"));

                trigger OnAfterGetRecord()
                begin
                    Window.Update(2, PurchaseAdvancesCZZMsg);
                    Window.Update(3, "No.");

                    if "Pay-to Vendor No." <> '' then
                        VendorCZZ.Get("Pay-to Vendor No.")
                    else
                        VendorCZZ.Init();

                    InsertCFLineForPurchAdvanceLetterHeader();
                end;

                trigger OnPreDataItem()
                begin
                    if not IsPurchaseAdvanceLettersConsideredCZZ then
                        CurrReport.Break();

                    if not ReadPermission then
                        CurrReport.Break();
                end;
            }
        }
        modify("Cust. Ledger Entry")
        {
            trigger OnBeforePreDataItem()
            begin
                SetRange("Advance Letter No. CZZ", '');
            end;
        }
        modify("Vendor Ledger Entry")
        {
            trigger OnBeforePreDataItem()
            begin
                SetRange("Advance Letter No. CZZ", '');
            end;
        }
        modify("Sales Line")
        {
            trigger OnAfterAfterGetRecord()
            var
                TempAdvanceLetterApplication: Record "Advance Letter Application CZZ" temporary;
            begin
                if not TempCFWorksheetLine.Find() then
                    exit;
                if "Document Type" = "Document Type"::Order then
                    AdvanceLetterApplication.GetAssignedAdvance("Adv. Letter Usage Doc.Type CZZ"::"Sales Order", "Document No.", TempAdvanceLetterApplication)
                else
                    AdvanceLetterApplication.GetAssignedAdvance("Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", "Document No.", TempAdvanceLetterApplication);
                TempAdvanceLetterApplication.CalcSums("Amount (LCY)");
                TempCFWorksheetLine."Amount (LCY)" -= TempAdvanceLetterApplication."Amount (LCY)";
                if TempCFWorksheetLine."Amount (LCY)" = 0 then
                    TempCFWorksheetLine.Delete()
                else
                    TempCFWorksheetLine.Modify();
            end;
        }
        modify("Purchase Line")
        {
            trigger OnAfterAfterGetRecord()
            var
                TempAdvanceLetterApplication: Record "Advance Letter Application CZZ" temporary;
            begin
                if not TempCFWorksheetLine.Find() then
                    exit;
                if "Document Type" = "Document Type"::Order then
                    AdvanceLetterApplication.GetAssignedAdvance("Adv. Letter Usage Doc.Type CZZ"::"Purchase Order", "Document No.", TempAdvanceLetterApplication)
                else
                    AdvanceLetterApplication.GetAssignedAdvance("Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", "Document No.", TempAdvanceLetterApplication);
                TempAdvanceLetterApplication.CalcSums("Amount (LCY)");
                TempCFWorksheetLine."Amount (LCY)" += TempAdvanceLetterApplication."Amount (LCY)";
                if TempCFWorksheetLine."Amount (LCY)" = 0 then
                    TempCFWorksheetLine.Delete()
                else
                    TempCFWorksheetLine.Modify();
            end;
        }
    }

    requestpage
    {
        layout
        {
            addafter("ConsiderSource[SourceType::""G/L Budget""]")
            {
                field(IsSalesAdvanceLettersConsidered; IsSalesAdvanceLettersConsideredCZZ)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Advances';
                    ToolTip = 'Specifies if sales advances will be sugested';
                }
                field(IsPurchaseAdvanceLettersConsidered; IsPurchaseAdvanceLettersConsideredCZZ)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Advances';
                    ToolTip = 'Specifies if purchase advances will be sugested';
                }
            }
        }

        trigger OnClosePage()
        begin
            SuggWkshLinesHandlerCZZ.SetSalesAdvanceLettersConsidered(IsSalesAdvanceLettersConsideredCZZ);
            SuggWkshLinesHandlerCZZ.SetPurchaseAdvanceLettersConsidered(IsPurchaseAdvanceLettersConsideredCZZ);
            BindSubscription(SuggWkshLinesHandlerCZZ);
        end;
    }

    trigger OnPreReport()
    begin
        UnbindSubscription(SuggWkshLinesHandlerCZZ);
        CashFlowSetup.Get();
    end;

    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        CustomerCZZ: Record Customer;
        CashFlowSetup: Record "Cash Flow Setup";
        VendorCZZ: Record Vendor;
        SuggWkshLinesHandlerCZZ: Codeunit "Sugg. Wksh. Lines Handler CZZ";
        IsSalesAdvanceLettersConsideredCZZ: Boolean;
        IsPurchaseAdvanceLettersConsideredCZZ: Boolean;
        SalesAdvancesCZZMsg: Label 'Sales Advances';
        PurchaseAdvancesCZZMsg: Label 'Purchase Advances';
        ThreePlaceholdersTxt: Label '%1 %2 %3', Comment = '%1 = table caption, %2 = name of customer/vendor, %3 = date';

    local procedure InsertCFLineForSalesAdvanceLetterHeader()
    var
        CashFlowWorksheetLine: Record "Cash Flow Worksheet Line";
        DummyCashFlowWorksheetLine: Record "Cash Flow Worksheet Line";
        PaymentTermsCode: Code[10];
    begin
        if "Cash Flow Forecast"."Consider CF Payment Terms" and (CustomerCZZ."Cash Flow Payment Terms Code" <> '') then
            PaymentTermsCode := CustomerCZZ."Cash Flow Payment Terms Code"
        else
            PaymentTermsCode := "Sales Adv. Letter Header CZZ"."Payment Terms Code";

        CashFlowWorksheetLine.Init();
        CashFlowWorksheetLine."Document Type" := CashFlowWorksheetLine."Document Type"::Invoice;
        CashFlowWorksheetLine."Document Date" := "Sales Adv. Letter Header CZZ"."Document Date";
        CashFlowWorksheetLine."Source Type" := Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ";
        CashFlowWorksheetLine."Source No." := "Sales Adv. Letter Header CZZ"."No.";
        CashFlowWorksheetLine."Shortcut Dimension 1 Code" := "Sales Adv. Letter Header CZZ"."Shortcut Dimension 1 Code";
        CashFlowWorksheetLine."Shortcut Dimension 2 Code" := "Sales Adv. Letter Header CZZ"."Shortcut Dimension 2 Code";
        CashFlowWorksheetLine."Dimension Set ID" := "Sales Adv. Letter Header CZZ"."Dimension Set ID";
        CashFlowWorksheetLine."Cash Flow Account No." := CashFlowSetup."S. Adv. Letter CF Acc. No. CZZ";
        CashFlowWorksheetLine.Description := CopyStr(
            StrSubstNo(
                ThreePlaceholdersTxt,
                "Sales Adv. Letter Header CZZ".TableCaption,
                "Sales Adv. Letter Header CZZ"."Bill-to Name",
                Format("Sales Adv. Letter Header CZZ"."Document Date")),
            1, MaxStrLen(DummyCashFlowWorksheetLine.Description));
        CashFlowWorksheetLine."Cash Flow Date" := "Sales Adv. Letter Header CZZ"."Advance Due Date";
        CashFlowWorksheetLine."Document No." := "Sales Adv. Letter Header CZZ"."No.";
        CashFlowWorksheetLine."Amount (LCY)" := CalculateAmountForSalesAdvanceLetter();
        CashFlowWorksheetLine."Payment Terms Code" := PaymentTermsCode;
        InsertTempCFWorksheetLine(CashFlowWorksheetLine, 0);
    end;

    local procedure InsertCFLineForPurchAdvanceLetterHeader()
    var
        CashFlowWorksheetLine: Record "Cash Flow Worksheet Line";
        DummyCashFlowWorksheetLine: Record "Cash Flow Worksheet Line";
        PaymentTermsCode: Code[10];
    begin
        if "Cash Flow Forecast"."Consider CF Payment Terms" and (VendorCZZ."Cash Flow Payment Terms Code" <> '') then
            PaymentTermsCode := VendorCZZ."Cash Flow Payment Terms Code"
        else
            PaymentTermsCode := "Purch. Adv. Letter Header CZZ"."Payment Terms Code";

        CashFlowWorksheetLine.Init();
        CashFlowWorksheetLine."Document Type" := CashFlowWorksheetLine."Document Type"::Invoice;
        CashFlowWorksheetLine."Document Date" := "Purch. Adv. Letter Header CZZ"."Document Date";
        CashFlowWorksheetLine."Source Type" := Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ";
        CashFlowWorksheetLine."Source No." := "Purch. Adv. Letter Header CZZ"."No.";
        CashFlowWorksheetLine."Shortcut Dimension 1 Code" := "Purch. Adv. Letter Header CZZ"."Shortcut Dimension 1 Code";
        CashFlowWorksheetLine."Shortcut Dimension 2 Code" := "Purch. Adv. Letter Header CZZ"."Shortcut Dimension 2 Code";
        CashFlowWorksheetLine."Dimension Set ID" := "Purch. Adv. Letter Header CZZ"."Dimension Set ID";
        CashFlowWorksheetLine."Cash Flow Account No." := CashFlowSetup."P. Adv. Letter CF Acc. No. CZZ";
        CashFlowWorksheetLine.Description := CopyStr(
            StrSubstNo(
                ThreePlaceholdersTxt,
                "Purch. Adv. Letter Header CZZ".TableCaption,
                "Purch. Adv. Letter Header CZZ"."Pay-to Name",
                Format("Purch. Adv. Letter Header CZZ"."Document Date")),
            1, MaxStrLen(DummyCashFlowWorksheetLine.Description));
        CashFlowWorksheetLine."Cash Flow Date" := "Purch. Adv. Letter Header CZZ"."Advance Due Date";
        CashFlowWorksheetLine."Document No." := "Purch. Adv. Letter Header CZZ"."No.";
        CashFlowWorksheetLine."Amount (LCY)" := CalculateAmountForPurchaseAdvanceLetter();
        CashFlowWorksheetLine."Payment Terms Code" := PaymentTermsCode;
        InsertTempCFWorksheetLine(CashFlowWorksheetLine, 0);
    end;

    local procedure CalculateAmountForSalesAdvanceLetter(): Decimal
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        InitialAmount: Decimal;
    begin
        SalesAdvLetterEntryCZZ.SetCurrentKey("Sales Adv. Letter No.", "Entry Type");
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", "Sales Adv. Letter Header CZZ"."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        SalesAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
        InitialAmount := SalesAdvLetterEntryCZZ."Amount (LCY)";

        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
        exit(InitialAmount + SalesAdvLetterEntryCZZ."Amount (LCY)");
    end;

    local procedure CalculateAmountForPurchaseAdvanceLetter(): Decimal
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        InitialAmount: Decimal;
    begin
        PurchAdvLetterEntryCZZ.SetCurrentKey("Purch. Adv. Letter No.", "Entry Type");
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", "Purch. Adv. Letter Header CZZ"."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        PurchAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
        InitialAmount := PurchAdvLetterEntryCZZ."Amount (LCY)";

        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ.CalcSums("Amount (LCY)");
        exit(InitialAmount + PurchAdvLetterEntryCZZ."Amount (LCY)");
    end;

    procedure InitializeRequestCZZ(IsSalesAdvanceLettersConsidered: Boolean; IsPurchaseAdvanceLettersConsidered: Boolean)
    begin
        IsSalesAdvanceLettersConsideredCZZ := IsSalesAdvanceLettersConsidered;
        IsPurchaseAdvanceLettersConsideredCZZ := IsPurchaseAdvanceLettersConsidered;
    end;
}
