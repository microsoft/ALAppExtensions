namespace Microsoft.DataMigration.BC;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Project.Job;
using Microsoft.Integration.Entity;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.Currency;
using Microsoft.Inventory.Tracking;
using Microsoft.Foundation.Shipping;

codeunit 4052 "Upg Mig - BaseApp"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '17.0';

    trigger OnRun()
    begin
        // This code is based on standard app upgrade logic.
        // Matching file: .\App\Layers\W1\BaseApp\Upgrade\UpgradeBaseApp.Codeunit.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 15.0 then
            exit;

        UpdateDefaultDimensionsReferencedIds();
        UpdateGenJournalBatchReferencedIds();
        UpdateItems();
        UpdateJobs();
        UpdateItemTrackingCodes();
        UpgradeStandardCustomerSalesCodes();
        UpgradeStandardVendorPurchaseCode();

        UpgradeAPIs();
    end;

    local procedure UpdateDefaultDimensionsReferencedIds()
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if DefaultDimension.FindSet() then
            repeat
                DefaultDimension.UpdateReferencedIds(); // Record is modified in procedure call
            until DefaultDimension.Next() = 0;
    end;

    local procedure UpdateGenJournalBatchReferencedIds()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        if GenJournalBatch.FindSet() then
            repeat
                GenJournalBatch.UpdateBalAccountId();
