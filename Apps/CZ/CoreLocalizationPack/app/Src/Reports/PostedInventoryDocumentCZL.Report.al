// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.History;

using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;

report 31079 "Posted Inventory Document CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PostedInventoryDocument.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Posted Inventory Document';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Item Register"; "Item Register")
        {
            DataItemTableView = sorting("No.");

            trigger OnAfterGetRecord()
            begin
                ItemRegister := "Item Register";
                CurrReport.Break();
            end;

            trigger OnPreDataItem()
            begin
                if "Item Register".GetFilters() = '' then
                    CurrReport.Break();
            end;
        }
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            DataItemTableView = sorting("Document No.", "Document Type", "Document Line No.") where(Quantity = filter(<> 0));
            RequestFilterFields = "Document No.", "Posting Date";
            column(CompanyName; StrSubstNo(CompanyInfoTok, CompanyInformation.Name, CompanyInformation."Name 2"))
            {
            }
            column(CompanyAddress; StrSubstNo(CompanyInfoTok, CompanyInformation.Address, CompanyInformation."Address 2"))
            {
            }
            column(CompanyCity; StrSubstNo(CompanyInfoTok, CompanyInformation."Post Code", CompanyInformation.City))
            {
            }
            column(CompanyRegNo; StrSubstNo(RegistrationInfoTok, CompanyInformation.FieldCaption("Registration No."), CompanyInformation."Registration No."))
            {
            }
            column(CompanyVATRegNo; StrSubstNo(RegistrationInfoTok, CompanyInformation.FieldCaption("VAT Registration No."), CompanyInformation."VAT Registration No."))
            {
            }
            column(EntryType; EntryType)
            {
            }
            column(DocumentNo; "Document No.")
            {
            }
            column(IssueDate; Format("Document Date", 0, 4))
            {
            }
            column(RegUserID; "Item Register"."User ID")
            {
            }
            column(PostingDate; Format("Posting Date", 0, 4))
            {
            }
            column(PostingDateCaption; StrSubstNo(PostingDateCaptionTok, FieldCaption("Posting Date")))
            {
            }
            column(ItemLedgerEntry_EntryType; "Entry Type")
            {
                IncludeCaption = true;
            }
            column(ItemLedgerEntry_PostingDate; "Posting Date")
            {
                IncludeCaption = true;
            }
            column(ItemLedgerEntry_ItemNo; "Item No.")
            {
                IncludeCaption = true;
            }
            column(DescriptionText; DescriptionText)
            {
            }
            column(ItemLedgerEntry_LocationCode; "Location Code")
            {
                IncludeCaption = true;
            }
            column(ItemLedgerEntry_UoM; UnitOfMeasureCode)
            {
            }
            column(ItemLedgerEntry_UoMCaption; FieldCaption("Unit of Measure Code"))
            {
            }
            column(ItemLedgerEntry_UnitPrice; UnitPrice)
            {
            }
            column(ItemLedgerEntry_Qty; Quantity)
            {
                IncludeCaption = true;
            }
            column(ItemLedgerEntry_Amount; "Cost Amount (Actual)")
            {
            }
            column(ItemLedgerEntry_Description; Description)
            {
                IncludeCaption = true;
            }
            column(ItemLedgerEntry_QuantityUoM; QuantityUoM)
            {
            }
            trigger OnAfterGetRecord()
            var
                ItemLedgerEntry1: Record "Item Ledger Entry";
            begin
                if Description <> '' then
                    DescriptionText := Description
                else begin
                    Item.Get("Item No.");
                    DescriptionText :=
                      CopyStr(Item.Description + ' ' + Item."Description 2", 1, MaxStrLen(DescriptionText));
                end;

                if PrintQtyInUoM = PrintQtyInUoM::"Base UoM" then begin
                    if Item."No." <> "Item No." then
                        Item.Get("Item No.");
                    UnitOfMeasureCode := Item."Base Unit of Measure";
                end else
                    UnitOfMeasureCode := "Unit of Measure Code";

                if (PrintQtyInUoM = PrintQtyInUoM::"Movement UoM") and (not ("Qty. per Unit of Measure" in [0, 1])) then
                    QuantityUoM := Round(Quantity / "Qty. per Unit of Measure", 0.00001)
                else
                    QuantityUoM := Quantity;

                CalcFields("Cost Amount (Actual)");

                if QuantityUoM <> 0 then
                    UnitPrice := "Cost Amount (Actual)" / QuantityUoM
                else
                    UnitPrice := 0;

                EntryType := CopyStr(UpperCase(Format("Entry Type")), 1, MaxStrLen(EntryType));
                if (CurrentDocNo = '') or (CurrentDocNo <> "Document No.") then begin
                    ItemLedgerEntry1 := ItemLedgerEntry;
                    ItemLedgerEntry1.SetRange("Document No.", "Document No.");
                    ItemLedgerEntry1.SetFilter("Entry Type", '<>%1', "Entry Type");
                    if not ItemLedgerEntry1.IsEmpty() then
                        Clear(EntryType);
                    CurrentDocNo := "Document No.";
                end;
            end;

            trigger OnPreDataItem()
            begin
                if ItemRegister."No." <> 0 then
                    SetRange("Entry No.", ItemRegister."From Entry No.", ItemRegister."To Entry No.");
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(PrintQtyInUoMField; PrintQtyInUoM)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print Quantity in:';
                    OptionCaption = 'Base Unit of Measure,Movement Unit of Measure';
                    ToolTip = 'Specifies if the base unit of measure or movement unit of measure has to be printed.';
                }
            }
        }
    }
    labels
    {
        PageLbl = 'Page';
        ReportCaptionLbl = 'Item Movement Document';
        IssueDateLbl = 'Issue date:';
        PostedByLbl = 'Posted by:';
        AmountLbl = 'Estimated Amount';
        UnitPriceLbl = 'Estimated Unit Price';
        TotalLbl = 'Total (Quantity, Amount):';
    }
    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        ItemRegister: Record "Item Register";
        DescriptionText: Text[100];
        UnitPrice: Decimal;
        QuantityUoM: Decimal;
        CurrentDocNo: Code[20];
        EntryType: Text[30];
        PrintQtyInUoM: Option "Base UoM","Movement UoM";
        UnitOfMeasureCode: Code[10];
        CompanyInfoTok: Label '%1 %2', Locked = true;
        RegistrationInfoTok: Label '%1: %2', Locked = true;
        PostingDateCaptionTok: Label '%1: ', Locked = true;
}
