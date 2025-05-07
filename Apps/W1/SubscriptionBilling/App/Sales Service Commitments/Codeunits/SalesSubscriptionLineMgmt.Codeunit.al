namespace Microsoft.SubscriptionBilling;

using System.Environment.Configuration;
using Microsoft.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Posting;
using Microsoft.Sales.History;
using Microsoft.Inventory.Item;

codeunit 8069 "Sales Subscription Line Mgmt."
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterInsertEvent, '', false, false)]
    local procedure SalesLineOnAfterInsertEvent(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if IsSalesLineRestoreInProgress(Rec) then
            exit;
        if RunTrigger then
            AddSalesServiceCommitmentsForSalesLine(Rec, false);
    end;

    internal procedure AddSalesServiceCommitmentsForSalesLine(var SalesLine: Record "Sales Line"; SkipAddAdditionalSalesServComm: Boolean)
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
        SalesHeader: Record "Sales Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAddSalesServiceCommitmentsForSalesLine(SalesLine, SkipAddAdditionalSalesServComm, IsHandled);
        if IsHandled then
            exit;

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

    local procedure AddAdditionalSalesServiceCommitmentsForSalesLine(var SalesLine: Record "Sales Line"; RemoveExistingPackageFromFilter: Boolean)
    var
        ServiceCommitmentPackage: Record "Subscription Package";
        ItemServCommitmentPackage: Record "Item Subscription Package";
        SalesHeader: Record "Sales Header";
        AssignServiceCommitments: Page "Assign Service Commitments";
        PackageFilter: Text;
        NoAddServicesForContractRenewalAllowedErr: Label 'Process must not be Contract Renewal. Additional Subscription Lines cannot be added to a Contract Renewal';
        ShowAssignServiceCommitments: Boolean;
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
        OnAddAdditionalSalesSubscriptionLinesForSalesLineAfterApplyFilters(ServiceCommitmentPackage, SalesLine);

        ShowAssignServiceCommitments := not ServiceCommitmentPackage.IsEmpty();
        OnAfterShowAssignServiceCommitmentsDetermined(SalesLine, ServiceCommitmentPackage, ShowAssignServiceCommitments);

        if ShowAssignServiceCommitments and GuiAllowed() then begin
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
            if not ItemManagement.IsServiceCommitmentItem(SalesLine."No.") then
                exit(false);
        end else
            if not ItemManagement.IsItemWithServiceCommitments(SalesLine."No.") then
                exit(false);
        exit(true);
    end;

    local procedure IsSalesLineWithSalesServiceCommitments(var SalesLine: Record "Sales Line"; SkipTemporaryCheck: Boolean): Boolean
    begin
        exit(IsSalesLineWithSalesServiceCommitments(SalesLine, SkipTemporaryCheck, false));
    end;

    internal procedure IsSalesLineWithServiceCommitmentItem(var SalesLine: Record "Sales Line"; SkipTemporaryCheck: Boolean): Boolean
    begin
        exit(IsSalesLineWithSalesServiceCommitments(SalesLine, SkipTemporaryCheck, true));
    end;

    internal procedure IsSalesLineWithSalesServiceCommitmentsToShip(SalesLine: Record "Sales Line"): Boolean
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

    internal procedure IsSalesLineWithServiceCommitmentItemToShip(SalesLine: Record "Sales Line"): Boolean
    begin
        if not IsSalesLineWithServiceCommitmentItem(SalesLine, true) then
            exit(false);
        if SalesLine."Qty. to Ship" = 0 then
            exit(false);

        exit(true);
    end;

    local procedure InsertSalesServiceCommitmentFromServiceCommitmentPackage(var SalesLine: Record "Sales Line"; ServCommPackageCode: Code[20])
    var
        ServiceCommitmentPackage: Record "Subscription Package";
        ServiceCommitmentPackageLine: Record "Subscription Package Line";
    begin
        if ServiceCommitmentPackage.Get(ServCommPackageCode) then begin
            ServiceCommitmentPackageLine.SetRange("Subscription Package Code", ServiceCommitmentPackage.Code);
            if ServiceCommitmentPackageLine.FindSet() then begin
                SalesLine.Modify(false);
                repeat
                    CreateSalesServCommLineFromServCommPackageLine(SalesLine, ServiceCommitmentPackageLine);
                until ServiceCommitmentPackageLine.Next() = 0;
            end;
        end;
    end;

    local procedure CreateSalesServCommLineFromServCommPackageLine(var SalesLine: Record "Sales Line"; ServiceCommitmentPackageLine: Record "Subscription Package Line")
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
    begin
        CreateSalesServCommLineFromServCommPackageLine(SalesLine, ServiceCommitmentPackageLine, SalesServiceCommitment);
    end;

    local procedure CreateSalesServCommLineFromServCommPackageLine(var SalesLine: Record "Sales Line"; ServiceCommitmentPackageLine: Record "Subscription Package Line"; var SalesServiceCommitment: Record "Sales Subscription Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateSalesSubscriptionLineFromSubscriptionPackageLine(SalesLine, ServiceCommitmentPackageLine, IsHandled);
        if not IsHandled then begin
            SalesServiceCommitment.InitRecord(SalesLine);
            SalesServiceCommitment.Insert(false);
            OnCreateSalesServCommLineFromServCommPackageLineOnAfterInsertSalesSubscriptionLineFromSubscriptionPackageLine(SalesServiceCommitment, ServiceCommitmentPackageLine);
            SalesServiceCommitment."Invoicing via" := ServiceCommitmentPackageLine."Invoicing via";
            SalesServiceCommitment.Validate("Item No.", GetItemNoForSalesServiceCommitment(SalesLine, ServiceCommitmentPackageLine));
            SalesServiceCommitment."Customer Price Group" := SalesLine."Customer Price Group";
            SalesServiceCommitment.Validate("Subscription Package Code", ServiceCommitmentPackageLine."Subscription Package Code");
            SalesServiceCommitment.Template := ServiceCommitmentPackageLine.Template;
            SalesServiceCommitment.Description := ServiceCommitmentPackageLine.Description;
            SalesServiceCommitment.Validate("Extension Term", ServiceCommitmentPackageLine."Extension Term");
            SalesServiceCommitment.Validate("Notice Period", ServiceCommitmentPackageLine."Notice Period");
            SalesServiceCommitment.Validate("Initial Term", ServiceCommitmentPackageLine."Initial Term");
            SalesServiceCommitment.Partner := ServiceCommitmentPackageLine.Partner;
            SalesServiceCommitment.Validate("Calculation Base Type", ServiceCommitmentPackageLine."Calculation Base Type");
            SalesServiceCommitment.Validate("Billing Base Period", ServiceCommitmentPackageLine."Billing Base Period");
            SalesServiceCommitment."Usage Based Billing" := ServiceCommitmentPackageLine."Usage Based Billing";
            SalesServiceCommitment."Usage Based Pricing" := ServiceCommitmentPackageLine."Usage Based Pricing";
            SalesServiceCommitment."Pricing Unit Cost Surcharge %" := ServiceCommitmentPackageLine."Pricing Unit Cost Surcharge %";
            SalesServiceCommitment."Calculation Base %" := ServiceCommitmentPackageLine."Calculation Base %";
            SalesServiceCommitment.Validate("Sub. Line Start Formula", ServiceCommitmentPackageLine."Sub. Line Start Formula");
            SalesServiceCommitment.Validate("Billing Rhythm", ServiceCommitmentPackageLine."Billing Rhythm");
            SalesServiceCommitment.Validate(Discount, ServiceCommitmentPackageLine.Discount);
            SalesServiceCommitment."Price Binding Period" := ServiceCommitmentPackageLine."Price Binding Period";
            SalesServiceCommitment."Period Calculation" := ServiceCommitmentPackageLine."Period Calculation";
            SalesServiceCommitment."Create Contract Deferrals" := ServiceCommitmentPackageLine."Create Contract Deferrals";
            SalesServiceCommitment.CalculateCalculationBaseAmount();
            if SalesServiceCommitment.Partner = SalesServiceCommitment.Partner::Customer then
                SalesServiceCommitment.CalculateUnitCost();
            OnBeforeModifySalesSubscriptionLineFromSubscriptionPackageLine(SalesServiceCommitment, ServiceCommitmentPackageLine);
            SalesServiceCommitment.Modify(false);
        end;
        OnAfterCreateSalesSubscriptionLineFromSubscriptionPackageLine(SalesLine, ServiceCommitmentPackageLine, SalesServiceCommitment);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, OnAfterStoreSalesLineArchive, '', false, false)]
    local procedure StoreSalesServiceCommitmentLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var SalesHeaderArchive: Record "Sales Header Archive")
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
        SalesServiceCommArchive: Record "Sales Sub. Line Archive";
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
        SalesServiceCommArchive: Record "Sales Sub. Line Archive";
        ToSalesServiceCommitment: Record "Sales Subscription Line";
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
        ToSalesServiceCommitment: Record "Sales Subscription Line";
        FromSalesServiceCommitment: Record "Sales Subscription Line";
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
        SalesServiceCommArchive: Record "Sales Sub. Line Archive";
        ToSalesServiceCommitment: Record "Sales Subscription Line";
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
        SalesServiceCommitment: Record "Sales Subscription Line";
    begin
        if not SalesLine.FindFirst() then
            exit;
        SalesServiceCommitment.FilterOnDocument(SalesLine."Document Type", SalesLine."Document No.");
        SalesServiceCommitment.DeleteAll(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", OnAfterInsertSalesOrderLine, '', false, false)]
    local procedure UpdateSalesServiceCommitmentOnAfterInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line"; SalesQuoteLine: Record "Sales Line")
    begin
        TransferServiceCommitments(SalesQuoteLine, SalesOrderLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", OnRunOnAfterSalesQuoteLineDeleteAll, '', false, false)]
    local procedure DeleteSalesServiceCommitmentOnAfterSalesQuoteLineDeleteAll(var SalesHeaderRec: Record "Sales Header")
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
    begin
        SalesServiceCommitment.SetRange("Document Type", SalesHeaderRec."Document Type");
        SalesServiceCommitment.SetRange("Document No.", SalesHeaderRec."No.");
        SalesServiceCommitment.DeleteAll(false);
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

    internal procedure GetItemNoForSalesServiceCommitment(var SalesLine: Record "Sales Line"; ServiceCommitmentPackageLine: Record "Subscription Package Line"): Code[20]
    var
        Item: Record Item;
        ItemNo: Code[20];
        IsHandled: Boolean;
    begin
        ItemNo := SalesLine."No.";
        IsHandled := false;
        OnBeforeGetItemNoForSalesServiceCommitment(SalesLine, ItemNo, IsHandled);
        if IsHandled then
            exit(ItemNo);
        Item.Get(ItemNo);
        case Item."Subscription Option" of
            Item."Subscription Option"::"Service Commitment Item":
                exit(Item."No.");
            Item."Subscription Option"::"Sales with Service Commitment":
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesSubscriptionLineFromSubscriptionPackageLine(var SalesLine: Record "Sales Line"; var SubscriptionPackageLine: Record "Subscription Package Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesSubscriptionLineFromSubscriptionPackageLine(var SalesLine: Record "Sales Line"; SubscriptionPackageLine: Record "Subscription Package Line"; var SalesSubscriptionLine: Record "Sales Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSalesServCommLineFromServCommPackageLineOnAfterInsertSalesSubscriptionLineFromSubscriptionPackageLine(var SalesServiceCommitment: Record "Sales Subscription Line"; ServiceCommitmentPackageLine: Record "Subscription Package Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesSubscriptionLineFromSubscriptionPackageLine(var SalesSubscriptionLine: Record "Sales Subscription Line"; SubscriptionPackageLine: Record "Subscription Package Line")
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

    [IntegrationEvent(false, false)]
    local procedure OnAddAdditionalSalesSubscriptionLinesForSalesLineAfterApplyFilters(var SubscriptionPackage: Record "Subscription Package"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetItemNoForSalesServiceCommitment(var SalesLine: Record "Sales Line"; var ItemNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    local procedure TransferServiceCommitments(var FromSalesLine: Record "Sales Line"; var ToSalesLine: Record "Sales Line")
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
        SalesServiceCommitment2: Record "Sales Subscription Line";
    begin
        SalesServiceCommitment.FilterOnSalesLine(FromSalesLine);
        if SalesServiceCommitment.FindSet() then
            repeat
                SalesServiceCommitment2 := SalesServiceCommitment;
                SalesServiceCommitment2.SetDocumentFields(ToSalesLine."Document Type", ToSalesLine."Document No.", ToSalesLine."Line No.");
                SalesServiceCommitment2."Line No." := 0;
                SalesServiceCommitment2.Validate("Calculation Base Amount", SalesServiceCommitment."Calculation Base Amount");
                SalesServiceCommitment2.Insert(false);
            until SalesServiceCommitment.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Sales Shipment Line", OnCodeOnBeforeProcessItemShptEntry, '', false, false)]
    local procedure RemoveQuantityInvoicedForServiceCommitmentItems(var SalesShipmentLine: Record "Sales Shipment Line")
    begin
        if ItemManagement.IsServiceCommitmentItem(SalesShipmentLine."No.") then begin
            SalesShipmentLine."Quantity Invoiced" := 0;
            SalesShipmentLine."Qty. Invoiced (Base)" := 0;
        end;
    end;

    internal procedure NotifyIfDiscountIsNotTransferredFromSalesLine(var SalesLine: Record "Sales Line")
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
        CustomerContract: Record "Customer Subscription Contract";
        MyNotification: Record "My Notifications";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        Notify: Notification;
        DiscountNotTransferredTxt: Label 'The %1 of %2 %3 has not been transferred to the Sales Subscription Line(s). The %1 is only transferred to Sales Subscription Line, if %4 is set to %5.';
        DontShowAgainActionLbl: Label 'Don''t show again';
    begin
        if SalesServiceCommitment.IsEmpty() then
            exit;
        if not MyNotification.IsEnabled(CustomerContract.GetNotificationIdDiscountIsNotTransferredFromSalesLine()) then
            exit;
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.SetRange(Partner, SalesServiceCommitment.Partner::Customer);
        SalesServiceCommitment.SetFilter("Calculation Base Type", '<>%1', SalesServiceCommitment."Calculation Base Type"::"Document Price And Discount");
        if not SalesServiceCommitment.IsEmpty() then begin
            NotificationLifecycleMgt.RecallNotificationsForRecord(SalesLine.RecordId(), false);
            Notify.Message :=
                StrSubstNo(
                    DiscountNotTransferredTxt,
                    SalesServiceCommitment.FieldCaption("Discount %"),
                    SalesLine.Type,
                    SalesLine."No.",
                    SalesServiceCommitment.FieldCaption("Calculation Base Type"),
                    SalesServiceCommitment."Calculation Base Type"::"Document Price And Discount");
            Notify.AddAction(DontShowAgainActionLbl, Codeunit::"Sales Subscription Line Mgmt.", 'SalesServComDiscPercentHideNotificationForCurrentUser');
            NotificationLifecycleMgt.SendNotification(Notify, SalesLine.RecordId());
        end;
    end;

    internal procedure SalesServComDiscPercentHideNotificationForCurrentUser(Notification: Notification)
    var
        CustomerContract: Record "Customer Subscription Contract";
    begin
        CustomerContract.DontNotifyCurrentUserAgain(CustomerContract.GetNotificationIdDiscountIsNotTransferredFromSalesLine());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddSalesServiceCommitmentsForSalesLine(SalesLine: Record "Sales Line"; SkipAddAdditionalSalesServComm: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowAssignServiceCommitmentsDetermined(SalesLine: Record "Sales Line"; var ServiceCommitmentPackage: Record "Subscription Package"; var ShowAssignServiceCommitments: Boolean)
    begin
    end;

    var
        SessionStore: Codeunit "Session Store";
        ItemManagement: Codeunit "Sub. Contracts Item Management";
        ServiceCommitmentWithNegativeQtyMessageThrown: Boolean;
        ServiceObjectNotCreatedMsg: Label 'For negative quantity the Subscription is not created.';
}