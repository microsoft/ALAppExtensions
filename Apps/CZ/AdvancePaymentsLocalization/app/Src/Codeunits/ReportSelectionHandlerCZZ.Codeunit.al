// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Setup;
using System.EMail;

codeunit 31420 "Report Selection Handler CZZ"
{
    [EventSubscriber(ObjectType::Page, Page::"Report Selection - Sales", 'OnSetUsageFilterOnAfterSetFiltersByReportUsage', '', false, false)]
    local procedure AddSalesAdvanceReportsOnSetUsageFilterOnAfterSetFiltersByReportUsage(var Rec: Record "Report Selections"; ReportUsage2: Option)
    begin
        case ReportUsage2 of
            "Report Selection Usage Sales"::"Advance Letter CZZ".AsInteger():
                Rec.SetRange(Usage, "Report Selection Usage"::"Sales Advance Letter CZZ");
            "Report Selection Usage Sales"::"Advance VAT Document CZZ".AsInteger():
                Rec.SetRange(Usage, "Report Selection Usage"::"Sales Advance VAT Document CZZ");
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Report Selection - Sales", 'OnInitUsageFilterOnElseCase', '', false, false)]
    local procedure AddSalesAdvanceReportsOnInitUsageFilterOnElseCase(ReportUsage: Enum "Report Selection Usage"; var ReportUsage2: Enum "Report Selection Usage Sales")
    begin
        case ReportUsage of
            "Report Selection Usage"::"Sales Advance Letter CZZ":
                ReportUsage2 := "Report Selection Usage Sales"::"Advance Letter CZZ";
            "Report Selection Usage"::"Sales Advance VAT Document CZZ":
                ReportUsage2 := "Report Selection Usage Sales"::"Advance VAT Document CZZ";
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Report Selection - Purchase", 'OnSetUsageFilterOnAfterSetFiltersByReportUsage', '', false, false)]
    local procedure AddPurchaseAdvanceReportsOnSetUsageFilterOnAfterSetFiltersByReportUsage(var Rec: Record "Report Selections"; ReportUsage2: Enum "Report Selection Usage Purchase")
    begin
        case ReportUsage2 of
            "Report Selection Usage Purchase"::"Advance Letter CZZ":
                Rec.SetRange(Usage, "Report Selection Usage"::"Purchase Advance Letter CZZ");
            "Report Selection Usage Purchase"::"Advance VAT Document CZZ":
                Rec.SetRange(Usage, "Report Selection Usage"::"Purchase Advance VAT Document CZZ");
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Report Selections", 'OnAfterOnMapTableUsageValueToPageValue', '', false, false)]
    local procedure AddSalesAdvanceReportsOnAfterOnMapTableUsageValueToPageValue(var Usage2: Enum "Custom Report Selection Sales"; CustomReportSelection: Record "Custom Report Selection")
    begin
        case CustomReportSelection.Usage of
            "Report Selection Usage"::"Sales Advance Letter CZZ":
                Usage2 := Usage2::"Advance Letter CZZ";
            "Report Selection Usage"::"Sales Advance VAT Document CZZ":
                Usage2 := Usage2::"Advance VAT Document CZZ";
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Report Selections", 'OnValidateUsage2OnCaseElse', '', false, false)]
    local procedure AddSalesAdvanceReportsOnValidateUsage2OnCaseElse(var CustomReportSelection: Record "Custom Report Selection"; ReportUsage: Option)
    begin
        case ReportUsage of
            "Custom Report Selection Sales"::"Advance Letter CZZ".AsInteger():
                CustomReportSelection.Usage := "Report Selection Usage"::"Sales Advance Letter CZZ";
            "Custom Report Selection Sales"::"Advance VAT Document CZZ".AsInteger():
                CustomReportSelection.Usage := "Report Selection Usage"::"Sales Advance VAT Document CZZ";
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Report Selections", 'OnAfterFilterCustomerUsageReportSelections', '', false, false)]
    local procedure AddSalesAdvanceReportsOnAfterFilterCustomerUsageReportSelections(var ReportSelections: Record "Report Selections")
    begin
        ReportSelections.SetFilter(
            Usage, '%1|%2|%3|%4|%5|%6|%7|%8|%9|%10',
            "Report Selection Usage"::"S.Quote",
            "Report Selection Usage"::"S.Order",
            "Report Selection Usage"::"S.Invoice",
            "Report Selection Usage"::"S.Cr.Memo",
            "Report Selection Usage"::"C.Statement",
            "Report Selection Usage"::JQ,
            "Report Selection Usage"::Reminder,
            "Report Selection Usage"::"S.Shipment",
            "Report Selection Usage"::"Sales Advance Letter CZZ",
            "Report Selection Usage"::"Sales Advance VAT Document CZZ");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Vendor Report Selections", 'OnAfterFilterVendorUsageReportSelections', '', false, false)]
    local procedure AddPurchaseAdvanceReportsOnAfterFilterVendorUsageReportSelections(var ReportSelections: Record "Report Selections")
    begin
        ReportSelections.SetFilter(
            Usage, '%1|%2|%3|%4|%5|%6',
            ReportSelections.Usage::"P.Order",
            ReportSelections.Usage::"V.Remittance",
            ReportSelections.Usage::"P.V.Remit.",
            ReportSelections.Usage::"P.Ret.Shpt.",
            ReportSelections.Usage::"Purchase Advance Letter CZZ",
            ReportSelections.Usage::"Purchase Advance VAT Document CZZ");
    end;

    procedure InsertRepSelection(ReportUsage: Enum "Report Selection Usage"; Sequence: Code[10]; ReportID: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        if not ReportSelections.Get(ReportUsage, Sequence) then begin
            ReportSelections.Init();
            ReportSelections.Usage := ReportUsage;
            ReportSelections.Sequence := Sequence;
            ReportSelections."Report ID" := ReportID;
            ReportSelections.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Report Distribution Management", 'OnAfterGetFullDocumentTypeText', '', false, false)]
    local procedure AddAdvanceReportsOnAfterGetFullDocumentTypeText(DocumentVariant: Variant; var DocumentTypeText: Text[50])
    var
        DocumentRecordRef: RecordRef;
        SalesAdvanceLetterLbl: Label 'Sales Advance';
        SalesAdvanceVATDocumentLbl: Label 'Sales Advance VAT Document';
        PurchaseAdvanceLetterLbl: Label 'Purchase Advance';
        PurchaseAdvanceVATDocumentLbl: Label 'Purchase Advance VAT Document';
    begin
        if DocumentVariant.IsRecord then
            DocumentRecordRef.GetTable(DocumentVariant)
        else
            if DocumentVariant.IsRecordRef then
                DocumentRecordRef := DocumentVariant;

        case DocumentRecordRef.Number of
            Database::"Sales Adv. Letter Header CZZ":
                DocumentTypeText := SalesAdvanceLetterLbl;
            Database::"Sales Adv. Letter Entry CZZ":
                DocumentTypeText := SalesAdvanceVATDocumentLbl;
            Database::"Purch. Adv. Letter Header CZZ":
                DocumentTypeText := PurchaseAdvanceLetterLbl;
            Database::"Purch. Adv. Letter Entry CZZ":
                DocumentTypeText := PurchaseAdvanceVATDocumentLbl;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email Scenario Mapping", 'OnAfterFromReportSelectionUsage', '', false, false)]
    local procedure AddSalesAdvanceReportsOnAfterFromReportSelectionUsage(ReportSelectionUsage: Enum "Report Selection Usage"; var EmailScenario: Enum "Email Scenario")
    begin
        case ReportSelectionUsage of
            ReportSelectionUsage::"Sales Advance Letter CZZ":
                EmailScenario := EmailScenario::"Sales Advance Letter CZZ";
            ReportSelectionUsage::"Sales Advance VAT Document CZZ":
                EmailScenario := EmailScenario::"Sales Advance VAT Document CZZ";
        end;
    end;
}
