// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Reports;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;

report 6219 "Sust. Track Item Of Concern"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Track Item of Concern';
    DefaultLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;
    DataAccessIntent = ReadOnly;
    RDLCLayout = 'src/Reports/TrackItemOfConcern.rdlc';

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = where("Item of Concern" = const(true));
            RequestFilterFields = "No.";
            dataitem(ItemEmissionBuffer; "Sust. Item Emission Buffer")
            {
                DataItemLink = "Item No." = field("No.");
                UseTemporary = true;
                DataItemTableView = sorting("Entry No.");
                column(CompanyName; CompanyProperty.DisplayName())
                {
                }
                column(Direction; Direction)
                {
                }
                column(Date; Date)
                {
                }
                column(ShowDetails; ShowDetails)
                {
                }
                column(Transaction_Type; "Transaction Type")
                {
                }
                column(Document_No; "Document No.")
                {
                }
                column(Source_No_; "Source No.")
                {
                }
                column(Item_No_; "Item No.")
                {
                }
                column(Item_Name; "Item Name")
                {
                }
                column(Quantity; Quantity)
                {
                }
                column(CO2e_Emission; "CO2e Emission")
                {
                }
                column(Emission_CO2; "Emission CO2")
                {
                }
                column(Emission_CH4; "Emission CH4")
                {
                }
                column(Emission_N2O; "Emission N2O")
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                InsertItemEmissionBuffer();
            end;
        }
    }
    requestpage
    {
        AboutText = 'This report provides information on the cumulative greenhouse gas (GHG) emissions across the chosen Sustainability Item.';
        AboutTitle = 'Total Emissions';
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(Show_Details; ShowDetails)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Details';
                        ToolTip = 'Specifies if the report includes all sustainability entries. By default, the report does not show such entries.';
                    }
                }
            }
        }
    }
    labels
    {
        TrackItemOfConcern = 'Item of Concern';
        PageCaption = 'Page';
        DirectionCaption = 'Direction';
        ItemNoCaption = ' Item No.';
        DateCaption = 'Posting Date';
        TransactionTypeCaption = 'Transaction Type';
        DocumentNoCaption = 'Document No.';
        SourceNoCaption = 'Source No.';
        QuantityCaption = 'Quantity';
        CO2eEmissionCaption = 'CO2e';
        EmissionCO2Caption = 'CO2';
        EmissionCH4Caption = 'CH4';
        EmissionN2OCaption = 'N2O';
        ItemNameCaption = 'Item Name';
    }

    trigger OnPreReport()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.GetReportingParameters(ReportingUOMCode, UseReportingUOMFactor, ReportingUOMFactor, RoundingDirection, RoundingPrecision);
    end;

    var
        ReportingUOMCode: Code[10];
        RoundingDirection: Text;
        ShowDetails, UseReportingUOMFactor : Boolean;
        ReportingUOMFactor, RoundingPrecision : Decimal;

    local procedure InsertItemEmissionBuffer()
    var
    begin
        InsertItemEmissionBufferFromSustValueEntry();
        InsertItemEmissionBufferFromPurchaseInvLine();
        InsertItemEmissionBufferFromPurchaseCrMemoLine();
        InsertItemEmissionBufferFromReturnShipmentLine();
    end;

    local procedure InsertItemEmissionBufferFromSustValueEntry()
    var
        SustainabilityValueEntry: Record "Sustainability Value Entry";
    begin
        SustainabilityValueEntry.SetRange(Type, SustainabilityValueEntry.Type::Item);
        SustainabilityValueEntry.SetRange("No.", Item."No.");
        SustainabilityValueEntry.SetRange("Expected Emission", false);
        SustainabilityValueEntry.SetFilter("Item Ledger Entry Type", '<>%1&<>%2', SustainabilityValueEntry."Item Ledger Entry Type"::Purchase, SustainabilityValueEntry."Item Ledger Entry Type"::Transfer);
        if SustainabilityValueEntry.FindSet() then
            repeat
                InsertItemEmissionBuffer(SustainabilityValueEntry);
            until SustainabilityValueEntry.Next() = 0;
    end;

    local procedure InsertItemEmissionBufferFromPurchaseInvLine()
    var
        PurchaseInvLine: Record "Purch. Inv. Line";
    begin
        PurchaseInvLine.SetRange(Type, PurchaseInvLine.Type::Item);
        PurchaseInvLine.SetRange("No.", Item."No.");
        PurchaseInvLine.SetFilter("Sust. Account No.", '<>%1', '');
        PurchaseInvLine.SetFilter(Quantity, '<>%1', 0);
        if PurchaseInvLine.FindSet() then
            repeat
                InsertItemEmissionBuffer(PurchaseInvLine);
            until PurchaseInvLine.Next() = 0;
    end;

    local procedure InsertItemEmissionBufferFromPurchaseCrMemoLine()
    var
        PurchaseCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        PurchaseCrMemoLine.SetRange(Type, PurchaseCrMemoLine.Type::Item);
        PurchaseCrMemoLine.SetRange("No.", Item."No.");
        PurchaseCrMemoLine.SetFilter("Sust. Account No.", '<>%1', '');
        PurchaseCrMemoLine.SetFilter(Quantity, '<>%1', 0);
        if PurchaseCrMemoLine.FindSet() then
            repeat
                InsertItemEmissionBuffer(PurchaseCrMemoLine);
            until PurchaseCrMemoLine.Next() = 0;
    end;

    local procedure InsertItemEmissionBufferFromReturnShipmentLine()
    var
        ReturnShipmentLine: Record "Return Shipment Line";
    begin
        ReturnShipmentLine.SetRange(Type, ReturnShipmentLine.Type::Item);
        ReturnShipmentLine.SetRange("No.", Item."No.");
        ReturnShipmentLine.SetFilter("Sust. Account No.", '<>%1', '');
        ReturnShipmentLine.SetFilter(Quantity, '<>%1', 0);
        if ReturnShipmentLine.FindSet() then
            repeat
                InsertItemEmissionBuffer(ReturnShipmentLine);
            until ReturnShipmentLine.Next() = 0;
    end;

    local procedure InsertItemEmissionBuffer(SustainabilityValueEntry: Record "Sustainability Value Entry")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemEmissionBuffer.Init();
        ItemEmissionBuffer."Entry No." := FindLastEntryNo() + 1;
        ItemEmissionBuffer.Direction := GetDirection(SustainabilityValueEntry."Item Ledger Entry Type");
        ItemEmissionBuffer.Date := SustainabilityValueEntry."Posting Date";
        ItemEmissionBuffer."Transaction Type" := SustainabilityValueEntry."Item Ledger Entry Type";
        ItemEmissionBuffer."Document No." := SustainabilityValueEntry."Document No.";
        ItemEmissionBuffer."Source Type" := ItemEmissionBuffer."Source Type"::" ";
        ItemEmissionBuffer."Source No." := '';
        if (SustainabilityValueEntry."Item Ledger Entry No." <> 0) then begin
            ItemLedgerEntry.Get(SustainabilityValueEntry."Item Ledger Entry No.");

            ItemEmissionBuffer."Source Type" := ItemLedgerEntry."Source Type";
            if ItemLedgerEntry."Source Type" in [ItemLedgerEntry."Source Type"::Customer, ItemLedgerEntry."Source Type"::Vendor] then
                ItemEmissionBuffer."Source No." := ItemLedgerEntry."Source No."
        end;

        ItemEmissionBuffer."Item No." := SustainabilityValueEntry."Item No.";
        ItemEmissionBuffer."Item Name" := Item.Description;
        ItemEmissionBuffer.Quantity := SustainabilityValueEntry."Item Ledger Entry Quantity";
        ItemEmissionBuffer."CO2e Emission" := SustainabilityValueEntry."CO2e Amount (Actual)";
        ItemEmissionBuffer."Emission CO2" := 0;
        ItemEmissionBuffer."Emission CH4" := 0;
        ItemEmissionBuffer."Emission N2O" := 0;
        if UseReportingUOMFactor then
            UpdateEmissionsByReportingUOMFactor();

        ItemEmissionBuffer.Insert();
    end;

    local procedure InsertItemEmissionBuffer(PurchaseInvLine: Record "Purch. Inv. Line")
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        ItemEmissionBuffer.Init();
        ItemEmissionBuffer."Entry No." := FindLastEntryNo() + 1;
        ItemEmissionBuffer.Direction := ItemEmissionBuffer.Direction::Inbound;
        ItemEmissionBuffer.Date := PurchaseInvLine."Posting Date";
        ItemEmissionBuffer."Transaction Type" := ItemEmissionBuffer."Transaction Type"::Purchase;
        ItemEmissionBuffer."Document No." := PurchaseInvLine."Document No.";
        ItemEmissionBuffer."Source Type" := ItemEmissionBuffer."Source Type"::Vendor;
        ItemEmissionBuffer."Source No." := PurchaseInvLine."Buy-from Vendor No.";
        ItemEmissionBuffer."Item No." := PurchaseInvLine."No.";
        ItemEmissionBuffer."Item Name" := Item.Description;
        ItemEmissionBuffer."CO2e Emission" := 0;
        ItemEmissionBuffer."Emission CO2" := 0;
        ItemEmissionBuffer."Emission CH4" := 0;
        ItemEmissionBuffer."Emission N2O" := 0;
        PurchaseInvLine.GetItemLedgEntries(TempItemLedgEntry, true);
        TempItemLedgEntry.CalcSums(Quantity);
        ItemEmissionBuffer.Quantity := TempItemLedgEntry.Quantity;

        GHGCredit := IsGHGCreditLine(PurchaseInvLine.Type, PurchaseInvLine."No.");
        Sign := GetPostingSign("Purchase Document Type"::Invoice, GHGCredit);

        FilterSustainabilityLedgerEntry(
            SustainabilityLedgerEntry, PurchaseInvLine."Document No.", PurchaseInvLine."Posting Date", PurchaseInvLine."Sust. Account No.",
            Sign * PurchaseInvLine."Emission CO2", Sign * PurchaseInvLine."Emission CH4", Sign * PurchaseInvLine."Emission N2O");
        if SustainabilityLedgerEntry.FindFirst() then begin
            ItemEmissionBuffer."Emission CO2" := SustainabilityLedgerEntry."Emission CO2";
            ItemEmissionBuffer."Emission CH4" := SustainabilityLedgerEntry."Emission CH4";
            ItemEmissionBuffer."Emission N2O" := SustainabilityLedgerEntry."Emission N2O";
            ItemEmissionBuffer."CO2e Emission" := SustainabilityLedgerEntry."CO2e Emission";
        end;

        if UseReportingUOMFactor then
            UpdateEmissionsByReportingUOMFactor();

        ItemEmissionBuffer.Insert();
    end;

    local procedure InsertItemEmissionBuffer(ReturnShipmentLine: Record "Return Shipment Line")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        ItemEmissionBuffer.Init();
        ItemEmissionBuffer."Entry No." := FindLastEntryNo() + 1;
        ItemEmissionBuffer.Direction := ItemEmissionBuffer.Direction::Inbound;
        ItemEmissionBuffer.Date := ReturnShipmentLine."Posting Date";
        ItemEmissionBuffer."Transaction Type" := ItemEmissionBuffer."Transaction Type"::Purchase;
        ItemEmissionBuffer."Document No." := ReturnShipmentLine."Document No.";
        ItemEmissionBuffer."Source Type" := ItemEmissionBuffer."Source Type"::Vendor;
        ItemEmissionBuffer."Source No." := ReturnShipmentLine."Buy-from Vendor No.";
        ItemEmissionBuffer."Item No." := ReturnShipmentLine."No.";
        ItemEmissionBuffer."Item Name" := Item.Description;
        ItemEmissionBuffer."CO2e Emission" := 0;
        ItemEmissionBuffer."Emission CO2" := 0;
        ItemEmissionBuffer."Emission CH4" := 0;
        ItemEmissionBuffer."Emission N2O" := 0;
        ReturnShipmentLine.FilterPstdDocLnItemLedgEntries(ItemLedgEntry);
        ItemLedgEntry.CalcSums(Quantity);
        ItemEmissionBuffer.Quantity := ItemLedgEntry.Quantity;

        GHGCredit := IsGHGCreditLine(ReturnShipmentLine.Type, ReturnShipmentLine."No.");
        Sign := GetPostingSign("Purchase Document Type"::"Credit Memo", GHGCredit);

        FilterSustainabilityLedgerEntry(
            SustainabilityLedgerEntry, ReturnShipmentLine."Document No.", ReturnShipmentLine."Posting Date", ReturnShipmentLine."Sust. Account No.",
            Sign * ReturnShipmentLine."Emission CO2", Sign * ReturnShipmentLine."Emission CH4", Sign * ReturnShipmentLine."Emission N2O");
        if SustainabilityLedgerEntry.FindFirst() then begin
            ItemEmissionBuffer."Emission CO2" := SustainabilityLedgerEntry."Emission CO2";
            ItemEmissionBuffer."Emission CH4" := SustainabilityLedgerEntry."Emission CH4";
            ItemEmissionBuffer."Emission N2O" := SustainabilityLedgerEntry."Emission N2O";
            ItemEmissionBuffer."CO2e Emission" := SustainabilityLedgerEntry."CO2e Emission";
        end;

        if UseReportingUOMFactor then
            UpdateEmissionsByReportingUOMFactor();

        ItemEmissionBuffer.Insert();
    end;

    local procedure InsertItemEmissionBuffer(PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        ItemEmissionBuffer.Init();
        ItemEmissionBuffer."Entry No." := FindLastEntryNo() + 1;
        ItemEmissionBuffer.Direction := ItemEmissionBuffer.Direction::Inbound;
        ItemEmissionBuffer.Date := PurchCrMemoLine."Posting Date";
        ItemEmissionBuffer."Transaction Type" := ItemEmissionBuffer."Transaction Type"::Purchase;
        ItemEmissionBuffer."Document No." := PurchCrMemoLine."Document No.";
        ItemEmissionBuffer."Source Type" := ItemEmissionBuffer."Source Type"::Vendor;
        ItemEmissionBuffer."Source No." := PurchCrMemoLine."Buy-from Vendor No.";
        ItemEmissionBuffer."Item No." := PurchCrMemoLine."No.";
        ItemEmissionBuffer."Item Name" := Item.Description;
        ItemEmissionBuffer."CO2e Emission" := 0;
        ItemEmissionBuffer."Emission CO2" := 0;
        ItemEmissionBuffer."Emission CH4" := 0;
        ItemEmissionBuffer."Emission N2O" := 0;

        PurchCrMemoLine.GetItemLedgEntries(TempItemLedgEntry, true);
        TempItemLedgEntry.CalcSums(Quantity);
        ItemEmissionBuffer.Quantity := TempItemLedgEntry.Quantity;

        GHGCredit := IsGHGCreditLine(PurchCrMemoLine.Type, PurchCrMemoLine."No.");
        Sign := GetPostingSign("Purchase Document Type"::"Return Order", GHGCredit);

        FilterSustainabilityLedgerEntry(
            SustainabilityLedgerEntry, PurchCrMemoLine."Document No.", PurchCrMemoLine."Posting Date", PurchCrMemoLine."Sust. Account No.",
            Sign * PurchCrMemoLine."Emission CO2", Sign * PurchCrMemoLine."Emission CH4", Sign * PurchCrMemoLine."Emission N2O");
        if SustainabilityLedgerEntry.FindFirst() then begin
            ItemEmissionBuffer."Emission CO2" := SustainabilityLedgerEntry."Emission CO2";
            ItemEmissionBuffer."Emission CH4" := SustainabilityLedgerEntry."Emission CH4";
            ItemEmissionBuffer."Emission N2O" := SustainabilityLedgerEntry."Emission N2O";
            ItemEmissionBuffer."CO2e Emission" := SustainabilityLedgerEntry."CO2e Emission";
        end;

        if UseReportingUOMFactor then
            UpdateEmissionsByReportingUOMFactor();

        ItemEmissionBuffer.Insert();
    end;

    local procedure GetDirection(EntryType: Enum "Item Ledger Entry Type") Direction: Option Inbound,Outbound
    begin
        case EntryType of
            EntryType::Purchase, EntryType::Output, EntryType::"Assembly Output":
                exit(Direction::Inbound);
            EntryType::Sale, EntryType::Consumption, EntryType::"Negative Adjmt.", EntryType::"Assembly Consumption":
                exit(Direction::Outbound);
            else
                exit(Direction::Outbound);
        end;
    end;

    local procedure FilterSustainabilityLedgerEntry(var SustainabilityLedgerEntry: Record "Sustainability Ledger Entry"; DocumentNo: Code[20]; PostingDate: Date; AccountNo: Code[20]; EmissionCO2: Decimal; EmissionCH4: Decimal; EmissionN2O: Decimal): Decimal
    begin
        SustainabilityLedgerEntry.Reset();
        SustainabilityLedgerEntry.SetRange("Document No.", DocumentNo);
        SustainabilityLedgerEntry.SetRange("Posting Date", PostingDate);
        SustainabilityLedgerEntry.SetRange("Account No.", AccountNo);
        SustainabilityLedgerEntry.SetRange("Emission CO2", EmissionCO2);
        SustainabilityLedgerEntry.SetRange("Emission CH4", EmissionCH4);
        SustainabilityLedgerEntry.SetRange("Emission N2O", EmissionN2O);
    end;

    local procedure UpdateEmissionsByReportingUOMFactor()
    begin
        ItemEmissionBuffer."CO2e Emission" := Round(ItemEmissionBuffer."CO2e Emission" * ReportingUOMFactor, RoundingPrecision, RoundingDirection);
        ItemEmissionBuffer."Emission CO2" := Round(ItemEmissionBuffer."Emission CO2" * ReportingUOMFactor, RoundingPrecision, RoundingDirection);
        ItemEmissionBuffer."Emission CH4" := Round(ItemEmissionBuffer."Emission CH4" * ReportingUOMFactor, RoundingPrecision, RoundingDirection);
        ItemEmissionBuffer."Emission N2O" := Round(ItemEmissionBuffer."Emission N2O" * ReportingUOMFactor, RoundingPrecision, RoundingDirection);
    end;

    internal procedure GetPostingSign(PurchaseDocumentType: Enum "Purchase Document Type"; GHGCredit: Boolean): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        case PurchaseDocumentType of
            PurchaseDocumentType::"Credit Memo", PurchaseDocumentType::"Return Order":
                if not GHGCredit then
                    Sign := -1;
            else
                if GHGCredit then
                    Sign := -1;
        end;

        exit(Sign);
    end;

    internal procedure IsGHGCreditLine(PurchaseLineType: Enum "Purchase Line Type"; ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if PurchaseLineType <> PurchaseLineType::Item then
            exit(false);

        if ItemNo = '' then
            exit(false);

        Item.Get(ItemNo);

        exit(Item."GHG Credit");
    end;

    local procedure FindLastEntryNo(): Integer
    begin
        ItemEmissionBuffer.Reset();
        if ItemEmissionBuffer.FindLast() then
            exit(ItemEmissionBuffer."Entry No.");
    end;
}