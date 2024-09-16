namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item.Catalog;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;

codeunit 8028 "Usage Based Contr. Subscribers"
{
    Access = Internal;

    var
        UsageBasedDocTypeConv: Codeunit "Usage Based Doc. Type Conv.";
        NotReferenceTypeVendorErr: Label 'The field Usage Data Vendor Reference Entry No. can only be filled for lines with the Reference Type "Vendor".';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Reference Management", 'OnCreateItemReferenceOnBeforeInsert', '', false, false)]
    local procedure SynchronizeUsageDataSupplierReferenceEntryNoOnCreateItemReferenceOnBeforeInsert(var ItemReference: Record "Item Reference"; ItemVendor: Record "Item Vendor")
    begin
        ItemReference."Supplier Ref. Entry No." := ItemVendor."Supplier Ref. Entry No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Vendor", 'OnAfterValidateEvent', 'Supplier Ref. Entry No.', false, false)]
    local procedure SynchronizeItemReferenceUsageDataSupplierReferenceEntryNoOnAfterValidateEvent(var Rec: Record "Item Vendor")
    begin
        SynchronizeItemReferenceUsageDataSupplierReferenceEntryNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Reference", 'OnAfterValidateEvent', 'Supplier Ref. Entry No.', false, false)]
    local procedure SynchronizeItemVendorUsageDataSupplierReferenceEntryNoOnAfterValidateEvent(var Rec: Record "Item Reference")
    begin
        SynchronizeItemVendorUsageDataSupplierReferenceEntryNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Reference", 'OnAfterCreateItemVendor', '', false, false)]
    local procedure SynchronizeItemVendorUsageDataSupplierReferenceEntryNoOnAfterCreateItemVendor(var ItemReference: Record "Item Reference"; ItemVendor: Record "Item Vendor")
    begin
        Commit();
        ItemVendor."Supplier Ref. Entry No." := ItemReference."Supplier Ref. Entry No.";
        ItemVendor.Modify(false);
    end;

    local procedure SynchronizeItemVendorUsageDataSupplierReferenceEntryNo(ItemReference: Record "Item Reference")
    var
        ItemVendor: Record "Item Vendor";
    begin
        if not (ItemReference."Reference Type" = Enum::"Item Reference Type"::Vendor) then
            Error(NotReferenceTypeVendorErr);
        ItemVendor.SetRange("Item No.", ItemReference."Item No.");
        ItemVendor.SetRange("Vendor No.", ItemReference."Reference Type No.");
        ItemVendor.SetRange("Vendor Item No.", ItemReference."Reference No.");
        ItemVendor.ModifyAll("Supplier Ref. Entry No.", ItemReference."Supplier Ref. Entry No.", false);
    end;

    local procedure SynchronizeItemReferenceUsageDataSupplierReferenceEntryNo(ItemVendor: Record "Item Vendor")
    var
        ItemReference: Record "Item Reference";
    begin
        if ItemVendor."Vendor No." = '' then
            exit;
        ItemReference.SetRange("Reference Type", Enum::"Item Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", ItemVendor."Vendor No.");
        ItemReference.SetRange("Item No.", ItemVendor."Item No.");
        ItemReference.SetRange("Reference No.", ItemVendor."Vendor Item No.");
        ItemReference.ModifyAll("Supplier Ref. Entry No.", ItemVendor."Supplier Ref. Entry No.", false);
    end;

    local procedure RemoveDocumentValuesFromUsageDataBilling(UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20])
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(UsageBasedBillingDocType, DocumentNo);
        if UsageDataBilling.IsEmpty() then
            exit;

        if UsageDataBilling.FindSet() then
            repeat
                UsageDataBilling.SaveDocumentValues(Enum::"Usage Based Billing Doc. Type"::None, '', 0, 0);
            until UsageDataBilling.Next() = 0;
    end;

    local procedure UsageDataBillingWithDocumentExist(var UsageDataBilling: Record "Usage Data Billing"; GetBillingDocumentTypeFromSalesDocumentType: Enum "Usage Based Billing Doc. Type"; DocumentNo: Code[20]): Boolean
    begin
        UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(GetBillingDocumentTypeFromSalesDocumentType, DocumentNo);
        exit(not UsageDataBilling.IsEmpty());
    end;

    internal procedure CreateContractInvoicesFromUsageDataImport(ServicePartner: Enum "Service Partner"; ContractNoFilter: Text; ContractLineFilter: Text; BillingRhytmFilter: Text)
    begin
        case ServicePartner of
            ServicePartner::Customer:
                RunCreateCustomerBillingDocuments(ServicePartner, ContractNoFilter, ContractLineFilter, BillingRhytmFilter);
            ServicePartner::Vendor:
                RunCreateVendorBillingDocuments(ServicePartner, ContractNoFilter, ContractLineFilter, BillingRhytmFilter);
        end;
    end;

    local procedure RunCreateCustomerBillingDocuments(ServicePartner: Enum "Service Partner"; ContractNoFilter: Text; ContractLineFilter: Text; BillingRhytmFilter: Text)
    var
        CreateBillingDocumentPage: Page "Create Usage B. Cust. B. Docs";
    begin
        CreateBillingDocumentPage.SetContractData(ServicePartner, ContractNoFilter, ContractLineFilter, BillingRhytmFilter);
        CreateBillingDocumentPage.RunModal();
    end;

    local procedure RunCreateVendorBillingDocuments(ServicePartner: Enum "Service Partner"; ContractNoFilter: Text; ContractLineFilter: Text; BillingRhytmFilter: Text)
    var
        CreateBillingDocumentPage: Page "Create Usage B. Vend. B. Docs";
    begin
        CreateBillingDocumentPage.SetContractData(ServicePartner, ContractNoFilter, ContractLineFilter, BillingRhytmFilter);
        CreateBillingDocumentPage.RunModal();
    end;

    local procedure CreateAdditionalUsageDataBilling(UsageDataBilling: Record "Usage Data Billing")
    var
        NewUsageDataBilling: Record "Usage Data Billing";
    begin
        NewUsageDataBilling := UsageDataBilling;
        NewUsageDataBilling."Document Type" := Enum::"Usage Based Billing Doc. Type"::None;
        NewUsageDataBilling."Document No." := '';
        NewUsageDataBilling."Document Line No." := 0;
        NewUsageDataBilling."Billing Line Entry No." := 0;
        NewUsageDataBilling."Entry No." := 0;
        NewUsageDataBilling.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure RemoveDocumentNoFromUsageDataBillingOnAfterDeleteSalesInvHeader(var Rec: Record "Sales Invoice Header")
    begin
        if not Rec."Recurring Billing" then
            exit;
        RemoveDocumentValuesFromUsageDataBilling(Enum::"Usage Based Billing Doc. Type"::"Posted Invoice", Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure RemovePurchDocumentNoFromUsageDataBillingOnAfterDeleteEvent(var Rec: Record "Purch. Inv. Header")
    begin
        if not Rec."Recurring Billing" then
            exit;
        RemoveDocumentValuesFromUsageDataBilling(Enum::"Usage Based Billing Doc. Type"::"Posted Invoice", Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure RemoveDocumentNoFromUsageDataBillingOnAfterDeleteEventSalesHeader(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;
        if not Rec."Recurring Billing" then
            exit;

        UsageDataBilling.SetRange("Document Type", UsageBasedDocTypeConv.ConvertSalesDocTypeToUsageBasedBillingDocType(Rec."Document Type"));
        UsageDataBilling.SetRange("Document No.", Rec."No.");
        if UsageDataBilling.IsEmpty() then
            exit;

        RemoveDocumentValuesFromUsageDataBilling(Enum::"Usage Based Billing Doc. Type"::Invoice, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterDeleteEvent', '', false, false)]
    local procedure RemoveDocumentNoFromUsageDataBillingOnAfterDeleteEventPurchaseHeader(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;
        if not Rec."Recurring Billing" then
            exit;

        UsageDataBilling.SetRange("Document Type", UsageBasedDocTypeConv.ConvertPurchaseDocTypeToUsageBasedBillingDocType(Rec."Document Type"));
        UsageDataBilling.SetRange("Document No.", Rec."No.");
        if UsageDataBilling.IsEmpty() then
            exit;

        RemoveDocumentValuesFromUsageDataBilling(Enum::"Usage Based Billing Doc. Type"::Invoice, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure UpdateDocumentNoOnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        if not SalesHeader."Recurring Billing" then
            exit;
        if not UsageDataBillingWithDocumentExist(UsageDataBilling, UsageBasedDocTypeConv.ConvertSalesDocTypeToUsageBasedBillingDocType(SalesHeader."Document Type"), SalesHeader."No.") then
            exit;

        if UsageDataBilling.FindSet() then
            repeat
                if SalesCrMemoHdrNo <> '' then begin
                    UsageDataBilling.SaveDocumentValues(Enum::"Usage Based Billing Doc. Type"::"Posted Credit Memo", SalesCrMemoHdrNo, UsageDataBilling."Document Line No.", UsageDataBilling."Billing Line Entry No.");
                    CreateAdditionalUsageDataBilling(UsageDataBilling);
                end
                else
                    UsageDataBilling.SaveDocumentValues(Enum::"Usage Based Billing Doc. Type"::"Posted Invoice", SalesInvHdrNo, UsageDataBilling."Document Line No.", UsageDataBilling."Billing Line Entry No.");
            until UsageDataBilling.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure UpdateDocumentNoOnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        if not PurchaseHeader."Recurring Billing" then
            exit;
        if not UsageDataBillingWithDocumentExist(UsageDataBilling, UsageBasedDocTypeConv.ConvertPurchaseDocTypeToUsageBasedBillingDocType(PurchaseHeader."Document Type"), PurchaseHeader."No.") then
            exit;
        if UsageDataBilling.FindSet() then
            repeat
                if PurchCrMemoHdrNo <> '' then begin
                    UsageDataBilling.SaveDocumentValues(Enum::"Usage Based Billing Doc. Type"::"Posted Credit Memo", PurchCrMemoHdrNo, UsageDataBilling."Document Line No.", UsageDataBilling."Billing Line Entry No.");
                    CreateAdditionalUsageDataBilling(UsageDataBilling);
                end
                else
                    UsageDataBilling.SaveDocumentValues(Enum::"Usage Based Billing Doc. Type"::"Posted Invoice", PurchInvHdrNo, UsageDataBilling."Document Line No.", UsageDataBilling."Billing Line Entry No.");
            until UsageDataBilling.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Documents", 'OnAfterInsertBillingLineArchiveOnMoveBillingLineToBillingLineArchive', '', false, false)]
    local procedure UpdateUsageDataBillingWithBillingArchiveLineSalesDocuments(var BillingLineArchive: Record "Billing Line Archive"; BillingLine: Record "Billing Line")
    var
        UsageDataBilling: Record "Usage Data Billing";
        ServiceCommitment: Record "Service Commitment";
    begin
        if not ServiceCommitment.Get(BillingLine."Service Commitment Entry No.") then
            exit;
        if not ServiceCommitment."Usage Based Billing" then
            exit;
        UsageDataBilling.SetRange("Billing Line Entry No.", BillingLine."Entry No.");
        UsageDataBilling.ModifyAll("Billing Line Entry No.", BillingLineArchive."Entry No.", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase Documents", 'OnAfterInsertBillingLineArchiveOnMoveBillingLineToBillingLineArchive', '', false, false)]
    local procedure UpdateUsageDataBillingWithBillingArchiveLinePurchaseDocuments(var BillingLineArchive: Record "Billing Line Archive"; BillingLine: Record "Billing Line")
    var
        UsageDataBilling: Record "Usage Data Billing";
        ServiceCommitment: Record "Service Commitment";
    begin
        if not ServiceCommitment.Get(BillingLine."Service Commitment Entry No.") then
            exit;
        if not ServiceCommitment."Usage Based Billing" then
            exit;
        UsageDataBilling.SetRange("Billing Line Entry No.", BillingLine."Entry No.");
        UsageDataBilling.ModifyAll("Billing Line Entry No.", BillingLineArchive."Entry No.", false);
    end;
}
