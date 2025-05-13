namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Posting;
using Microsoft.Inventory;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Tracking;
using Microsoft.Warehouse.Activity;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Utilities;

codeunit 8063 "Sales Documents"
{
    SingleInstance = true;

    var
        TempSubscriptionItemSalesLine: Record "Sales Line" temporary;
        SalesServiceCommMgmt: Codeunit "Sales Subscription Line Mgmt.";
        CalledFromContractRenewal: Boolean;

    local procedure DeleteAllTempSubscriptionItemSalesLines()
    begin
        TempSubscriptionItemSalesLine.Reset();
        TempSubscriptionItemSalesLine.DeleteAll(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeDeleteEvent, '', false, false)]
    local procedure SalesHeaderOnBeforeDeleteEvent(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        SalesLine: Record "Sales Line";
        BillingLine: Record "Billing Line";
        InvoiceNo: Code[20];
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;

        if not (Rec."Document Type" in [Enum::"Sales Document Type"::Invoice, Enum::"Sales Document Type"::"Credit Memo"]) then
            exit;

        if Rec."Document Type" = "Sales Document Type"::"Credit Memo" then
            InvoiceNo := GetAppliesToDocNo(Rec);

        if (Rec."Document Type" = Rec."Document Type"::"Credit Memo") and (InvoiceNo <> '') then begin
            SalesLine.SetRange("Document Type", Rec."Document Type");
            SalesLine.SetRange("Document No.", Rec."No.");
            if SalesLine.FindSet() then
                repeat
                    ResetServiceCommitmentAndDeleteBillingLinesForSalesLine(SalesLine);
                until SalesLine.Next() = 0;
        end else
            if AutoResetServiceCommitmentAndDeleteBillingLinesForSalesDocument(Rec."No.") then begin
                SalesLine.SetRange("Document Type", Rec."Document Type");
                SalesLine.SetRange("Document No.", Rec."No.");
                if SalesLine.FindSet() then
                    repeat
                        ResetServiceCommitmentAndDeleteAllBillingLinesForDocument(SalesLine);
                    until SalesLine.Next() = 0;
            end else begin
                BillingLine.SetRange("Document Type", BillingLine."Document Type"::Invoice);
                BillingLine.SetRange("Document No.", Rec."No.");
                ResetSalesDocumentFieldsForBillingLines(BillingLine);
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeDeleteEvent, '', false, false)]
    local procedure SalesLineOnAfterDeleteEvent(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        BillingLine: Record "Billing Line";
        SalesHeader: Record "Sales Header";
        InvoiceNo: Code[20];
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        if not (Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::"Credit Memo"]) then
            exit;

        Rec.InitCachedVar();

        if (not Rec.IsLineAttachedToBillingLine()) or
            (Rec."Recurring Billing from" = 0D) or
            (Rec."Recurring Billing to" = 0D)
        then
            exit;

        if Rec."Document Type" = "Sales Document Type"::"Credit Memo" then
            if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
                InvoiceNo := GetAppliesToDocNo(SalesHeader);

        if (Rec."Document Type" = Rec."Document Type"::"Credit Memo") and (InvoiceNo <> '') then
            ResetServiceCommitmentAndDeleteBillingLinesForSalesLine(Rec)
        else
            if AutoResetServiceCommitmentAndDeleteBillingLinesForSalesDocument(Rec."Document No.") then
                ResetServiceCommitmentAndDeleteAllBillingLinesForDocument(Rec)
            else begin
                FilterBillingLinePerSalesLine(BillingLine, Rec);
                ResetSalesDocumentFieldsForBillingLines(BillingLine);
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterAssignFieldsForNo, '', false, false)]
    local procedure SetVATProductPostingGroupInContractRenewalLineOnAfterAssignFieldsForNo(var SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        GLAccount: Record "G/L Account";
        ServiceObject: Record "Subscription Header";
    begin
        if not SalesLine.IsLineWithServiceObject() then
            exit;

        ServiceObject.Get(SalesLine."No.");
        if ServiceObject."Source No." = '' then
            exit;

        case ServiceObject.Type of
            ServiceObject.Type::Item:
                begin
                    Item.Get(ServiceObject."Source No.");
                    if Item."VAT Prod. Posting Group" <> '' then
                        SalesLine.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                end;
            ServiceObject.Type::"G/L Account":
                begin
                    GLAccount.Get(ServiceObject."Source No.");
                    if GLAccount."VAT Prod. Posting Group" <> '' then
                        SalesLine.Validate("VAT Prod. Posting Group", GLAccount."VAT Prod. Posting Group");
                end;
        end;
    end;

    local procedure ResetServiceCommitmentAndDeleteBillingLinesForSalesLine(SalesLine: Record "Sales Line")
    var
        BillingLine: Record "Billing Line";
    begin
        FilterBillingLinePerSalesLine(BillingLine, SalesLine);
        if BillingLine.FindFirst() then begin
            BillingLine.FindFirstBillingLineForServiceCommitment(BillingLine);
            BillingLine.ResetServiceCommitmentNextBillingDate();
            BillingLine.DeleteAll(false);
        end;
    end;

    local procedure FilterBillingLinePerSalesLine(var BillingLine: Record "Billing Line"; SalesLine: Record "Sales Line")
    begin
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), SalesLine."Document No.", SalesLine."Line No.");
    end;

    local procedure ResetSalesDocumentFieldsForBillingLines(var BillingLine: Record "Billing Line")
    begin
        if not BillingLine.IsEmpty() then begin
            BillingLine.ModifyAll("Document Type", BillingLine."Document Type"::None, false);
            BillingLine.SetRange("Document Type", BillingLine."Document Type"::None);
            BillingLine.ModifyAll("Document No.", '', false);
            BillingLine.ModifyAll("Document Line No.", 0, false);
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeDeleteAfterPosting, '', false, false)]
    local procedure SalesPostOnBeforeSalesLineDeleteAll(var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SkipDelete: Boolean; CommitIsSuppressed: Boolean)
    var
        SalesLine: Record "Sales Line";
        BillingLine: Record "Billing Line";
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"]) then
            exit;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Recurring Billing from", '<>%1', 0D);
        SalesLine.SetFilter("Recurring Billing to", '<>%1', 0D);

        if SalesLine.FindSet() then
            repeat
                FilterBillingLinePerSalesLine(BillingLine, SalesLine);
                MoveBillingLineToBillingLineArchive(BillingLine, SalesHeader, SalesInvoiceHeader, SalesCrMemoHeader);
                BillingLine.DeleteAll(false);
            until SalesLine.Next() = 0;
    end;

    local procedure MoveBillingLineToBillingLineArchive(var BillingLine: Record "Billing Line"; var SalesHeader: Record "Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        BillingLineArchive: Record "Billing Line Archive";
        PostedDocumentNo: Code[20];
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                PostedDocumentNo := SalesInvoiceHeader."No.";
            SalesHeader."Document Type"::"Credit Memo":
                PostedDocumentNo := SalesCrMemoHeader."No.";
        end;
        if BillingLine.FindSet() then
            repeat
                BillingLineArchive.Init();
                BillingLineArchive.TransferFields(BillingLine);
                BillingLineArchive."Document No." := PostedDocumentNo;
                BillingLineArchive."Entry No." := 0;
                BillingLineArchive.Insert(false);
                OnAfterInsertBillingLineArchiveOnMoveBillingLineToBillingLineArchive(BillingLineArchive, BillingLine);
            until BillingLine.Next() = 0;
    end;

    internal procedure MoveBillingLineToBillingLineArchiveForPostingPreview(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SkipDelete: Boolean;
        CommitIsSuppressed: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeMoveBillingLineToBillingLineArchiveForPostingPreview(IsHandled);
        if IsHandled then
            exit;
        if SalesHeader.Get(SalesHeader."Document Type"::Invoice, SalesInvoiceHeader."Pre-Assigned No.") then
            SalesPostOnBeforeSalesLineDeleteAll(SalesHeader, SalesInvoiceHeader, SalesCrMemoHeader, SkipDelete, CommitIsSuppressed);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", OnBeforeInsertSalesOrderLine, '', false, false)]
    local procedure ValidateQuantityOnSalesLineOnBeforeInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line")
    begin
        if SalesServiceCommMgmt.IsSalesLineWithSalesServiceCommitmentsToShip(SalesOrderLine) then
            SalesOrderLine.Validate(Quantity);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Blanket Sales Order to Order", OnBeforeInsertSalesOrderLine, '', false, false)]
    local procedure BlanketSalesOrderToOrderValidateQuantityOnSalesLineOnBeforeInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line")
    begin
        if SalesServiceCommMgmt.IsSalesLineWithSalesServiceCommitmentsToShip(SalesOrderLine) then
            SalesOrderLine.Validate(Quantity);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterValidateEvent, "Qty. to Invoice", false, false)]
    local procedure ClearQtyToInvoiceForServiceCommitmentItemAfterValidateEventQtyToInvoice(var Rec: Record "Sales Line")
    begin
        ClearQtyToInvoiceOnForServiceCommitmentItem(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterInitQtyToInvoice, '', false, false)]
    local procedure ClearQtyToInvoiceForServiceCommitmentItemAfterInitQtyToInvoice(var SalesLine: Record "Sales Line")
    begin
        ClearQtyToInvoiceOnForServiceCommitmentItem(SalesLine);
    end;

    local procedure ClearQtyToInvoiceOnForServiceCommitmentItem(var SalesLine: Record "Sales Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforeClearQtyToInvoiceOnForSubscriptionItem(SalesLine, IsHandled);
        if IsHandled then
            exit;

        if not SalesServiceCommMgmt.IsSalesLineWithServiceCommitmentItem(SalesLine, false) then
            exit;

        SalesLine."Qty. to Invoice" := 0;
        SalesLine."Qty. to Invoice (Base)" := 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterCopyToTempLines, '', false, false)]
    local procedure ResetValueForServiceCommitmentItemsBeforePosting(var TempSalesLine: Record "Sales Line")
    begin
        //The function resets the amounts for Sales Lines with Subscription Items in order to create correct GLentries and Customer Ledger Entries
        //In this context the Subscription Items are never invoiced. The Subscription Items can only be invoiced over Contracts
        DeleteAllTempSubscriptionItemSalesLines();
        if TempSalesLine.FindSet() then
            repeat
                if CheckResetValueForServiceCommitmentItems(TempSalesLine) then begin
                    TempSubscriptionItemSalesLine := TempSalesLine;
                    TempSubscriptionItemSalesLine.Insert(false);
                    TempSalesLine."Unit Price" := 0;
                    TempSalesLine."Line Discount %" := 0;
                    TempSalesLine."Line Discount Amount" := 0;
                    TempSalesLine."Inv. Discount Amount" := 0;
                    TempSalesLine."Inv. Disc. Amount to Invoice" := 0;
                    TempSalesLine.UpdateAmounts();
                    TempSalesLine.Modify(false);
                end;
            until TempSalesLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnPostUpdateOrderLineOnBeforeInitOutstanding, '', false, false)]
    local procedure RestoreValueForServiceCommitmentItemsAfterPosting(var TempSalesLine: Record "Sales Line" temporary; var IsHandled: Boolean)
    begin
        // The function restores the amounts for Sales Lines with Service Commitment Items after posting
        if not TempSubscriptionItemSalesLine.Get(TempSalesLine."Document Type", TempSalesLine."Document No.", TempSalesLine."Line No.") then
            exit;
        TempSalesLine."Unit Price" := TempSubscriptionItemSalesLine."Unit Price";
        TempSalesLine."Line Discount %" := TempSubscriptionItemSalesLine."Line Discount %";
        TempSalesLine."Line Discount Amount" := TempSubscriptionItemSalesLine."Line Discount Amount";
        TempSalesLine."Inv. Discount Amount" := TempSubscriptionItemSalesLine."Inv. Discount Amount";
        TempSalesLine."Inv. Disc. Amount to Invoice" := TempSubscriptionItemSalesLine."Inv. Disc. Amount to Invoice";
        TempSalesLine.UpdateAmounts();
        TempSalesLine.Modify(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeUpdatePostingNo, '', false, false)]
    local procedure SkipInitializingPostingNo(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        //The function makes sure that for a sales document containing only Subscription Items no Posting No. is being reserved
        if SalesHeader.Invoice then
            if AllSalesLinesAreServiceCommitmentItems(SalesHeader) then
                IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnInsertPostedHeadersOnBeforeInsertInvoiceHeader, '', false, false)]
    local procedure SkipInsertingSalesInvoiceHeaderIfOnlyServiceCommitmentItemsExist(SalesHeader: Record "Sales Header"; var IsHandled: Boolean; SalesInvHeader: Record "Sales Invoice Header"; var GenJnlLineDocType: Enum "Gen. Journal Document Type"; var GenJnlLineDocNo: Code[20]; var GenJnlLineExtDocNo: Code[35])
    begin
        //The function makes sure that for a sales document containing only Subscription Items no Posted Invoice is being created
        if SalesHeader.Invoice then
            if AllSalesLinesAreServiceCommitmentItems(SalesHeader) then
                IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnPostSalesLineOnBeforeInsertInvoiceLine, '', false, false)]
    local procedure SkipInsertingSalesInvoiceLineIfServiceCommitmentItemsExist(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    var
        ParentSalesLine: Record "Sales Line";
    begin
        //The function skips inserting Sales Invoice Lines in two cases:
        //When a SalesLine is a Subscription Item
        //When a SalesLine is attached to a Subscription Item (Extended Text)
        IsHandled := SalesLineShouldSkipInvoicing(SalesLine);
        if (SalesLine.Type = SalesLine.Type::" ") and (SalesLine."Attached to Line No." <> 0) then
            if ParentSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Attached to Line No.") then
                IsHandled := SalesLineShouldSkipInvoicing(ParentSalesLine);
        OnAfterSkipInsertingSalesInvoiceLineIfServiceCommitmentItemsExist(SalesHeader, SalesLine, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterInsertShipmentLine, '', false, false)]
    local procedure CreateServiceObjectWithSerialNoOnAfterInsertShipmentLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var SalesShptLine: Record "Sales Shipment Line")
    begin
        //The function creates Subscription for Sales Line with Subscription Lines
        CreateServiceObjectFromSales(SalesHeader, SalesLine, SalesShptLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterSalesShptLineInsert, '', false, false)]
    local procedure CreateServiceObjectWithSerialNoOnAfterSalesShptLineInsert(var SalesShptLine: Record "Sales Shipment Line"; SalesShptHeader: Record "Sales Shipment Header"; SalesOrderLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        //The function creates Subscription for Sales Line with Subscription Lines
        SalesHeader.Get(SalesOrderLine."Document Type", SalesOrderLine."Document No.");
        CreateServiceObjectFromSales(SalesHeader, SalesOrderLine, SalesShptLine);
    end;

    local procedure CreateServiceObjectFromSales(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var SalesShptLine: Record "Sales Shipment Line")
    var
        TempTrackingSpecBuffer: Record "Tracking Specification" temporary;
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
    begin
        //The function creates Subscription for Sales Line with Subscription Lines
        if SalesServiceCommMgmt.IsSalesLineWithSalesServiceCommitmentsToShip(SalesLine, SalesShptLine.Quantity) then begin
            ItemTrackingDocMgt.RetrieveDocumentItemTracking(TempTrackingSpecBuffer, SalesShptLine."Document No.", Database::"Sales Shipment Header", 0);
            TempTrackingSpecBuffer.SetRange("Source Ref. No.", SalesShptLine."Line No.");
            if not TempTrackingSpecBuffer.IsEmpty() then
                CreateServiceObjectFromTrackingSpecification(SalesHeader, SalesLine, TempTrackingSpecBuffer)
            else
                CreateServiceObjectFromSalesLine(SalesHeader, SalesLine);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnPostUpdateOrderLineOnSetDefaultQtyBlank, '', false, false)]
    local procedure UpdateQuantitiesOnPostUpdateOrderLineOnSetDefaultQtyBlank(var TempSalesLine: Record "Sales Line" temporary)
    var
        ShouldModifySalesLine: Boolean;
    begin
        //The function makes sure that Shipped and Invoiced quantities for Subscription Items are properly set
        ShouldModifySalesLine := SalesLineShouldSkipInvoicing(TempSalesLine, true);
        OnUpdateQuantitiesOnPostUpdateOrderLineOnSetDefaultQtyBlankOnAfterCalcShouldModifySalesLine(TempSalesLine, ShouldModifySalesLine);
        if not ShouldModifySalesLine then
            exit;

        TempSalesLine."Quantity Invoiced" := TempSalesLine."Quantity Shipped";
        TempSalesLine."Qty. Invoiced (Base)" := TempSalesLine."Qty. Shipped (Base)";
        TempSalesLine."Qty. Shipped Not Invoiced" := 0;
        TempSalesLine."Qty. Shipped Not Invd. (Base)" := 0;
        TempSalesLine."Shipped Not Invoiced" := 0;
        TempSalesLine."Shipped Not Invoiced (LCY)" := 0;
        TempSalesLine."Shipped Not Inv. (LCY) No VAT" := 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnInsertShipmentLineOnAfterInitQuantityFields, '', false, false)]
    local procedure UpdateInvoicedQtyOnShipmentLineOnBeforeModifySalesShptLine(var SalesShptLine: Record "Sales Shipment Line"; var SalesLine: Record "Sales Line")
    begin
        //The function makes sure that Shipped and Invoiced quantities for Subscription Items are properly set for Sales Shipment Line
        if not SalesLineShouldSkipInvoicing(SalesLine) then
            exit;

        SalesShptLine."Quantity Invoiced" := SalesShptLine.Quantity;
        SalesShptLine."Qty. Invoiced (Base)" := SalesShptLine."Quantity (Base)";
        SalesShptLine."Qty. Shipped Not Invoiced" := 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostUpdateOrderLineModifyTempLine, '', false, false)]
    local procedure SetQtyToInvoiceToZeroOnBeforePostUpdateOrderLineModifyTempLine(var TempSalesLine: Record "Sales Line" temporary)
    var
        SalesLine: Record "Sales Line";
        ShouldModifySalesLine: Boolean;
    begin
        //The function makes sure that amounts are reset to previous values for Sales Lines with Subscription Items
        //The function makes sure that Qty. To Invoice for Subscription Items is properly set to 0 as it should never have the non-zero value
        //The Qty. To Invoice is normally being set to Qty. to Ship at this point
        ShouldModifySalesLine := SalesLineShouldSkipInvoicing(TempSalesLine);
        OnSetQtyToInvoiceToZeroOnBeforePostUpdateOrderLineModifyTempLineOnAfterCalcShouldModifySalesLine(TempSalesLine, ShouldModifySalesLine);
        if not ShouldModifySalesLine then
            exit;

        if SalesLine.Get(TempSalesLine."Document Type", TempSalesLine."Document No.", TempSalesLine."Line No.") then begin
            TempSalesLine."Unit Price" := SalesLine."Unit Price";
            TempSalesLine."Line Discount %" := SalesLine."Line Discount %";
            TempSalesLine."Line Discount Amount" := SalesLine."Line Discount Amount";
            TempSalesLine."Inv. Discount Amount" := SalesLine."Inv. Discount Amount";
            TempSalesLine.UpdateAmounts();
        end;

        if TempSalesLine."Qty. to Ship" <> 0 then
            TempSalesLine.Validate("Qty. to Invoice", 0);
    end;

    local procedure CheckResetValueForServiceCommitmentItems(var TempSalesLine: Record "Sales Line") ResetValueForServiceCommitmentItems: Boolean
    var
        ContractRenewalMgt: Codeunit "Sub. Contract Renewal Mgt.";
        IsHandled: Boolean;
    begin
        ResetValueForServiceCommitmentItems := false;
        OnCheckResetValueForSubscriptionItems(TempSalesLine, ResetValueForServiceCommitmentItems, IsHandled);
        if IsHandled then
            exit(ResetValueForServiceCommitmentItems);
        exit(SalesServiceCommMgmt.IsSalesLineWithServiceCommitmentItem(TempSalesLine, true) or ContractRenewalMgt.IsContractRenewal(TempSalesLine));
    end;

    local procedure CreateServiceObjectFromSalesLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        Item: Record Item;
    begin
        if SalesLine.Type <> Enum::"Sales Line Type"::Item then
            exit;
        if not Item.Get(SalesLine."No.") then
            exit;
        if Item.HasSNSpecificItemTracking() then
            exit;
        CreateServiceObjectFromSalesLine(SalesHeader, SalesLine, '', 0);
    end;

    local procedure CreateServiceObjectFromSalesLine(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; SerialNo: Code[50]; QtyPerSerialNo: Decimal)
    var
        ServiceObject: Record "Subscription Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateSubscriptionHeaderFromSalesLine(ServiceObject, SalesHeader, SalesLine, SerialNo, QtyPerSerialNo, IsHandled);
        if IsHandled then
            exit;

        if SerialNo = '' then
            CreateServiceObject(ServiceObject, SalesHeader, SalesLine, SalesLine."Qty. to Ship", SerialNo)
        else
            CreateServiceObject(ServiceObject, SalesHeader, SalesLine, QtyPerSerialNo, SerialNo);

        CreateSubscriptionLineFromSalesLine(ServiceObject, SalesHeader, SalesLine);
        OnAfterCreateSubscriptionHeaderFromSalesLine(ServiceObject, SalesHeader, SalesLine);
    end;

    local procedure CreateServiceObject(var ServiceObject: Record "Subscription Header"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; Quantity: Decimal; SerialNo: Code[50])
    var
    begin
        ServiceObject.Init();
        ServiceObject.SetHideValidationDialog(true);
        ServiceObject.Type := ServiceObject.Type::Item;
        ServiceObject."Source No." := SalesLine."No.";
        ServiceObject.Validate(Description, SalesLine.Description);
        ServiceObject.Validate(Quantity, Abs(Quantity));

        ServiceObject."Serial No." := SerialNo;
        ServiceObject.Validate("Unit of Measure", SalesLine."Unit of Measure Code");
        SalesLine.TestField(SalesLine."Shipment Date");
        ServiceObject.Validate("Provision Start Date", SalesLine."Shipment Date");
        ServiceObject.Validate("End-User Contact No.", SalesHeader."Sell-to Contact No.");
        ServiceObject.Validate("End-User Customer No.", SalesHeader."Sell-to Customer No.");
        ServiceObject."Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
        ServiceObject."Bill-to Contact No." := SalesHeader."Bill-to Contact No.";
        ServiceObject."Bill-to Contact" := SalesHeader."Bill-to Contact";
        ServiceObject."Bill-to Name" := SalesHeader."Bill-to Name";
        ServiceObject."Bill-to Name 2" := SalesHeader."Bill-to Name 2";
        ServiceObject."Bill-to Address" := SalesHeader."Bill-to Address";
        ServiceObject."Bill-to Address 2" := SalesHeader."Bill-to Address 2";
        ServiceObject."Bill-to City" := SalesHeader."Bill-to City";
        ServiceObject."Bill-to Post Code" := SalesHeader."Bill-to Post Code";
        ServiceObject."Bill-to Country/Region Code" := SalesHeader."Bill-to Country/Region Code";
        ServiceObject."Bill-to County" := SalesHeader."Bill-to County";
        ServiceObject."Ship-to Name" := SalesHeader."Ship-to Name";
        ServiceObject."Ship-to Name 2" := SalesHeader."Ship-to Name 2";
        ServiceObject."Ship-to Code" := SalesHeader."Ship-to Code";
        ServiceObject."Ship-to Address" := SalesHeader."Ship-to Address";
        ServiceObject."Ship-to Address 2" := SalesHeader."Ship-to Address 2";
        ServiceObject."Ship-to City" := SalesHeader."Ship-to City";
        ServiceObject."Ship-to Post Code" := SalesHeader."Ship-to Post Code";
        ServiceObject."Ship-to Country/Region Code" := SalesHeader."Ship-to Country/Region Code";
        ServiceObject."Ship-to County" := SalesHeader."Ship-to County";
        ServiceObject."Ship-to Contact" := SalesHeader."Ship-to Contact";
        ServiceObject."Customer Price Group" := SalesHeader."Customer Price Group";
        ServiceObject."Customer Reference" := SalesHeader."Your Reference";
        ServiceObject."Variant Code" := SalesLine."Variant Code";
        OnCreateSubscriptionHeaderFromSalesLineBeforeInsertSubscriptionHeader(ServiceObject, SalesHeader, SalesLine);
        ServiceObject.Insert(true);
        OnCreateSubscriptionHeaderFromSalesLineAfterInsertSubscriptionHeader(ServiceObject, SalesHeader, SalesLine);
    end;

    local procedure CreateSubscriptionLineFromSalesLine(ServiceObject: Record "Subscription Header"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        SalesSubscriptionLine: Record "Sales Subscription Line";
        SubscriptionLine: Record "Subscription Line";
    begin
        SalesSubscriptionLine.FilterOnSalesLine(SalesLine);
        if SalesSubscriptionLine.FindSet() then
            repeat
                SubscriptionLine.Init();
                SubscriptionLine."Subscription Header No." := ServiceObject."No.";
                SubscriptionLine."Entry No." := 0;

                SubscriptionLine."Customer Price Group" := SalesLine."Customer Price Group";
                if SalesSubscriptionLine."Agreed Sub. Line Start Date" <> 0D then
                    SubscriptionLine.Validate("Subscription Line Start Date", SalesSubscriptionLine."Agreed Sub. Line Start Date")
                else
                    if Format(SalesSubscriptionLine."Sub. Line Start Formula") = '' then
                        SubscriptionLine.Validate("Subscription Line Start Date", SalesLine."Shipment Date")
                    else
                        SubscriptionLine.Validate("Subscription Line Start Date", CalcDate(SalesSubscriptionLine."Sub. Line Start Formula", SalesLine."Shipment Date"));
                SubscriptionLine.CopyFromSalesServiceCommitment(SalesSubscriptionLine);
                if SalesSubscriptionLine.Discount then
                    SubscriptionLine.Validate("Calculation Base Amount", SubscriptionLine."Calculation Base Amount" * -1);

                SubscriptionLine.UpdateNextPriceUpdate();
                SubscriptionLine.CalculateInitialTermUntilDate();
                SubscriptionLine.CalculateInitialServiceEndDate();
                SubscriptionLine.CalculateInitialCancellationPossibleUntilDate();
                SubscriptionLine.SetCurrencyData(SalesHeader."Currency Factor", SalesHeader."Posting Date", SalesHeader."Currency Code");
                SubscriptionLine.SetLCYFields(true);
                SubscriptionLine.SetDefaultDimensions(false);
                SubscriptionLine.GetCombinedDimensionSetID(SalesLine."Dimension Set ID", SubscriptionLine."Dimension Set ID");
                SubscriptionLine."Renewal Term" := SubscriptionLine."Initial Term";
                OnCreateSubscriptionHeaderFromSalesLineBeforeInsertSubscriptionLine(SubscriptionLine, SalesSubscriptionLine, SalesLine);
                SubscriptionLine.CalculateServiceAmount(SubscriptionLine.FieldNo("Discount %"));
                SubscriptionLine.Insert(false);
                OnCreateSubscriptionHeaderFromSalesLineAfterInsertSubscriptionLine(SubscriptionLine, SalesSubscriptionLine, SalesLine);
            until SalesSubscriptionLine.Next() = 0;
    end;

    procedure AllSalesLinesAreServiceCommitmentItems(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        ServiceCommitmentItemFound: Boolean;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '>%1', SalesLine.Type::" ");
        if SalesLine.FindSet() then
            repeat
                if not SalesServiceCommMgmt.IsSalesLineWithServiceCommitmentItem(SalesLine, false) then
                    exit(false)
                else
                    ServiceCommitmentItemFound := true;
            until SalesLine.Next() = 0;

        exit(ServiceCommitmentItemFound);
    end;

    local procedure AutoResetServiceCommitmentAndDeleteBillingLinesForSalesDocument(DocumentNo: Code[20]): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetFilter("Document Type", '%1|%2', Enum::"Rec. Billing Document Type"::Invoice, Enum::"Rec. Billing Document Type"::"Credit Memo");
        BillingLine.SetRange("Document No.", DocumentNo);
        BillingLine.SetRange(Partner, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Billing Template Code", '');
        exit(not BillingLine.IsEmpty());
    end;

    local procedure ResetServiceCommitmentAndDeleteAllBillingLinesForDocument(SalesLine: Record "Sales Line")
    var
        BillingLine: Record "Billing Line";
    begin
        FilterBillingLinePerSalesLine(BillingLine, SalesLine);
        if BillingLine.FindFirst() then begin
            BillingLine.ResetServiceCommitmentNextBillingDate();
            BillingLine.DeleteAll(false);
        end;
    end;

    local procedure CreateServiceObjectFromTrackingSpecification(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var TempTrackingSpecBuffer: Record "Tracking Specification" temporary)
    begin
        if TempTrackingSpecBuffer.FindSet() then
            repeat
                CreateServiceObjectFromSalesLine(SalesHeader, SalesLine, TempTrackingSpecBuffer."Serial No.", TempTrackingSpecBuffer."Quantity (Base)");
            until TempTrackingSpecBuffer.Next() = 0;
        TempTrackingSpecBuffer.Reset();
        TempTrackingSpecBuffer.DeleteAll(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Post", OnUpdateSourceDocumentOnAfterSalesLineModify, '', false, false)]
    local procedure ModifyShipmentDateFromInventoryPickPostingDate(var SalesLine: Record "Sales Line"; WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
    begin
        ServiceContractSetup.Get();
        if not (ServiceContractSetup."Sub. Line Start Date Inv. Pick" = ServiceContractSetup."Sub. Line Start Date Inv. Pick"::"Posting Date") then
            exit;
        if not (WarehouseActivityLine."Activity Type" = WarehouseActivityLine."Activity Type"::"Invt. Pick") then
            exit;
        if SalesServiceCommMgmt.IsSalesLineWithSalesServiceCommitmentsToShip(SalesLine) then begin
            WarehouseActivityHeader.Get(WarehouseActivityLine."Activity Type", WarehouseActivityLine."No.");
            WarehouseActivityHeader.TestField("Posting Date");
            SalesLine."Shipment Date" := WarehouseActivityHeader."Posting Date";
            SalesLine.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeCustLedgEntryInsert, '', false, false)]
    local procedure TransferRecurringBillingMark(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        RecurringBilling: Boolean;
        SubscriptionBillingTok: Label 'Subscription Billing', Locked = true;
        MessageTok: Label 'Subscription Billing Customer Ledger Entry Created', Locked = true;
    begin
        RecurringBilling := GetRecurringBillingField(CustLedgerEntry."Document Type", CustLedgerEntry."Document No.");
        if not RecurringBilling then
            exit;

        CustLedgerEntry."Recurring Billing" := RecurringBilling;

        Session.LogMessage('0000NN3', MessageTok, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SubscriptionBillingTok);
    end;

    local procedure GetRecurringBillingField(DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case DocumentType of
            "Gen. Journal Document Type"::Invoice:
                if SalesInvoiceHeader.Get(DocumentNo) then
                    exit(SalesInvoiceHeader."Recurring Billing");
            "Gen. Journal Document Type"::"Credit Memo":
                if SalesCrMemoHeader.Get(DocumentNo) then
                    exit(SalesCrMemoHeader."Recurring Billing");
            else
                exit(false);
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeConfirmKeepExistingDimensions, '', false, false)]
    local procedure HideConfirmKeepExistingDimensions(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; FieldNo: Integer; OldDimSetID: Integer; var Confirmed: Boolean; var IsHandled: Boolean)
    begin
        if FieldNo <> 0 then
            exit;
        if SalesHeader."Recurring Billing" or CalledFromContractRenewal then begin
            Confirmed := true;
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Line", OnAfterInitFromSalesLine, '', false, false)]
    local procedure SalesInvLineCopyContractNoOnAfterInitFromSalesLine(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line")
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), SalesLine."Document No.", SalesLine."Line No.");
        if not BillingLine.FindFirst() then
            exit;
        SalesInvLine."Subscription Contract No." := BillingLine."Subscription Contract No.";
        SalesInvLine."Subscription Contract Line No." := BillingLine."Subscription Contract Line No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Line", OnAfterInitFromSalesLine, '', false, false)]
    local procedure SalesCrMemoLineCopyContractNoOnAfterInitFromSalesLine(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesLine: Record "Sales Line")
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesLine."Document Type"), SalesLine."Document No.", SalesLine."Line No.");
        if not BillingLine.FindFirst() then
            exit;
        SalesCrMemoLine."Subscription Contract No." := BillingLine."Subscription Contract No.";
        SalesCrMemoLine."Subscription Contract Line No." := BillingLine."Subscription Contract Line No.";
    end;

    internal procedure SetCalledFromContractRenewal(NewCalledFromContractRenewal: Boolean)
    begin
        CalledFromContractRenewal := NewCalledFromContractRenewal;
    end;

    internal procedure IsInvoiceCredited(DocumentNo: Code[20]): Boolean
    var
        BillingLineArchive: Record "Billing Line Archive";
    begin
        if DocumentNo = '' then
            exit(false);
        exit(BillingLineArchive.IsInvoiceCredited("Service Partner"::Customer, DocumentNo));
    end;

    internal procedure GetAppliesToDocNo(SalesHeader: Record "Sales Header"): Code[20]
    var
        BillingLine: Record "Billing Line";
    begin
        if SalesHeader."Applies-to Doc. No." <> '' then
            exit(SalesHeader."Applies-to Doc. No.");
        exit(BillingLine.GetCorrectionDocumentNo("Service Partner"::Customer, SalesHeader."No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Posting Management", OnUpdateSalesLineOnBeforeSalesLineModify, '', false, false)]
    local procedure RevertInvoicedQuantityOnUpdateSalesLineOnBeforeSalesLineModify(var SalesLine: Record "Sales Line")
    var
        ShouldModifySalesLine: Boolean;
    begin
        ShouldModifySalesLine := SalesServiceCommMgmt.IsSalesLineWithServiceCommitmentItemToShip(SalesLine);
        OnRevertInvoicedQuantityOnUpdateSalesLineOnBeforeSalesLineModifyOnAfterCalcShouldModifySalesLine(SalesLine, ShouldModifySalesLine);
        if not ShouldModifySalesLine then
            exit;

        SalesLine."Quantity Invoiced" := SalesLine."Quantity Shipped";
        SalesLine."Qty. Invoiced (Base)" := SalesLine."Qty. Shipped (Base)";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnCopySalesDocLineOnBeforeCopyThisLine, '', false, false)]
    local procedure ClearQtyToInvoiceInSalesLineForServiceCommitmentItem(ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line"; FromSalesDocType: Enum "Sales Document Type From"; var RecalculateLines: Boolean; var CopyThisLine: Boolean; var LinesNotCopied: Integer; var Result: Boolean; var IsHandled: Boolean; var NextLineNo: Integer; DocLineNo: Integer; MoveNegLines: Boolean)
    var
        Item: Record Item;
    begin
        if ToSalesHeader."Recurring Billing" then
            exit;
        if not ToSalesLine.IsSalesDocumentTypeWithServiceCommitments() then
            exit;
        if ToSalesLine.Type <> ToSalesLine.Type::Item then
            exit;
        Item.Get(ToSalesLine."No.");
        if not Item.IsServiceCommitmentItem() then
            exit;

        ToSalesLine."Qty. to Invoice" := 0;
        ToSalesLine."Qty. to Invoice (Base)" := 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Posting Management", OnUpdateSalesLineOnBeforeInitOustanding, '', false, false)]
    local procedure UpdateInvoicedQtyOnSalesLineAfterUndoShipment(var SalesLine: Record "Sales Line")
    begin
        if not SalesServiceCommMgmt.IsSalesLineWithServiceCommitmentItem(SalesLine, false) then
            exit;

        SalesLine."Quantity Invoiced" := SalesLine."Quantity Shipped";
        SalesLine."Qty. Invoiced (Base)" := SalesLine."Qty. Shipped (Base)";
    end;

    procedure SalesLineShouldSkipInvoicing(var SalesLine: Record "Sales Line"): Boolean
    begin
        exit(SalesLineShouldSkipInvoicing(SalesLine, false));
    end;

    procedure SalesLineShouldSkipInvoicing(var SalesLine: Record "Sales Line"; SkipTemporaryCheck: Boolean) Result: Boolean
    begin
        if SalesServiceCommMgmt.IsSalesLineWithServiceCommitmentItem(SalesLine, SkipTemporaryCheck) then
            Result := true;
        OnAfterSalesLineShouldSkipInvoicing(SalesLine, SkipTemporaryCheck, Result);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckResetValueForSubscriptionItems(var TempSalesLine: Record "Sales Line"; var ResetValueForSubscriptionItems: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSubscriptionHeaderFromSalesLineBeforeInsertSubscriptionHeader(var SubscriptionHeader: Record "Subscription Header"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSubscriptionHeaderFromSalesLineAfterInsertSubscriptionHeader(var SubscriptionHeader: Record "Subscription Header"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSubscriptionHeaderFromSalesLineBeforeInsertSubscriptionLine(var SubscriptionLine: Record "Subscription Line"; SalesSubscriptionLine: Record "Sales Subscription Line"; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateSubscriptionHeaderFromSalesLineAfterInsertSubscriptionLine(var SubscriptionLine: Record "Subscription Line"; SalesSubscriptionLine: Record "Sales Subscription Line"; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSubscriptionHeaderFromSalesLine(SubscriptionHeader: Record "Subscription Header"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; SerialNo: Code[50]; QtyPerSerialNo: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSubscriptionHeaderFromSalesLine(SubscriptionHeader: Record "Subscription Header"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertBillingLineArchiveOnMoveBillingLineToBillingLineArchive(var BillingLineArchive: Record "Billing Line Archive"; BillingLine: Record "Billing Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMoveBillingLineToBillingLineArchiveForPostingPreview(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeClearQtyToInvoiceOnForSubscriptionItem(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSalesLineShouldSkipInvoicing(var SalesLine: Record "Sales Line"; SkipTemporaryCheck: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSkipInsertingSalesInvoiceLineIfServiceCommitmentItemsExist(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateQuantitiesOnPostUpdateOrderLineOnSetDefaultQtyBlankOnAfterCalcShouldModifySalesLine(var TempSalesLine: Record "Sales Line" temporary; var ShouldModifySalesLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRevertInvoicedQuantityOnUpdateSalesLineOnBeforeSalesLineModifyOnAfterCalcShouldModifySalesLine(var SalesLine: Record "Sales Line"; var ShouldModifySalesLine: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetQtyToInvoiceToZeroOnBeforePostUpdateOrderLineModifyTempLineOnAfterCalcShouldModifySalesLine(var TempSalesLine: Record "Sales Line" temporary; var ShouldModifySalesLine: Boolean)
    begin
    end;
}