namespace Microsoft.SubscriptionBilling;

using Microsoft.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Posting;
using Microsoft.Sales.History;
using Microsoft.Inventory.Item;

codeunit 8069 "Sales Service Commitment Mgmt."
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterInsertEvent, '', false, false)]
    local procedure SalesLineOnAfterInsertEvent(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if IsSalesLineRestoreInProgress(Rec) then
            exit;
        if RunTrigger then
            AddSalesServiceCommitmentsForSalesLine(Rec, false);
    end;

    procedure AddSalesServiceCommitmentsForSalesLine(var SalesLine: Record "Sales Line"; SkipAddAdditionalSalesServComm: Boolean)
    var
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        SalesHeader: Record "Sales Header";
    begin
        if not IsSalesLineWithSalesServiceCommitments(SalesLine, false) then
            exit;

        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        ItemServCommitmentPackage.SetRange("Item No.", SalesLine."No.");
        ItemServCommitmentPackage.SetRange("Price Group", SalesHeader."Customer Price Group");
        ItemServCommitmentPackage.SetRange(Standard, true);
        if ItemServCommitmentPackage.IsEmpty() then
            ItemServCommitmentPackage.SetFilter("Price Group", '%1', '');
        if ItemServCommitmentPackage.IsEmpty() then
            ItemServCommitmentPackage.SetRange("Price Group");

        if ItemServCommitmentPackage.FindSet() then
            repeat
                if not ItemServCommitmentPackage.IsPackageAssignedToSalesLine(SalesLine, ItemServCommitmentPackage.Code) then
                    InsertSalesServiceCommitmentFromServiceCommitmentPackage(SalesLine, ItemServCommitmentPackage.Code);
            until ItemServCommitmentPackage.Next() = 0;

        if not SkipAddAdditionalSalesServComm then
            AddAdditionalSalesServiceCommitmentsForSalesLine(SalesLine, true);
    end;

    internal procedure AddAdditionalSalesServiceCommitmentsForSalesLine(var SalesLine: Record "Sales Line")
    begin
        AddAdditionalSalesServiceCommitmentsForSalesLine(SalesLine, false);
    end;

    internal procedure AddAdditionalSalesServiceCommitmentsForSalesLine(var SalesLine: Record "Sales Line"; RemoveExistingPackageFromFilter: Boolean)
    var
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        SalesHeader: Record "Sales Header";
        AssignServiceCommitments: Page "Assign Service Commitments";
        PackageFilter: Text;
        NoAddServicesForContractRenewalAllowedErr: Label 'Pricess must not be Contract Renewal. Additional services cannot be added to a Contract Renewal';
    begin
        if SalesLine."Line No." = 0 then
            exit;
        if SalesLine.IsContractRenewal() then
            Error(NoAddServicesForContractRenewalAllowedErr);

        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        ServiceCommitmentPackage.SetRange("Price Group", SalesHeader."Customer Price Group");
        if ServiceCommitmentPackage.IsEmpty then
            ServiceCommitmentPackage.SetRange("Price Group");

        PackageFilter := ItemServCommitmentPackage.GetPackageFilterForItem(SalesLine, RemoveExistingPackageFromFilter);
        ServiceCommitmentPackage.FilterCodeOnPackageFilter(PackageFilter);
        OnAddAdditionalSalesServiceCommitmentsForSalesLineAfterApplyFilters(ServiceCommitmentPackage, SalesLine);

        if not ServiceCommitmentPackage.IsEmpty() then begin
            AssignServiceCommitments.SetTableView(ServiceCommitmentPackage);
            AssignServiceCommitments.SetSalesLine(SalesLine);
            AssignServiceCommitments.LookupMode(true);
            Commit(); // Commit before RunModal
            if AssignServiceCommitments.RunModal() = Action::LookupOK then begin
                AssignServiceCommitments.GetSelectionFilter(ServiceCommitmentPackage);
                if ServiceCommitmentPackage.FindSet() then
                    repeat
                        InsertSalesServiceCommitmentFromServiceCommitmentPackage(SalesLine, ServiceCommitmentPackage.Code);
                    until ServiceCommitmentPackage.Next() = 0;
            end;
        end;
    end;

    local procedure IsSalesLineWithSalesServiceCommitments(var SalesLine: Record "Sales Line"; SkipTemporaryCheck: Boolean; ServiceCommitmentItemOnly: Boolean): Boolean
    var
        SalesLine2: Record "Sales Line";
    begin
        if not SkipTemporaryCheck then
            if SalesLine.IsTemporary() then
                exit(false);
        if (SalesLine.Type <> SalesLine.Type::Item) or
           (SalesLine."No." = '') or
           (SalesLine."Line No." = 0) or
           not SalesLine.IsSalesDocumentTypeWithServiceCommitments()
        then
            exit(false);
        if not SalesLine2.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") then
            exit(false);
        if ServiceCommitmentItemOnly then begin
            if not IsServiceCommitmentItem(SalesLine."No.") then
                exit(false);
        end else
            if not IsItemWithServiceCommitments(SalesLine."No.") then
                exit(false);
        exit(true);
    end;

    procedure IsSalesLineWithSalesServiceCommitments(var SalesLine: Record "Sales Line"; SkipTemporaryCheck: Boolean): Boolean
    begin
        exit(IsSalesLineWithSalesServiceCommitments(SalesLine, SkipTemporaryCheck, false));
    end;

    procedure IsSalesLineWithServiceCommitmentItem(var SalesLine: Record "Sales Line"; SkipTemporaryCheck: Boolean): Boolean
    begin
        exit(IsSalesLineWithSalesServiceCommitments(SalesLine, SkipTemporaryCheck, true));
    end;

    procedure IsItemWithServiceCommitments(ItemNo: Code[20]): Boolean
    begin
        exit(ItemManagement.IsItemWithServiceCommitments(ItemNo));
    end;

    procedure IsServiceCommitmentItem(ItemNo: Code[20]): Boolean
    begin
        exit(ItemManagement.IsServiceCommitmentItem(ItemNo));
    end;

    procedure IsSalesLineWithSalesServiceCommitmentsToShip(SalesLine: Record "Sales Line"): Boolean
    begin
        if not IsSalesLineWithSalesServiceCommitments(SalesLine, true) then
            exit(false);
        if SalesLine."Qty. to Ship" = 0 then
            exit(false);

        exit(true);
    end;

    internal procedure IsSalesLineWithSalesServiceCommitmentsToShip(SalesLine: Record "Sales Line"; QuantityToCheck: Decimal): Boolean
    begin
        if not IsSalesLineWithSalesServiceCommitmentsToShip(SalesLine) then
            exit(false);
        if CheckNegativeQuantityAndShowMessageForServiceCommitment(QuantityToCheck) then
            exit(false);

        exit(true);
    end;

    procedure IsSalesLineWithServiceCommitmentItemToShip(SalesLine: Record "Sales Line"): Boolean
    begin
        if not IsSalesLineWithServiceCommitmentItem(SalesLine, true) then
            exit(false);
        if SalesLine."Qty. to Ship" = 0 then
            exit(false);

        exit(true);
    end;

    internal procedure IsSalesLineWithServiceCommitmentItemToInvoice(SalesLine: Record "Sales Line"): Boolean
    begin
        if not IsSalesLineWithServiceCommitmentItem(SalesLine, true) then
            exit(false);
        if SalesLine."Qty. to Invoice" = 0 then
            exit(false);

        exit(true);
    end;

    local procedure InsertSalesServiceCommitmentFromServiceCommitmentPackage(var SalesLine: Record "Sales Line"; ServCommPackageCode: Code[20])
    var
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ServiceCommitmentPackageLine: Record "Service Comm. Package Line";
    begin
        if ServiceCommitmentPackage.Get(ServCommPackageCode) then begin
            ServiceCommitmentPackageLine.SetRange("Package Code", ServiceCommitmentPackage.Code);
            if ServiceCommitmentPackageLine.FindSet() then begin
                SalesLine.Modify(false);
                repeat
                    CreateSalesServCommLineFromServCommPackageLine(SalesLine, ServiceCommitmentPackageLine);
                until ServiceCommitmentPackageLine.Next() = 0;
            end;
        end;
    end;

    local procedure CreateSalesServCommLineFromServCommPackageLine(var SalesLine: Record "Sales Line"; ServiceCommitmentPackageLine: Record "Service Comm. Package Line")
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateSalesServCommLineFromServCommPackageLine(SalesLine, ServiceCommitmentPackageLine, IsHandled);
        if not IsHandled then begin
            SalesServiceCommitment.InitRecord(SalesLine);
            SalesServiceCommitment.Insert(false);
            SalesServiceCommitment."Invoicing via" := ServiceCommitmentPackageLine."Invoicing via";
            SalesServiceCommitment.Validate("Item No.", GetItemNoForSalesServiceCommitment(SalesLine, ServiceCommitmentPackageLine));
            SalesServiceCommitment."Customer Price Group" := SalesLine."Customer Price Group";
            SalesServiceCommitment.Validate("Package Code", ServiceCommitmentPackageLine."Package Code");
            SalesServiceCommitment.Template := ServiceCommitmentPackageLine.Template;
            SalesServiceCommitment.Description := ServiceCommitmentPackageLine.Description;
            SalesServiceCommitment.Validate("Extension Term", ServiceCommitmentPackageLine."Extension Term");
            SalesServiceCommitment.Validate("Notice Period", ServiceCommitmentPackageLine."Notice Period");
            SalesServiceCommitment.Validate("Initial Term", ServiceCommitmentPackageLine."Initial Term");
            SalesServiceCommitment.Partner := ServiceCommitmentPackageLine.Partner;
            SalesServiceCommitment.Validate("Calculation Base Type", ServiceCommitmentPackageLine."Calculation Base Type");
            SalesServiceCommitment.Validate("Billing Base Period", ServiceCommitmentPackageLine."Billing Base Period");
            SalesServiceCommitment."Calculation Base %" := ServiceCommitmentPackageLine."Calculation Base %";
            SalesServiceCommitment.Validate("Service Comm. Start Formula", ServiceCommitmentPackageLine."Service Comm. Start Formula");
            SalesServiceCommitment.Validate("Billing Rhythm", ServiceCommitmentPackageLine."Billing Rhythm");
            SalesServiceCommitment.Validate(Discount, ServiceCommitmentPackageLine.Discount);
            SalesServiceCommitment."Price Binding Period" := ServiceCommitmentPackageLine."Price Binding Period";
            SalesServiceCommitment."Period Calculation" := ServiceCommitmentPackageLine."Period Calculation";
            SalesServiceCommitment.CalculateCalculationBaseAmount();
            SalesServiceCommitment."Usage Based Billing" := ServiceCommitmentPackageLine."Usage Based Billing";
            SalesServiceCommitment."Usage Based Pricing" := ServiceCommitmentPackageLine."Usage Based Pricing";
            SalesServiceCommitment."Pricing Unit Cost Surcharge %" := ServiceCommitmentPackageLine."Pricing Unit Cost Surcharge %";
            OnBeforeModifySalesServiceCommitmentFromServCommPackageLine(SalesServiceCommitment, ServiceCommitmentPackageLine);
            SalesServiceCommitment.Modify(false);
        end;
        OnAfterCreateSalesServCommLineFromServCommPackageLine(SalesLine, ServiceCommitmentPackageLine, SalesServiceCommitment);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, OnAfterStoreSalesLineArchive, '', false, false)]
    local procedure StoreSalesServiceCommitmentLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var SalesHeaderArchive: Record "Sales Header Archive")
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
        SalesServiceCommArchive: Record "Sales Service Comm. Archive";
    begin
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        if SalesServiceCommitment.FindSet() then
            repeat
                SalesServiceCommArchive.Init();
                SalesServiceCommArchive.TransferFields(SalesServiceCommitment);
                SalesServiceCommArchive."Doc. No. Occurrence" := SalesHeader."Doc. No. Occurrence";
                SalesServiceCommArchive."Version No." := SalesHeaderArchive."Version No.";
                SalesServiceCommArchive."Line No." := 0;
                SalesServiceCommArchive.Insert(false);
            until SalesServiceCommitment.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, OnAfterRestoreSalesLine, '', false, false)]
    local procedure RestoreSalesServiceCommitment(var SalesHeaderArchive: Record "Sales Header Archive"; var SalesLineArchive: Record "Sales Line Archive")
    var
        SalesServiceCommArchive: Record "Sales Service Comm. Archive";
        ToSalesServiceCommitment: Record "Sales Service Commitment";
    begin
        SalesServiceCommArchive.FilterOnSalesLineArchive(SalesLineArchive);
        if SalesServiceCommArchive.FindSet() then
            repeat
                ToSalesServiceCommitment.Init();
                ToSalesServiceCommitment.TransferFields(SalesServiceCommArchive);
                ToSalesServiceCommitment."Line No." := 0;
                ToSalesServiceCommitment.Insert(false);
            until SalesServiceCommArchive.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnAfterInsertToSalesLine, '', false, false)]
    local procedure CreateSalesServiceCommitmentFromSalesServiceCommitmentOnAfterInsertToSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line"; RecalculateLines: Boolean)
    begin
        if not FromSalesLine.IsSalesDocumentTypeWithServiceCommitments() then
            exit;
        CreateSalesServiceCommitmentFromSalesServiceCommitment(ToSalesLine, FromSalesLine, RecalculateLines);
    end;

    local procedure CreateSalesServiceCommitmentFromSalesServiceCommitment(ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line"; RecalculateLines: Boolean)
    var
        ToSalesServiceCommitment: Record "Sales Service Commitment";
        FromSalesServiceCommitment: Record "Sales Service Commitment";
    begin
        if RecalculateLines then
            AddSalesServiceCommitmentsForSalesLine(ToSalesLine, true)
        else begin
            FromSalesServiceCommitment.FilterOnSalesLine(FromSalesLine);
            if FromSalesServiceCommitment.FindSet() then
                repeat
                    ToSalesServiceCommitment.Init();
                    ToSalesServiceCommitment.TransferFields(FromSalesServiceCommitment);
                    ToSalesServiceCommitment.SetDocumentFields(ToSalesLine."Document Type", ToSalesLine."Document No.", ToSalesLine."Line No.");
                    ToSalesServiceCommitment."Line No." := 0;
                    ToSalesServiceCommitment.Insert(false);
                until FromSalesServiceCommitment.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnCopyArchSalesLineOnAfterToSalesLineInsert, '', false, false)]
    local procedure CreateSalesServiceCommitmentFromSalesServiceCommArchiveOnCopyArchSalesLineOnAfterToSalesLineInsert(var ToSalesLine: Record "Sales Line"; FromSalesLineArchive: Record "Sales Line Archive"; RecalculateLines: Boolean)
    var
        SalesServiceCommArchive: Record "Sales Service Comm. Archive";
        ToSalesServiceCommitment: Record "Sales Service Commitment";
    begin
        if RecalculateLines then
            exit;
        if not FromSalesLineArchive.IsSalesDocumentTypeWithServiceCommitments() then
            exit;
        SalesServiceCommArchive.FilterOnSalesLineArchive(FromSalesLineArchive);
        if SalesServiceCommArchive.FindSet() then
            repeat
                ToSalesServiceCommitment.Init();
                ToSalesServiceCommitment.TransferFields(SalesServiceCommArchive);
                ToSalesServiceCommitment.SetDocumentFields(ToSalesLine."Document Type", ToSalesLine."Document No.", ToSalesLine."Line No.");
                ToSalesServiceCommitment."Line No." := 0;
                ToSalesServiceCommitment.Insert(false);
            until SalesServiceCommArchive.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesLineDeleteAll, '', false, false)]
    local procedure DeleteSalesServiceCommitmentOnBeforeSalesLineDeleteAll(var SalesLine: Record "Sales Line")
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
    begin
        if not SalesLine.FindFirst() then
            exit;
        SalesServiceCommitment.SetRange("Document Type", SalesLine."Document Type");
        SalesServiceCommitment.SetRange("Document No.", SalesLine."Document No.");
        SalesServiceCommitment.DeleteAll(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", OnAfterInsertSalesOrderLine, '', false, false)]
    local procedure UpdateSalesServiceCommitmentOnAfterInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line"; SalesQuoteLine: Record "Sales Line")
    begin
        TransferServiceCommitments(SalesQuoteLine, SalesOrderLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Blanket Sales Order to Order", OnAfterInsertSalesOrderLine, '', false, false)]
    local procedure BlanketSalesOrderToOrderUpdateSalesServiceCommitmentOnAfterInsertSalesOrderLine(BlanketOrderSalesLine: Record "Sales Line"; var SalesOrderLine: Record "Sales Line")
    begin
        TransferServiceCommitments(BlanketOrderSalesLine, SalesOrderLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, OnRestoreSalesLinesOnBeforeSalesLineInsert, '', false, false)]
    local procedure SetSalesLineRestoreInProgressOnRestoreSalesLinesOnBeforeSalesLineInsert(var SalesLine: Record "Sales Line")
    begin
        SessionStore.SetBooleanKey('SalesLineRestoreInProgress ' + Format(SalesLine.RecordId()), true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, OnRestoreSalesLinesOnAfterSalesLineInsert, '', false, false)]
    local procedure RemoveSalesLineRestoreInProgressOnRestoreSalesLinesOnAfterSalesLineInsert(var SalesLine: Record "Sales Line")
    begin
        SessionStore.RemoveBooleanKey('SalesLineRestoreInProgress ' + Format(SalesLine.RecordId()));
    end;

    local procedure IsSalesLineRestoreInProgress(var SalesLine: Record "Sales Line"): Boolean
    begin
        exit(SessionStore.GetBooleanKey('SalesLineRestoreInProgress ' + Format(SalesLine.RecordId())));
    end;

    procedure GetItemNoForSalesServiceCommitment(var SalesLine: Record "Sales Line"; ServiceCommitmentPackageLine: Record "Service Comm. Package Line"): Code[20]
    var
        Item: Record Item;
    begin
        Item.Get(SalesLine."No.");
        case Item."Service Commitment Option" of
            Item."Service Commitment Option"::"Service Commitment Item":
                exit(Item."No.");
            Item."Service Commitment Option"::"Sales with Service Commitment":
                begin
                    if ServiceCommitmentPackageLine."Invoicing via" = Enum::"Invoicing Via"::Contract then
                        ServiceCommitmentPackageLine.TestField("Invoicing Item No.");
                    exit(ServiceCommitmentPackageLine."Invoicing Item No.");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterCreateSalesLine, '', false, false)]
    local procedure RecreateStandardSalesServiceCommitmentsOnAfterCreateSalesLine(var SalesLine: Record "Sales Line")
    begin
        AddSalesServiceCommitmentsForSalesLine(SalesLine, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Explode BOM", OnExplodeBOMCompLinesOnAfterToSalesLineInsert, '', false, false)]
    local procedure AddSalesServiceCommitmentsForSalesLineOnAfterExplodeBOM(ToSalesLine: Record "Sales Line")
    begin
        ToSalesLine.Get(ToSalesLine."Document Type", ToSalesLine."Document No.", ToSalesLine."Line No.");
        AddSalesServiceCommitmentsForSalesLine(ToSalesLine, false);
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateSalesServCommLineFromServCommPackageLine(var SalesLine: Record "Sales Line"; var ServiceCommitmentPackageLine: Record "Service Comm. Package Line"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateSalesServCommLineFromServCommPackageLine(var SalesLine: Record "Sales Line"; ServiceCommitmentPackageLine: Record "Service Comm. Package Line"; var SalesServiceCommitment: Record "Sales Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeModifySalesServiceCommitmentFromServCommPackageLine(var SalesServiceCommitment: Record "Sales Service Commitment"; ServiceCommitmentPackageLine: Record "Service Comm. Package Line")
    begin
    end;

    local procedure CheckNegativeQuantityAndShowMessageForServiceCommitment(Quantity: Decimal): Boolean
    begin
        if Quantity <= 0 then begin
            if not ServiceCommitmentWithNegativeQtyMessageThrown then begin
                Message(ServiceObjectNotCreatedMsg);
                ServiceCommitmentWithNegativeQtyMessageThrown := true;
            end;
            exit(true);
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesLines, '', false, false)]
    local procedure ResetServiceCommitmentWithNegativeQtyMessageThrownOnAfterPostSalesLines()
    begin
        ServiceCommitmentWithNegativeQtyMessageThrown := false;
    end;

    [InternalEvent(false, false)]
    local procedure OnAddAdditionalSalesServiceCommitmentsForSalesLineAfterApplyFilters(var ServiceCommitmentPackage: Record "Service Commitment Package"; var SalesLine: Record "Sales Line")
    begin
    end;

    local procedure TransferServiceCommitments(var FromSalesLine: Record "Sales Line"; var ToSalesLine: Record "Sales Line")
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
        SalesServiceCommitment2: Record "Sales Service Commitment";
    begin
        SalesServiceCommitment.FilterOnSalesLine(FromSalesLine);
        if SalesServiceCommitment.FindSet() then
            repeat
                SalesServiceCommitment2 := SalesServiceCommitment;
                SalesServiceCommitment2.SetDocumentFields(ToSalesLine."Document Type", ToSalesLine."Document No.", ToSalesLine."Line No.");
                SalesServiceCommitment2."Line No." := 0;
                SalesServiceCommitment2.Insert(false);
                SalesServiceCommitment2.CalculateCalculationBaseAmount();
                SalesServiceCommitment2.Modify(false);
            until SalesServiceCommitment.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Sales Shipment Line", OnCodeOnBeforeProcessItemShptEntry, '', false, false)]
    local procedure RemoveQuantityInvoicedForServiceCommitmentItems(var SalesShipmentLine: Record "Sales Shipment Line")
    begin
        if IsServiceCommitmentItem(SalesShipmentLine."No.") then begin
            SalesShipmentLine."Quantity Invoiced" := 0;
            SalesShipmentLine."Qty. Invoiced (Base)" := 0;
        end;
    end;

    var
        SessionStore: Codeunit "Session Store";
        ItemManagement: Codeunit "Contracts Item Management";
        ServiceCommitmentWithNegativeQtyMessageThrown: Boolean;
        ServiceObjectNotCreatedMsg: Label 'For negative quantity the Service Object is not created.';
}