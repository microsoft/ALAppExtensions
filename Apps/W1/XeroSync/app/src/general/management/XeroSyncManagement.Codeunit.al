codeunit 2411 "XS Xero Sync Management"
{
    var
        XeroBaseUriTxt: Label 'https://api.xero.com/api.xro/2.0', locked = true;

        // Items
    procedure GetXeroUrlForItem(): Text
    begin
        exit(XeroBaseUriTxt + '/Items/');
    end;

    procedure GetJsonTagForItemID(): Text
    begin
        exit('ItemID');
    end;

    procedure GetJsonTagForItems(): Text
    begin
        exit('Items');
    end;

    procedure GetJsonTagForItemCode(): Text
    begin
        exit('Code');
    end;

    // Contacts (Customers)
    procedure GetXeroUrlForCustomer(): Text
    begin
        exit(XeroBaseUriTxt + '/Contacts/');
    end;

    procedure GetJsonTagForCustomerID(): Text
    begin
        exit('ContactID');
    end;

    procedure GetJsonTagForCustomers(): Text
    begin
        exit('Contacts');
    end;

    procedure GetJsonTagForCustomerName(): Text
    begin
        exit('Name');
    end;

    procedure GetJsonTagForCustomerTaxNumber(): Text
    begin
        exit('TaxNumber');
    end;

    procedure GetJsonTagForCustomerStatus(): Text
    begin
        exit('ContactStatus');
    end;

    // Sales Invoices
    procedure GetXeroUrlForInvoices(): Text
    begin
        exit(XeroBaseUriTxt + '/Invoices/');
    end;

    procedure GetJsonTagForInvoiceID(): Text
    begin
        exit('InvoiceID');
    end;

    procedure GetJsonTagForInvoices(): Text
    begin
        exit('Invoices');
    end;

    procedure GetXeroUrlForCurrencies(): Text
    begin
        exit(XeroBaseUriTxt + '/Currencies/');
    end;

    procedure GetXeroUrlForAccounts(): Text
    begin
        exit(XeroBaseUriTxt + '/Accounts/');
    end;

    procedure GetJsonTagForCurrencies(): Text
    begin
        exit('Currencies');
    end;

    procedure GetJsonTagForAccounts(): Text
    begin
        exit('Accounts');
    end;

    // Reports
    procedure GetXeroUrlForReports(): Text
    begin
        exit(XeroBaseUriTxt + '/Reports/');
    end;

    procedure GetJsonTagForReports(): Text
    begin
        exit('Reports');
    end;

    procedure GetJsonTagForReportTitles(): Text
    begin
        exit('ReportTitles');
    end;

    procedure GetUrlTextFromDate(): Text
    begin
        exit('fromDate');
    end;

    procedure GetUrlTextForToDate(): Text
    begin
        exit('toDate');
    end;

    procedure GetUrlTextForDate(): Text
    begin
        exit('date');
    end;

    procedure GetUrlTextForPeriods(): Text
    begin
        exit('periods');
    end;

    procedure GetUrlTextForTimeFrame(): Text
    begin
        exit('timeframe');
    end;

    procedure GetUrlTextForTrialBalance(): Text
    begin
        exit('TrialBalance');
    end;

    procedure GetUrlTextForProfitAndLoss(): Text
    begin
        exit('ProfitAndLoss');
    end;

    procedure GetJsonTagForRows(): Text
    begin
        exit('Rows');
    end;

    procedure GetJsonTagForRowType(): Text
    begin
        exit('RowType');
    end;

    procedure GetJsonTagForTitle(): Text
    begin
        exit('Title');
    end;

    procedure GetJsonTagForCells(): Text
    begin
        exit('Cells');
    end;

    // General
    procedure GetJsonTagForUpdatedTimeUTC(): Text
    begin
        exit('UpdatedDateUTC');
    end;

    procedure GetUrlQuestionMark(): Text
    begin
        exit('?');
    end;

    procedure GetUrlAmpersend(): Text
    begin
        exit('&');
    end;

    procedure GetUrlEquals(): Text
    begin
        exit('=');
    end;

    procedure IsGBTenant(): Boolean
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        exit(StrPos(ApplicationSystemConstants.ApplicationVersion(), 'GB') = 1);
    end;

    procedure GetXeroHandler(): Integer
    begin
        exit(Codeunit::"XS Process Xero Change");
    end;

    procedure CreateCustomerDataJson(var Customer: Record Customer; ChangeType: Option Create,Update,Delete," ") CustomerDataJsonTxt: Text
    var
        CreateCustomerDataJson: Codeunit "XS Create Customer Data Json";
    begin
        CustomerDataJsonTxt := CreateCustomerDataJson.CreateCustomerDataJson(Customer, ChangeType);
    end;

    procedure CreateCustomerDeleteJson() CustomerDataJsonTxt: Text
    var
        CreateCustomerDeleteJson: Codeunit "XS Create Customer Delete Json";
    begin
        CustomerDataJsonTxt := CreateCustomerDeleteJson.CreateCustomerDeleteJson();
    end;

    procedure UpdateXeroContactWithNAVCustomerNo(var Customer: Record Customer; var SyncMapping: Record "Sync Mapping")
    var
        UpdateXeroContactWithCustomerNo: Codeunit "XS Update Xero Customer No.";
    begin
        UpdateXeroContactWithCustomerNo.UpdateXeroContactWithNAVCustomerNo(Customer, SyncMapping);
    end;

    procedure CreateItemDataJson(var Item: Record Item) ItemDataJsonTxt: Text
    var
        CreateItemDataJson: Codeunit "XS Create Item Data Json";
    begin
        ItemDataJsonTxt := CreateItemDataJson.CreateItemDataJson(Item);
    end;

    procedure CreateSalesInvoiceJson(var SalesInvoiceHeader: Record "Sales Invoice Header") SalesInvoiceDataJsonTxt: Text
    var
        CreateSalesInvoiceJson: Codeunit "XS Create Sales Inv. Json";
    begin
        SalesInvoiceDataJsonTxt := CreateSalesInvoiceJson.CreateSalesInvoiceJson(SalesInvoiceHeader);
    end;

    procedure FetchReportsFromXero(XeroSyncManagementReportID: Integer; var JsonEntities: JsonArray; ListOfAdditionalParametersForReports: List of [Text]) IsSuccessStatusCode: Boolean;
    var
        RestWebService: Record "XS REST Web Service Parameters" temporary;
        DummySyncChange: Record "Sync Change";
        DummyDateTime: DateTime;
    begin
        IsSuccessStatusCode := RestWebService.CommunicateWithXero(DummySyncChange, XeroSyncMAnagementReportID, '', 0, 0, DummyDateTime, false, '', JsonEntities, ListOfAdditionalParametersForReports);
    end;

    procedure CompareRecords(var RecRefTempEntity: RecordRef; var RecRefEntity: RecordRef; NAVEntityID: Integer) DoUpdate: Boolean
    var
        SynchronizationField: Record "XS Synchronization Field";
        FieldRef: FieldRef;
        TempFieldRef: FieldRef;
    begin
        SynchronizationField.SetRange("Table No.", NAVEntityID);

        if SynchronizationField.FindSet() then;
        repeat
            FieldRef := RecRefEntity.Field(SynchronizationField."Field No.");
            TempFieldRef := RecRefTempEntity.Field(SynchronizationField."Field No.");
            if (FieldRef.Class() = FieldRef.Class() ::Normal) and (FieldRef.Type() <> FieldRef.Type() ::Blob) then
                if FieldRef.Value() <> TempFieldRef.Value() then begin
                    DoUpdate := true;
                    FieldRef.Value(TempFieldRef.Value());
                end;
        until SynchronizationField.Next() = 0;
    end;

    procedure ReMapSyncMappingIfNeeded(var SyncMapping: Record "Sync Mapping"; var SyncChange: Record "Sync Change"; NAVEntityID: Integer; FilterValue: Text) ReMapped: Boolean
    var
        Item: Record Item;
        Customer: Record Customer;
        RecID: RecordId;
    begin
        case NAVEntityID of
            Database::Item:
                if not Item.Get(FilterValue) then
                    exit
                else
                    RecID := Item.RecordId();
            Database::Customer:
                begin
                    Customer.SetRange("Name", FilterValue);
                    if not Customer.FindFirst() then
                        exit
                    else
                        RecID := Customer.RecordId();
                end;
        end;

        SyncMapping.SetRange("Internal ID", RecID);
        if SyncMapping.FindFirst() then begin
            SyncMapping."External Id" := SyncChange."External ID";
            ReMapped := SyncMapping.Modify(true);
            SyncChange."Change Type" := SyncChange."Change Type"::Update;
            SyncChange."XS ReMapped" := true;
        end;
    end;
}
