// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;
using System.Integration;

codeunit 47011 "SL PO Migrator"
{
    var
        ItemWarningTxt: Label 'PO Line was skipped because the Item is invalid. Item: %1', Locked = true;
        ItemUnitOfMeasureWarningTxt: Label 'PO Line was skipped because the Item Unit of Measure is invalid. Item: %1, Unit of Measure: %2', Locked = true;
        MigratedFromSLDescriptionTxt: Label 'Migrated from SL';
        MigrationPOTxt: Label 'PO', Locked = true;
        MigrationPOLineTxt: Label 'PO Line', Locked = true;
        PurchaseAccountWarningTxt: Label 'PO Line was skipped because the Purchase Account is invalid. Account: %1', Locked = true;
        SLPOStatusTxt: Label 'O|P', Locked = true;
        SLPOTypeRegularOrderTxt: Label 'OR', Locked = true;
        VendorNotMigratedWarningTxt: Label 'PO was skipped because Vendor (%1) has not been migrated.', Locked = true;

    procedure MigrateOpenPurchaseOrders()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
    begin
        SLCompanyAdditionalSettings.Get(CompanyName());
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetMigrateOpenPOs() then
            exit;

        MigrateOpenPurchaseOrderData();
    end;

    procedure MigrateOpenPurchaseOrderData()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchasePayablesSetup: Record "Purchases & Payables Setup";
        SLMigrationWarnings: Record "SL Migration Warnings";
        SLPurchOrd: Record "SL PurchOrd Buffer";
        Vendor: Record Vendor;
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        ShipViaID: Code[10];
        PurchaseDocumentType: Enum "Purchase Document Type";
        PurchaseDocumentStatus: Enum "Purchase Document Status";
    begin
        SLPurchOrd.SetRange(CpnyID, CopyStr(CompanyName, 1, MaxStrLen(SLPurchOrd.CpnyID)));
        SLPurchOrd.SetRange(POType, SLPOTypeRegularOrderTxt); // Regular Order
        SLPurchOrd.SetFilter(Status, SLPOStatusTxt); // Open Order | Purchase Order
        SLPurchOrd.SetFilter(VendID, '<>%1', '');
        if not SLPurchOrd.FindSet() then
            exit;

        repeat
            if Vendor.Get(SLPurchOrd.VendID) then begin
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLPurchOrd.RecordId));
                Clear(PurchaseHeader);

                PurchaseHeader.Validate("Document Type", PurchaseDocumentType::Order);
                PurchaseHeader."No." := SLPurchOrd.PONbr;
                PurchaseHeader.Status := PurchaseDocumentStatus::Open;
                PurchaseHeader.Insert(true);

                PurchaseHeader.Validate("Buy-from Vendor No.", SLPurchOrd.VendID);
                PurchaseHeader.Validate("Pay-to Vendor No.", SLPurchOrd.VendID);
                PurchaseHeader.Validate("Order Date", SLPurchOrd.PODate);
                PurchaseHeader.Validate("Posting Date", SLPurchOrd.PODate);
                PurchaseHeader.Validate("Document Date", SLPurchOrd.PODate);
                PurchaseHeader.Validate("Posting Description", MigratedFromSLDescriptionTxt);

                if SLPurchOrd.ShipVia <> '' then begin
                    ShipViaID := CopyStr(SLPurchOrd.ShipVia, 1, MaxStrLen(PurchaseHeader."Shipment Method Code"));
                    DataMigrationFacadeHelper.CreateShipmentMethodIfNeeded(ShipViaID, ShipViaID + ' - ' + MigratedFromSLDescriptionTxt);
                    PurchaseHeader."Shipment Method Code" := ShipViaID;
                end;
                PurchaseHeader.Validate("Prices Including VAT", false);

                UpdateShipToAddress(SLPurchOrd, PurchaseHeader);

                if PurchasePayablesSetup.FindFirst() then begin
                    PurchaseHeader.Validate("Posting No. Series", PurchasePayablesSetup."Posted Invoice Nos.");
                    PurchaseHeader.Validate("Receiving No. Series", PurchasePayablesSetup."Posted Receipt Nos.")
                end;

                PurchaseHeader.Modify(true);
                CreateLines(PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No.");

                // If no lines were created, delete the empty Purchase Header
                PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                if PurchaseLine.IsEmpty then
                    PurchaseHeader.Delete();
            end else
                SLMigrationWarnings.InsertWarning(MigrationPOTxt, SLPurchOrd.PONbr, StrSubstNo(VendorNotMigratedWarningTxt, SLPurchOrd.VendID.TrimEnd()));
        until SLPurchOrd.Next() = 0;
    end;

    local procedure UpdateShipToAddress(SLPurchOrd: Record "SL PurchOrd Buffer"; var PurchaseHeader: Record "Purchase Header")
    begin
        if SLPurchOrd.ShipName.Trim() <> '' then
            PurchaseHeader."Ship-to Name" := CopyStr(SLPurchOrd.ShipName.Trim(), 1, MaxStrLen(PurchaseHeader."Ship-to Name"));
        if SLPurchOrd.ShipAttn.Trim() <> '' then
            PurchaseHeader."Ship-to Contact" := CopyStr(SLPurchOrd.ShipAttn.Trim(), 1, MaxStrLen(PurchaseHeader."Ship-to Contact"));
        if SLPurchOrd.ShipAddr1.Trim() <> '' then
            PurchaseHeader."Ship-to Address" := CopyStr(SLPurchOrd.ShipAddr1.Trim(), 1, MaxStrLen(PurchaseHeader."Ship-to Address"));
        if SLPurchOrd.ShipAddr2.Trim() <> '' then
            PurchaseHeader."Ship-to Address 2" := CopyStr(SLPurchOrd.ShipAddr2.Trim(), 1, MaxStrLen(PurchaseHeader."Ship-to Address 2"));
        if SLPurchOrd.ShipCity.Trim() <> '' then
            PurchaseHeader."Ship-to City" := CopyStr(SLPurchOrd.ShipCity.Trim(), 1, MaxStrLen(PurchaseHeader."Ship-to City"));
        if SLPurchOrd.ShipState.Trim() <> '' then
            PurchaseHeader."Ship-to County" := CopyStr(SLPurchOrd.ShipState.Trim(), 1, MaxStrLen(PurchaseHeader."Ship-to County"));
        if SLPurchOrd.ShipCountry.Trim() <> '' then
            PurchaseHeader."Ship-to Country/Region Code" := CopyStr(SLPurchOrd.ShipCountry.Trim(), 1, MaxStrLen(PurchaseHeader."Ship-to Country/Region Code"));
        if SLPurchOrd.ShipZip.Trim() <> '' then
            PurchaseHeader."Ship-to Post Code" := CopyStr(SLPurchOrd.ShipZip.Trim(), 1, MaxStrLen(PurchaseHeader."Ship-to Post Code"));
    end;

    local procedure CreateLines(PONumber: Code[20]; VendorNo: Code[20])
    var
        GLAccount: Record "G/L Account";
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        SLMigrationWarnings: Record "SL Migration Warnings";
        SLPurOrdDet: Record "SL PurOrdDet Buffer";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DimSetIDPurchaseLine: Integer;
        InventoryID: Text[20];
        PurchaseAccount: Text[10];
        PurchaseUnitOfMeasure: Text[6];
    begin
        SLPurOrdDet.SetRange(PONbr, PONumber);
        SLPurOrdDet.SetRange(OpenLine, 1);
        if not SLPurOrdDet.FindSet() then
            exit;

        repeat
            PurchaseLine."Document Type" := PurchaseLine."Document Type"::Order;
            PurchaseLine."Document No." := PONumber;
            PurchaseLine."Line No." := SLPurOrdDet.LineID;
            PurchaseLine."Buy-from Vendor No." := VendorNo;
            PurchaseAccount := CopyStr(SLPurOrdDet.PurAcct.TrimEnd(), 1, MaxStrLen(PurchaseAccount));
            DimSetIDPurchaseLine := SLHelperFunctions.GetDimSetIDByFullSubaccount(SLPurOrdDet.PurSub);
            case SLPurOrdDet.PurchaseType of
                'DL':  // Description Line
                    begin
                        PurchaseLine.Validate(Type, PurchaseLine.Type::" ");
                        PurchaseLine.Validate(Description, SLPurOrdDet.TranDesc.TrimEnd());
                        PurchaseLine.Insert(true);
                    end;

                'FR', 'MI':  // Freight Charges, Misc Charges 
                    begin
                        if not ValidatePOLineAccount(PurchaseAccount) then begin
                            // Log warning and skip line
                            SLMigrationWarnings.InsertWarning(MigrationPOLineTxt, SLPurOrdDet.PONbr, StrSubstNo(PurchaseAccountWarningTxt, PurchaseAccount));
                            continue;
                        end;
                        if GLAccount.Get(PurchaseAccount) then begin
                            PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
                            PurchaseLine.Validate("No.", PurchaseAccount);
                            PurchaseLine.Validate(Description, SLPurOrdDet.TranDesc.TrimEnd());
                            PurchaseLine.Validate(Quantity, 1);
                            PurchaseLine.Validate("Direct Unit Cost", SLPurOrdDet.ExtCost);
                            PurchaseLine.Validate("Dimension Set ID", DimSetIDPurchaseLine);
                            PurchaseLine.Insert(true);
                        end;
                    end;

                'GI', 'GS', 'GP', 'PI', 'PS':  // Goods for Inventory, Goods for Sales Order, Goods for Project, Goods for Project Inventory, Goods for Project Sales Order
                    begin
                        InventoryID := CopyStr(SLPurOrdDet.InvtID.TrimEnd(), 1, MaxStrLen(Item."No."));
                        PurchaseUnitOfMeasure := CopyStr(SLPurOrdDet.PurchUnit.TrimEnd(), 1, MaxStrLen(SLPurOrdDet.PurchUnit));
                        if not ValidatePOLineItem(InventoryID) then begin
                            // Log warning and skip line
                            SLMigrationWarnings.InsertWarning(MigrationPOLineTxt, SLPurOrdDet.PONbr, StrSubstNo(ItemWarningTxt, InventoryID));
                            continue;
                        end;
                        if not ValidatePOLineItemUOM(InventoryID, PurchaseUnitOfMeasure) then
                            if not CreateItemUnitOfMeasure(InventoryID, PurchaseUnitOfMeasure) then begin
                                // Log warning and skip line
                                SLMigrationWarnings.InsertWarning(MigrationPOLineTxt, SLPurOrdDet.PONbr, StrSubstNo(ItemUnitOfMeasureWarningTxt, InventoryID, PurchaseUnitOfMeasure));
                                continue;
                            end;

                        DimSetIDPurchaseLine := SLHelperFunctions.GetDimSetIDByFullSubaccount(SLPurOrdDet.PurSub);

                        if Item.Get(InventoryID) then begin
                            PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
                            PurchaseLine.Validate("No.", InventoryID);
                            PurchaseLine.Validate(Description, SLPurOrdDet.TranDesc.TrimEnd());
                            PurchaseLine.Validate("Location Code", SLPurOrdDet.SiteID);
                            PurchaseLine.Validate(Quantity, SLPurOrdDet.QtyOrd - SLPurOrdDet.QtyRcvd);
                            PurchaseLine.Validate("Unit of Measure Code", PurchaseUnitOfMeasure);
                            PurchaseLine.Validate("Direct Unit Cost", SLPurOrdDet.UnitCost);
                            PurchaseLine.Validate("Promised Receipt Date", SLPurOrdDet.PromDate);
                            PurchaseLine.Validate("Dimension Set ID", DimSetIDPurchaseLine);
                            PurchaseLine.Insert(true);
                        end;
                    end;
                'GN', 'SE', 'SP':  // Goods for non-Inventory, Services for Expense, Services for Project
                    begin
                        if not ValidatePOLineAccount(PurchaseAccount) then begin
                            // Log warning and skip line
                            SLMigrationWarnings.InsertWarning(MigrationPOLineTxt, SLPurOrdDet.PONbr, StrSubstNo(PurchaseAccountWarningTxt, PurchaseAccount));
                            continue;
                        end;
                        if GLAccount.Get(PurchaseAccount) then begin
                            PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
                            PurchaseLine.Validate("No.", PurchaseAccount);
                            PurchaseLine.Validate(Description, SLPurOrdDet.TranDesc.TrimEnd());
                            PurchaseLine.Validate(Quantity, SLPurOrdDet.QtyOrd - SLPurOrdDet.QtyRcvd);
                            PurchaseLine.Validate("Direct Unit Cost", SLPurOrdDet.UnitCost);
                            PurchaseLine.Validate("Promised Receipt Date", SLPurOrdDet.PromDate);
                            PurchaseLine.Validate("Dimension Set ID", DimSetIDPurchaseLine);
                            PurchaseLine.Insert(true);
                        end;
                    end;
            end;
        until SLPurOrdDet.Next() = 0;
    end;

    procedure CreateItemUnitOfMeasure(InvtId: Text[20]; FromUnit: Text[6]): Boolean
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SLINUnit: Record "SL INUnit";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        GlobalTxt: Label '1', Locked = true;
        ItemSpecificTxt: Label '3', Locked = true;
    begin
        if not Item.Get(InvtId) then
            exit(false);

        SLHelperFunctions.CreateUnitOfMeasureIfNeeded(FromUnit, FromUnit.TrimEnd() + ' - ' + MigratedFromSLDescriptionTxt);

        SLINUnit.SetRange(UnitType, ItemSpecificTxt);
        SLINUnit.SetRange(InvtId, InvtId);
        SLINUnit.SetFilter(FromUnit, '%1', FromUnit);
        SLINUnit.SetFilter(ToUnit, '%1', Item."Base Unit of Measure");
        if SLINUnit.FindFirst() then begin
            // Create Item Unit of Measure record based on SLINUnit record
            ItemUnitOfMeasure.Validate("Item No.", InvtId);
            ItemUnitOfMeasure.Validate(Code, FromUnit);
            ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", SLINUnit.CnvFact);
            ItemUnitOfMeasure.Insert();
            exit(true);
        end;

        Clear(SLINUnit);
        SLINUnit.SetRange(UnitType, GlobalTxt);
        SLINUnit.SetFilter(FromUnit, '%1', FromUnit);
        SLINUnit.SetFilter(ToUnit, '%1', Item."Base Unit of Measure");
        if SLINUnit.FindFirst() then begin
            // Create Item Unit of Measure record based on SLINUnit record
            ItemUnitOfMeasure.Validate("Item No.", InvtId);
            ItemUnitOfMeasure.Validate(Code, FromUnit);
            ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", SLINUnit.CnvFact);
            ItemUnitOfMeasure.Insert();
            exit(true);
        end;

        exit(false);
    end;

    local procedure ValidatePOLineAccount(PurchAcct: Text[10]): Boolean
    var
        GLAccount: Record "G/L Account";
    begin
        exit(GLAccount.Get(PurchAcct));
    end;

    local procedure ValidatePOLineItem(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        exit(Item.Get(ItemNo));
    end;

    local procedure ValidatePOLineItemUOM(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]): Boolean
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        exit(ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode));
    end;
}