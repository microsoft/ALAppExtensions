// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

page 18467 "Create GST Liability"
{
    Caption = 'Create GST Liability';
    PageType = Worksheet;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Delivery Challan Line";
    SourceTableView = sorting("Document No.", "Document Line No.", "Production Order No.", "Production Order Line No.", "Prod. Order Comp. Line No.")
        order(Ascending) where("Remaining Quantity" = Filter(<> 0));
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Vendor No. Filter"; VendorNo)
                {
                    Caption = 'Vendor No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Vendor: Record Vendor;
                        VendorList: Page "Vendor List";
                    begin
                        Vendor.Reset();
                        Vendor.SetRange(Subcontractor, true);
                        if not Vendor.IsEmpty() then
                            VendorList.SetTableView(Vendor);
                        VendorList.LookupMode(true);
                        if VendorList.RunModal() = Action::LookupOK then begin
                            VendorList.GetRecord(Vendor);
                            VendorNo := Vendor."No.";
                        end;

                        FilterSpecifiedRecords();
                    end;

                    trigger OnValidate()
                    begin
                        FilterSpecifiedRecords();
                    end;
                }
                field("Subcontracting Order No. Filter"; SubcontractingOrderNo)
                {
                    Caption = 'Subcontracting Order No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting order number.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PurchaseHeader: Record "Purchase Header";
                        SubContractingOrderList: Page "Subcontracting Order List";
                    begin
                        PurchaseHeader.Reset();
                        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                        PurchaseHeader.SetRange(Subcontracting, true);
                        if not PurchaseHeader.IsEmpty() then
                            SubContractingOrderList.SetTableView(PurchaseHeader);
                        SubContractingOrderList.LookupMode(true);
                        if SubContractingOrderList.RunModal() = Action::LookupOK then begin
                            SubContractingOrderList.GetRecord(PurchaseHeader);
                            SubcontractingOrderNo := PurchaseHeader."No.";
                        end;

                        FilterSpecifiedRecords();
                    end;

                    trigger OnValidate()
                    begin
                        FilterSpecifiedRecords();
                    end;
                }
                field("Delivery Challan No. Filter"; DeliveryChallanNo)
                {
                    Caption = 'Delivery Challan No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting delivery challan number.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DeliveryChallanHeader: Record "Delivery Challan Header";
                        DeliveryChallanList: Page "Delivery Challan List";
                    begin
                        DeliveryChallanHeader.Reset();
                        if not DeliveryChallanHeader.IsEmpty() then
                            DeliveryChallanList.SetTableView(DeliveryChallanHeader);
                        DeliveryChallanList.LookupMode(true);
                        if DeliveryChallanList.RunModal() = Action::LookupOK then begin
                            DeliveryChallanList.GetRecord(DeliveryChallanHeader);
                            DeliveryChallanNo := DeliveryChallanHeader."No.";
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        FilterSpecifiedRecords();
                    end;
                }
                field("Liability Date Filter"; LiabilityDate)
                {
                    Caption = 'Liability Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the liability date.';

                    trigger OnValidate()
                    begin
                        FilterSpecifiedRecords();
                    end;
                }
                field("Liability Document No."; LiabilityDocumentNo)
                {
                    Caption = 'Liability Document No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the liability document number.';

                    trigger OnValidate()
                    begin
                        CheckLiabilityDocumentNoExists(LiabilityDocumentNo);
                    end;
                }
            }
            repeater(control1)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number.';
                    Editable = false;
                }
                field("Subcontracting Order No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the  subcontracting order number.';
                    Editable = false;
                }
                field("Subcontracting Order Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting delivery challan line number.';
                    Editable = false;
                }
                field("Delivery Challan No."; Rec."Delivery Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting delivery challan number.';
                    Editable = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery challan line number.';
                    Editable = false;
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component code for the parent item.';
                    Editable = false;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of component.';
                    Editable = false;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of component.';
                    Editable = false;

                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining quantity.';
                    Editable = false;
                }
                field("Components in Rework Qty."; Rec."Components in Rework Qty.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component rework quantity.';
                    Editable = false;
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date for the entry.';
                    Editable = false;
                }
                field("Last Date"; Rec."Last Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date by when vendor should return the finished material as per GST law.';
                    Editable = false;
                }
                field("Job Work Return Period"; Rec."Job Work Return Period")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies job work return period of GST';
                    Editable = false;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            group(Functions)
            {
                Caption = 'F&unctions';
                Image = Action;
                action("Create GST Liability")
                {
                    Caption = 'Create GST Liability';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Create GST Liability';
                    Image = Action;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    begin
                        if LiabilityDate = 0D then
                            Error(LiabilityDateErr);

                        if LiabilityDocumentNo = '' then
                            Error(LiabilityDocNotBlankErr);

                        FillGSTLiability(LiabilityDate, LiabilityDocumentNo);
                        FilterRecords();
                        ResetVariables();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        FilterRecords();
    end;

    var
        VendorNo: Code[20];
        SubcontractingOrderNo: Code[20];
        DeliveryChallanNo: Code[20];
        LiabilityDocumentNo: Code[20];
        LiabilityDate: Date;
        LiabilityDateErr: Label 'You must enter the Liability Date.';
        LiabilityDocExistErr: Label 'Liability Document No. %1 already exists.', Comment = '%1 = Liability Document No.';
        LiabilityDocNotBlankErr: Label 'Liability Document No. must not be blank.';
        UnitCostErr: Label 'UnitCost should not be empty in %1.', Comment = '%1 = Delivery Challan Item No.';

    local procedure FilterRecords()
    begin
        Rec.Reset();
        Rec.SetFilter("Remaining Quantity", '>0');
        Rec.SetFilter("Total GST Amount", '<>%1', 0);
        Rec.SetRange("GST Liability Created", 0);
        Rec.SetRange("GST Credit", Rec."GST Credit"::Availment);
        Rec.SetRange(Exempted, false);
        CurrPage.Update();
    end;

    local procedure FilterSpecifiedRecords()
    begin
        FilterRecords();

        if VendorNo <> '' then
            Rec.SetRange("Vendor No.", VendorNo);

        if SubcontractingOrderNo <> '' then
            Rec.SetRange("Document No.", SubcontractingOrderNo);

        if DeliveryChallanNo <> '' then
            Rec.SetRange("Delivery Challan No.", DeliveryChallanNo);

        if LiabilityDate <> 0D then
            Rec.SetFilter("Last Date", '<%1', LiabilityDate);

        CurrPage.Update();
    end;

    local procedure CheckLiabilityDocumentNoExists(LiabilityDocNo: Code[20])
    var
        PostedGSTLiabilityLine: Record "Posted GST Liability Line";
    begin
        PostedGSTLiabilityLine.Reset();
        PostedGSTLiabilityLine.SetRange("Liability Document No.", LiabilityDocNo);
        if not PostedGSTLiabilityLine.IsEmpty() then
            Error(LiabilityDocExistErr, LiabilityDocNo);
    end;

    local procedure ResetVariables()
    begin
        LiabilityDate := 0D;
        LiabilityDocumentNo := '';
        VendorNo := '';
        SubcontractingOrderNo := '';
        DeliveryChallanNo := '';
    end;

    local procedure FillGSTLiability(LiabilityDate: Date; LiabilityDocNo: Code[20])
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        GSTLiabilityLine: Record "GST Liability Line";
        PurchaseHeader: Record "Purchase Header";
        SubcontractingValidations: Codeunit "Subcontracting Validations";
        UnitCost: Decimal;
    begin
        CheckLiabilityDocumentNoExists(LiabilityDocNo);
        DeleteGSTLiability();

        DeliveryChallanLine.CopyFilters(Rec);
        if DeliveryChallanLine.FindSet() then
            repeat
                DeliveryChallanLine.Calcfields("Remaining Quantity");

                GSTLiabilityLine.Init();
                GSTLiabilityLine."Liability Document No." := LiabilityDocNo;
                GSTLiabilityLine."Liability Document Line No." := GetGSTLiabilityLineDocumentLineNo(LiabilityDocNo);
                GSTLiabilityLine."Liability Date" := LiabilityDate;
                GSTLiabilityLine."Posting Date" := WorkDate();
                GSTLiabilityLine.TransferFields(DeliveryChallanLine);
                GSTLiabilityLine."GST Jurisdiction Type" := DeliveryChallanLine."GST Jurisdiction Type";

                if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DeliveryChallanLine."Document No.") then begin
                    GSTLiabilityLine."Location State Code" := PurchaseHeader."Location State Code";
                    GSTLiabilityLine."Location GST Reg. No." := PurchaseHeader."Location GST Reg. No.";
                    GSTLiabilityLine."GST Vendor Type" := PurchaseHeader."GST Vendor Type";
                    GSTLiabilityLine."Vendor State Code" := PurchaseHeader.State;
                    GSTLiabilityLine."Vendor GST Reg. No." := PurchaseHeader."Vendor GST Reg. No.";
                end;

                UnitCost := 0;
                UnitCost := SubcontractingValidations.GetProdOrderCompUnitCost(
                    DeliveryChallanLine."Production Order No.",
                    DeliveryChallanLine."Production Order Line No.",
                    DeliveryChallanLine."Item No.");
                if UnitCost = 0 then
                    Error(UnitCostErr, DeliveryChallanLine."Item No.");

                GSTLiabilityLine.Validate("GST Base Amount", (UnitCost * DeliveryChallanLine."Remaining Quantity"));
                GSTLiabilityLine.TestField("GST Base Amount");
                GSTLiabilityLine.Insert();
            until DeliveryChallanLine.next() = 0;

        Page.Run(Page::"GST Liability Line");
    end;

    local procedure DeleteGSTLiability()
    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        GSTLiabilityLine: Record "GST Liability Line";
    begin
        DeliveryChallanLine.CopyFilters(Rec);
        if DeliveryChallanLine.FindSet() then
            repeat
                GSTLiabilityLine.DeleteAll();
            until DeliveryChallanLine.next() = 0;
    end;

    local procedure GetGSTLiabilityLineDocumentLineNo(LiabilityDocNo: Code[20]): Integer
    var
        GSTLiabilityLine: Record "GST Liability Line";

    begin
        GSTLiabilityLine.Reset();
        GSTLiabilityLine.SetRange("Liability Document No.", LiabilityDocNo);
        if GSTLiabilityLine.FindLast() then
            exit(GSTLiabilityLine."Liability Document Line No." + 10000)
        else
            exit(10000);
    end;
}
