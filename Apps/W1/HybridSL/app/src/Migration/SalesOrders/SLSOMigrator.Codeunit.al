// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.Shipping;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Setup;
using System.Integration;

codeunit 47007 "SL SO Migrator"
{
    var
        SLHelperFunctions: Codeunit "SL Helper Functions";
        CustomerNotMigratedWarningTxt: Label 'Sales Order was skipped because Customer (%1) has not been migrated.', Locked = true;
        ItemWarningTxt: Label 'Sales Order Line was skipped because the Item is invalid. Item: %1', Locked = true;
        ItemUnitOfMeasureWarningTxt: Label 'Sales Order Line was skipped because the Item Unit of Measure is invalid. Item: %1, Unit of Measure: %2', Locked = true;
        MessageCodeNoDataTxt: Label 'No Data', Locked = true;
        MessageCodeOrderTypeTxt: Label 'Order Type', Locked = true;
        MessageTextNoLinesTxt: Label 'No lines to migrate for Sales Order %1.', Locked = true;
        MessageTextNoLocationCodeTxt: Label 'Location Code for Sales Order Line could not be determined. Location: %1, Item: %2', Locked = true;
        MessageTextNoOrdersTxt: Label 'No open Sales Orders to migrate.', Locked = true;
        MessageTextBehaviorNotSupportedTxt: Label 'Sales Order (%1) skipped because its Order Type behavior is not supported.', Locked = true;
        MigratedFromSLDescriptionTxt: Label 'Migrated from SL', Locked = true;
        MigrationAreaSalesOrderLineTxt: Label 'Sales Order Line', Locked = true;
        MigrationSOTxt: Label 'SO', Locked = true;
        OpenStatusTxt: Label 'O', Locked = true;
        PostMigrationTypeSOTxt: Label 'SALES ORDERS', Locked = true;
        SLSOHeaderTxt: Label 'SL SOHeader', Locked = true;
        SLSOLineTxt: Label 'SL SOLine', Locked = true;

    procedure MigrateOpenSalesOrders()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
    begin
        SLCompanyAdditionalSettings.Get(CompanyName());
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetReceivablesModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetMigrateOpenSOs() then
            exit;

        MigrateOpenSalesOrderData();
    end;

    local procedure MigrateOpenSalesOrderData()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SLMigrationWarnings: Record "SL Migration Warnings";
        SLSOHeader: Record "SL SOHeader Buffer";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        SalesDocumentStatus: Enum "Sales Document Status";
        SalesDocumentType: Enum "Sales Document Type";
        SalesHeaderShippingAdvice: Enum "Sales Header Shipping Advice";
        ShipViaID: Code[10];
        SalesHeaderDimSetID: Integer;
    begin
        SLSOHeader.SetFilter(CpnyID, '= %1', CopyStr(CompanyName, 1, MaxStrLen(SLSOHeader.CpnyID)));
        SLSOHeader.SetFilter(Status, '= %1', OpenStatusTxt);
        if not SLSOHeader.FindSet() then begin
            SLHelperFunctions.LogPostMigrationDataMessage(PostMigrationTypeSOTxt, SLSOHeaderTxt, MessageCodeNoDataTxt, MessageTextNoOrdersTxt);
            exit;
        end;
        UpdateSalesOrderNumberSeries();

        repeat
            if not CheckIfSalesOrderBehavior(SLSOHeader.SOTypeID) then begin
                SLHelperFunctions.LogPostMigrationDataMessage(PostMigrationTypeSOTxt, SLSOHeaderTxt, MessageCodeOrderTypeTxt, StrSubstNo(MessageTextBehaviorNotSupportedTxt, SLSOHeader.OrdNbr.TrimEnd()));
                continue;
            end;

            if Customer.Get(SLSOHeader.CustID) then begin
                DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLSOHeader.RecordId));
                Clear(SalesHeader);

                SalesHeader.Validate("Document Type", SalesDocumentType::Order);
                SalesHeader.Validate("No.", SLSOHeader.OrdNbr);
                SalesHeader.Status := SalesDocumentStatus::Open;
                SalesHeader.Insert(true);

                SalesHeader.Validate("Sell-to Customer No.", SLSOHeader.CustID);
                SalesHeader.Validate("Bill-to Customer No.", SLSOHeader.CustID);
                SalesHeader.Validate("Order Date", SLSOHeader.OrdDate);
                SalesHeader.Validate("Posting Date", SLSOHeader.OrdDate);
                SalesHeader.Validate("Document Date", SLSOHeader.OrdDate);
                SalesHeader.Validate("Posting Description", MigratedFromSLDescriptionTxt);

                if SLSOHeader.ShipViaID <> '' then begin
                    ShipViaID := CopyStr(SLSOHeader.ShipViaID, 1, MaxStrLen(SalesHeader."Shipment Method Code"));
                    DataMigrationFacadeHelper.CreateShipmentMethodIfNeeded(ShipViaID, ShipViaID + '-' + MigratedFromSLDescriptionTxt);
                    SalesHeader.Validate("Shipment Method Code", ShipViaID);
                end;

                if SLSOHeader.ShipCmplt = 1 then
                    SalesHeader.Validate("Shipping Advice", SalesHeaderShippingAdvice::Complete)
                else
                    SalesHeader.Validate("Shipping Advice", SalesHeaderShippingAdvice::Partial);

                UpdateShipToAddressOnSalesOrder(SLSOHeader, SalesHeader);
                SalesHeaderDimSetID := GetSalesOrderDimSetID(SLSOHeader);
                if SalesHeaderDimSetID <> 0 then
                    SalesHeader.Validate("Dimension Set ID", SalesHeaderDimSetID);

                if SalesReceivablesSetup.FindFirst() then begin
                    SalesHeader.Validate("Posting No. Series", SalesReceivablesSetup."Posted Invoice Nos.");
                    SalesHeader.Validate("Shipping No. Series", SalesReceivablesSetup."Posted Shipment Nos.");
                end;

                SalesHeader.Modify(true);
                CreateLines(SalesHeader);

            end else
                SLMigrationWarnings.InsertWarning(MigrationSOTxt, SLSOHeader.OrdNbr, StrSubstNo(CustomerNotMigratedWarningTxt, SLSOHeader.CustID));
        until SLSOHeader.Next() = 0;
    end;

    procedure CheckIfSalesOrderBehavior(SOTypeID: Text[4]): Boolean;
    var
        SLSOType: Record "SL SOType Buffer";
        SOBehaviorTxt: Label 'SO', Locked = true;
    begin
        SLSOType.SetFilter(CpnyID, '= %1', CompanyName);
        SLSOType.SetFilter(SOTypeID, '= %1', SOTypeID);
        SLSOType.SetFilter(Behavior, '= %1', SOBehaviorTxt);
        if not SLSOType.IsEmpty then
            exit(true);
        exit(false);
    end;

    procedure CreateLines(SalesHeader: Record "Sales Header")
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
        SLMigrationWarnings: Record "SL Migration Warnings";
        SLSOLine: Record "SL SOLine Buffer";
        InventoryID: Code[20];
        LocationCode: Code[10];
        SalesUnitOfMeasure: Text[6];
    begin
        SLSOLine.SetFilter(CpnyID, '= %1', CompanyName);
        SLSOLine.SetRange(OrdNbr, SalesHeader."No.");
        SLSOLine.SetFilter(QtyBO, '> %1', 0);
        if not SLSOLine.FindSet() then begin
            SLHelperFunctions.LogPostMigrationDataMessage(PostMigrationTypeSOTxt, SLSOLineTxt, MessageCodeNoDataTxt, StrSubstNo(MessageTextNoLinesTxt, SalesHeader."No."));
            exit;
        end;

        repeat
            SalesLine."Document Type" := SalesLine."Document Type"::Order;
            SalesLine."Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
            SalesLine."Document No." := SalesHeader."No.";
            Evaluate(SalesLine."Line No.", SLSOLine.LineRef);

            InventoryID := CopyStr(SLSOLine.InvtID.TrimEnd(), 1, MaxStrLen(Item."No."));
            SalesUnitOfMeasure := CopyStr(SLSOLine.UnitDesc.TrimEnd(), 1, MaxStrLen(SLSOLine.UnitDesc));
            LocationCode := CopyStr(SLSOLine.SiteID.TrimEnd(), 1, MaxStrLen(SLSOLine.SiteID));
            if not ValidateSOLineItem(InventoryID) then begin
                // Log warning and skip line                
                SLMigrationWarnings.InsertWarning(MigrationAreaSalesOrderLineTxt, SalesHeader."No.", StrSubstNo(ItemWarningTxt, InventoryID));
                continue;
            end;
            if not ValidateSOLineItemUOM(InventoryID, SalesUnitOfMeasure) then begin
                SLMigrationWarnings.InsertWarning(MigrationAreaSalesOrderLineTxt, SalesHeader."No.", StrSubstNo(ItemUnitOfMeasureWarningTxt, InventoryID, SalesUnitOfMeasure));
                continue;
            end;
            if not ValidateSOLineLocationCode(SLSOLine.SiteID) then begin
                SLHelperFunctions.LogPostMigrationDataMessage(PostMigrationTypeSOTxt, SLSOLineTxt, MessageCodeOrderTypeTxt, StrSubstNo(MessageTextNoLocationCodeTxt, SLSOLine.SiteID, InventoryID));
                LocationCode := '';
                continue;
            end;
            if Item.Get(InventoryID) then begin
                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine.Validate("No.", InventoryID);
                if LocationCode <> '' then
                    SalesLine.Validate("Location Code", LocationCode);
                SalesLine.Validate("Unit of Measure", SalesUnitOfMeasure);
                SalesLine.Validate(Quantity, SLSOLine.QtyBO);
                SalesLine.Validate("Unit Price", SLSOLine.SlsPrice);
                // SalesLine.Validate(Amount, SLSOLine.TotOrd);
                SalesLine.Insert(true);
            end;
        until SLSOLine.Next() = 0;
    end;

    local procedure GetSalesOrderDimSetID(SLSOHeader: Record "SL SOHeader Buffer"): Integer
    var
        SLCustomer: Record "SL Customer";
        SLARSalesSubaccount: Text[24];
        SalesOrderDimSetID: Integer;
    begin
        // Use the A/R Sales Subaccount from the SL Customer record
        SLCustomer.Get(SLSOHeader.CustID);
        if SLCustomer.SlsSub.TrimEnd() <> '' then
            SLARSalesSubaccount := SLCustomer.SlsSub;

        SalesOrderDimSetID := SLHelperFunctions.GetDimSetIDByFullSubaccount(SLARSalesSubaccount);
        exit(SalesOrderDimSetID);
    end;

    procedure UpdateSalesOrderNumberSeries()
    var
        NoSeries: Record "No. Series";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if SalesReceivablesSetup.FindFirst() then begin
            NoSeries.Get(SalesReceivablesSetup."Order Nos.");
            NoSeries."Manual Nos." := true;
            NoSeries.Modify();
        end;
    end;

    local procedure UpdateShipToAddressOnSalesOrder(SLSOHeader: Record "SL SOHeader Buffer"; var SalesHeader: Record "Sales Header")
    begin
        if SLSOHeader.ShipName.TrimEnd() <> '' then
            SalesHeader."Ship-to Name" := CopyStr(SLSOHeader.ShipName.TrimEnd(), 1, MaxStrLen(SalesHeader."Ship-to Name"));
        if SLSOHeader.ShipAttn.TrimEnd() <> '' then
            SalesHeader."Ship-to Contact" := CopyStr(SLSOHeader.ShipAttn.TrimEnd(), 1, MaxStrLen(SalesHeader."Ship-to Contact"));
        if SLSOHeader.ShipAddr1.TrimEnd() <> '' then
            SalesHeader."Ship-to Address" := CopyStr(SLSOHeader.ShipAddr1.TrimEnd(), 1, MaxStrLen(SalesHeader."Ship-to Address"));
        if SLSOHeader.ShipAddr2.TrimEnd() <> '' then
            SalesHeader."Ship-to Address 2" := CopyStr(SLSOHeader.ShipAddr2.TrimEnd(), 1, MaxStrLen(SalesHeader."Ship-to Address 2"));
        if SLSOHeader.ShipCity.TrimEnd() <> '' then
            SalesHeader."Ship-to City" := CopyStr(SLSOHeader.ShipCity.TrimEnd(), 1, MaxStrLen(SalesHeader."Ship-to City"));
        if SLSOHeader.ShipState.TrimEnd() <> '' then
            SalesHeader."Ship-to County" := CopyStr(SLSOHeader.ShipState.TrimEnd(), 1, MaxStrLen(SalesHeader."Ship-to County"));
        if SLSOHeader.ShipCountry.TrimEnd() <> '' then
            SalesHeader."Ship-to Country/Region Code" := CopyStr(SLSOHeader.ShipCountry.TrimEnd(), 1, MaxStrLen(SalesHeader."Ship-to Country/Region Code"));
        if SLSOHeader.ShipZip.TrimEnd() <> '' then
            SalesHeader."Ship-to Post Code" := CopyStr(SLSOHeader.ShipZip.TrimEnd(), 1, MaxStrLen(SalesHeader."Ship-to Post Code"));
    end;

    local procedure ValidateSOLineItem(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        exit(Item.Get(ItemNo));
    end;

    local procedure ValidateSOLineItemUOM(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]): Boolean
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        exit(ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode));
    end;

    local procedure ValidateSOLineLocationCode(LocationCode: Code[10]): Boolean
    var
        Location: Record Location;
    begin
        exit(Location.Get(LocationCode));
    end;
}