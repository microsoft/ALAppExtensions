// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Purchases.Payables;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.Currency;
using Microsoft.Finance.TaxBase;

codeunit 18685 "TDS Entity Management"
{
    procedure AddTDSSubSection(TDSSection: Record "TDS Section")
    var
        ToSection: Record "TDS Section";
        SubSection: Record "TDS Section";
    begin
        ToSection.Init();

        SubSection.Reset();
        SubSection.SetCurrentKey("Section Order");
        SubSection.SetRange("Parent Code", TDSSection.Code);
        if SubSection.FindLast() then
            ToSection."Section Order" := SubSection."Section Order" + 1
        else
            ToSection."Section Order" := 1;

        if StrLen(TDSSection.Code) + 2 <= MaxStrLen(TDSSection.Code) then
            ToSection.Code := Format(TDSSection.Code) + '-' + Format(ToSection."Section Order")
        else
            ToSection.Code := Format(ToSection."Section Order");

        ToSection.Description := TDSSection.Description;
        ToSection."Parent Code" := TDSSection.Code;
        ToSection."Indentation Level" := TDSSection."Indentation Level" + 1;
        ToSection.Insert(true);
    end;

    procedure GetDetailTxt(TDSSection: Record "TDS Section") DetailTxt: Text
    var
        InStream: InStream;
        SectionsDetailLbl: Label 'Click here to enter Section Details';
    begin
        TDSSection.CalcFields(Detail);
        if not TDSSection.Detail.HasValue() then begin
            DetailTxt := SectionsDetailLbl;
            exit;
        end else
            TDSSection.Detail.CreateInStream(InStream);
        InStream.ReadText(DetailTxt);
    end;

    procedure SetDetailTxt(DetailTxt: Text; var TDSSection: Record "TDS Section")
    var
        OutStream: OutStream;
    begin
        TDSSection.Detail.CreateOutStream(OutStream);
        OutStream.WriteText(DetailTxt);
        TDSSection.Modify(true);
    end;

    procedure OpenTDSEntries(FromEntry: Integer; ToEntry: Integer)
    var
        TDSEntry: Record "TDS Entry";
        GLEntry: Record "G/L Entry";
        FromTransactionNo: Integer;
        ToTransactionNo: Integer;
    begin
        if GLEntry.Get(FromEntry) then
            FromTransactionNo := GLEntry."Transaction No.";
        if GLEntry.Get(ToEntry) then
            ToTransactionNo := GLEntry."Transaction No.";
        TDSEntry.SetRange("Transaction No.", FromTransactionNo, ToTransactionNo);
        if not TDSEntry.IsEmpty() then
            Page.Run(0, TDSEntry);
    end;

    procedure RoundTDSAmount(TDSAmount: Decimal): Decimal
    var
        TaxComponent: Record "Tax Component";
        TDSSetup: Record "TDS Setup";
        TDSRoundingDirection: Text;
    begin
        if not TDSSetup.Get() then
            exit;

        TDSSetup.TestField("Tax Type");

        TaxComponent.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxComponent.SetRange(Name, TDSSetup."Tax Type");
        TaxComponent.FindFirst();
        case TaxComponent.Direction of
            TaxComponent.Direction::Nearest:
                TDSRoundingDirection := '=';
            TaxComponent.Direction::Up:
                TDSRoundingDirection := '>';
            TaxComponent.Direction::Down:
                TDSRoundingDirection := '<';
        end;
        exit(Round(TDSAmount, TaxComponent."Rounding Precision", TDSRoundingDirection));
    end;

    procedure ConvertTDSAmountToLCY(
    CurrencyCode: Code[10];
    Amount: Decimal;
    CurrencyFactor: Decimal;
    PostingDate: Date): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        TaxComponent: Record "Tax Component";
        TDSSetup: Record "TDS Setup";
    begin
        if not TDSSetup.Get() then
            exit;

        TDSSetup.TestField("Tax Type");
        TaxComponent.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxComponent.SetRange(Name, TDSSetup."Tax Type");
        TaxComponent.FindFirst();

        exit(Round(
        CurrencyExchangeRate.ExchangeAmtFCYToLCY(
        PostingDate, CurrencyCode, Amount, CurrencyFactor), TaxComponent."Rounding Precision"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document GL Posting", 'OnPrepareTransValueToPost', '', false, false)]
    local procedure SetTotalTDSInclSHECessAmount(var TempTransValue: Record "Tax Transaction Value")
    var
        TDSSetup: Record "TDS Setup";
        TaxComponent: Record "Tax Component";
        TaxBaseSubscribers: Codeunit "Tax Base Subscribers";
        ComponenetNameLbl: Label 'Total TDS Amount';
    begin
        if TempTransValue."Value Type" <> TempTransValue."Value Type"::COMPONENT then
            exit;

        if not TDSSetup.Get() then
            exit;

        if TempTransValue."Tax Type" <> TDSSetup."Tax Type" then
            exit;

        TaxComponent.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxComponent.SetRange(Name, ComponenetNameLbl);
        if not TaxComponent.FindFirst() then
            exit;

        if TempTransValue."Value ID" <> TaxComponent.Id then
            exit;

        TaxBaseSubscribers.GetTDSAmount(TempTransValue.Amount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"TDS Section", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertTDSSection()
    var
        ParentSectionCode: Code[10];
        PresentationOrder: Integer;
    begin
        ParentSectionCode := '';
        ReAssignPresentationOrder(ParentSectionCode, PresentationOrder);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Suggest Vendor Payments", 'OnAfterPostDataItem', '', false, false)]
    local procedure OnAfterPostDataItemSuggetVendorPayment()
    var
        TDSEntryUpdateMgt: Codeunit "TDS Entry Update Mgt.";
    begin
        TDSEntryUpdateMgt.ClearVendorPayment();
    end;

    [EventSubscriber(ObjectType::Report, Report::"Suggest Vendor Payments", 'OnAfterIncludeVendor', '', false, false)]
    local procedure OnAfterIncludeVendorSuggetVendorPayment()
    var
        TDSEntryUpdateMgt: Codeunit "TDS Entry Update Mgt.";
    begin
        TDSEntryUpdateMgt.SetSuggetVendorPayment();
    end;

    local procedure ReAssignPresentationOrder(ParentSectionCode: Code[10]; var PresentationOrder: Integer)
    var
        TDSSection: Record "TDS Section";
    begin
        TDSSection.SetRange("Parent Code", ParentSectionCode);
        if TDSSection.FindSet() then
            repeat
                PresentationOrder += 1;
                TDSSection."Presentation Order" := PresentationOrder;
                TDSSection.Modify();
                ReAssignPresentationOrder(TDSSection.Code, PresentationOrder);
            until TDSSection.Next() = 0;
    end;
}
