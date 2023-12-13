// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

report 31013 "Adjust Adv. Exch. Rates CZZ"
{
    Caption = 'Adjust Advance Letter Exchange Rates';
    UsageCategory = Tasks;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";

            dataitem("Sales Adv. Letter Header CZZ"; "Sales Adv. Letter Header CZZ")
            {
                DataItemTableView = where("Currency Code" = filter(<> ''));
                DataItemLink = "Bill-to Customer No." = field("No.");

                trigger OnAfterGetRecord()
                var
                    SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
                begin
                    if Status = Status::Closed then begin
                        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", "No.");
                        SalesAdvLetterEntryCZZ.SetFilter("Posting Date", '>%1', AdjustToDate);
                        if not SalesAdvLetterEntryCZZ.IsEmpty() then begin
                            TempSalesAdvLetterHeaderCZZ := "Sales Adv. Letter Header CZZ";
                            TempSalesAdvLetterHeaderCZZ.Insert();
                        end;
                    end else begin
                        TempSalesAdvLetterHeaderCZZ := "Sales Adv. Letter Header CZZ";
                        TempSalesAdvLetterHeaderCZZ.Insert();
                    end;
                end;
            }

            trigger OnPreDataItem()
            begin
                if not AdjustCustomer then
                    CurrReport.Break();
            end;

            trigger OnPostDataItem()
            var
                SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
                DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
            begin
                if TempSalesAdvLetterHeaderCZZ.FindSet() then
                    repeat
                        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", TempSalesAdvLetterHeaderCZZ."No.");
                        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
                        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                        SalesAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', AdjustToDate);
                        if SalesAdvLetterEntryCZZ.FindSet() then
                            repeat
                                if SalesAdvLetterManagementCZZ.GetRemAmtSalAdvPayment(SalesAdvLetterEntryCZZ, AdjustToDate) <> 0 then begin
                                    DetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
                                    DetailedCustLedgEntry.SetFilter("Entry Type", '%1|%2', DetailedCustLedgEntry."Entry Type"::"Unrealized Gain", DetailedCustLedgEntry."Entry Type"::"Unrealized Loss");
                                    DetailedCustLedgEntry.SetFilter("Posting Date", '..%1', AdjustToDate);
                                    if DetailedCustLedgEntry.FindSet() then
                                        repeat
                                            if DetailedCustLedgEntry."Amount (LCY)" <> 0 then
                                                SalesAdvLetterManagementCZZ.AdjustVATExchangeRate(SalesAdvLetterEntryCZZ, DetailedCustLedgEntry."Amount (LCY)", DetailedCustLedgEntry."Entry No.", AdjustToDate, DocumentNo, PostingDescription);
                                        until DetailedCustLedgEntry.Next() = 0;
                                end;
                            until SalesAdvLetterEntryCZZ.Next() = 0;
                    until TempSalesAdvLetterHeaderCZZ.Next() = 0;
            end;
        }
        dataitem(Vendor; Vendor)
        {
            RequestFilterFields = "No.";

            dataitem("Purch. Adv. Letter Header CZZ"; "Purch. Adv. Letter Header CZZ")
            {
                DataItemTableView = where("Currency Code" = filter(<> ''));
                DataItemLink = "Pay-to Vendor No." = field("No.");

                trigger OnAfterGetRecord()
                var
                    PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
                begin
                    if Status = Status::Closed then begin
                        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", "No.");
                        PurchAdvLetterEntryCZZ.SetFilter("Posting Date", '>%1', AdjustToDate);
                        if not PurchAdvLetterEntryCZZ.IsEmpty() then begin
                            TempPurchAdvLetterHeaderCZZ := "Purch. Adv. Letter Header CZZ";
                            TempPurchAdvLetterHeaderCZZ.Insert();
                        end;
                    end else begin
                        TempPurchAdvLetterHeaderCZZ := "Purch. Adv. Letter Header CZZ";
                        TempPurchAdvLetterHeaderCZZ.Insert();
                    end;
                end;
            }

            trigger OnPreDataItem()
            begin
                if not AdjustVendor then
                    CurrReport.Break();
            end;

            trigger OnPostDataItem()
            var
                PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
                DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
            begin
                if TempPurchAdvLetterHeaderCZZ.FindSet() then
                    repeat
                        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", TempPurchAdvLetterHeaderCZZ."No.");
                        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
                        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                        PurchAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', AdjustToDate);
                        if PurchAdvLetterEntryCZZ.FindSet() then
                            repeat
                                if PurchAdvLetterManagementCZZ.GetRemAmtPurchAdvPayment(PurchAdvLetterEntryCZZ, AdjustToDate) <> 0 then begin
                                    DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
                                    DetailedVendorLedgEntry.SetFilter("Entry Type", '%1|%2', DetailedVendorLedgEntry."Entry Type"::"Unrealized Gain", DetailedVendorLedgEntry."Entry Type"::"Unrealized Loss");
                                    DetailedVendorLedgEntry.SetFilter("Posting Date", '..%1', AdjustToDate);
                                    if DetailedVendorLedgEntry.FindSet() then
                                        repeat
                                            if DetailedVendorLedgEntry."Amount (LCY)" <> 0 then
                                                PurchAdvLetterManagementCZZ.AdjustVATExchangeRate(PurchAdvLetterEntryCZZ, DetailedVendorLedgEntry."Amount (LCY)", DetailedVendorLedgEntry."Entry No.", AdjustToDate, DocumentNo, PostingDescription);
                                        until DetailedVendorLedgEntry.Next() = 0;
                                end;
                            until PurchAdvLetterEntryCZZ.Next() = 0;
                    until TempPurchAdvLetterHeaderCZZ.Next() = 0;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(AdjustToDateField; AdjustToDate)
                    {
                        Caption = 'Adjust to Date';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Adjust to date.';
                    }
                    field(DocumentNoField; DocumentNo)
                    {
                        Caption = 'Document No.';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Document no.';
                    }
                    field(PostingDesriptionField; PostingDescription)
                    {
                        Caption = 'Posting Description';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Posting Description';
                    }
                    field(AdjustCustomerField; AdjustCustomer)
                    {
                        Caption = 'Adjust Customer';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if customer''s entries have to be adjusted.';
                    }
                    field(AdjustVendorField; AdjustVendor)
                    {
                        Caption = 'Adjust Vendor';
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies if vendor''s entries have to be adjusted.';
                    }
                }
            }
        }
    }

    var
        TempSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ" temporary;
        TempPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ" temporary;
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
        PostingDescription: Text[100];
        DocumentNo: Code[20];
        AdjustToDate: Date;
        AdjustCustomer: Boolean;
        AdjustVendor: Boolean;
        DocumentNoEmptyErr: Label 'Document no. cannot be empty.';

    trigger OnPreReport()
    begin
        if DocumentNo = '' then
            Error(DocumentNoEmptyErr);

        if AdjustToDate = 0D then
            AdjustToDate := WorkDate();
    end;
}
