namespace Microsoft.Foundation.DataSearch;

using Microsoft.Assembly.Document;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Projects.Project.Job;
using Microsoft.Utilities;
using Microsoft.Projects.Project.Planning;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Reminder;
using Microsoft.Service.Contract;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Warehouse.Activity;
using Microsoft.Warehouse.Activity.History;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Warehouse.Document;
using Microsoft.Warehouse.History;
using System.Reflection;

codeunit 2685 "Data Search Object Mapping"
{
    SingleInstance = true;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure GetListPageNo(TableNo: Integer; TableSubType: Integer): Integer
    var
        TableMetaData: Record "Table Metadata";
        DataSearchEvents: Codeunit "Data Search Events";
        SalesDocumentType: Enum "Sales Document Type";
        PurchaseDocumentType: Enum "Purchase Document Type";
        ServiceDocumentType: Enum "Service Document Type";
        ServiceContractType: Enum "Service Contract Type";
        ParentTableNo: Integer;
        PageNo: Integer;
    begin

        ParentTableNo := GetParentTableNo(TableNo);
        if (ParentTableNo > 0) and (ParentTableNo <> TableNo) then
            TableNo := ParentTableNo;

        case TableNo of
            Database::"Gen. Journal Line":
                PageNo := GetGenJournalPageNo(TableSubType);
            Database::"Sales Header":
                case TableSubType of
                    SalesDocumentType::"Blanket Order".AsInteger():
                        PageNo := Page::"Blanket Sales Orders";
                    SalesDocumentType::"Credit Memo".AsInteger():
                        PageNo := Page::"Sales Credit Memos";
                    SalesDocumentType::Invoice.AsInteger():
                        PageNo := Page::"Sales Invoice List";
                    SalesDocumentType::Order.AsInteger():
                        PageNo := Page::"Sales Order List";
                    SalesDocumentType::Quote.AsInteger():
                        PageNo := Page::"Sales Quotes";
                    SalesDocumentType::"Return Order".AsInteger():
                        PageNo := Page::"Sales Return Order List";
                end;
            Database::"Purchase Header":
                case TableSubType of
                    PurchaseDocumentType::"Blanket Order".AsInteger():
                        PageNo := Page::"Blanket Purchase Orders";
                    PurchaseDocumentType::"Credit Memo".AsInteger():
                        PageNo := Page::"Purchase Credit Memos";
                    PurchaseDocumentType::Invoice.AsInteger():
                        PageNo := Page::"Purchase Invoices";
                    PurchaseDocumentType::Order.AsInteger():
                        PageNo := Page::"Purchase Order List";
                    PurchaseDocumentType::Quote.AsInteger():
                        PageNo := Page::"Purchase Quotes";
                    PurchaseDocumentType::"Return Order".AsInteger():
                        PageNo := Page::"Purchase Return Order List";
                end;
            Database::"Service Header":
                case TableSubType of
                    ServiceDocumentType::"Credit Memo".AsInteger():
                        PageNo := Page::"Service Credit Memos";
                    ServiceDocumentType::Invoice.AsInteger():
                        PageNo := Page::"Service Invoices";
                    ServiceDocumentType::Order.AsInteger():
                        PageNo := Page::"Service Orders";
                    ServiceDocumentType::Quote.AsInteger():
                        PageNo := Page::"Service Quotes";
                end;
            Database::"Service Contract Header":
                case TableSubType of
                    ServiceContractType::Contract.AsInteger():
                        PageNo := Page::"Service Contract List";
                    ServiceContractType::Quote.AsInteger():
                        PageNo := Page::"Service Contract Quotes";
                    ServiceContractType::Template.AsInteger():
                        PageNo := Page::"Service Contract Template List";
                end;
        end;
        if PageNo = 0 then
            DataSearchEvents.OnGetListPageNo(TableNo, TableSubType, PageNo);
        if PageNo = 0 then
            if TableMetaData.Get(TableNo) then
                PageNo := TableMetaData.LookupPageID;
        exit(PageNo);
    end;

    internal procedure GetParentTableNo(TableNo: Integer): Integer
    var
        DataSearchEvents: Codeunit "Data Search Events";
        ParentTableNo: Integer;
    begin
        case TableNo of
            Database::"Sales Line":
                ParentTableNo := Database::"Sales Header";
            Database::"Purchase Line":
                ParentTableNo := Database::"Purchase Header";
            Database::"Service Item Line":
                ParentTableNo := Database::"Service Header";
            Database::"Service Contract Line":
                ParentTableNo := Database::"Service Contract Header";
            Database::"Sales Invoice Line":
                ParentTableNo := Database::"Sales Invoice Header";
            Database::"Sales Shipment Line":
                ParentTableNo := Database::"Sales Shipment Header";
            Database::"Sales Cr.Memo Line":
                ParentTableNo := Database::"Sales Cr.Memo Header";
            Database::"Purch. Inv. Line":
                ParentTableNo := Database::"Purch. Inv. Header";
            Database::"Purch. Cr. Memo Line":
                ParentTableNo := Database::"Purch. Cr. Memo Hdr.";
            Database::"Purch. Rcpt. Line":
                ParentTableNo := Database::"Purch. Rcpt. Header";
            Database::"Service Shipment Item Line", Database::"Service Shipment Line":
                ParentTableNo := Database::"Service Shipment Header";
            Database::"Service Invoice Line":
                ParentTableNo := Database::"Service Invoice Header";
            Database::"Service Cr.Memo Line":
                ParentTableNo := Database::"Service Cr.Memo Header";
            Database::"Reminder Line":
                ParentTableNo := Database::"Reminder Header";
            Database::"Issued Reminder Line":
                ParentTableNo := Database::"Issued Reminder Header";
            Database::"Sales Line Archive":
                ParentTableNo := Database::"Sales Header Archive";
            Database::"Purchase Line Archive":
                ParentTableNo := Database::"Purchase Header Archive";
            Database::"Job Task":
                ParentTableNo := Database::"Job";
            Database::"Job Planning Line":
                ParentTableNo := Database::"Job";
            Database::"Prod. Order Line":
                ParentTableNo := Database::"Production Order";
            Database::"Production BOM Line":
                ParentTableNo := Database::"Production BOM Header";
            Database::"Routing Line":
                ParentTableNo := Database::"Routing Header";
            Database::"Warehouse Shipment Line":
                ParentTableNo := Database::"Warehouse Shipment Header";
            Database::"Warehouse Receipt Line":
                ParentTableNo := Database::"Warehouse Receipt Header";
            Database::"Warehouse Activity Line":
                ParentTableNo := Database::"Warehouse Activity Header";
            Database::"Registered Whse. Activity Line":
                ParentTableNo := Database::"Registered Whse. Activity Hdr.";
            Database::"Posted Whse. Receipt Line":
                ParentTableNo := Database::"Posted Whse. Receipt Header";
            Database::"Assembly Line":
                ParentTableNo := Database::"Assembly Header";
            Database::"Transfer Line":
                ParentTableNo := Database::"Transfer Header";
            else
                ParentTableNo := 0;
        end;
        if ParentTableNo = 0 then
            DataSearchEvents.OnGetParentTable(TableNo, ParentTableNo);
        exit(ParentTableNo);
    end;

    internal procedure GetSubTableNos(TableNo: Integer): List of [Integer]
    var
        DataSearchEvents: Codeunit "Data Search Events";
        SubTableNos: List of [Integer];
        SubTableNo: Integer;
    begin
        case TableNo of
            Database::"Sales Header":
                SubTableNos.Add(Database::"Sales Line");
            Database::"Purchase Header":
                SubTableNos.Add(Database::"Purchase Line");
            Database::"Service Header":
                SubTableNos.Add(Database::"Service Item Line");
            Database::"Service Contract Header":
                SubTableNos.Add(Database::"Service Contract Line");
            Database::"Sales Invoice Header":
                SubTableNos.Add(Database::"Sales Invoice Line");
            Database::"Sales Shipment Header":
                SubTableNos.Add(Database::"Sales Shipment Line");
            Database::"Sales Cr.Memo Header":
                SubTableNos.Add(Database::"Sales Cr.Memo Line");
            Database::"Purch. Inv. Header":
                SubTableNos.Add(Database::"Purch. Inv. Line");
            Database::"Purch. Cr. Memo Hdr.":
                SubTableNos.Add(Database::"Purch. Cr. Memo Line");
            Database::"Purch. Rcpt. Header":
                SubTableNos.Add(Database::"Purch. Rcpt. Line");
            Database::"Service Shipment Header":
                begin
                    SubTableNos.Add(Database::"Service Shipment Item Line");
                    SubTableNos.Add(Database::"Service Shipment Line");
                end;
            Database::"Service Invoice Header":
                SubTableNos.Add(Database::"Service Invoice Line");
            Database::"Service Cr.Memo Header":
                SubTableNos.Add(Database::"Service Cr.Memo Line");
            Database::"Reminder Header":
                SubTableNos.Add(Database::"Reminder Line");
            Database::"Issued Reminder Header":
                SubTableNos.Add(Database::"Issued Reminder Line");
            Database::"Sales Header Archive":
                SubTableNos.Add(Database::"Sales Line Archive");
            Database::"Purchase Header Archive":
                SubTableNos.Add(Database::"Purchase Line Archive");
            Database::Job:
                begin
                    SubTableNos.Add(Database::"Job Task");
                    SubTableNos.Add(Database::"Job Planning Line");
                end;
            Database::"Production Order":
                SubTableNos.Add(Database::"Prod. Order Line");
            Database::"Production BOM Header":
                SubTableNos.Add(Database::"Production BOM Line");
            Database::"Routing Header":
                SubTableNos.Add(Database::"Routing Line");
            Database::"Warehouse Shipment Header":
                SubTableNos.Add(Database::"Warehouse Shipment Line");
            Database::"Warehouse Receipt Header":
                SubTableNos.Add(Database::"Warehouse Receipt Line");
            Database::"Warehouse Activity Header":
                SubTableNos.Add(Database::"Warehouse Activity Line");
            Database::"Registered Whse. Activity Hdr.":
                SubTableNos.Add(Database::"Registered Whse. Activity Line");
            Database::"Posted Whse. Receipt Header":
                SubTableNos.Add(Database::"Posted Whse. Receipt Line");
            Database::"Assembly Header":
                SubTableNos.Add(Database::"Assembly Line");
            Database::"Transfer Header":
                SubTableNos.Add(Database::"Transfer Line");
        end;
        if SubTableNos.Count() = 0 then begin
            DataSearchEvents.OnGetSubTable(TableNo, SubTableNo);
            if SubTableNo > 0 then
                SubTableNos.Add(SubTableNo);
        end;
        exit(SubTableNos);
    end;

    internal procedure GetTypeNoField(TableNo: Integer): Integer
    var
        DataSearchEvents: Codeunit "Data Search Events";
        FieldNo: Integer;
    begin
        case TableNo of
            Database::"Gen. Journal Line":
                FieldNo := 1;
            Database::"Sales Header", Database::"Sales Line",
            Database::"Purchase Header", Database::"Purchase Line",
            Database::"Service Header", Database::"Service Line",
            Database::"Service Contract Line":
                FieldNo := 1;
            Database::"Service Item Line":
                FieldNo := 43;
            Database::"Service Contract Header":
                FieldNo := 2;
        end;
        if FieldNo = 0 then
            DataSearchEvents.OnGetFieldNoForTableType(TableNo, FieldNo);
        exit(FieldNo);
    end;

    local procedure GetGenJournalPageNo(TableSubType: Integer): Integer
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetLoadFields("Page ID");
        GenJournalTemplate.SetFilter("Page ID", '>0');
        GenJournalTemplate.SetRange(Type, TableSubType);
        if GenJournalTemplate.FindFirst() then
            exit(GenJournalTemplate."Page ID");
        exit(page::"General Journal");
    end;

    internal procedure SetTypeFilterOnRecRef(var RecRef: RecordRef; TableType: Integer; FieldNo: Integer)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        FldRef: FieldRef;
        FilterTxt: TextBuilder;
    begin
        if not RecRef.FieldExist(FieldNo) then
            exit;
        FldRef := RecRef.Field(FieldNo);
        case RecRef.Number of
            Database::"Gen. Journal Line":
                begin
                    GenJournalTemplate.SetLoadFields(Name);
                    GenJournalTemplate.SetRange(Type, TableType);
                    if GenJournalTemplate.FindSet() then
                        repeat
                            if FilterTxt.Length() > 0 then
                                FilterTxt.Append('|');
                            FilterTxt.Append('''');
                            FilterTxt.Append(GenJournalTemplate.Name);
                            FilterTxt.Append('''');
                        until GenJournalTemplate.Next() = 0;
                    if FilterTxt.Length > 0 then
                        FldRef.SetFilter(FilterTxt.ToText())
                    else
                        FldRef.SetRange(CopyStr(DelChr(Format(CreateGuid()), '=', '{-}'), 1, 10)); // no templates, so we don't find any lines (likely)
                end;
            else
                FldRef.SetRange(TableType);
        end;
    end;


    internal procedure IsSubTable(TableNo: Integer): Boolean
    var
        DataSearchEvents: Codeunit "Data Search Events";
        ParentTableNo: Integer;
        TableIsSubtable: Boolean;
    begin
        ParentTableNo := GetParentTableNo(TableNo);
        TableIsSubTable := (ParentTableNo > 0) and (ParentTableNo <> TableNo);
        if not TableIsSubtable then begin
            DataSearchEvents.OnGetParentTable(TableNo, ParentTableNo);
            TableIsSubTable := (ParentTableNo > 0) and (ParentTableNo <> TableNo);
        end;
        exit(TableIsSubtable);
    end;

    internal procedure GetSubtypes(var DataSearchSetupTable: Record "Data Search Setup (Table)"; var SubtypeList: list of [Integer])
    var
        DataSearchEvents: Codeunit "Data Search Events";
        FieldNo: Integer;
    begin
        case DataSearchSetupTable."Table No." of
            Database::"Gen. Journal Line":
                FieldNo := 1;
            Database::"Sales Header", Database::"Sales Line",
            Database::"Purchase Header", Database::"Purchase Line",
            Database::"Service Header", Database::"Service Item Line",
            Database::"Service Contract Line":
                FieldNo := 1;
            Database::"Service Contract Header":
                FieldNo := 2;
        end;
        if FieldNo = 0 then
            DataSearchEvents.OnGetFieldNoForTableType(DataSearchSetupTable."Table No.", FieldNo);
        if FieldNo > 0 then
            GetSubtypesForField(DataSearchSetupTable."Table No.", FieldNo, SubtypeList);
    end;

    local procedure GetSubtypesForField(TableNo: Integer; FieldNo: Integer; var SubtypeList: list of [Integer])
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        if TableNo = Database::"Gen. Journal Line" then begin
            TableNo := Database::"Gen. Journal Template";
            FieldNo := 9; // Type
        end;
        RecRef.Open(TableNo);
        FldRef := RecRef.Field(FieldNo);
        for i := 1 to FldRef.EnumValueCount() do
            SubtypeList.Add(FldRef.GetEnumValueOrdinal(i));
    end;

    internal procedure GetTableSubTypeFromPage(PageNo: Integer): Integer
    var
        PageMetaData: Record "Page Metadata";
        DataSearchEvents: Codeunit "Data Search Events";
        SalesDocumentType: Enum "Sales Document Type";
        PurchaseDocumentType: Enum "Purchase Document Type";
        ServiceDocumentType: Enum "Service Document Type";
        ServiceContractType: Enum "Service Contract Type";
        TableSubtype: Integer;
    begin
        case PageNo of
            Page::"Blanket Sales Orders":
                exit(SalesDocumentType::"Blanket Order".AsInteger());
            Page::"Sales Credit Memos":
                exit(SalesDocumentType::"Credit Memo".AsInteger());
            Page::"Sales Invoice List":
                exit(SalesDocumentType::Invoice.AsInteger());
            Page::"Sales Order List":
                exit(SalesDocumentType::Order.AsInteger());
            Page::"Sales Quotes":
                exit(SalesDocumentType::Quote.AsInteger());
            Page::"Sales Return Order List":
                exit(SalesDocumentType::"Return Order".AsInteger());
            Page::"Blanket Purchase Orders":
                exit(PurchaseDocumentType::"Blanket Order".AsInteger());
            Page::"Purchase Credit Memos":
                exit(PurchaseDocumentType::"Credit Memo".AsInteger());
            Page::"Purchase Invoices":
                exit(PurchaseDocumentType::Invoice.AsInteger());
            Page::"Purchase Order List":
                exit(PurchaseDocumentType::Order.AsInteger());
            Page::"Purchase Quotes":
                exit(PurchaseDocumentType::Quote.AsInteger());
            Page::"Purchase Return Order List":
                exit(PurchaseDocumentType::"Return Order".AsInteger());
            Page::"Service Credit Memos":
                exit(ServiceDocumentType::"Credit Memo".AsInteger());
            Page::"Service Invoices":
                exit(ServiceDocumentType::Invoice.AsInteger());
            Page::"Service Orders":
                exit(ServiceDocumentType::Order.AsInteger());
            Page::"Service Quotes":
                exit(ServiceDocumentType::Quote.AsInteger());
            Page::"Service Contract List":
                exit(ServiceContractType::Contract.AsInteger());
            Page::"Service Contract Quotes":
                exit(ServiceContractType::Quote.AsInteger());
            Page::"Service Contract Template List":
                exit(ServiceContractType::Template.AsInteger());
            else begin
                if PageMetaData.Get(PageNo) and (PageMetaData.SourceTable = Database::"Gen. Journal Line") then
                    exit(FindGenJournalTemplateType(PageNo));
                TableSubtype := 0;
                DataSearchEvents.OnGetTableSubTypeFromPage(PageNo, TableSubtype);
                exit(TableSubtype);
            end;
        end;
    end;

    local procedure FindGenJournalTemplateType(PageNo: Integer): Integer
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetLoadFields(Type);
        GenJournalTemplate.SetRange("Page ID", PageNo);
        if GenJournalTemplate.FindFirst() then
            exit(GenJournalTemplate.Type.AsInteger());
        exit(0);
    end;

    /*
    Returns the search setup in the format of (example):
    [
      {
         "tableNo": 1234,
         "tableSubtype": 0,
         "tableSubtypeFieldNo": 3,
         "tableSearchFieldNos": [ 1, 2, 5, 8 ]
      }
    ]
    */
    internal procedure GetDataSearchSetup(var SetupInfo: JsonArray)
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        DataSearchSetupField: Record "Data Search Setup (Field)";
        AllProfile: Record "All Profile";
        DataSearchDefaults: Codeunit "Data Search Defaults";
        jObject: JsonObject;
        jArray: JsonArray;
    begin
        AllProfile.SetRange("Profile ID", DataSearchSetupTable.GetProfileID());
        if AllProfile.FindFirst() then;
        DataSearchSetupTable.SetRange("Role Center ID", AllProfile."Role Center ID");
        if DataSearchSetupTable.IsEmpty then
            DataSearchDefaults.InitSetupForProfile(AllProfile."Role Center ID");
        if DataSearchSetupTable.FindSet() then
            repeat
                Clear(jObject);
                Clear(jArray);
                jObject.Add('tableNo', Format(DataSearchSetupTable."Table No."));
                jObject.Add('tableSubtype', Format(DataSearchSetupTable."Table Subtype"));
                jObject.Add('tableSubtypeFieldNo', Format(GetTypeNoField(DataSearchSetupTable."Table No.")));
                DataSearchSetupField.SetRange("Table No.", DataSearchSetupTable."Table No.");
                DataSearchSetupField.SetRange("Enable Search", true);
                if DataSearchSetupField.IsEmpty() then
                    DataSearchDefaults.AddDefaultFields(DataSearchSetupTable."Table No.");
                if DataSearchSetupField.FindSet() then
                    repeat
                        jArray.Add(Format(DataSearchSetupField."Field No."));
                    until DataSearchSetupField.Next() = 0;
                jObject.Add('tableSearchFieldNos', jArray);
                SetupInfo.Add(jObject);
            until DataSearchSetupTable.Next() = 0;
    end;

    internal procedure GetDisplayPageId(TableNo: Integer; SystemId: Guid; var DisplayPageId: Integer; var DisplayTableNo: Integer; var DisplaySystemId: Guid)
    var
        PageMetaData: Record "Page Metadata";
        DataSearchEvents: Codeunit "Data Search Events";
        PageManagement: Codeunit "Page Management";
        RecRef: RecordRef;
    begin
        if TableNo = 0 then
            exit;
        RecRef.Open(TableNo);
        if not RecRef.GetBySystemId(SystemId) then
            exit;
        MapLinesRecToHeaderRec(RecRef);
        DisplayTableNo := RecRef.Number;
        DisplaySystemId := RecRef.Field(RecRef.SystemIdNo).Value;
        DisplayPageId := PageManagement.GetPageID(RecRef);
        if DisplayPageId = 0 then
            DataSearchEvents.OnGetCardPageNo(RecRef.Number, 0, DisplayPageId);
        if DisplayPageId = 0 then begin
            DisplayPageId := GetListPageNo(TableNo, RecRef.Field(GetTypeNoField(RecRef.Number)).Value);
            if not PageMetaData.Get(DisplayPageId) then
                exit;
            if PageMetaData.CardPageID <> 0 then
                DisplayPageId := PageMetaData.CardPageID;
        end;
    end;

    internal procedure MapLinesRecToHeaderRec(var RecRef: RecordRef): Boolean
    var
        DataSearchEvents: Codeunit "Data Search Events";
        Mapped: Boolean;
        LineTableNo: Integer;
    begin
        Mapped := true;
        case RecRef.Number of
            Database::"Sales Line":
                SalesLineToHeader(RecRef);
            Database::"Purchase Line":
                PurchaseLineToHeader(RecRef);
            Database::"Sales Invoice Line":
                SalesInvoiceLineToHeader(RecRef);
            Database::"Sales Shipment Line":
                SalesShipmentLineToHeader(RecRef);
            Database::"Sales Cr.Memo Line":
                SalesCreditMemoLineToHeader(RecRef);
            Database::"Purch. Inv. Line":
                PurchaseInvLineToHeader(RecRef);
            Database::"Purch. Rcpt. Line":
                PurchRcptLineToHeader(RecRef);
            Database::"Purch. Cr. Memo Line":
                PurchCrMemoLineToHeader(RecRef);
            Database::"Sales Line Archive":
                SalesLineArchiveToHeader(RecRef);
            Database::"Purchase Line Archive":
                PurchaseLineArchiveToHeader(RecRef);
            Database::"Reminder Line":
                ReminderLineToHeader(RecRef);
            Database::"Issued Reminder Line":
                IssuedReminderLineToHeader(RecRef);
            Database::"Job Task":
                JobTaskToJob(RecRef);
            Database::"Job Planning Line":
                JobPlanningLineToJob(RecRef);
            Database::"Service Item Line":
                ServiceItemLineToHeader(RecRef);
            Database::"Service Shipment Item Line":
                ServiceShipmentItemLineToHeader(RecRef);
            Database::"Service Shipment Line":
                ServiceShipmentLineToHeader(RecRef);
            Database::"Service Invoice Line":
                ServiceInvoiceLineToHeader(RecRef);
            Database::"Service Cr.Memo Line":
                ServiceCrMemoLineToHeader(RecRef);
            Database::"Service Contract Line":
                ServiceContractLineToHeader(RecRef);
            Database::"Prod. Order Line":
                ProdOrderLineToHeader(RecRef);
            Database::"Production BOM Line":
                ProductionBOMLineToHeader(RecRef);
            Database::"Routing Line":
                RoutingLineToHeader(RecRef);
            Database::"Warehouse Shipment Line":
                WarehouseShipmentLineToHeader(RecRef);
            Database::"Warehouse Receipt Line":
                WarehouseReceiptLineToHeader(RecRef);
            Database::"Warehouse Activity Line":
                WarehouseActivityLineToHeader(RecRef);
            Database::"Registered Whse. Activity Line":
                RegisteredWhseActivityLineToHeader(RecRef);
            Database::"Posted Whse. Receipt Line":
                PostedWhseReciptLineToHeader(RecRef);
            Database::"Assembly Line":
                AssemblyLineToHeader(RecRef);
            Database::"Transfer Line":
                TransferLineToHeader(RecRef);
            else begin
                LineTableNo := RecRef.Number;
                DataSearchEvents.OnMapLineRecToHeaderRec(RecRef, RecRef);
                Mapped := LineTableNo <> RecRef.Number;
            end;
        end;
        exit(Mapped);
    end;

    local procedure SalesLineToHeader(var RecRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        RecRef.SetTable(SalesLine);
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        RecRef.GetTable(SalesHeader);
    end;

    local procedure PurchaseLineToHeader(var RecRef: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        RecRef.SetTable(PurchaseLine);
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        RecRef.GetTable(PurchaseHeader);
    end;

    local procedure SalesInvoiceLineToHeader(var RecRef: RecordRef)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        RecRef.SetTable(SalesInvoiceLine);
        SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
        RecRef.GetTable(SalesInvoiceHeader);
    end;

    local procedure SalesShipmentLineToHeader(var RecRef: RecordRef)
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        RecRef.SetTable(SalesShipmentLine);
        SalesShipmentHeader.Get(SalesShipmentLine."Document No.");
        RecRef.GetTable(SalesShipmentHeader);
    end;

    local procedure SalesCreditMemoLineToHeader(var RecRef: RecordRef)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        RecRef.SetTable(SalesCrMemoLine);
        SalesCrMemoHeader.Get(SalesCrMemoLine."Document No.");
        RecRef.GetTable(SalesCrMemoHeader);
    end;

    local procedure PurchaseInvLineToHeader(var RecRef: RecordRef)
    var
        PurchaseInvHeader: Record "Purch. Inv. Header";
        PurchaseInvLine: Record "Purch. Inv. Line";
    begin
        RecRef.SetTable(PurchaseInvLine);
        PurchaseInvHeader.Get(PurchaseInvLine."Document No.");
        RecRef.GetTable(PurchaseInvHeader);
    end;

    local procedure PurchRcptLineToHeader(var RecRef: RecordRef)
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        RecRef.SetTable(PurchRcptLine);
        PurchRcptHeader.Get(PurchRcptLine."Document No.");
        RecRef.GetTable(PurchRcptHeader);
    end;

    local procedure PurchCrMemoLineToHeader(var RecRef: RecordRef)
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        RecRef.SetTable(PurchCrMemoLine);
        PurchCrMemoHdr.Get(PurchCrMemoLine."Document No.");
        RecRef.GetTable(PurchCrMemoHdr);
    end;

    local procedure ServiceItemLineToHeader(var RecRef: RecordRef)
    var
        ServiceHeader: Record "Service Header";
        ServiceItemLine: Record "Service Item Line";
    begin
        RecRef.SetTable(ServiceItemLine);
        ServiceHeader.Get(ServiceItemLine."Document Type", ServiceItemLine."Document No.");
        RecRef.GetTable(ServiceHeader);
    end;

    local procedure ServiceShipmentItemLineToHeader(var RecRef: RecordRef)
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceShipmentItemLine: Record "Service Shipment Item Line";
    begin
        RecRef.SetTable(ServiceShipmentItemLine);
        ServiceShipmentHeader.Get(ServiceShipmentItemLine."No.");
        RecRef.GetTable(ServiceShipmentHeader);
    end;

    local procedure ServiceShipmentLineToHeader(var RecRef: RecordRef)
    var
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceShipmentLine: Record "Service Shipment Line";
    begin
        RecRef.SetTable(ServiceShipmentLine);
        ServiceShipmentHeader.Get(ServiceShipmentLine."Document No.");
        RecRef.GetTable(ServiceShipmentHeader);
    end;

    local procedure ServiceInvoiceLineToHeader(var RecRef: RecordRef)
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceInvoiceLine: Record "Service Invoice Line";
    begin
        RecRef.SetTable(ServiceInvoiceLine);
        ServiceInvoiceHeader.Get(ServiceInvoiceLine."Document No.");
        RecRef.GetTable(ServiceInvoiceHeader);
    end;

    local procedure ServiceCrMemoLineToHeader(var RecRef: RecordRef)
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
    begin
        RecRef.SetTable(ServiceCrMemoLine);
        ServiceCrMemoHeader.Get(ServiceCrMemoLine."Document No.");
        RecRef.GetTable(ServiceCrMemoHeader);
    end;

    local procedure ServiceContractLineToHeader(var RecRef: RecordRef)
    var
        ServiceContractHeader: Record "Service Contract Header";
        ServiceContractLine: Record "Service Contract Line";
    begin
        RecRef.SetTable(ServiceContractLine);
        ServiceContractHeader.Get(ServiceContractLine."Contract Type", ServiceContractLine."Contract No.");
        RecRef.GetTable(ServiceContractHeader);
    end;

    local procedure SalesLineArchiveToHeader(var RecRef: RecordRef)
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesLineArchive: Record "Sales Line Archive";
    begin
        RecRef.SetTable(SalesLineArchive);
        SalesHeaderArchive.Get(SalesLineArchive."Document Type", SalesLineArchive."Document No.", SalesLineArchive."Doc. No. Occurrence", SalesLineArchive."Version No.");
        RecRef.GetTable(SalesHeaderArchive);
    end;

    local procedure PurchaseLineArchiveToHeader(var RecRef: RecordRef)
    var
        PurchaseHeaderArchive: Record "Purchase Header Archive";
        PurchaseLineArchive: Record "Purchase Line Archive";
    begin
        RecRef.SetTable(PurchaseLineArchive);
        PurchaseHeaderArchive.Get(PurchaseLineArchive."Document Type", PurchaseLineArchive."Document No.", PurchaseLineArchive."Doc. No. Occurrence", PurchaseLineArchive."Version No.");
        RecRef.GetTable(PurchaseHeaderArchive);
    end;

    local procedure ReminderLineToHeader(var RecRef: RecordRef)
    var
        ReminderHeader: Record "Reminder Header";
        ReminderLine: Record "Reminder Line";
    begin
        RecRef.SetTable(ReminderLine);
        ReminderHeader.Get(ReminderLine."Reminder No.");
        RecRef.GetTable(ReminderHeader);
    end;

    local procedure IssuedReminderLineToHeader(var RecRef: RecordRef)
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderLine: Record "Issued Reminder Line";
    begin
        RecRef.SetTable(IssuedReminderLine);
        IssuedReminderHeader.Get(IssuedReminderLine."Reminder No.");
        RecRef.GetTable(IssuedReminderHeader);
    end;

    local procedure JobTaskToJob(var RecRef: RecordRef)
    var
        Job: Record Job;
        JobTask: Record "Job Task";
    begin
        RecRef.SetTable(JobTask);
        Job.Get(JobTask."Job No.");
        RecRef.GetTable(Job);
    end;

    local procedure JobPlanningLineToJob(var RecRef: RecordRef)
    var
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
    begin
        RecRef.SetTable(JobPlanningLine);
        Job.Get(JobPlanningLine."Job No.");
        RecRef.GetTable(Job);
    end;

    local procedure ProdOrderLineToHeader(var RecRef: RecordRef)
    var
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        RecRef.SetTable(ProdOrderLine);
        ProductionOrder.Get(ProdOrderLine.Status, ProdOrderLine."Prod. Order No.");
        RecRef.GetTable(ProductionOrder);
    end;

    local procedure ProductionBOMLineToHeader(var RecRef: RecordRef)
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMLine: Record "Production BOM Line";
    begin
        RecRef.SetTable(ProductionBOMLine);
        ProductionBOMHeader.Get(ProductionBOMLine."Production BOM No.");
        RecRef.GetTable(ProductionBOMHeader);
    end;

    local procedure RoutingLineToHeader(var RecRef: RecordRef)
    var
        RoutingHeader: Record "Routing Header";
        RoutingLine: Record "Routing Line";
    begin
        RecRef.SetTable(RoutingLine);
        RoutingHeader.Get(RoutingLine."Routing No.");
        RecRef.GetTable(RoutingHeader);
    end;

    local procedure WarehouseShipmentLineToHeader(var RecRef: RecordRef)
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        RecRef.SetTable(WarehouseShipmentLine);
        WarehouseShipmentHeader.Get(WarehouseShipmentLine."No.");
        RecRef.GetTable(WarehouseShipmentHeader);
    end;

    local procedure WarehouseReceiptLineToHeader(var RecRef: RecordRef)
    var
        WarehouseReceiptHeader: Record "Warehouse Receipt Header";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        RecRef.SetTable(WarehouseReceiptLine);
        WarehouseReceiptHeader.Get(WarehouseReceiptLine."No.");
        RecRef.GetTable(WarehouseReceiptHeader);
    end;

    local procedure WarehouseActivityLineToHeader(var RecRef: RecordRef)
    var
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        RecRef.SetTable(WarehouseActivityLine);
        WarehouseActivityHeader.Get(WarehouseActivityLine."No.");
        RecRef.GetTable(WarehouseActivityHeader);
    end;

    local procedure RegisteredWhseActivityLineToHeader(var RecRef: RecordRef)
    var
        RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr.";
        RegisteredWhseActivityLine: Record "Registered Whse. Activity Line";
    begin
        RecRef.SetTable(RegisteredWhseActivityLine);
        RegisteredWhseActivityHdr.Get(RegisteredWhseActivityLine."No.");
        RecRef.GetTable(RegisteredWhseActivityHdr);
    end;

    local procedure PostedWhseReciptLineToHeader(var RecRef: RecordRef)
    var
        PostedWhseReceiptHeader: Record "Posted Whse. Receipt Header";
        PostedWhseReceiptLine: Record "Posted Whse. Receipt Line";
    begin
        RecRef.SetTable(PostedWhseReceiptLine);
        PostedWhseReceiptHeader.Get(PostedWhseReceiptLine."No.");
        RecRef.GetTable(PostedWhseReceiptHeader);
    end;

    local procedure AssemblyLineToHeader(var RecRef: RecordRef)
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
    begin
        RecRef.SetTable(AssemblyLine);
        AssemblyHeader.Get(AssemblyLine."Document Type", AssemblyLine."Document No.");
        RecRef.GetTable(AssemblyHeader);
    end;

    local procedure TransferLineToHeader(var RecRef: RecordRef)
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
    begin
        RecRef.SetTable(TransferLine);
        TransferHeader.Get(TransferLine."Document No.");
        RecRef.GetTable(TransferHeader);
    end;
}