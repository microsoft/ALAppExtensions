// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using System.Utilities;

report 18468 "Stock Register for Job Work"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './GSTSubcontracting/src/Reports/StockRegisterforJobWork.rdlc';
    Caption = 'Stock Register for Job Work';

    dataset
    {
        dataitem("Delivery Challan Line"; "Delivery Challan Line")
        {
            DataItemTableView = sorting("Document No.", "Document Line No.", "Production Order No.", "Production Order Line No.", "Prod. Order Comp. Line No.") Order(Ascending);
            RequestFilterfields = "Document No.", "Document Line No.", "Vendor Location", "Company Location";
            column(USERID; USERID)
            {
            }
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo())
            {
            }
            column(FORMAT_TODAY_0_4_; FORMAT(TODAY, 0, 4))
            {
            }
            column(DeliveryChallanLnFilters; DeliveryChallanLnFilters)
            {
            }
            column(Delivery_Challan_Line__Document_No__; "Document No.")
            {
            }
            column(Delivery_Challan_Line__Document_No___Control1500050; "Document No.")
            {
            }
            column(Delivery_Challan_Line_Quantity; Quantity)
            {
            }
            column(Delivery_Challan_Line__Unit_of_Measure_; "Unit of Measure")
            {
            }
            column(Delivery_Challan_Line__Deliver_Challan_No__; "Delivery Challan No.")
            {
            }
            column(Vendor__No___________Vendor_Name_________Vendor_Address________Vendor__Address_2_; Vendor."No." + '  ' + Vendor.Name + '  ' + Vendor.Address + '  ' + Vendor."Address 2")
            {
            }
            column(Delivery_Challan_Line__Process_Description_; "Process Description")
            {
            }
            column(Delivery_Challan_Line__Posting_Date_; FORMAT("Posting Date"))
            {
            }
            column(Delivery_Challan_Line__Last_Date_; FORMAT("Last Date"))
            {
            }
            column(Delivery_Challan_Line__Identification_Mark_; "Identification Mark")
            {
            }
            column(Delivery_Challan_Line__Remaining_Quantity_; "Remaining Quantity")
            {
            }
            column(Delivery_Challan_Line__Delivery_Challan_Line___Scrap___; "Scrap %")
            {
            }
            column(Item_Description; Item.Description)
            {
            }
            column(Delivery_Challan_Line_Line_No_; "Line No.")
            {
            }
            column(Delivery_Challan_Line_Document_Line_No_; "Document Line No.")
            {
            }
            column(Delivery_Challan_Line_Production_Order_No_; "Production Order No.")
            {
            }
            column(Delivery_Challan_Line_Production_Order_Line_No_; "Production Order Line No.")
            {
            }
            column(Delivery_Challan_Line_Item_No_; "Item No.")
            {
            }
            column(Delivery_Challan_Line_Vendor_Location; "Vendor Location")
            {
            }
            column(Stock_Register_for_Job_WorkCaption; Stock_Register_for_Job_WorkCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Delivery_Challan_NumberCaption; Delivery_Challan_NumberCaptionLbl)
            {
            }
            column(Date_of_DispatchCaption; Date_of_DispatchCaptionLbl)
            {
            }
            column(Description_of_goods_dispatchedCaption; Description_of_goods_dispatchedCaptionLbl)
            {
            }
            column(Due_Date_of_returnCaption; Due_Date_of_returnCaptionLbl)
            {
            }
            column(Unit_of_measurement__No_Kg_Litre_etc__Caption; Unit_of_measurement__No_Kg_Litre_etc__CaptionLbl)
            {
            }
            column(Quantity_dispatched_to_job_workerCaption; Quantity_dispatched_to_job_workerCaptionLbl)
            {
            }
            column(Identification_MarkCaption; Identification_MarkCaptionLbl)
            {
            }
            column(Name_and_address_of_job_workerCaption; Name_and_address_of_job_workerCaptionLbl)
            {
            }
            column(Job_Worker_Reg__No_Caption; Job_Worker_Reg__No_CaptionLbl)
            {
            }
            column(Nature_of_Processing_requiredCaption; Nature_of_Processing_requiredCaptionLbl)
            {
            }
            column(V2Caption; V2CaptionLbl)
            {
            }
            column(V3Caption; V3CaptionLbl)
            {
            }
            column(V4Caption; V4CaptionLbl)
            {
            }
            column(V5Caption; V5CaptionLbl)
            {
            }
            column(V6Caption; V6CaptionLbl)
            {
            }
            column(V7Caption; V7CaptionLbl)
            {
            }
            column(V8Caption; V8CaptionLbl)
            {
            }
            column(Quantity_received_from_job_workerCaption; Quantity_received_from_job_workerCaptionLbl)
            {
            }
            column(V9Caption; V9CaptionLbl)
            {
            }
            column(V10Caption; V10CaptionLbl)
            {
            }
            column(V11Caption; V11CaptionLbl)
            {
            }
            column(V12Caption; V12CaptionLbl)
            {
            }
            column(V1Caption; V1CaptionLbl)
            {
            }
            column(Job_worker_s_Delivery_challan_No__and_dateCaption; Job_worker_s_Delivery_challan_No__and_dateCaptionLbl)
            {
            }
            column(V13Caption; V13CaptionLbl)
            {
            }
            column(GRN_and_dateCaption; GRN_and_dateCaptionLbl)
            {
            }
            column(V14Caption; V14CaptionLbl)
            {
            }
            column(Wastage___Scrap__Caption; Wastage___Scrap__CaptionLbl)
            {
            }
            column(V15Caption; V15CaptionLbl)
            {
            }
            column(V16Caption; V16CaptionLbl)
            {
            }
            column(Balance_QuantityCaption; Balance_QuantityCaptionLbl)
            {
            }
            column(V17Caption; V17CaptionLbl)
            {
            }
            column(V18Caption; V18CaptionLbl)
            {
            }
            column(V19Caption; V19CaptionLbl)
            {
            }
            column(Subcontracting_Order_No_Caption; Subcontracting_Order_No_CaptionLbl)
            {
            }
            column(Subcontracting_Order_No_Caption_Control1500051; Subcontracting_Order_No_Caption_Control1500051Lbl)
            {
            }
            dataitem(ItemLedgerEntry; "Item Ledger Entry")
            {
                DataItemLink =
                  "External Document No." = field("Delivery Challan No."),
                  "Item No." = field("Item No."),
                  "Location Code" = field("Vendor Location"),
                  "Order No." = field("Production Order No."),
                  "Order Line No." = field("Production Order Line No.");

                DataItemTableView = sorting("Entry Type", "Location Code", "External Document No.", "Item No.", "Order Type", "Order No.", "Order Line No.")
                        Order(Ascending) where("Order Type" = const(Production));
                column(Item_Ledger_Entry_Entry_No_; "Entry No.")
                {
                }
                column(Item_Ledger_Entry_External_Document_No_; "External Document No.")
                {
                }
                column(Item_Ledger_Entry_Item_No_; "Item No.")
                {
                }
                column(Item_Ledger_Entry_Location_Code; "Location Code")
                {
                }
                column(Item_Ledger_Entry_Order_No_; "Order No.")
                {
                }
                column(Item_Ledger_Entry_Order_Line_No_; "Order Line No.")
                {
                }
                dataitem("Item Ledger Entry 2"; "Item Ledger Entry")
                {
                    DataItemTableView = sorting("Entry No.") Order(Ascending);

                    trigger OnPreDataItem()
                    begin
                        CurrReport.Break();
                    end;
                }
                dataitem(ILELoop; Integer)
                {
                    DataItemTableView = sorting(Number);
                    column(Vendor__No___________Vendor_Name_________Vendor_Address________Vendor__Address_2__Control1280107; Vendor."No." + '  ' + Vendor.Name + '  ' + Vendor.Address + '  ' + Vendor."Address 2")
                    {
                    }
                    column(Item_Ledger_Entry_2__Quantity; -"Item Ledger Entry 2".Quantity)
                    {
                    }
                    column(Item_Ledger_Entry_2___External_Document_No__; "Item Ledger Entry 2"."External Document No.")
                    {
                    }
                    column(Item_Ledger_Entry_2___Unit_of_Measure_Code_; "Item Ledger Entry 2"."Unit of Measure Code")
                    {
                    }
                    column(Item_Ledger_Entry_2___Entry_Type_; "Item Ledger Entry 2"."Entry Type")
                    {
                    }
                    column(Item_Ledger_Entry_2___Posting_Date_; FORMAT("Item Ledger Entry 2"."Posting Date"))
                    {
                    }
                    column(Item_Description_Control1280051; Item.Description)
                    {
                    }
                    column(ILELoop_Number; Number)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempItemEntry.FindFirst()
                        else
                            if TempItemEntry.Next() = 0 then
                                CurrReport.Break();

                        if TempItemEntry."Entry Type" = TempItemEntry."Entry Type"::"Negative Adjmt." then
                            Scrap := true
                        else
                            Scrap := false;

                        if TempItemEntry.Quantity > 0 then
                            CurrReport.Skip();

                        "Item Ledger Entry 2".COPY(TempItemEntry);
                        Item.Get("Item Ledger Entry 2"."Item No.");
                    end;

                    trigger OnPreDataItem()
                    begin
                        if TempItemEntry.Count > 0 then
                            SetRange(Number, 1, TempItemEntry.Count)
                        else
                            SetRange(Number, 0);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    FindAppliedEntry(ItemLedgerEntry);
                end;

                trigger OnPreDataItem()
                begin
                    TempItemEntry.DeleteAll();
                end;
            }
            dataitem("Purch. Rcpt. Line"; "Purch. Rcpt. Line")
            {
                DataItemLink = "Prod. Order No." = field("Production Order No."), "Prod. Order Line No." = field("Production Order Line No.");
                DataItemTableView = sorting("Prod. Order No.", "Prod. Order Line No.") Order(Ascending);
                column(Vendor__No___________Vendor_Name_________Vendor_Address________Vendor__Address_2__Control1280014; Vendor."No." + '  ' + Vendor.Name + '  ' + Vendor.Address + '  ' + Vendor."Address 2")
                {
                }
                column(Purch__Rcpt__Line__Document_No__; "Document No.")
                {
                }
                column(Purch__Rcpt__Line_Quantity; Quantity)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Description2; Description)
                {
                }
                column(Purch__Rcpt__Line__Unit_of_Measure_Code_; "Unit of Measure Code")
                {
                }
                column(PurchRcptHeader__Posting_Date_; FORMAT(PurchRcptHeader."Posting Date"))
                {
                }
                column(Purch__Rcpt__Line_Line_No_; "Line No.")
                {
                }
                column(Purch__Rcpt__Line_Prod__Order_No_; "Prod. Order No.")
                {
                }
                column(Purch__Rcpt__Line_Prod__Order_Line_No_; "Prod. Order Line No.")
                {
                }
                column(OutputCaption; OutputCaptionLbl)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    PurchRcptHeader.SetFilter("No.", "Purch. Rcpt. Line"."Document No.");
                    PurchRcptHeader.FindFirst();

                    if Item.Get("Purch. Rcpt. Line"."No.") then
                        Description2 := Item.Description
                    else
                        Description2 := "Purch. Rcpt. Line".Description;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if Quantity = 0 then
                    CurrReport.Skip();

                Vendor.Get("Delivery Challan Line"."Vendor No.");
                Item.Get("Delivery Challan Line"."Item No.");
                Vendor1.Get("Delivery Challan Line"."Vendor No.");
            end;

            trigger OnPreDataItem()
            begin
                DeliveryChallanLnFilters := GetFilters;
            end;
        }
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    var
        TempItemEntry: Record "Item Ledger Entry" temporary;
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        Item: Record Item;
        Vendor1: Record Vendor;
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
        Scrap: Boolean;
        Description2: Text[30];
        DeliveryChallanLnFilters: Text[250];
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Stock_Register_for_Job_WorkCaptionLbl: Label 'Stock Register for Job Work';
        Delivery_Challan_NumberCaptionLbl: Label 'Delivery Challan Number';
        Date_of_DispatchCaptionLbl: Label 'Date of Dispatch';
        Description_of_goods_dispatchedCaptionLbl: Label 'Description of goods dispatched';
        Due_Date_of_returnCaptionLbl: Label 'Due Date of return';
        Unit_of_measurement__No_Kg_Litre_etc__CaptionLbl: Label 'Unit of measurement (No/Kg/Litre etc.)';
        Quantity_dispatched_to_job_workerCaptionLbl: Label 'Quantity dispatched to job worker';
        Identification_MarkCaptionLbl: Label 'Identification Mark';
        Name_and_address_of_job_workerCaptionLbl: Label 'Name and address of job worker';
        Job_Worker_Reg__No_CaptionLbl: Label 'Job Worker Reg. No.';
        Nature_of_Processing_requiredCaptionLbl: Label 'Nature of Processing required';
        Quantity_received_from_job_workerCaptionLbl: Label 'Quantity received from job worker';
        V1CaptionLbl: Label '1';
        V2CaptionLbl: Label '2';
        V3CaptionLbl: Label '3';
        V4CaptionLbl: Label '4';
        V5CaptionLbl: Label '5';
        V6CaptionLbl: Label '6';
        V7CaptionLbl: Label '7';
        V8CaptionLbl: Label '8';
        V9CaptionLbl: Label '9';
        V10CaptionLbl: Label '10';
        V11CaptionLbl: Label '11';
        V12CaptionLbl: Label '12';
        V13CaptionLbl: Label '13';
        V14CaptionLbl: Label '14';
        V15CaptionLbl: Label '15';
        V16CaptionLbl: Label '16';
        V17CaptionLbl: Label '17';
        V18CaptionLbl: Label '18';
        V19CaptionLbl: Label '19';

        Job_worker_s_Delivery_challan_No__and_dateCaptionLbl: Label 'Job worker''s Delivery challan No. and date';
        GRN_and_dateCaptionLbl: Label 'GRN and date';
        Wastage___Scrap__CaptionLbl: Label 'Wastage / Scrap %';
        Balance_QuantityCaptionLbl: Label 'Balance Quantity';
        Subcontracting_Order_No_CaptionLbl: Label 'Subcontracting Order No.';
        Subcontracting_Order_No_Caption_Control1500051Lbl: Label 'Subcontracting Order No.';
        OutputCaptionLbl: Label 'Output';

    local procedure FindAppliedEntry(ItemLedgEntry: Record "Item Ledger Entry")
    var
        ItemApplnEntry: Record "Item Application Entry";
    begin
        if ItemLedgEntry.Positive then begin
            ItemApplnEntry.Reset();
            ItemApplnEntry.SetCurrentKey("Inbound Item Entry No.", "Outbound Item Entry No.", "Cost Application");
            ItemApplnEntry.SetRange("Inbound Item Entry No.", ItemLedgEntry."Entry No.");
            ItemApplnEntry.SetRange("Cost Application", true);
            ItemApplnEntry.SetFilter("Outbound Item Entry No.", '<>%1', 0);
            if ItemApplnEntry.Findset() then
                Repeat
                    if (ItemLedgEntry."Entry Type" <> ItemLedgEntry."Entry Type"::Transfer) or
                       (ItemApplnEntry."Item Ledger Entry No." <> ItemLedgEntry."Entry No.")
                    then
                        InsertTempEntry(ItemApplnEntry."Item Ledger Entry No.", ItemApplnEntry.Quantity);
                Until ItemApplnEntry.Next() = 0;

            ItemApplnEntry.Reset();
            ItemApplnEntry.SetCurrentKey("Transferred-from Entry No.", "Cost Application");
            ItemApplnEntry.SetRange("Transferred-from Entry No.", ItemLedgEntry."Entry No.");
            ItemApplnEntry.SetRange("Cost Application", true);
            if ItemApplnEntry.Findset() then
                Repeat
                    InsertTempEntry(ItemApplnEntry."Item Ledger Entry No.", ItemApplnEntry.Quantity);
                Until ItemApplnEntry.Next() = 0;

        end else begin
            ItemApplnEntry.Reset();
            ItemApplnEntry.SetCurrentKey("Item Ledger Entry No.", "Outbound Item Entry No.", "Cost Application");
            ItemApplnEntry.SetRange("Item Ledger Entry No.", ItemLedgEntry."Entry No.");
            ItemApplnEntry.SetRange("Outbound Item Entry No.", ItemLedgEntry."Entry No.");
            ItemApplnEntry.SetRange("Cost Application", true);
            if ItemApplnEntry.Findset() then
                Repeat
                    InsertTempEntry(ItemApplnEntry."Inbound Item Entry No.", -ItemApplnEntry.Quantity);
                Until ItemApplnEntry.Next() = 0;
        end;
    end;

    local procedure InsertTempEntry(EntryNo: Integer; AppliedQty: Decimal)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        if not TempItemEntry.Get(EntryNo) then begin
            ItemLedgEntry.Get(EntryNo);
            TempItemEntry.Init();
            TempItemEntry := ItemLedgEntry;
            TempItemEntry.Quantity := AppliedQty;
            TempItemEntry.Insert();
        end else begin
            TempItemEntry.Quantity := TempItemEntry.Quantity + AppliedQty;
            TempItemEntry.MODifY();
        end;
    end;
}
