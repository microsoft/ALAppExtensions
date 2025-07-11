// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Reports;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Ledger;

report 31300 "Intrastat - Invoice Check CZ"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/IntrastatInvoiceCheck.rdl';
    Caption = 'Intrastat - Invoice Checklist';

    dataset
    {
        dataitem("Intrastat Report Line"; "Intrastat Report Line")
        {
            DataItemTableView = sorting("Intrastat No.", "Line No.");
            RequestFilterFields = "Intrastat No.";

            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(Type_IntrastatReportLine; Type)
            {
                IncludeCaption = true;
            }
            column(DocumentType_ItemLedgerEntry; DocTypeText)
            {
            }
            column(DocumentNo_ItemLedgerEntry; ItemLedgerEntry."Document No.")
            {
            }
            column(PostingDate_ItemLedgerEntry; ItemLedgerEntry."Posting Date")
            {
            }
            column(ItemNo_IntrastatReportLine; "Item No.")
            {
                IncludeCaption = true;
            }
            column(TariffDescription_IntrastatReportLine; "Tariff Description")
            {
                IncludeCaption = true;
            }
            column(TariffNo_IntrastatReportLine; "Tariff No.")
            {
                IncludeCaption = true;
            }
            column(CountryRegionCode_IntrastatReportLine; "Country/Region Code")
            {
                IncludeCaption = true;
            }
            column(TransactionType_IntrastatReportLine; "Transaction Type")
            {
                IncludeCaption = true;
            }
            column(TransactionSpecification_IntrastatReportLine; "Transaction Specification")
            {
                IncludeCaption = true;
            }
            column(TransportMethod_IntrastatReportLine; "Transport Method")
            {
                IncludeCaption = true;
            }
            column(ShipmentMethodCode_IntrastatReportLine; "Shpt. Method Code")
            {
                IncludeCaption = true;
            }
            column(Area_IntrastatReportLine; Area)
            {
                IncludeCaption = true;
            }
            column(Quantity_IntrastatReportLine; Quantity)
            {
                IncludeCaption = true;
            }
            column(TotalWeight_IntrastatReportLine; "Total Weight")
            {
                IncludeCaption = true;
            }
            column(Amount_IntrastatReportLine; Amount)
            {
                IncludeCaption = true;
            }
            column(IntrastatNo_IntrastatReportLine; "Intrastat No.")
            {
            }
            column(LineNo_IntrastatReportLine; "Line No.")
            {
            }
            dataitem(TempDocBuffer; "G/L Account Adjust. Buffer CZL")
            {

                DataItemTableView = sorting("Document No.");
                UseTemporary = true;
                column(DocumentType_TempDocBuffer; TempDocBuffer.Description)
                {
                }
                column(DocumentNo_TempDocBuffer; TempDocBuffer."Document No.")
                {
                }
                column(PostingDate_TempDocBuffer; TempDocBuffer."Posting Date")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if TempDocBuffer."Debit Amount" + TempDocBuffer."Credit Amount" = 0 then
                        CurrReport.Skip();
                    if "Intrastat Report Line".Type = "Intrastat Report Line".Type::Shipment then begin
                        TempDocBuffer."Debit Amount" := -TempDocBuffer."Debit Amount";
                        TempDocBuffer."Credit Amount" := -TempDocBuffer."Credit Amount";
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                ValueEntry: Record "Value Entry";
                TotalAmt: Decimal;
                TotalCostAmt: Decimal;
                TotalAmtExpected: Decimal;
                TotalCostAmtExpected: Decimal;
                EntryNoWithQuantity: Integer;
            begin
                TempDocBuffer.DeleteAll();
                ValueEntry.SetCurrentKey("Item Ledger Entry No.");
                ValueEntry.SetRange("Item Ledger Entry No.", "Source Entry No.");
                ValueEntry.SetRange("Posting Date", StartDate, EndDate);
                ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
                if ValueEntry.FindSet() then
                    repeat
                        if ValueEntry."Item Charge No." = '' then
                            CalcTotalAmounts(ValueEntry, TotalAmt, TotalCostAmt, TotalAmtExpected, TotalCostAmtExpected);
                        if (ValueEntry."Item Ledger Entry Quantity" <> 0) and (ValueEntry."Valued Quantity" = 0) then
                            EntryNoWithQuantity := ValueEntry."Entry No."
                        else
                            AddToBuffer(ValueEntry."Document No.", TotalAmt, TotalCostAmt, ValueEntry."Posting Date", ValueEntry."Document Type");
                    until ValueEntry.Next() = 0;

                if ((TotalAmtExpected <> 0) or (TotalCostAmtExpected <> 0)) and (EntryNoWithQuantity <> 0) then begin
                    ValueEntry.Get(EntryNoWithQuantity);
                    AddToBuffer(ValueEntry."Document No.", TotalAmtExpected, TotalCostAmtExpected, ValueEntry."Posting Date", ValueEntry."Document Type");
                end;
                if not ItemLedgerEntry.Get("Source Entry No.") then
                    ItemLedgerEntry.Init();
                DocTypeText := Format(ItemLedgerEntry."Document Type");
            end;

            trigger OnPreDataItem()
            begin
                if not FindFirst() then
                    CurrReport.Break();
                GeneralLedgerSetup.Get();
                IntrastatReportHeader.Get("Intrastat No.");
                if IntrastatReportHeader."Amounts in Add. Currency" then
                    AddCurrencyFactor := CurrencyExchangeRate.ExchangeRate(WorkDate(), GeneralLedgerSetup."Additional Reporting Currency");
                StartDate := IntrastatReportHeader.GetStatisticsStartDate();
                EndDate := CalcDate('<CM>', StartDate);
            end;
        }
    }

    labels
    {
        PageLbl = 'Page';
        ReportNameLbl = 'Intrastat - Invoice Checklist';
        DocumentType_CaptionLbl = 'Document Type';
        DocumentNo_CaptionLbl = 'Document No.';
        Date_CaptionLbl = 'Date';
    }

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        IntrastatReportHeader: Record "Intrastat Report Header";
        ItemLedgerEntry: Record "Item Ledger Entry";
        DocTypeText: Text;
        StartDate: Date;
        EndDate: Date;
        AddCurrencyFactor: Decimal;

    local procedure CalcTotalAmounts(var ValueEntry: Record "Value Entry"; var TotalAmt: Decimal; var TotalCostAmt: Decimal; var TotalAmtExpected: Decimal; var TotalCostAmtExpected: Decimal)
    begin
        if not IntrastatReportHeader."Amounts in Add. Currency" then begin
            TotalAmt := ValueEntry."Sales Amount (Actual)";
            TotalCostAmt := ValueEntry."Cost Amount (Actual)";
            TotalAmtExpected := TotalAmtExpected + ValueEntry."Sales Amount (Expected)";
            TotalCostAmtExpected := TotalCostAmtExpected + ValueEntry."Cost Amount (Expected)";
        end else begin
            TotalCostAmt := ValueEntry."Cost Amount (Actual) (ACY)";
            TotalCostAmtExpected := TotalCostAmtExpected + ValueEntry."Cost Amount (Expected) (ACY)";
            if ValueEntry."Cost per Unit" <> 0 then begin
                TotalAmt :=
                  ValueEntry."Sales Amount (Actual)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit";
                TotalAmtExpected :=
                  TotalAmtExpected +
                  ValueEntry."Sales Amount (Expected)" * ValueEntry."Cost per Unit (ACY)" / ValueEntry."Cost per Unit";
            end else begin
                TotalAmt :=
                  CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                    ValueEntry."Posting Date", GeneralLedgerSetup."Additional Reporting Currency",
                    ValueEntry."Sales Amount (Actual)", AddCurrencyFactor);
                TotalAmtExpected :=
                  TotalAmtExpected +
                  CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                    ValueEntry."Posting Date", GeneralLedgerSetup."Additional Reporting Currency",
                    ValueEntry."Sales Amount (Expected)", AddCurrencyFactor);
            end;
        end;
    end;

    local procedure AddToBuffer(DocumentNo: Code[20]; SalesAmount: Decimal; CostAmount: Decimal; PostingDate: Date; DocumentType: Enum "Item Ledger Document Type")
    begin
        if TempDocBuffer.Get(DocumentNo) then begin
            TempDocBuffer."Debit Amount" := TempDocBuffer."Debit Amount" + SalesAmount;
            TempDocBuffer."Credit Amount" := TempDocBuffer."Credit Amount" + CostAmount;
            TempDocBuffer.Modify();
        end else begin
            TempDocBuffer.Init();
            TempDocBuffer."Document No." := DocumentNo;
            TempDocBuffer."Debit Amount" := SalesAmount;
            TempDocBuffer."Credit Amount" := CostAmount;
            TempDocBuffer."Posting Date" := PostingDate;
            TempDocBuffer.Description := Format(DocumentType);
            TempDocBuffer.Insert();
        end;
    end;
}
