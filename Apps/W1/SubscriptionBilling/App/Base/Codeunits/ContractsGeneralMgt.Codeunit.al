namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Foundation.Attachment;

codeunit 8059 "Contracts General Mgt."
{
    Access = Internal;
    SingleInstance = true;

    procedure OpenContractCard(Partner: Enum "Service Partner"; ContractNo: Code[20])
    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
    begin
        if ContractNo = '' then
            exit;

        case Partner of
            Partner::Customer:
                begin
                    CustomerContract.Get(ContractNo);
                    CustomerContract.SetRecFilter();
                    Page.Run(Page::"Customer Contract", CustomerContract);
                end;
            Partner::Vendor:
                begin
                    VendorContract.Get(ContractNo);
                    VendorContract.SetRecFilter();
                    Page.Run(Page::"Vendor Contract", VendorContract);
                end;
        end;
    end;

    procedure OpenPartnerCard(Partner: Enum "Service Partner"; PartnerNo: Code[20])
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        if PartnerNo = '' then
            exit;

        case Partner of
            Partner::Customer:
                begin
                    Customer.Get(PartnerNo);
                    Page.RunModal(Page::"Customer Card", Customer);
                end;
            Partner::Vendor:
                begin
                    Vendor.Get(PartnerNo);
                    Page.RunModal(Page::"Vendor Card", Vendor);
                end;
        end;
    end;

    procedure GetContractDescription(Partner: Enum "Service Partner"; ContractNo: Code[20]): Text
    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
    begin
        if ContractNo = '' then
            exit;

        case Partner of
            Partner::Customer:
                if CustomerContract.Get(ContractNo) then
                    exit(CustomerContract.GetDescription());
            Partner::Vendor:
                if VendorContract.Get(ContractNo) then
                    exit(VendorContract.GetDescription());
        end;
    end;

    procedure GetPartnerName(Partner: Enum "Service Partner"; PartnerNo: Code[20]): Text
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        if PartnerNo = '' then
            exit;
        case Partner of
            Partner::Customer:
                if Customer.Get(PartnerNo) then
                    exit(Customer.Name);
            Partner::Vendor:
                if Vendor.Get(PartnerNo) then
                    exit(Vendor.Name);
        end;
    end;

    procedure HasConnectionToContractLine(ContractNo: Code[20]; ContractLineNo: Integer): Boolean
    begin
        exit((ContractNo <> '') and (ContractLineNo <> 0));
    end;

    procedure ShowBillingLines(ContractNo: Code[20]; ContractLineNo: Integer; ServicePartner: Enum "Service Partner")
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnContractLine(ServicePartner, ContractNo, ContractLineNo);
        Page.Run(0, BillingLine);
    end;

    procedure ShowBillingLinesForDocumentLine(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; DocumentNoLineNo: Integer)
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(DocumentType), DocumentNo, DocumentNoLineNo);
        Page.Run(0, BillingLine);
    end;

    procedure ShowArchivedBillingLinesForServiceCommitment(ServiceCommitmentEntryNo: Integer)
    var
        BillingLineArchive: Record "Billing Line Archive";
    begin
        BillingLineArchive.FilterBillingLineArchiveOnServiceCommitment(ServiceCommitmentEntryNo);
        Page.Run(0, BillingLineArchive);
    end;

    procedure ShowArchivedBillingLines(ContractNo: Code[20]; ContractLineNo: Integer; ServicePartner: Enum "Service Partner"; RecurringBillingDocumentType: Enum "Rec. Billing Document Type"; DocumentNo: Code[20])
    var
        BillingLineArchive: Record "Billing Line Archive";
    begin
        BillingLineArchive.FilterBillingLineArchiveOnDocument(RecurringBillingDocumentType, DocumentNo);
        BillingLineArchive.FilterBillingLineArchiveOnContractLine(ServicePartner, ContractNo, ContractLineNo);
        Page.Run(0, BillingLineArchive);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Line", OnAfterDeleteEvent, '', false, false)]
    local procedure SalesInvoiceLineDeleteArchivedBillingLines(var Rec: Record "Sales Invoice Line")
    var
        BillingLineArchive: Record "Billing Line Archive";
        CustomerContactLine: Record "Customer Contract Line";
    begin
        if Rec.IsTemporary() then
            exit;

        BillingLineArchive.SetRange(Partner, Enum::"Service Partner"::Customer);
        BillingLineArchive.SetRange("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
        BillingLineArchive.SetRange("Document No.", Rec."Document No.");
        if BillingLineArchive.FindSet() then
            repeat
                if not CustomerContactLine.Get(BillingLineArchive."Contract No.", BillingLineArchive."Contract Line No.") then
                    BillingLineArchive.Delete(false);
            until BillingLineArchive.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Inv. Line", OnAfterDeleteEvent, '', false, false)]
    local procedure PurchaseInvoiceLineDeleteArchivedBillingLines(var Rec: Record "Purch. Inv. Line")
    var
        BillingLineArchive: Record "Billing Line Archive";
        VendorContactLine: Record "Vendor Contract Line";
    begin
        if Rec.IsTemporary() then
            exit;

        BillingLineArchive.SetRange(Partner, Enum::"Service Partner"::Vendor);
        BillingLineArchive.SetRange("Document Type", Enum::"Rec. Billing Document Type"::Invoice);
        BillingLineArchive.SetRange("Document No.", Rec."Document No.");
        if BillingLineArchive.FindSet() then
            repeat
                if not VendorContactLine.Get(BillingLineArchive."Contract No.", BillingLineArchive."Contract Line No.") then
                    BillingLineArchive.Delete(false);
            until BillingLineArchive.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Cr.Memo Line", OnAfterDeleteEvent, '', false, false)]
    local procedure SalesCrMemoLineDeleteArchivedBillingLines(var Rec: Record "Sales Cr.Memo Line")
    var
        BillingLineArchive: Record "Billing Line Archive";
        CustomerContactLine: Record "Customer Contract Line";
    begin
        if Rec.IsTemporary() then
            exit;

        BillingLineArchive.SetRange(Partner, Enum::"Service Partner"::Customer);
        BillingLineArchive.SetRange("Document Type", Enum::"Rec. Billing Document Type"::"Credit Memo");
        BillingLineArchive.SetRange("Document No.", Rec."Document No.");
        if BillingLineArchive.FindSet() then
            repeat
                if not CustomerContactLine.Get(BillingLineArchive."Contract No.", BillingLineArchive."Contract Line No.") then
                    BillingLineArchive.Delete(false);
            until BillingLineArchive.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Cr. Memo Line", OnAfterDeleteEvent, '', false, false)]
    local procedure PurchCrMemoLineDeleteArchivedBillingLines(var Rec: Record "Purch. Cr. Memo Line")
    var
        BillingLineArchive: Record "Billing Line Archive";
        VendorContactLine: Record "Vendor Contract Line";
    begin
        if Rec.IsTemporary() then
            exit;

        BillingLineArchive.SetRange(Partner, Enum::"Service Partner"::Vendor);
        BillingLineArchive.SetRange("Document Type", Enum::"Rec. Billing Document Type"::"Credit Memo");
        BillingLineArchive.SetRange("Document No.", Rec."Document No.");
        if BillingLineArchive.FindSet() then
            repeat
                if not VendorContactLine.Get(BillingLineArchive."Contract No.", BillingLineArchive."Contract Line No.") then
                    BillingLineArchive.Delete(false);
            until BillingLineArchive.Next() = 0;
    end;

    procedure ShowUnpostedSalesDocument(SalesDocumentType: Enum "Sales Document Type"; CustomerContract: Record "Customer Contract")
    var
        SalesHeader: Record "Sales Header";
    begin
        MarkSalesHeaderFromBillingLine(SalesHeader, SalesDocumentType, CustomerContract."No.");
        case SalesDocumentType of
            SalesDocumentType::Invoice:
                Page.Run(Page::"Sales Invoice List", SalesHeader);
            SalesDocumentType::"Credit Memo":
                Page.Run(Page::"Sales Credit Memos", SalesHeader);
        end;
    end;

    local procedure MarkSalesHeaderFromBillingLine(var SalesHeader: Record "Sales Header"; SalesDocumentType: Enum "Sales Document Type"; CustomerContractNo: Code[20])
    var
        TempSalesHeader: Record "Sales Header" temporary;
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetRange("Document Type", BillingLine.GetBillingDocumentTypeFromSalesDocumentType(SalesDocumentType));
        BillingLine.SetRange(Partner, Enum::"Service Partner"::Customer);
        BillingLine.SetRange("Contract No.", CustomerContractNo);
        if BillingLine.FindSet() then
            repeat
                if not TempSalesHeader.Get(SalesDocumentType, BillingLine."Document No.") then begin
                    SalesHeader.Get(SalesDocumentType, BillingLine."Document No.");
                    SalesHeader.Mark(true);
                    TempSalesHeader := SalesHeader;
                    TempSalesHeader.Insert(false);
                end;
            until BillingLine.Next() = 0;
        SalesHeader.MarkedOnly(true);
    end;

    procedure ShowPostedSalesInvoices(CustomerContract: Record "Customer Contract")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
    begin
        SalesInvoiceLine.SetRange("Contract No.", CustomerContract."No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                if not TempSalesInvoiceHeader.Get(SalesInvoiceLine."Document No.") then begin
                    SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
                    SalesInvoiceHeader.Mark(true);
                    TempSalesInvoiceHeader := SalesInvoiceHeader;
                    TempSalesInvoiceHeader.Insert(false);
                end;
            until SalesInvoiceLine.Next() = 0;

        SalesInvoiceHeader.MarkedOnly(true);
        Page.Run(Page::"Posted Sales Invoices", SalesInvoiceHeader);
    end;

    procedure ShowPostedSalesCreditMemos(CustomerContract: Record "Customer Contract")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempSalesCrMemoHeader: Record "Sales Cr.Memo Header" temporary;
    begin
        SalesCrMemoLine.SetRange("Contract No.", CustomerContract."No.");
        if SalesCrMemoLine.FindSet() then
            repeat
                if not TempSalesCrMemoHeader.Get(SalesCrMemoLine."Document No.") then begin
                    SalesCrMemoHeader.Get(SalesCrMemoLine."Document No.");
                    SalesCrMemoHeader.Mark(true);
                    TempSalesCrMemoHeader := SalesCrMemoHeader;
                    TempSalesCrMemoHeader.Insert(false);
                end;
            until SalesCrMemoLine.Next() = 0;

        SalesCrMemoHeader.MarkedOnly(true);
        Page.Run(Page::"Posted Sales Credit Memos", TempSalesCrMemoHeader);
    end;


    procedure ShowPostedPurchaseInvoices(VendorContract: Record "Vendor Contract")
    var
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        TempPurchaseInvoiceHeader: Record "Purch. Inv. Header" temporary;
    begin
        PurchaseInvoiceLine.SetRange("Contract No.", VendorContract."No.");
        if PurchaseInvoiceLine.FindSet() then
            repeat
                if not TempPurchaseInvoiceHeader.Get(PurchaseInvoiceLine."Document No.") then begin
                    PurchaseInvoiceHeader.Get(PurchaseInvoiceLine."Document No.");
                    PurchaseInvoiceHeader.Mark(true);
                    TempPurchaseInvoiceHeader := PurchaseInvoiceHeader;
                    TempPurchaseInvoiceHeader.Insert(false);
                end;
            until PurchaseInvoiceLine.Next() = 0;

        PurchaseInvoiceHeader.MarkedOnly(true);
        Page.Run(Page::"Posted Purchase Invoices", PurchaseInvoiceHeader);
    end;

    procedure ShowPostedPurchaseCreditMemos(VendorContract: Record "Vendor Contract")
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        TempPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr." temporary;
    begin
        PurchCrMemoLine.SetRange("Contract No.", VendorContract."No.");
        if PurchCrMemoLine.FindSet() then
            repeat
                if not TempPurchCrMemoHeader.Get(PurchCrMemoLine."Document No.") then begin
                    PurchCrMemoHeader.Get(PurchCrMemoLine."Document No.");
                    PurchCrMemoHeader.Mark(true);
                    TempPurchCrMemoHeader := PurchCrMemoHeader;
                    TempPurchCrMemoHeader.Insert(false);
                end;
            until PurchCrMemoLine.Next() = 0;

        PurchCrMemoHeader.MarkedOnly(true);
        Page.Run(Page::"Posted Purchase Credit Memos", TempPurchCrMemoHeader);
    end;

    procedure ShowUnpostedPurchDocument(PurchDocumentType: Enum "Purchase Document Type"; VendorContract: Record "Vendor Contract")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        MarkPurchaseHeaderFromBillingLine(PurchaseHeader, PurchDocumentType, VendorContract."No.");
        case PurchDocumentType of
            PurchDocumentType::Invoice:
                Page.Run(Page::"Purchase Invoices", PurchaseHeader);
            PurchDocumentType::"Credit Memo":
                Page.Run(Page::"Purchase Credit Memos", PurchaseHeader);
        end;
    end;

    local procedure MarkPurchaseHeaderFromBillingLine(var PurchaseHeader: Record "Purchase Header"; PurchDocumentType: Enum "Purchase Document Type"; VendorContractNo: Code[20])
    var
        TempPurchaseHeader: Record "Purchase Header" temporary;
        BillingLine: Record "Billing Line";
    begin
        BillingLine.SetRange("Document Type", BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(PurchDocumentType));
        BillingLine.SetRange(Partner, Enum::"Service Partner"::Vendor);
        BillingLine.SetRange("Contract No.", VendorContractNo);
        if BillingLine.FindSet() then
            repeat
                if not TempPurchaseHeader.Get(PurchDocumentType, BillingLine."Document No.") then begin
                    PurchaseHeader.Get(PurchDocumentType, BillingLine."Document No.");
                    PurchaseHeader.Mark(true);
                    TempPurchaseHeader := PurchaseHeader;
                    TempPurchaseHeader.Insert(false);
                end;
            until BillingLine.Next() = 0;
        PurchaseHeader.MarkedOnly(true);
    end;

    internal procedure BillingLineExists(ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineNo: Integer): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        FilterBillingLineOnContractLine(BillingLine, ServicePartner, ContractNo, ContractLineNo);
        exit(not BillingLine.IsEmpty);
    end;

    internal procedure FilterBillingLineOnContractLine(var BillingLine: Record "Billing Line"; ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLineNo: Integer): Boolean
    begin
        BillingLine.SetRange(Partner, ServicePartner);
        BillingLine.SetRange("Contract No.", ContractNo);
        BillingLine.SetRange("Contract Line No.", ContractLineNo);
    end;

    internal procedure TestMergingServiceObjects(ServiceObject: Record "Service Object"; PrevServiceObject: Record "Service Object")
    begin
        ServiceObject.TestField("Item No.", PrevServiceObject."Item No.");
        ServiceObject.TestField("Unit of Measure", PrevServiceObject."Unit of Measure");
        ServiceObject.TestField("End-User Contact No.", PrevServiceObject."End-User Contact No.");
        ServiceObject.TestField("End-User Customer No.", PrevServiceObject."End-User Customer No.");
        ServiceObject.TestField("Bill-to Customer No.", PrevServiceObject."Bill-to Customer No.");
        ServiceObject.TestField("Bill-to Contact No.", PrevServiceObject."Bill-to Contact No.");
        ServiceObject.TestField("Bill-to Contact", PrevServiceObject."Bill-to Contact");
        ServiceObject.TestField("Bill-to Name", PrevServiceObject."Bill-to Name");
        ServiceObject.TestField("Bill-to Name 2", PrevServiceObject."Bill-to Name 2");
        ServiceObject.TestField("Bill-to Address", PrevServiceObject."Bill-to Address");
        ServiceObject.TestField("Bill-to Address 2", PrevServiceObject."Bill-to Address 2");
        ServiceObject.TestField("Bill-to City", PrevServiceObject."Bill-to City");
        ServiceObject.TestField("Bill-to Post Code", PrevServiceObject."Bill-to Post Code");
        ServiceObject.TestField("Bill-to Country/Region Code", PrevServiceObject."Bill-to Country/Region Code");
        ServiceObject.TestField("Bill-to County", PrevServiceObject."Bill-to County");
        ServiceObject.TestField("Ship-to Name", PrevServiceObject."Ship-to Name");
        ServiceObject.TestField("Ship-to Name 2", PrevServiceObject."Ship-to Name 2");
        ServiceObject.TestField("Ship-to Code", PrevServiceObject."Ship-to Code");
        ServiceObject.TestField("Ship-to Address", PrevServiceObject."Ship-to Address");
        ServiceObject.TestField("Ship-to Address 2", PrevServiceObject."Ship-to Address 2");
        ServiceObject.TestField("Ship-to City", PrevServiceObject."Ship-to City");
        ServiceObject.TestField("Ship-to Post Code", PrevServiceObject."Ship-to Post Code");
        ServiceObject.TestField("Ship-to Country/Region Code", PrevServiceObject."Ship-to Country/Region Code");
        ServiceObject.TestField("Ship-to County", PrevServiceObject."Ship-to County");
        ServiceObject.TestField("Ship-to Contact", PrevServiceObject."Ship-to Contact");
        ServiceObject.TestField("Customer Price Group", PrevServiceObject."Customer Price Group");
    end;

    internal procedure TestMergingServiceCommitments(ServiceCommitment: Record "Service Commitment"; PrevServiceCommitment: Record "Service Commitment")
    begin
        ServiceCommitment.TestField("Service End Date", PrevServiceCommitment."Service End Date");
        ServiceCommitment.TestField("Calculation Base Amount", PrevServiceCommitment."Calculation Base Amount");
        ServiceCommitment.TestField("Calculation Base %", PrevServiceCommitment."Calculation Base %");
        ServiceCommitment.TestField(Price, PrevServiceCommitment.Price);
        ServiceCommitment.TestField("Billing Base Period", PrevServiceCommitment."Billing Base Period");
        ServiceCommitment.TestField("Invoicing via", PrevServiceCommitment."Invoicing via");
        ServiceCommitment.TestField("Invoicing Item No.", PrevServiceCommitment."Invoicing Item No.");
        ServiceCommitment.TestField(Partner, PrevServiceCommitment.Partner);
        ServiceCommitment.TestField("Contract No.", PrevServiceCommitment."Contract No.");
        ServiceCommitment.TestField("Notice Period", PrevServiceCommitment."Notice Period");
        ServiceCommitment.TestField("Initial Term", PrevServiceCommitment."Initial Term");
        ServiceCommitment.TestField("Extension Term", PrevServiceCommitment."Extension Term");
        ServiceCommitment.TestField("Billing Rhythm", PrevServiceCommitment."Billing Rhythm");
        ServiceCommitment.TestField("Service Object Customer No.", PrevServiceCommitment."Service Object Customer No.");
        ServiceCommitment.TestField("Customer Price Group", PrevServiceCommitment."Customer Price Group");
    end;

#if not CLEAN25
    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", OnBeforeDrillDown, '', false, false)]
    local procedure SetServiceObjectAsRecRef(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        ServiceObject: Record "Service Object";
        CustomerContract: Record "Customer Contract";
    begin
        case DocumentAttachment."Table ID" of
            Database::"Service Object":
                begin
                    RecRef.Open(Database::"Service Object");
                    if ServiceObject.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(ServiceObject);
                end;
            Database::"Customer Contract":
                begin
                    RecRef.Open(Database::"Customer Contract");
                    if CustomerContract.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(CustomerContract);
                end;
        end;
    end;
#endif
    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", OnAfterOpenForRecRef, '', false, false)]
    local procedure FilterDocumentAttachmentOnRecRefPrimaryKey(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        DocumentAttachment.SetRange("Table ID", RecRef.Number);

        case RecRef.Number of
            Database::"Service Object",
            Database::"Customer Contract":
                begin
                    FieldRef := RecRef.Field(3); // "No." = 3
                    RecNo := FieldRef.Value();
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", OnAfterInitFieldsFromRecRef, '', false, false)]
    local procedure InitDocumentAttachmentFields(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        case RecRef.Number of
            Database::"Service Object",
            Database::"Customer Contract":
                begin
                    FieldRef := RecRef.Field(3); // "No." = 3
                    RecNo := FieldRef.Value();
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;

    internal procedure DeleteDocumentAttachmentForNo(TableId: Integer; RecNo: Code[20])
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        DocumentAttachment.SetRange("Table ID", TableId);
        DocumentAttachment.SetRange("No.", RecNo);
        if not DocumentAttachment.IsEmpty() then
            DocumentAttachment.DeleteAll(false);
    end;
}