#pragma warning disable AA0214
                if GenJournalBatch.Modify() then;
            until GenJournalBatch.Next() = 0;
    end;

    local procedure UpdateItems()
    var
        ItemCategory: Record "Item Category";
        Item: Record "Item";
    begin
        if not ItemCategory.IsEmpty() then begin
            Item.SetFilter("Item Category Code", '<>''''');
            if Item.FindSet(true) then
                repeat
                    Item.UpdateItemCategoryId();
                    if Item.Modify() then;
                until Item.Next() = 0;
        end;
    end;

    local procedure UpdateJobs()
    var
        Job: Record "Job";
    begin
        if Job.FindSet(true) then
            repeat
                if IsNullGuid(Job.SystemId) then
                    Job.UpdateReferencedIds();
            until Job.Next() = 0;
    end;

    local procedure UpgradeAPIs()
    begin
        UpgradeSalesInvoiceEntityAggregate();
        UpgradePurchInvEntityAggregate();
        UpgradeSalesOrderEntityBuffer();
        UpgradeSalesQuoteEntityBuffer();
        UpgradeSalesCrMemoEntityBuffer();
        UpgradeSalesOrderShipmentMethod();
        UpgradeSalesCrMemoShipmentMethod();
    end;

    local procedure UpgradeSalesInvoiceEntityAggregate()
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SourceRecordRef: RecordRef;
        TargetRecordRef: RecordRef;
    begin
        if SalesInvoiceEntityAggregate.FindSet(true) then
            repeat
                if SalesInvoiceEntityAggregate.Posted then begin
                    SalesInvoiceHeader.SetRange(SystemId, SalesInvoiceEntityAggregate.Id);
                    if SalesInvoiceHeader.FindFirst() then begin
                        SourceRecordRef.GetTable(SalesInvoiceHeader);
                        TargetRecordRef.GetTable(SalesInvoiceEntityAggregate);
                        UpdateSalesDocumentFields(SourceRecordRef, TargetRecordRef, true, true, true);
                    end;
                end else begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
                    SalesHeader.SetRange(SystemId, SalesInvoiceEntityAggregate.Id);
                    if SalesHeader.FindFirst() then begin
                        SourceRecordRef.GetTable(SalesHeader);
                        TargetRecordRef.GetTable(SalesInvoiceEntityAggregate);
                        UpdateSalesDocumentFields(SourceRecordRef, TargetRecordRef, true, true, true);
                    end;
                end;
            until SalesInvoiceEntityAggregate.Next() = 0;
    end;

    local procedure UpgradePurchInvEntityAggregate()
    var
        PurchInvEntityAggregate: Record "Purch. Inv. Entity Aggregate";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        SourceRecordRef: RecordRef;
        TargetRecordRef: RecordRef;
    begin
        if PurchInvEntityAggregate.FindSet(true) then
            repeat
                if PurchInvEntityAggregate.Posted then begin
                    PurchInvHeader.SetRange(SystemId, PurchInvEntityAggregate.Id);
                    if PurchInvHeader.FindFirst() then begin
                        SourceRecordRef.GetTable(PurchInvHeader);
                        TargetRecordRef.GetTable(PurchInvEntityAggregate);
                        UpdatePurchaseDocumentFields(SourceRecordRef, TargetRecordRef, true, true);
                    end;
                end else begin
                    PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
                    PurchaseHeader.SetRange(SystemId, PurchInvEntityAggregate.Id);
                    if PurchaseHeader.FindFirst() then begin
                        SourceRecordRef.GetTable(PurchaseHeader);
                        TargetRecordRef.GetTable(PurchInvEntityAggregate);
                        UpdatePurchaseDocumentFields(SourceRecordRef, TargetRecordRef, true, true);
                    end;
                end;
            until PurchInvEntityAggregate.Next() = 0;
    end;

    local procedure UpgradeSalesOrderEntityBuffer()
    var
        SalesOrderEntityBuffer: Record "Sales Order Entity Buffer";
        SalesHeader: Record "Sales Header";
        SourceRecordRef: RecordRef;
        TargetRecordRef: RecordRef;
    begin
        if SalesOrderEntityBuffer.FindSet(true) then
            repeat
                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                SalesHeader.SetRange(SystemId, SalesOrderEntityBuffer.Id);
                if SalesHeader.FindFirst() then begin
                    SourceRecordRef.GetTable(SalesHeader);
                    TargetRecordRef.GetTable(SalesOrderEntityBuffer);
                    UpdateSalesDocumentFields(SourceRecordRef, TargetRecordRef, true, true, true);
                end;
            until SalesOrderEntityBuffer.Next() = 0;
    end;

    local procedure UpgradeSalesQuoteEntityBuffer()
    var
        SalesQuoteEntityBuffer: Record "Sales Quote Entity Buffer";
        SalesHeader: Record "Sales Header";
        SourceRecordRef: RecordRef;
        TargetRecordRef: RecordRef;
    begin
        if SalesQuoteEntityBuffer.FindSet(true) then
            repeat
                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
                SalesHeader.SetRange(SystemId, SalesQuoteEntityBuffer.Id);
                if SalesHeader.FindFirst() then begin
                    SourceRecordRef.GetTable(SalesHeader);
                    TargetRecordRef.GetTable(SalesQuoteEntityBuffer);
                    UpdateSalesDocumentFields(SourceRecordRef, TargetRecordRef, true, true, true);
                end;
            until SalesQuoteEntityBuffer.Next() = 0;
    end;

    local procedure UpgradeSalesCrMemoEntityBuffer()
    var
        SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SourceRecordRef: RecordRef;
        TargetRecordRef: RecordRef;
    begin
        if SalesCrMemoEntityBuffer.FindSet(true) then
            repeat
                if SalesCrMemoEntityBuffer.Posted then begin
                    SalesCrMemoHeader.SetRange(SystemId, SalesCrMemoEntityBuffer.Id);
                    if SalesCrMemoHeader.FindFirst() then begin
                        SourceRecordRef.GetTable(SalesCrMemoHeader);
                        TargetRecordRef.GetTable(SalesCrMemoEntityBuffer);
                        UpdateSalesDocumentFields(SourceRecordRef, TargetRecordRef, true, true, false);
                    end;
                end else begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
                    SalesHeader.SetRange(SystemId, SalesCrMemoEntityBuffer.Id);
                    if SalesHeader.FindFirst() then begin
                        SourceRecordRef.GetTable(SalesHeader);
                        TargetRecordRef.GetTable(SalesCrMemoEntityBuffer);
                        UpdateSalesDocumentFields(SourceRecordRef, TargetRecordRef, true, true, false);
                    end;
                end;
            until SalesCrMemoEntityBuffer.Next() = 0;
    end;

    local procedure UpdateSalesDocumentFields(var SourceRecordRef: RecordRef; var TargetRecordRef: RecordRef; SellTo: Boolean; BillTo: Boolean; ShipTo: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesOrderEntityBuffer: Record "Sales Order Entity Buffer";
        Customer: Record "Customer";
        CodeFieldRef: FieldRef;
        IdFieldRef: FieldRef;
        EmptyGuid: Guid;
    begin
        if SellTo then begin
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Sell-to Phone No."));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Sell-to E-Mail"));
        end;
        if BillTo then begin
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Bill-to Customer No."));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Bill-to Name"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Bill-to Address"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Bill-to Address 2"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Bill-to City"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Bill-to Contact"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Bill-to Post Code"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Bill-to County"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Bill-to Country/Region Code"));
            CodeFieldRef := TargetRecordRef.Field(SalesOrderEntityBuffer.FIELDNO("Bill-to Customer No."));
            IdFieldRef := TargetRecordRef.Field(SalesOrderEntityBuffer.FIELDNO("Bill-to Customer Id"));
            if Customer.Get(CodeFieldRef.Value()) then
                IdFieldRef.Value(Customer.SystemId)
            else
                IdFieldRef.Value(EmptyGuid);
        end;
        if ShipTo then begin
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Ship-to Code"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Ship-to Name"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Ship-to Address"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Ship-to Address 2"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Ship-to City"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Ship-to Contact"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Ship-to Post Code"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Ship-to County"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Ship-to Country/Region Code"));
        end;
        TargetRecordRef.Modify();
    end;

    local procedure UpdatePurchaseDocumentFields(var SourceRecordRef: RecordRef; var TargetRecordRef: RecordRef; PayTo: Boolean; ShipTo: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchInvEntityAggregate: Record "Purch. Inv. Entity Aggregate";
        Vendor: Record "Vendor";
        Currency: Record "Currency";
        CodeFieldRef: FieldRef;
        IdFieldRef: FieldRef;
        EmptyGuid: Guid;
    begin
        if PayTo then begin
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Pay-to Vendor No."));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Pay-to Name"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Pay-to Address"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Pay-to Address 2"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Pay-to City"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Pay-to Contact"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Pay-to Post Code"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Pay-to County"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Pay-to Country/Region Code"));
            CodeFieldRef := TargetRecordRef.Field(PurchInvEntityAggregate.FIELDNO("Pay-to Vendor No."));
            IdFieldRef := TargetRecordRef.Field(PurchInvEntityAggregate.FIELDNO("Pay-to Vendor Id"));
            if Vendor.Get(CodeFieldRef.Value()) then
                IdFieldRef.Value(Vendor.SystemId)
            else
                IdFieldRef.Value(EmptyGuid);
            CodeFieldRef := TargetRecordRef.Field(PurchInvEntityAggregate.FIELDNO("Currency Code"));
            IdFieldRef := TargetRecordRef.Field(PurchInvEntityAggregate.FIELDNO("Currency Id"));
            if Vendor.Get(CodeFieldRef.Value()) then
                IdFieldRef.Value(Currency.SystemId)
            else
                IdFieldRef.Value(EmptyGuid);
        end;
        if ShipTo then begin
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Ship-to Code"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Ship-to Name"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Ship-to Address"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Ship-to Address 2"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Ship-to City"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Ship-to Contact"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Ship-to Post Code"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Ship-to County"));
            CopyFieldValue(SourceRecordRef, TargetRecordRef, PurchaseHeader.FIELDNO("Ship-to Country/Region Code"));
        end;
        TargetRecordRef.Modify();
    end;

    local procedure CopyFieldValue(var SourceRecordRef: RecordRef; var TargetRecordRef: RecordRef; FieldNo: Integer)
    var
        SourceFieldRef: FieldRef;
        TargetFieldRef: FieldRef;
    begin
        SourceFieldRef := SourceRecordRef.Field(FieldNo);
        TargetFieldRef := TargetRecordRef.Field(FieldNo);
        if TargetFieldRef.Value() <> SourceFieldRef.Value() then
            TargetFieldRef.Value(SourceFieldRef.Value());
    end;

    local procedure UpdateItemTrackingCodes()
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        ItemTrackingCode.SetRange("Use Expiration Dates", false);
        if not ItemTrackingCode.IsEmpty() then
            // until now, expiration date was always ON, so let's reflect this
            ItemTrackingCode.ModifyAll("Use Expiration Dates", true);
    end;

    local procedure UpgradeStandardCustomerSalesCodes()
    var
        StandardSalesCode: Record "Standard Sales Code";
        StandardCustomerSalesCode: Record "Standard Customer Sales Code";
    begin
        if StandardSalesCode.FindSet() then
            repeat
                StandardCustomerSalesCode.SetRange(Code, StandardSalesCode.Code);
                StandardCustomerSalesCode.ModifyAll("Currency Code", StandardSalesCode."Currency Code");
            until StandardSalesCode.Next() = 0;
    end;

    local procedure UpgradeStandardVendorPurchaseCode()
    var
        StandardPurchaseCode: Record "Standard Purchase Code";
        StandardVendorPurchaseCode: Record "Standard Vendor Purchase Code";
    begin
        if StandardPurchaseCode.FindSet() then
            repeat
                StandardVendorPurchaseCode.SetRange(Code, StandardPurchaseCode.Code);
                StandardVendorPurchaseCode.ModifyAll("Currency Code", StandardPurchaseCode."Currency Code");
            until StandardPurchaseCode.Next() = 0;
    end;

    local procedure UpgradeSalesOrderShipmentMethod()
    var
        SalesOrderEntityBuffer: Record "Sales Order Entity Buffer";
        SalesHeader: Record "Sales Header";
        SourceRecordRef: RecordRef;
        TargetRecordRef: RecordRef;
    begin
        if SalesOrderEntityBuffer.FindSet(true) then
            repeat
                SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                SalesHeader.SetRange(SystemId, SalesOrderEntityBuffer.Id);
                if SalesHeader.FindFirst() then begin
                    SourceRecordRef.GetTable(SalesHeader);
                    TargetRecordRef.GetTable(SalesOrderEntityBuffer);
                    UpdateSalesDocumentShipmentMethodFields(SourceRecordRef, TargetRecordRef);
                end;
            until SalesOrderEntityBuffer.Next() = 0;
    end;

    local procedure UpgradeSalesCrMemoShipmentMethod()
    var
        SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SourceRecordRef: RecordRef;
        TargetRecordRef: RecordRef;
    begin
        if SalesCrMemoEntityBuffer.FindSet(true) then
            repeat
                if SalesCrMemoEntityBuffer.Posted then begin
                    SalesCrMemoHeader.SetRange(SystemId, SalesCrMemoEntityBuffer.Id);
                    if SalesCrMemoHeader.FindFirst() then begin
                        SourceRecordRef.GetTable(SalesCrMemoHeader);
                        TargetRecordRef.GetTable(SalesCrMemoEntityBuffer);
                        UpdateSalesDocumentShipmentMethodFields(SourceRecordRef, TargetRecordRef);
                    end;
                end else begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Credit Memo");
                    SalesHeader.SetRange(SystemId, SalesCrMemoEntityBuffer.Id);
                    if SalesHeader.FindFirst() then begin
                        SourceRecordRef.GetTable(SalesHeader);
                        TargetRecordRef.GetTable(SalesCrMemoEntityBuffer);
                        UpdateSalesDocumentShipmentMethodFields(SourceRecordRef, TargetRecordRef);
                    end;
                end;
            until SalesCrMemoEntityBuffer.Next() = 0;
    end;

    local procedure UpdateSalesDocumentShipmentMethodFields(var SourceRecordRef: RecordRef; var TargetRecordRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
        SalesOrderEntityBuffer: Record "Sales Order Entity Buffer";
        ShipmentMethod: Record "Shipment Method";
        CodeFieldRef: FieldRef;
        IdFieldRef: FieldRef;
        EmptyGuid: Guid;
    begin
        CopyFieldValue(SourceRecordRef, TargetRecordRef, SalesHeader.FIELDNO("Shipment Method Code"));
        CodeFieldRef := TargetRecordRef.Field(SalesOrderEntityBuffer.FIELDNO("Shipment Method Code"));
        IdFieldRef := TargetRecordRef.Field(SalesOrderEntityBuffer.FIELDNO("Shipment Method Id"));
        if ShipmentMethod.Get(CodeFieldRef.Value()) then
            IdFieldRef.Value(ShipmentMethod.SystemId)
        else
            IdFieldRef.Value(EmptyGuid);
        TargetRecordRef.Modify();
    end;
}
