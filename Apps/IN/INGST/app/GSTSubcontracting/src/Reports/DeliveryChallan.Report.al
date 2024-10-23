// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;

report 18467 "Delivery Challan"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './GSTSubcontracting/src/Reports/DeliveryChallan.rdlc';
    Caption = 'Delivery Challan';

    dataset
    {
        dataitem(DeliveryChallanHeader; "Delivery Challan Header")
        {
            DataItemTableView = sorting("No.") order(Ascending);
            RequestFilterFields = "No.", "Challan Date";
            column(Format_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(UserID; UserID)
            {
            }
            column(Delivery_Challan_Header__No__; "No.")
            {
            }
            column(Delivery_Challan_Header__Challan_Date_; Format("Challan Date"))
            {
            }
            column(Delivery_Challan_Header__Vendor_No__; "Vendor No.")
            {
            }
            column(Delivery_Challan_Header__Commissioner_s_Permission_No__; "Commissioner's Permission No.")
            {
            }
            column(VendAddr_4_; VendAddr[4])
            {
            }
            column(VendAddr_3_; VendAddr[3])
            {
            }
            column(VendAddr_2_; VendAddr[2])
            {
            }
            column(VendAddr_1_; VendAddr[1])
            {
            }
            column(VendAddr_5_; VendAddr[5])
            {
            }
            column(VendAddr_6_; VendAddr[6])
            {
            }
            column(VendAddr_7_; VendAddr[7])
            {
            }
            column(VendAddr_8_; VendAddr[8])
            {
            }
            column(Delivery_Challan_Header__No___Control1500021; "No.")
            {
            }
            column(Delivery_Challan_Header__Challan_Date__Control1500023; Format("Challan Date"))
            {
            }
            column(Delivery_Challan_Header__Vendor_No___Control1500025; "Vendor No.")
            {
            }
            column(Delivery_Challan_Header__Commissioner_s_Permission_No___Control1500028; "Commissioner's Permission No.")
            {
            }
            column(Vendor_GSTRegistration_No_; Vendor."GST Registration No.")
            {
            }
            column(VendAddr_4__Control1500032; VendAddr[4])
            {
            }
            column(VendAddr_3__Control1500033; VendAddr[3])
            {
            }
            column(VendAddr_2__Control1500034; VendAddr[2])
            {
            }
            column(VendAddr_1__Control1500035; VendAddr[1])
            {
            }
            column(VendAddr_5__Control1500036; VendAddr[5])
            {
            }
            column(VendAddr_6__Control1500037; VendAddr[6])
            {
            }
            column(VendAddr_7__Control1500038; VendAddr[7])
            {
            }
            column(VendAddr_8__Control1500039; VendAddr[8])
            {
            }
            column(DeliveryChallanFilters; DeliveryChallanFilters)
            {
            }
            column(Delivery_Challan_Header__Item_No__; "Item No.")
            {
            }
            column(Delivery_Challan_Header__Quantity_for_rework_; "Quantity for rework")
            {
            }
            column(SumAmount; SumAmount)
            {
            }
            column(Delivery_ChallanCaption; Delivery_ChallanCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Delivery_Challan_Header__No__Caption; FieldCaption("No."))
            {
            }
            column(Delivery_Challan_Header__Challan_Date_Caption; Delivery_Challan_Header__Challan_Date_CaptionLbl)
            {
            }
            column(Delivery_Challan_Header__Vendor_No__Caption; FieldCaption("Vendor No."))
            {
            }
            column(Vendor_NameCaption; Vendor_NameCaptionLbl)
            {
            }
            column(Delivery_Challan_Header__Commissioner_s_Permission_No__Caption; FieldCaption("Commissioner's Permission No."))
            {
            }
            column(Excise_Registration_No_Caption; Excise_Registration_No_CaptionLbl)
            {
            }
            column(Cost_AmountCaption; Cost_AmountCaptionLbl)
            {
            }
            column(Parent_Item_No_Caption; Parent_Item_No_CaptionLbl)
            {
            }
            column(Process_DescriptionCaption; Process_DescriptionCaptionLbl)
            {
            }
            column(Item_No_Caption; Item_No_CaptionLbl)
            {
            }
            column(DescriptionCaption; DescriptionCaptionLbl)
            {
            }
            column(Unit_of_MeasureCaption; Unit_of_MeasureCaptionLbl)
            {
            }
            column(QuantityCaption; QuantityCaptionLbl)
            {
            }
            column(Components_in_Rework_Qty_Caption; Components_in_Rework_Qty_CaptionLbl)
            {
            }
            column(Excise_AmountCaption; Excise_AmountCaptionLbl)
            {
            }
            column(Delivery_Challan_Header__No___Control1500021Caption; FieldCaption("No."))
            {
            }
            column(Delivery_Challan_Header__Challan_Date__Control1500023Caption; Delivery_Challan_Header__Challan_Date__Control1500023CaptionLbl)
            {
            }
            column(Delivery_Challan_Header__Vendor_No___Control1500025Caption; FieldCaption("Vendor No."))
            {
            }
            column(Vendor_NameCaption_Control1500027; Vendor_NameCaption_Control1500027Lbl)
            {
            }
            column(Delivery_Challan_Header__Commissioner_s_Permission_No___Control1500028Caption; FieldCaption("Commissioner's Permission No."))
            {
            }
            column(Excise_Registration_No_Caption_Control1500031; Excise_Registration_No_Caption_Control1500031Lbl)
            {
            }
            column(Delivery_Challan_Header__Item_No__Caption; FieldCaption("Item No."))
            {
            }
            column(Delivery_Challan_Header__Quantity_for_rework_Caption; FieldCaption("Quantity for rework"))
            {
            }
            column(Rework_DetailsCaption; Rework_DetailsCaptionLbl)
            {
            }
            column(Components_DetailsCaption; Components_DetailsCaptionLbl)
            {
            }
            column(Signature_of_Manufacturer___Authorized_SignatoryCaption; Signature_of_Manufacturer___Authorized_SignatoryCaptionLbl)
            {
            }
            column(GST_Registration_No_CaptionLbl; GST_Registration_No_CaptionLbl)
            {
            }
            column(Vendor_GST_Registration_No_CaptionLbl; Vendor_GST_Registration_No_CaptionLbl)
            {
            }
            column(Place__Caption; Place__CaptionLbl)
            {
            }
            column(Date__Caption; Date__CaptionLbl)
            {
            }
            column(Delivery_Challan_TotalCaption; Delivery_Challan_TotalCaptionLbl)
            {
            }
            dataitem(DeliveryChallanLine; "Delivery Challan Line")
            {
                DataItemLink = "Delivery Challan No." = field("No.");
                DataItemTableView = sorting("Document No.", "Document Line No.", "Production Order No.", "Production Order Line No.", "Prod. Order Comp. Line No.") order(Ascending);

                column(Delivery_Challan_Line_Deliver_Challan_No_; "Delivery Challan No.")
                {
                }
                column(Delivery_Challan_Line_Line_No_; "Line No.")
                {
                }
                column(Delivery_Challan_Line__Document_No__; "Document No.")
                {
                }
                column(Delivery_Challan_Line__Production_Order_No__; "Production Order No.")
                {
                }
                column(Delivery_Challan_Line__Process_Description_; "Process Description")
                {
                }
                column(Delivery_Challan_Line_Description; Description)
                {
                }
                column(Delivery_Challan_Line__Parent_Item_No__; "Parent Item No.")
                {
                }
                column(Delivery_Challan_Line__Item_No__; "Item No.")
                {
                }
                column(Delivery_Challan_Line__Unit_of_Measure_; "Unit of Measure")
                {
                }
                column(Delivery_Challan_Line_Quantity; Quantity)
                {
                }
                column(Delivery_Challan_Line_Quantity_Control1500013; Quantity)
                {
                }

                column(Delivery_Challan_Line__Components_in_Rework_Qty__; "Components in Rework Qty.")
                {
                }
                column(SumAmount_Control1280038; SumAmount)
                {
                }
                column(HSNSACCode_DeliveryChallanLine; "HSN/SAC Code")
                {
                }
                column(Delivery_Challan_Line__Parent_Item_No__Caption; FieldCaption("Parent Item No."))
                {
                }
                column(Delivery_Challan_Line__Process_Description_Caption; FieldCaption("Process Description"))
                {
                }
                column(Delivery_Challan_Line_DescriptionCaption; FieldCaption(Description))
                {
                }
                column(Delivery_Challan_Line__Unit_of_Measure_Caption; FieldCaption("Unit of Measure"))
                {
                }
                column(Delivery_Challan_Line_QuantityCaption; FieldCaption(Quantity))
                {
                }
                column(Delivery_Challan_Line__Components_in_Rework_Qty__Caption; FieldCaption("Components in Rework Qty."))
                {
                }
                column(Cost_AmountCaption_Control1280039; Cost_AmountCaption_Control1280039Lbl)
                {
                }
                column(Sub_Order_No_Caption; Sub_Order_No_CaptionLbl)
                {
                }
                column(Delivery_Challan_Line__Production_Order_No__Caption; FieldCaption("Production Order No."))
                {
                }
                column(TotalCaption; TotalCaptionLbl)
                {
                }
                column(HSNSAC_Code_Lbl; HSNSAC_Code_Lbl)
                {
                }
                column(Delivery_Challan_Line__Item_No__Caption; FieldCaption("Item No."))
                {
                }
                column(Delivery_Challan_Line__Components_in_Rework_Qty___Control1500011; "Components in Rework Qty.")
                {
                }
                column(SumAmount_Control1500020; SumAmount)
                {
                }
                column(GSTComponentCode1; GSTComponentCode[1] + ' Amount')
                {
                }
                column(GSTComponentCode2; GSTComponentCode[2] + ' Amount')
                {
                }
                column(GSTComponentCode3; GSTComponentCode[3] + ' Amount')
                {
                }
                column(GSTComponentCode4; GSTComponentCode[4] + 'Amount')
                {
                }
                column(GSTCompAmount1; ABS(GSTCompAmount[1]))
                {
                }
                column(GSTCompAmount2; ABS(GSTCompAmount[2]))
                {
                }
                column(GSTCompAmount3; ABS(GSTCompAmount[3]))
                {
                }
                column(GSTCompAmount4; ABS(GSTCompAmount[4]))
                {
                }
                column(Location_GSTRegistration_No_; Location."GST Registration No.")
                {
                }
                column(Location_Name_; Location.Name)
                {
                }
                column(Location_Address_; Location.Address)
                {
                }
                column(Location_Address_2_; Location."Address 2")
                {
                }
                column(Location_City_; Location.City)
                {
                }
                column(Location_PostCode_; Location."Post Code")
                {
                }
                column(Location_PhoneNo_; Location."Phone No.")
                {
                }
                column(Location_StateCode_; Location."State Code")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    SumAmount := 0;
                    if Location.Get("Company Location") then;
                    SumAmount := DeliveryChallanLine."GST Base Amount";
                end;

                trigger OnPreDataItem()
                begin
                    CurrReport.CreateTotals(SumAmount);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Vendor.Get("Vendor No.");
                FormatAddr.Vendor(VendAddr, Vendor);
                GetGSTAmounts(DeliveryChallanHeader);
            end;

            trigger OnPreDataItem()
            begin
                Clear(GSTComponentCode);
                Clear(GSTCompAmount);
            end;
        }
    }


    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    local procedure GetGSTAmounts(DeliveryChallanHeader: Record "Delivery Challan Header")
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
        DeliveryChallanLine: record "Delivery Challan Line";
    begin
        if not GSTSetup.Get() then
            exit;

        DeliveryChallanLine.Reset();
        DeliveryChallanLine.SetRange("Delivery Challan No.", DeliveryChallanHeader."No.");
        if DeliveryChallanLine.FindSet() then
            repeat
                TaxTransactionValue.Reset();
                TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
                TaxTransactionValue.SetRange("Tax Record ID", DeliveryChallanLine.RecordId);
                TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
                TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
                if TaxTransactionValue.FindSet() then
                    repeat
                        case TaxTransactionValue."Value ID" of
                            6:
                                begin
                                    GSTCompAmount[1] += TaxTransactionValue.Amount;
                                    if GSTComponentCode[1] = '' then
                                        GSTComponentCode[1] := 'SGST';
                                end;
                            2:
                                begin
                                    GSTCompAmount[2] += TaxTransactionValue.Amount;
                                    if GSTComponentCode[2] = '' then
                                        GSTComponentCode[2] := 'CGST';
                                end;
                            3:
                                begin
                                    GSTCompAmount[3] += TaxTransactionValue.Amount;
                                    if GSTComponentCode[3] = '' then
                                        GSTComponentCode[3] := 'IGST';
                                end;
                        end;
                    until TaxTransactionValue.Next() = 0;
            until DeliveryChallanLine.Next() = 0;
    end;


    var
        Vendor: Record Vendor;
        Location: Record Location;
        CompanyInformation: Record "Company Information";
        FormatAddr: Codeunit "Format Address";
        GSTComponentCode: array[20] of Code[10];
        GSTCompAmount: array[20] of Decimal;
        SumAmount: Decimal;
        DeliveryChallanFilters: Text[250];
        Delivery_ChallanCaptionLbl: Label 'Delivery Challan';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Delivery_Challan_Header__Challan_Date_CaptionLbl: Label 'Challan Date';
        Vendor_NameCaptionLbl: Label 'Vendor Name';
        Excise_Registration_No_CaptionLbl: Label 'Excise Registration No.';
        Cost_AmountCaptionLbl: Label 'Cost Amount';
        Parent_Item_No_CaptionLbl: Label 'Parent Item No.';
        Process_DescriptionCaptionLbl: Label 'Process Description';
        Item_No_CaptionLbl: Label 'Item No.';
        DescriptionCaptionLbl: Label 'Description';
        Unit_of_MeasureCaptionLbl: Label 'Unit of Measure';
        QuantityCaptionLbl: Label 'Quantity';
        Components_in_Rework_Qty_CaptionLbl: Label 'Components in Rework Qty.';
        Excise_AmountCaptionLbl: Label 'Excise Amount';
        Delivery_Challan_Header__Challan_Date__Control1500023CaptionLbl: Label 'Challan Date';
        Vendor_NameCaption_Control1500027Lbl: Label 'Vendor Name';
        Excise_Registration_No_Caption_Control1500031Lbl: Label 'Excise Registration No.';
        Rework_DetailsCaptionLbl: Label 'Rework Details';
        Components_DetailsCaptionLbl: Label 'Components Details';
        Signature_of_Manufacturer___Authorized_SignatoryCaptionLbl: Label 'Signature of Manufacturer / Authorized Signatory';
        Place__CaptionLbl: Label 'Place :';
        Date__CaptionLbl: Label 'Date :';
        Delivery_Challan_TotalCaptionLbl: Label 'Delivery Challan Total';
        Cost_AmountCaption_Control1280039Lbl: Label 'Cost Amount';
        Sub_Order_No_CaptionLbl: Label 'Sub Order No.';
        TotalCaptionLbl: Label 'Total';
        HSNSAC_Code_Lbl: Label 'HSN/SAC Code.';
        GST_Registration_No_CaptionLbl: Label 'GST Registration No.';
        VendAddr: array[8] of Text[50];
        Vendor_GST_Registration_No_CaptionLbl: Label 'Vendor GST Registration No.';
}
