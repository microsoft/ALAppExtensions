namespace System.DataAdministration;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.CostAccounting.Ledger;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Inventory.Ledger;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Projects.Project.WIP;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reminder;
using Microsoft.Service.History;
using System.Reflection;
using System.Telemetry;
using System.IO;

codeunit 6202 "Transact. Storage Export Data"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Transact. Storage Table Entry" = RIMD,
                  tabledata "Transact. Storage Task Entry" = RIM,
                  tabledata "Trans. Storage Export Data" = RIMD,
                  tabledata "G/L Entry" = r,
                  tabledata "VAT Entry" = r,
                  tabledata "Cust. Ledger Entry" = r,
                  tabledata "Vendor Ledger Entry" = r,
                  tabledata "Detailed Cust. Ledg. Entry" = r,
                  tabledata "Detailed Vendor Ledg. Entry" = r,
                  tabledata "Item Ledger Entry" = r,
                  tabledata "Bank Account Ledger Entry" = r,
                  tabledata "Job Ledger Entry" = r,
                  tabledata "Job WIP G/L Entry" = r,
                  tabledata "FA Ledger Entry" = r,
                  tabledata "Value Entry" = r,
                  tabledata "Cost Entry" = r,
                  tabledata "Sales Invoice Header" = r,
                  tabledata "Sales Invoice Line" = r,
                  tabledata "Sales Cr.Memo Header" = r,
                  tabledata "Sales Cr.Memo Line" = r,
                  tabledata "Purch. Inv. Header" = r,
                  tabledata "Purch. Inv. Line" = r,
                  tabledata "Purch. Cr. Memo Hdr." = r,
                  tabledata "Purch. Cr. Memo Line" = r,
                  tabledata "Service Invoice Header" = r,
                  tabledata "Service Invoice Line" = r,
                  tabledata "Service Cr.Memo Header" = r,
                  tabledata "Service Cr.Memo Line" = r,
                  tabledata "Issued Reminder Header" = r,
                  tabledata "Issued Reminder Line" = r,
                  tabledata "Issued Fin. Charge Memo Header" = r,
                  tabledata "Issued Fin. Charge Memo Line" = r,
                  tabledata "Currency Exchange Rate" = r,
                  tabledata Customer = r,
                  tabledata Vendor = r,
                  tabledata "Bank Account" = r,
                  tabledata "G/L Account" = r,
                  tabledata "Fixed Asset" = r,
                  tabledata "Depreciation Book" = r,
                  tabledata "FA Depreciation Book" = r;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TransactStorageExport: Codeunit "Transact. Storage Export";
        TransactionStorageTok: Label 'Transaction Storage', Locked = true;
        NoOfRecordsToCollectTxt: Label 'Number of records to collect', Locked = true;
        NoOfCollectedRecordTxt: Label 'Number of collected records', Locked = true;
        NoOfCollectedPartsTxt: Label 'Parts', Locked = true;
        DocumentNoFieldNameTxt: Label 'Document No.', Locked = true;
        NoPermissionsForTableErr: Label 'User does not have permissions to read the table %1', Comment = '%1 = table name', Locked = true;
        ExportRecCountExceedsLimitErr: Label 'The number of records to export exceeds the limit. See Custom Dimensions.', Locked = true;

    procedure ExportData(TaskStartingDateTime: DateTime)
    var
        TransStorageExportData: Record "Trans. Storage Export Data";
        TempFieldList: Record Field temporary;
        TransactionStorageABS: Codeunit "Transaction Storage ABS";
        HandledIncomingDocs: Dictionary of [Text, Integer];
        MasterData: Dictionary of [Integer, List of [Code[50]]];
        TablesToExport: List of [Integer];
        TableID: Integer;
        FilterRecToDateTime: DateTime;
    begin
        TransStorageExportData.DeleteAll(true);
        TablesToExport := GetTablesToExport();
        FilterRecToDateTime := GetFilterRecToDateTime(TablesToExport, TaskStartingDateTime);
        LogNumberOfRecordsToCollect(TablesToExport, FilterRecToDateTime);
        foreach TableID in TablesToExport do
            CollectDataFromTable(HandledIncomingDocs, TempFieldList, MasterData, FilterRecToDateTime, TableID);
        TransactStorageExport.CheckTaskTimedOut(TaskStartingDateTime);
        LogNumberOfCollectedRecords(TablesToExport);
        CollectMasterData(MasterData);
        if (not TransStorageExportData.IsEmpty()) or (HandledIncomingDocs.Count() <> 0) then
            TransactionStorageABS.ArchiveTransactionsToABS(HandledIncomingDocs);
    end;

    local procedure CollectDataFromTable(var HandledIncomingDocs: Dictionary of [Text, Integer]; var TempFieldList: Record Field temporary; var MasterData: Dictionary of [Integer, List of [Code[50]]]; FilterRecordTo: DateTime; TableID: Integer)
    var
        TransactStorageTableEntry: Record "Transact. Storage Table Entry";
        RecRef: RecordRef;
        RecordJsonObject: JsonObject;
        TableJsonArray: JsonArray;
        RecordChunkSize: Integer;
        RecordsHandled: Integer;
        Part: Integer;
    begin
        RecRef.Open(TableID);
        if not RecRef.ReadPermission() then begin
            FeatureTelemetry.LogError('0000MLH', TransactionStorageTok, '', StrSubstNo(NoPermissionsForTableErr, RecRef.Name));
            exit;
        end;
        SetFieldsToHandle(TempFieldList, RecRef.Number);
        SetLoadFieldForRecRef(RecRef, TempFieldList);
        TransactStorageExport.GetRecordExportData(TransactStorageTableEntry, RecRef);
        SetRangeOnDataTable(RecRef, TransactStorageTableEntry, FilterRecordTo);
        TransactStorageTableEntry."No. Of Records Exported" := 0;
        RecordChunkSize := GetRecordChunkSize();
        if RecRef.FindSet() then begin
            Clear(TableJsonArray);
            repeat
                RecordsHandled += 1;
                TransactStorageTableEntry."No. Of Records Exported" += 1;
                HandleTableFieldSet(RecordJsonObject, MasterData, TempFieldList, RecRef, true);
                TableJsonArray.Add(RecordJsonObject);
                AddJsonArrayToTransStorageExportData(Part, TableJsonArray, RecordsHandled, RecordChunkSize, RecRef.Number());
                TransactStorageExport.HandleIncomingDocuments(HandledIncomingDocs, RecRef);
            until RecRef.Next() = 0;
            AddJsonArrayToTransStorageExportData(Part, TableJsonArray, RecordsHandled, 0, RecRef.Number());
        end else
            TransactStorageExport.SetTableEntryProcessed(TransactStorageTableEntry, TransactStorageTableEntry."Filter Record To DT", false, '');
        TransactStorageTableEntry."Record Filters" := CopyStr(GetRecordFilters(RecRef), 1, MaxStrLen(TransactStorageTableEntry."Record Filters"));
        TransactStorageTableEntry.Modify();
        RecRef.Close();
    end;

    local procedure CollectMasterData(var MasterData: Dictionary of [Integer, List of [Code[50]]])
    var
        TempFieldList: Record Field temporary;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        MasterDataTableNo: Integer;
        MasterDataCodes: List of [Code[50]];
        MasterDataCode: Code[50];
        RecordJsonObject: JsonObject;
        TableJsonArray: JsonArray;
        RecordChunkSize: Integer;
        RecordsHandled: Integer;
        Part: Integer;
    begin
        foreach MasterDataTableNo in MasterData.Keys() do begin
            Part := 0;
            RecordsHandled := 0;
            MasterDataCodes := MasterData.Get(MasterDataTableNo);
            RecRef.Open(MasterDataTableNo);
            if not RecRef.ReadPermission() then begin
                FeatureTelemetry.LogError('0000MLI', TransactionStorageTok, '', StrSubstNo(NoPermissionsForTableErr, RecRef.Name));
                exit;
            end;
            SetFieldsToHandle(TempFieldList, RecRef.Number);
            SetLoadFieldForRecRef(RecRef, TempFieldList);
            KeyRef := RecRef.KeyIndex(1);
            FieldRef := KeyRef.FieldIndex(1);
            RecordChunkSize := GetRecordChunkSize();
            if MasterDataCodes.Count <> 0 then begin
                Clear(TableJsonArray);
                foreach MasterDataCode in MasterDataCodes do begin
                    FieldRef.SetRange(MasterDataCode);
                    if RecRef.FindFirst() then begin
                        RecordsHandled += 1;
                        HandleTableFieldSet(RecordJsonObject, MasterData, TempFieldList, RecRef, false);
                        TableJsonArray.Add(RecordJsonObject);
                        AddJsonArrayToTransStorageExportData(Part, TableJsonArray, RecordsHandled, RecordChunkSize, RecRef.Number());
                    end;
                end;
                AddJsonArrayToTransStorageExportData(Part, TableJsonArray, RecordsHandled, 0, RecRef.Number());
            end;
            RecRef.Close();
            Commit();
        end;
    end;

    local procedure AddJsonArrayToTransStorageExportData(var Part: Integer; var TableJsonArray: JsonArray; var RecordsHandled: Integer; ChunkSize: Integer; TableID: Integer)
    var
        TransStorageExportData: Record "Trans. Storage Export Data";
    begin
        if RecordsHandled < ChunkSize then
            exit;
        TransStorageExportData.Add(Part, TableJsonArray, TableID, RecordsHandled);
        RecordsHandled := 0;
        Clear(TableJsonArray);
    end;

    local procedure SetRangeOnDataTable(var RecRef: RecordRef; var TransactStorageTableEntry: Record "Transact. Storage Table Entry"; FilterRecTo: DateTime)
    var
        SystemModifiedAtFieldRef: FieldRef;
        FilterRecFrom: DateTime;
    begin
        FilterRecFrom := TransactStorageTableEntry."Last Handled Date/Time" + 10;
        SystemModifiedAtFieldRef := RecRef.Field(RecRef.SystemModifiedAtNo());
        SystemModifiedAtFieldRef.SetRange(FilterRecFrom, FilterRecTo);
        TransactStorageTableEntry."Filter Record To DT" := FilterRecTo;
    end;

    local procedure GetRecordFilters(var RecRef: RecordRef) Filters: Text
    var
        TranslationHelper: Codeunit "Translation Helper";
    begin
        TranslationHelper.SetGlobalLanguageToDefault();
        Filters := RecRef.GetFilters();
        TranslationHelper.RestoreGlobalLanguage();
    end;

    local procedure GetFilterRecToDateTime(TablesToExport: List of [Integer]; TaskStartingDateTime: DateTime): DateTime
    var
        RecRef: RecordRef;
        TableID: Integer;
        CurrFilterRecTo: DateTime;
        MinFilterRecTo: DateTime;
    begin
        MinFilterRecTo := TaskStartingDateTime;
        foreach TableID in TablesToExport do begin
            RecRef.Open(TableID);
            if RecRef.ReadPermission() then begin
                CurrFilterRecTo := CalcFilterRecordToDateTime(RecRef, TaskStartingDateTime);
                if CurrFilterRecTo < MinFilterRecTo then
                    MinFilterRecTo := CurrFilterRecTo;
            end;
            RecRef.Close();
        end;
        exit(MinFilterRecTo);
    end;

    local procedure CalcFilterRecordToDateTime(var RecRef: RecordRef; TaskStartingDateTime: DateTime) FilterRecTo: DateTime
    var
        TransactStorageTableEntry: Record "Transact. Storage Table Entry";
        SystemModifiedAtFieldRef: FieldRef;
        FilterRecFromDate: Date;
        FilterRecFromTime: Time;
        FilterRecFrom: DateTime;
        FilterRecToDate: Date;
        FilterRecToTime: Time;
        MaxExportPeriodDays: Integer;
        RecordCount: Integer;
        MaxRecordCount: Integer;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        TransactStorageExport.GetRecordExportData(TransactStorageTableEntry, RecRef);

        FilterRecFromDate := DT2Date(TransactStorageTableEntry."Last Handled Date/Time");
        FilterRecFromTime := DT2Time(TransactStorageTableEntry."Last Handled Date/Time") + 10;
        FilterRecFrom := CreateDateTime(FilterRecFromDate, FilterRecFromTime);

        FilterRecToDate := DT2Date(TaskStartingDateTime);
        FilterRecToTime := DT2Time(TaskStartingDateTime);
        FilterRecTo := TaskStartingDateTime;

        MaxRecordCount := GetMaxRecordCount();
        SystemModifiedAtFieldRef := RecRef.Field(RecRef.SystemModifiedAtNo());
        SystemModifiedAtFieldRef.SetRange(FilterRecFrom, FilterRecTo);
        if RecRef.CountApprox() < MaxRecordCount then
            exit;

        // limit the export period to 10 days
        MaxExportPeriodDays := GetMaxExportPeriodDays();
        if FilterRecToDate - FilterRecFromDate > MaxExportPeriodDays then begin
            FilterRecToDate := FilterRecFromDate + MaxExportPeriodDays;
            FilterRecToTime := 0T;
        end;

        // limit the number of records to export by reducing the export period up to 1 day
        repeat
            FilterRecTo := CreateDateTime(FilterRecToDate, FilterRecToTime);
            SystemModifiedAtFieldRef.SetRange(FilterRecFrom, FilterRecTo);
            FilterRecToDate -= 1;
        until (RecRef.CountApprox() < MaxRecordCount) or (FilterRecToDate - FilterRecFromDate < 1);
        if RecRef.CountApprox() < MaxRecordCount then
            exit;

        // limit the number of records to export using Entry No. field
        CalcFilterRecToDateTimeByEntryNo(RecRef, FilterRecFrom, FilterRecTo);

        // log warning if after all the limitations the number of records to export still exceeds the limit
        RecordCount := RecRef.Count();
        if RecordCount > MaxRecordCount then begin
            SystemModifiedAtFieldRef.SetRange(FilterRecFrom, FilterRecTo);
            CustomDimensions.Add('TableName', RecRef.Name);
            CustomDimensions.Add('RecordCount', Format(RecordCount));
            CustomDimensions.Add('MaxRecordCount', Format(MaxRecordCount));
            CustomDimensions.Add('FilterRecFrom', Format(FilterRecFrom));
            CustomDimensions.Add('FilterRecordTo', Format(FilterRecTo));
            TransactStorageExport.LogWarning('0000NBO', ExportRecCountExceedsLimitErr, CustomDimensions);
        end;
    end;

    local procedure CalcFilterRecToDateTimeByEntryNo(var RecRef: RecordRef; FilterRecFrom: DateTime; var FilterRecTo: DateTime)
    var
        EntryNoFieldRef: FieldRef;
        SystemModifiedAtFieldRef: FieldRef;
        DocumentNoFieldRef: FieldRef;
        KeyRef: KeyRef;
        StartEntryNo: Integer;
        EndEntryNo: Integer;
    begin
        // calculates the ending date/time of period by limiting then number of records to export
        RecRef.Reset();
        KeyRef := RecRef.KeyIndex(1);
        if KeyRef.FieldCount() > 1 then
            exit;
        EntryNoFieldRef := KeyRef.FieldIndex(1);
        if not (EntryNoFieldRef.Type = FieldType::Integer) then
            exit;
        SystemModifiedAtFieldRef := RecRef.Field(RecRef.SystemModifiedAtNo());
        SystemModifiedAtFieldRef.SetFilter('%1..', FilterRecFrom);
        if not RecRef.FindFirst() then
            exit;
        StartEntryNo := EntryNoFieldRef.Value();
        EndEntryNo := StartEntryNo + GetMaxRecordCount();
        EntryNoFieldRef.SetRange(StartEntryNo, EndEntryNo);
        if not RecRef.FindLast() then
            exit;
        FilterRecTo := SystemModifiedAtFieldRef.Value();

        // try to export all entries for the last document
        if GetDocumentNoField(RecRef, DocumentNoFieldRef) then begin
            EntryNoFieldRef.SetRange();
            DocumentNoFieldRef.SetRange(DocumentNoFieldRef.Value());
            if RecRef.FindLast() then
                FilterRecTo := SystemModifiedAtFieldRef.Value();
        end;
        RecRef.Reset();
    end;

    local procedure GetDocumentNoField(RecRef: RecordRef; var DocumentNoFieldRef: FieldRef): Boolean
    var
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        exit(DataTypeManagement.FindFieldByName(RecRef, DocumentNoFieldRef, DocumentNoFieldNameTxt));
    end;

    local procedure HandleTableFieldSet(var RecordJsonObject: JsonObject; var MasterData: Dictionary of [Integer, List of [Code[50]]]; var TempFieldList: Record Field temporary; var RecRef: RecordRef; MasterDataCollectionRequired: Boolean)
    var
        FieldRef: FieldRef;
        MasterDataCodes: List of [Code[50]];
    begin
        Clear(RecordJsonObject);
        TempFieldList.SetRange(TableNo, RecRef.Number);
        if not TempFieldList.FindSet() then
            exit;
        repeat
            FieldRef := RecRef.Field(TempFieldList."No.");
            if FieldRef.Class = FieldClass::FlowField then
                FieldRef.CalcField();
            RecordJsonObject.Add(FieldRef.Name, Format(FieldRef.Value));
            if MasterDataCollectionRequired and (Format(FieldRef.Value) <> '') then
                if FieldRef.Relation in
                    [Database::"G/L Account", Database::Customer, Database::Vendor, Database::"Bank Account",
                     Database::"Fixed Asset", Database::"Depreciation Book"]
                then
                    if MasterData.ContainsKey(FieldRef.Relation) then begin
                        MasterDataCodes := MasterData.Get(FieldRef.Relation);
                        if not MasterDataCodes.Contains(FieldRef.Value) then begin
                            MasterDataCodes.Add(FieldRef.Value);
                            MasterData.Set(FieldRef.Relation, MasterDataCodes);
                        end;
                    end else begin
                        Clear(MasterDataCodes);
                        MasterDataCodes.Add(FieldRef.Value);
                        MasterData.Add(FieldRef.Relation, MasterDataCodes);
                    end;
        until TempFieldList.Next() = 0;
    end;

    local procedure SetFieldsToHandle(var TempFieldList: Record Field temporary; TableID: Integer)
    var
        FieldsToExport: List of [Integer];
        FieldID: Integer;
    begin
        FieldsToExport := GetFieldsToExport(TableID);
        foreach FieldID in FieldsToExport do
            UpdateTempFieldList(TempFieldList, TableID, FieldID);
    end;

    local procedure LogNumberOfRecordsToCollect(TablesToExport: List of [Integer]; FilterRecTo: DateTime)
    var
        TransactStorageTableEntry: Record "Transact. Storage Table Entry";
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
        SystemModifiedAtFieldRef: FieldRef;
        TableID: Integer;
        FilterRecFrom: DateTime;
        RecordCountApprox: Integer;
        CustomDimensions: Dictionary of [Text, Text];
        RecordLogJson: JsonObject;
        RecordLogTxt: Text;
    begin
        foreach TableID in TablesToExport do begin
            RecRef.Open(TableID);
            if RecRef.ReadPermission() then begin
                TransactStorageExport.GetRecordExportData(TransactStorageTableEntry, RecRef);
                FilterRecFrom := TransactStorageTableEntry."Last Handled Date/Time" + 10;
                SystemModifiedAtFieldRef := RecRef.Field(RecRef.SystemModifiedAtNo());
                SystemModifiedAtFieldRef.SetRange(FilterRecFrom, FilterRecTo);
                RecordCountApprox := RecRef.CountApprox();
            end;
            RecRef.Close();

            TableMetadata.Get(TableID);
            Clear(RecordLogJson);
            RecordLogJson.Add('CountApprox', RecordCountApprox);
            RecordLogJson.Add('FilterFrom', FormatDateTimeForLog(FilterRecFrom));
            RecordLogJson.Add('FilterTo', FormatDateTimeForLog(FilterRecTo));
            RecordLogJson.WriteTo(RecordLogTxt);
            CustomDimensions.Add(TableMetadata.Name, RecordLogTxt);
        end;
        FeatureTelemetry.LogUsage('0000NU9', TransactionStorageTok, NoOfRecordsToCollectTxt, CustomDimensions);
    end;

    local procedure FormatDateTimeForLog(InputValue: DateTime): Text
    begin
        exit(Format(InputValue, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
    end;

    local procedure LogNumberOfCollectedRecords(TablesToExport: List of [Integer])
    var
        TransStorageExportData: Record "Trans. Storage Export Data";
        TransactStorageTableEntry: Record "Transact. Storage Table Entry";
        TableMetadata: Record "Table Metadata";
        RecordsCustomDimensions: Dictionary of [Text, Text];
        PartsCustomDimensions: Dictionary of [Text, Text];
        TableID: Integer;
        RecordLogJson: JsonObject;
        RecordLogTxt: Text;
    begin
        foreach TableID in TablesToExport do begin
            TableMetadata.Get(TableID);
            TransStorageExportData.SetRange("Table ID", TableID);
            TransStorageExportData.CalcSums("Record Count");

            Clear(RecordLogJson);
            RecordLogJson.Add('Count', Format(TransStorageExportData."Record Count"));
            if TransactStorageTableEntry.Get(TableID) then
                RecordLogJson.Add('Filters', TransactStorageTableEntry."Record Filters");
            RecordLogJson.WriteTo(RecordLogTxt);

            RecordsCustomDimensions.Add(TableMetadata.Name, RecordLogTxt);
            PartsCustomDimensions.Add(TableMetadata.Name, Format(TransStorageExportData.Count()));
        end;
        FeatureTelemetry.LogUsage('0000LK7', TransactionStorageTok, NoOfCollectedRecordTxt, RecordsCustomDimensions);
        FeatureTelemetry.LogUsage('0000N1I', TransactionStorageTok, NoOfCollectedPartsTxt, PartsCustomDimensions);
    end;

    local procedure GetTablesToExport() TablesToExport: List of [Integer]
    begin
        TablesToExport.Add(Database::"G/L Entry");
        TablesToExport.Add(Database::"VAT Entry");
        TablesToExport.Add(Database::"Cust. Ledger Entry");
        TablesToExport.Add(Database::"Vendor Ledger Entry");
        TablesToExport.Add(Database::"Detailed Cust. Ledg. Entry");
        TablesToExport.Add(Database::"Detailed Vendor Ledg. Entry");
        TablesToExport.Add(Database::"Item Ledger Entry");
        TablesToExport.Add(Database::"Bank Account Ledger Entry");
        TablesToExport.Add(Database::"Job Ledger Entry");
        TablesToExport.Add(Database::"Job WIP G/L Entry");
        TablesToExport.Add(Database::"FA Ledger Entry");
        TablesToExport.Add(Database::"Value Entry");
        TablesToExport.Add(Database::"Cost Entry");
        TablesToExport.Add(Database::"Sales Invoice Header");
        TablesToExport.Add(Database::"Sales Invoice Line");
        TablesToExport.Add(Database::"Sales Cr.Memo Header");
        TablesToExport.Add(Database::"Sales Cr.Memo Line");
        TablesToExport.Add(Database::"Purch. Inv. Header");
        TablesToExport.Add(Database::"Purch. Inv. Line");
        TablesToExport.Add(Database::"Purch. Cr. Memo Hdr.");
        TablesToExport.Add(Database::"Purch. Cr. Memo Line");
        TablesToExport.Add(Database::"Service Invoice Header");
        TablesToExport.Add(Database::"Service Invoice Line");
        TablesToExport.Add(Database::"Service Cr.Memo Header");
        TablesToExport.Add(Database::"Service Cr.Memo Line");
        TablesToExport.Add(Database::"Issued Reminder Header");
        TablesToExport.Add(Database::"Issued Reminder Line");
        TablesToExport.Add(Database::"Issued Fin. Charge Memo Header");
        TablesToExport.Add(Database::"Issued Fin. Charge Memo Line");
        TablesToExport.Add(Database::"Currency Exchange Rate");
    end;

    local procedure GetFieldsToExport(TableID: Integer) FieldsToExport: List of [Integer]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
        FixedAsset: Record "Fixed Asset";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        GLEntry: Record "G/L Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedVendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VATEntry: Record "VAT Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        JobLedgerEntry: Record "Job Ledger Entry";
        JobWIPGLEntry: Record "Job WIP G/L Entry";
        FALedgerEntry: Record "FA Ledger Entry";
        ValueEntry: Record "Value Entry";
        CostEntry: Record "Cost Entry";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        ServiceInvHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ServiceInvLine: Record "Service Invoice Line";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        IssuedReminderHeader: Record "Issued Reminder Header";
        IssuedReminderLine: Record "Issued Reminder Line";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        case TableID of
            Database::"G/L Account":
                begin
                    FieldsToExport.Add(GLAccount.FieldNo("No."));
                    FieldsToExport.Add(GLAccount.FieldNo(Name));
                    FieldsToExport.Add(GLAccount.FieldNo("Account Type"));
                    FieldsToExport.Add(GLAccount.FieldNo("Account Category"));
                    FieldsToExport.Add(GLAccount.FieldNo("Income/Balance"));
                end;
            Database::Customer:
                begin
                    FieldsToExport.Add(Customer.FieldNo("No."));
                    FieldsToExport.Add(Customer.FieldNo(Name));
                    FieldsToExport.Add(Customer.FieldNo(Address));
                    FieldsToExport.Add(Customer.FieldNo("Address 2"));
                    FieldsToExport.Add(Customer.FieldNo(City));
                    FieldsToExport.Add(Customer.FieldNo("Currency Code"));
                    FieldsToExport.Add(Customer.FieldNo("Registration Number"));
                    FieldsToExport.Add(Customer.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(Customer.FieldNo("Country/Region Code"));
                    FieldsToExport.Add(Customer.FieldNo("Post Code"));
                end;
            Database::Vendor:
                begin
                    FieldsToExport.Add(Vendor.FieldNo("No."));
                    FieldsToExport.Add(Vendor.FieldNo(Name));
                    FieldsToExport.Add(Vendor.FieldNo(Address));
                    FieldsToExport.Add(Vendor.FieldNo("Address 2"));
                    FieldsToExport.Add(Vendor.FieldNo(City));
                    FieldsToExport.Add(Vendor.FieldNo("Currency Code"));
                    FieldsToExport.Add(Vendor.FieldNo("Registration Number"));
                    FieldsToExport.Add(Vendor.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(Vendor.FieldNo("Country/Region Code"));
                    FieldsToExport.Add(Vendor.FieldNo("Post Code"));
                end;
            Database::"Bank Account":
                begin
                    FieldsToExport.Add(BankAccount.FieldNo("No."));
                    FieldsToExport.Add(BankAccount.FieldNo(Name));
                    FieldsToExport.Add(BankAccount.FieldNo("Name 2"));
                    FieldsToExport.Add(BankAccount.FieldNo("Bank Account No."));
                end;
            Database::"Fixed Asset":
                begin
                    FieldsToExport.Add(FixedAsset.FieldNo("No."));
                    FieldsToExport.Add(FixedAsset.FieldNo(Description));
                    FieldsToExport.Add(FixedAsset.FieldNo("FA Class Code"));
                    FieldsToExport.Add(FixedAsset.FieldNo("FA Subclass Code"));
                    FieldsToExport.Add(FixedAsset.FieldNo("FA Location Code"));
                    FieldsToExport.Add(FixedAsset.FieldNo("Vendor No."));
                    FieldsToExport.Add(FixedAsset.FieldNo("Main Asset/Component"));
                    FieldsToExport.Add(FixedAsset.FieldNo("Component of Main Asset"));
                    FieldsToExport.Add(FixedAsset.FieldNo("Budgeted Asset"));
                    FieldsToExport.Add(FixedAsset.FieldNo("Warranty Date"));
                    FieldsToExport.Add(FixedAsset.FieldNo("Serial No."));
                    FieldsToExport.Add(FixedAsset.FieldNo(Inactive));
                    FieldsToExport.Add(FixedAsset.FieldNo(Acquired));
                end;
            Database::"Depreciation Book":
                begin
                    FieldsToExport.Add(DepreciationBook.FieldNo(Code));
                    FieldsToExport.Add(DepreciationBook.FieldNo(Description));
                    FieldsToExport.Add(DepreciationBook.FieldNo("Disposal Calculation Method"));
                    FieldsToExport.Add(DepreciationBook.FieldNo("Allow Depr. Below Zero"));
                    FieldsToExport.Add(DepreciationBook.FieldNo("Fiscal Year 365 Days"));
                end;
            Database::"FA Depreciation Book":
                begin
                    FieldsToExport.Add(FADepreciationBook.FieldNo("FA No."));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Depreciation Book Code"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Depreciation Method"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Depreciation Starting Date"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Straight-Line %"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("No. of Depreciation Years"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("No. of Depreciation Months"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Fixed Depr. Amount"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Declining-Balance %"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Ending Book Value"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Depreciation Ending Date"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Acquisition Cost"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Depreciation"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Book Value"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Proceeds on Disposal"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Gain/Loss"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Write-Down"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Appreciation"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Depreciable Basis"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Salvage Value"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Book Value on Disposal"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Acquisition Date"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("G/L Acquisition Date"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Disposal Date"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Last Acquisition Cost Date"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Last Depreciation Date"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Last Write-Down Date"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Last Appreciation Date"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Depr. Below Zero %"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo(Description));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Use Half-Year Convention"));
                    FieldsToExport.Add(FADepreciationBook.FieldNo("Use DB% First Fiscal Year"));
                end;
            Database::"G/L Entry":
                begin
                    FieldsToExport.Add(GLEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(GLEntry.FieldNo("G/L Account No."));
                    FieldsToExport.Add(GLEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(GLEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(GLEntry.FieldNo("Document No."));
                    FieldsToExport.Add(GLEntry.FieldNo(Description));
                    FieldsToExport.Add(GLEntry.FieldNo("Bal. Account No."));
                    FieldsToExport.Add(GLEntry.FieldNo(Amount));
                    FieldsToExport.Add(GLEntry.FieldNo("Global Dimension 1 Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("Global Dimension 2 Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("User ID"));
                    FieldsToExport.Add(GLEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("Business Unit Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("Transaction No."));
                    FieldsToExport.Add(GLEntry.FieldNo("Debit Amount"));
                    FieldsToExport.Add(GLEntry.FieldNo("Credit Amount"));
                    FieldsToExport.Add(GLEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(GLEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(GLEntry.FieldNo("Source Type"));
                    FieldsToExport.Add(GLEntry.FieldNo("Source No."));
                    FieldsToExport.Add(GLEntry.FieldNo("G/L Account Name"));
                    FieldsToExport.Add(GLEntry.FieldNo("VAT Reporting Date"));
                    FieldsToExport.Add(GLEntry.FieldNo("Shortcut Dimension 3 Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("Shortcut Dimension 4 Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("Shortcut Dimension 5 Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("Shortcut Dimension 6 Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("Shortcut Dimension 7 Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("Shortcut Dimension 8 Code"));
                end;
            Database::"Cust. Ledger Entry":
                begin
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Customer No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Document No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Description"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Customer Name"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Currency Code"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Amount"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Amount (LCY)"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Global Dimension 1 Code"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Global Dimension 2 Code"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("User ID"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Applies-to Doc. Type"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Applies-to Doc. No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Due Date"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Closed by Entry No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Closed at Date"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Closed by Amount"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Transaction No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Amount to Apply"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Applying Entry"));
                end;
            Database::"Vendor Ledger Entry":
                begin
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Vendor No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Document No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo(Description));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Vendor Name"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Currency Code"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo(Amount));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Amount (LCY)"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Buy-from Vendor No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Global Dimension 1 Code"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Global Dimension 2 Code"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("User ID"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Applies-to Doc. Type"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Applies-to Doc. No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Due Date"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Closed by Entry No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Closed at Date"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Closed by Amount"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Transaction No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Amount to Apply"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Applying Entry"));
                end;
            Database::"Detailed Cust. Ledg. Entry":
                begin
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Cust. Ledger Entry No."));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Entry Type"));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Document No."));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo(Amount));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Amount (LCY)"));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Customer No."));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Currency Code"));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("User ID"));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(DetailedCustLedgEntry.FieldNo("Initial Document Type"));
                end;
            Database::"Detailed Vendor Ledg. Entry":
                begin
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Vendor Ledger Entry No."));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Entry Type"));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Document No."));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo(Amount));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Amount (LCY)"));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Vendor No."));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Currency Code"));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("User ID"));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(DetailedVendLedgEntry.FieldNo("Initial Document Type"));
                end;
            Database::"Item Ledger Entry":
                begin
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Item No."));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Entry Type"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Source No."));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Document No."));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo(Description));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Location Code"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo(Quantity));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Invoiced Quantity"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Source Type"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Drop Shipment"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Transaction Type"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Transport Method"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Country/Region Code"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Document Line No."));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Variant Code"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Qty. per Unit of Measure"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Unit of Measure Code"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Item Category Code"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Completely Invoiced"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Cost Amount (Expected)"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Cost Amount (Actual)"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Sales Amount (Expected)"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Sales Amount (Actual)"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Serial No."));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Lot No."));
                end;
            Database::"Job Ledger Entry":
                begin
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Job No."));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Document No."));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo(Type));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("No."));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo(Description));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo(Quantity));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Direct Unit Cost (LCY)"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Unit Cost (LCY)"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Total Cost (LCY)"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Unit Price (LCY)"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Total Price (LCY)"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Unit of Measure Code"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Location Code"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("User ID"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Entry Type"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Unit Cost"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Total Cost"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Unit Price"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Total Price"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Currency Code"));
                    FieldsToExport.Add(JobLedgerEntry.FieldNo("Currency Factor"));
                end;
            Database::"Job WIP G/L Entry":
                begin
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("Job No."));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("Document No."));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("G/L Account No."));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("WIP Entry Amount"));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo(Type));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("WIP Method Used"));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("WIP Posting Method Used"));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("WIP Posting Date"));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo(Description));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("G/L Entry No."));
                    FieldsToExport.Add(JobWIPGLEntry.FieldNo("WIP Transaction No."));
                end;
            Database::"FA Ledger Entry":
                begin
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("G/L Entry No."));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("FA No."));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("FA Posting Date"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Document No."));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(FALedgerEntry.FieldNo(Description));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Depreciation Book Code"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("FA Posting Category"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("FA Posting Type"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo(Amount));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Part of Book Value"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Part of Depreciable Basis"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Disposal Calculation Method"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Disposal Entry No."));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("No. of Depreciation Days"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo(Quantity));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("FA Subclass Code"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("FA Location Code"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("User ID"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Depreciation Method"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Depreciation Starting Date"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Straight-Line %"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("No. of Depreciation Years"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Fixed Depr. Amount"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Declining-Balance %"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Transaction No."));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Gen. Posting Type"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("FA Class Code"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Amount (LCY)"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Result on Disposal"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo("Depreciation Ending Date"));
                    FieldsToExport.Add(FALedgerEntry.FieldNo(Reversed));
                end;
            Database::"VAT Entry":
                begin
                    FieldsToExport.Add(VATEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(VATEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(VATEntry.FieldNo("Document No."));
                    FieldsToExport.Add(VATEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(VATEntry.FieldNo(Type));
                    FieldsToExport.Add(VATEntry.FieldNo(Base));
                    FieldsToExport.Add(VATEntry.FieldNo(Amount));
                    FieldsToExport.Add(VATEntry.FieldNo("VAT Calculation Type"));
                    FieldsToExport.Add(VATEntry.FieldNo("Bill-to/Pay-to No."));
                    FieldsToExport.Add(VATEntry.FieldNo("EU 3-Party Trade"));
                    FieldsToExport.Add(VATEntry.FieldNo("User ID"));
                    FieldsToExport.Add(VATEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(VATEntry.FieldNo("Transaction No."));
                    FieldsToExport.Add(VATEntry.FieldNo("Unrealized Amount"));
                    FieldsToExport.Add(VATEntry.FieldNo("Unrealized Base"));
                    FieldsToExport.Add(VATEntry.FieldNo("Remaining Unrealized Amount"));
                    FieldsToExport.Add(VATEntry.FieldNo("Remaining Unrealized Base"));
                    FieldsToExport.Add(VATEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(VATEntry.FieldNo("VAT Base Discount %"));
                    FieldsToExport.Add(VATEntry.FieldNo("VAT Difference"));
                    FieldsToExport.Add(VATEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(VATEntry.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(VATEntry.FieldNo("Base Before Pmt. Disc."));
                    FieldsToExport.Add(VATEntry.FieldNo("Realized Amount"));
                    FieldsToExport.Add(VATEntry.FieldNo("Realized Base"));
                    FieldsToExport.Add(VATEntry.FieldNo("G/L Acc. No."));
                    FieldsToExport.Add(VATEntry.FieldNo("VAT Reporting Date"));
                    FieldsToExport.Add(VATEntry.FieldNo("Non-Deductible VAT %"));
                    FieldsToExport.Add(VATEntry.FieldNo("Non-Deductible VAT Base"));
                    FieldsToExport.Add(VATEntry.FieldNo("Non-Deductible VAT Amount"));
                    FieldsToExport.Add(VATEntry.FieldNo("Non-Deductible VAT Diff."));
                end;
            Database::"Value Entry":
                begin
                    FieldsToExport.Add(ValueEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(ValueEntry.FieldNo("Item No."));
                    FieldsToExport.Add(ValueEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Item Ledger Entry Type"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Source No."));
                    FieldsToExport.Add(ValueEntry.FieldNo("Document No."));
                    FieldsToExport.Add(ValueEntry.FieldNo(Description));
                    FieldsToExport.Add(ValueEntry.FieldNo("Location Code"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Item Ledger Entry No."));
                    FieldsToExport.Add(ValueEntry.FieldNo("Valued Quantity"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Item Ledger Entry Quantity"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Invoiced Quantity"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Cost per Unit"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Sales Amount (Actual)"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Discount Amount"));
                    FieldsToExport.Add(ValueEntry.FieldNo("User ID"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Source Type"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Cost Amount (Actual)"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Cost Posted to G/L"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(ValueEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(ValueEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Document Line No."));
                    FieldsToExport.Add(ValueEntry.FieldNo("VAT Reporting Date"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Item Charge No."));
                    FieldsToExport.Add(ValueEntry.FieldNo("Valuation Date"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Entry Type"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Variance Type"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Purchase Amount (Actual)"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Purchase Amount (Expected)"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Sales Amount (Expected)"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Cost Amount (Expected)"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Cost Amount (Non-Invtbl.)"));
                end;
            Database::"Cost Entry":
                begin
                    FieldsToExport.Add(CostEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(CostEntry.FieldNo("Cost Type No."));
                    FieldsToExport.Add(CostEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(CostEntry.FieldNo("Document No."));
                    FieldsToExport.Add(CostEntry.FieldNo(Description));
                    FieldsToExport.Add(CostEntry.FieldNo(Amount));
                    FieldsToExport.Add(CostEntry.FieldNo("Cost Center Code"));
                    FieldsToExport.Add(CostEntry.FieldNo("Cost Object Code"));
                    FieldsToExport.Add(CostEntry.FieldNo("G/L Account"));
                    FieldsToExport.Add(CostEntry.FieldNo("G/L Entry No."));
                    FieldsToExport.Add(CostEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(CostEntry.FieldNo("User ID"));
                    FieldsToExport.Add(CostEntry.FieldNo(Allocated));
                    FieldsToExport.Add(CostEntry.FieldNo("Allocation Description"));
                    FieldsToExport.Add(CostEntry.FieldNo("Allocation ID"));
                end;
            Database::"Bank Account Ledger Entry":
                begin
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo("Bank Account No."));
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo("Document No."));
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo(Description));
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo("Currency Code"));
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo(Amount));
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo("Amount (LCY)"));
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo("User ID"));
                    FieldsToExport.Add(BankAccountLedgerEntry.FieldNo("Transaction No."));
                end;
            Database::"Sales Invoice Header":
                begin
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Bill-to Customer No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Bill-to Name"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Bill-to Address"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Bill-to City"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Currency Factor"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Prices Including VAT"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("EU 3-Party Trade"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Transaction Type"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Transport Method"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("VAT Country/Region Code"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Sell-to Customer Name"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Sell-to Address"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Sell-to City"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Bill-to Post Code"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Bill-to Country/Region Code"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Sell-to Post Code"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Sell-to Country/Region Code"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Exit Point"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("External Document No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Area"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("User ID"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Invoice Discount Value"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Prepayment Invoice"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("VAT Reporting Date"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Cust. Ledger Entry No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Responsibility Center"));
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Bill-to Customer No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Bill-to Name"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Bill-to Address"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Bill-to City"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Currency Factor"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Prices Including VAT"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("EU 3-Party Trade"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Transaction Type"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Transport Method"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("VAT Country/Region Code"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Sell-to Customer Name"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Sell-to Address"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Sell-to City"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Bill-to Post Code"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Bill-to Country/Region Code"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Sell-to Post Code"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Sell-to Country/Region Code"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Exit Point"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("External Document No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Area"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("User ID"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Prepayment Credit Memo"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("VAT Reporting Date"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Cust. Ledger Entry No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Responsibility Center"));
                end;
            Database::"Purch. Inv. Header":
                begin
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Buy-from Vendor No."));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("No."));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Pay-to Vendor No."));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Pay-to Name"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Pay-to Address"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Pay-to City"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Currency Factor"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Prices Including VAT"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Vendor Invoice No."));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Transaction Type"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Transport Method"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("VAT Country/Region Code"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Buy-from Vendor Name"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Buy-from Address"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Buy-from City"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Pay-to Post Code"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Pay-to Country/Region Code"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Buy-from Post Code"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Buy-from Country/Region Code"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Entry Point"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Area"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("User ID"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Prepayment Invoice"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("VAT Reporting Date"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Vendor Ledger Entry No."));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Invoice Discount Amount"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Responsibility Center"));
                end;
            Database::"Purch. Cr. Memo Hdr.":
                begin
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Buy-from Vendor No."));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("No."));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Pay-to Vendor No."));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Pay-to Name"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Pay-to Address"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Pay-to City"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Currency Factor"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Prices Including VAT"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Vendor Cr. Memo No."));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Transaction Type"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Transport Method"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("VAT Country/Region Code"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Buy-from Vendor Name"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Buy-from Address"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Buy-from City"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Pay-to Post Code"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Pay-to Country/Region Code"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Buy-from Post Code"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Buy-from Country/Region Code"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Area"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("User ID"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Prepayment Credit Memo"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("VAT Reporting Date"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Vendor Ledger Entry No."));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Invoice Discount Amount"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Responsibility Center"));
                end;
            Database::"Sales Invoice Line":
                begin
                    FieldsToExport.Add(SalesInvLine.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Document No."));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Line No."));
                    FieldsToExport.Add(SalesInvLine.FieldNo(Type));
                    FieldsToExport.Add(SalesInvLine.FieldNo("No."));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Location Code"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Shipment Date"));
                    FieldsToExport.Add(SalesInvLine.FieldNo(Description));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Unit of Measure"));
                    FieldsToExport.Add(SalesInvLine.FieldNo(Quantity));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Unit Price"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("VAT %"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Line Discount Amount"));
                    FieldsToExport.Add(SalesInvLine.FieldNo(Amount));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Amount Including VAT"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Bill-to Customer No."));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Drop Shipment"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("VAT Base Amount"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Line Amount"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Qty. per Unit of Measure"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Unit of Measure Code"));
                end;
            Database::"Sales Cr.Memo Line":
                begin
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Document No."));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Line No."));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo(Type));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("No."));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Location Code"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Shipment Date"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo(Description));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Unit of Measure"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo(Quantity));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Unit Price"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("VAT %"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Line Discount Amount"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo(Amount));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Amount Including VAT"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Bill-to Customer No."));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("VAT Base Amount"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Line Amount"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Qty. per Unit of Measure"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Unit of Measure Code"));
                end;
            Database::"Purch. Inv. Line":
                begin
                    FieldsToExport.Add(PurchInvLine.FieldNo("Buy-From Vendor No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Document No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Line No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo(Type));
                    FieldsToExport.Add(PurchInvLine.FieldNo("No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Location Code"));
                    FieldsToExport.Add(PurchInvLine.FieldNo(Description));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Unit of Measure"));
                    FieldsToExport.Add(PurchInvLine.FieldNo(Quantity));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Direct Unit Cost"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Unit Cost (LCY)"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("VAT %"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Line Discount Amount"));
                    FieldsToExport.Add(PurchInvLine.FieldNo(Amount));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Amount Including VAT"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Receipt No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Pay-To Vendor No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo("VAT Base Amount"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Line Amount"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Qty. per Unit of Measure"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Unit of Measure Code"));
                end;
            Database::"Purch. Cr. Memo Line":
                begin
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Buy-From Vendor No."));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Document No."));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Line No."));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo(Type));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("No."));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Location Code"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo(Description));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Unit of Measure"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo(Quantity));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Direct Unit Cost"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Unit Cost (LCY)"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("VAT %"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Line Discount Amount"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo(Amount));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Amount Including VAT"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Pay-To Vendor No."));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("VAT Base Amount"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Line Amount"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Qty. per Unit of Measure"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Unit of Measure Code"));
                end;
            Database::"Service Invoice Header":
                begin
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Customer No."));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("No."));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Bill-to Customer No."));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Bill-to Name"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Bill-to Address"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Bill-to City"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Currency Factor"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Prices Including VAT"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("EU 3-Party Trade"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Transaction Type"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Transport Method"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("VAT Country/Region Code"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo(Name));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo(Address));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo(City));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Bill-to Post Code"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Bill-to Country/Region Code"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Post Code"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Country/Region Code"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Exit Point"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo(Area));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("User ID"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo("VAT Reporting Date"));
                    FieldsToExport.Add(ServiceInvHeader.FieldNo(Description));
                end;
            Database::"Service Invoice Line":
                begin
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Customer No."));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Document No."));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Line No."));
                    FieldsToExport.Add(ServiceInvLine.FieldNo(Type));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("No."));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Location Code"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo(Description));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Unit of Measure"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo(Quantity));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Unit Price"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Unit Cost (LCY)"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("VAT %"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Line Discount Amount"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo(Amount));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Amount Including VAT"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Inv. Discount Amount"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Transaction Type"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Line Amount"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Qty. per Unit of Measure"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Unit of Measure Code"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Quantity (Base)"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Service Item No."));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Service Item Line No."));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Service Item Serial No."));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Service Item Line Description"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Posting Date"));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Replaced Item No."));
                    FieldsToExport.Add(ServiceInvLine.FieldNo("Replaced Item Type"));
                end;
            Database::"Service Cr.Memo Header":
                begin
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Customer No."));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("No."));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Bill-to Customer No."));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Bill-to Name"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Bill-to Address"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Bill-to City"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Currency Factor"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Prices Including VAT"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("EU 3-Party Trade"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Transaction Type"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Transport Method"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("VAT Country/Region Code"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo(Name));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo(Address));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo(City));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Bill-to Post Code"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Bill-to Country/Region Code"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Post Code"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Country/Region Code"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Exit Point"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo(Area));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("User ID"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo("VAT Reporting Date"));
                    FieldsToExport.Add(ServiceCrMemoHeader.FieldNo(Description));
                end;
            Database::"Service Cr.Memo Line":
                begin
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Customer No."));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Document No."));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Line No."));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo(Type));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("No."));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Location Code"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo(Description));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Unit of Measure"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo(Quantity));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Unit Price"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Unit Cost (LCY)"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("VAT %"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Line Discount Amount"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo(Amount));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Amount Including VAT"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Inv. Discount Amount"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Transaction Type"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Line Amount"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Qty. per Unit of Measure"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Unit of Measure Code"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Quantity (Base)"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Service Item No."));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Service Item Serial No."));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Service Item Line Description"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Posting Date"));
                    FieldsToExport.Add(ServiceCrMemoLine.FieldNo("Replaced Item No."));
                end;
            Database::"Issued Reminder Header":
                begin
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("No."));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("Customer No."));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo(Name));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo(Address));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("Post Code"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo(City));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("Country/Region Code"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("Remaining Amount"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("Interest Amount"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("Additional Fee"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("VAT Amount"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("User ID"));
                    FieldsToExport.Add(IssuedReminderHeader.FieldNo("VAT Reporting Date"));
                end;
            Database::"Issued Reminder Line":
                begin
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Reminder No."));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Line No."));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Attached to Line No."));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo(Type));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Entry No."));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Posting Date"));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Document Date"));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Document Type"));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Document No."));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo(Description));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Original Amount"));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Remaining Amount"));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("No."));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo(Amount));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Interest Rate"));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("VAT %"));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("VAT Amount"));
                    FieldsToExport.Add(IssuedReminderLine.FieldNo("Line Type"));
                end;
            Database::"Issued Fin. Charge Memo Header":
                begin
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("No."));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Customer No."));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo(Name));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo(Address));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Post Code"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo(City));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Country/Region Code"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Remaining Amount"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Interest Amount"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("Additional Fee"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("VAT Amount"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("User ID"));
                    FieldsToExport.Add(IssuedFinChargeMemoHeader.FieldNo("VAT Reporting Date"));
                end;
            Database::"Issued Fin. Charge Memo Line":
                begin
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Finance Charge Memo No."));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Line No."));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Attached to Line No."));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo(Type));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Entry No."));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Posting Date"));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Document Date"));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Document Type"));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Document No."));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo(Description));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Original Amount"));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Remaining Amount"));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("No."));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo(Amount));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Interest Rate"));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("VAT %"));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("VAT Amount"));
                    FieldsToExport.Add(IssuedFinChargeMemoLine.FieldNo("Line Type"));
                end;
            Database::"Currency Exchange Rate":
                begin
                    FieldsToExport.Add(CurrencyExchangeRate.FieldNo("Currency Code"));
                    FieldsToExport.Add(CurrencyExchangeRate.FieldNo("Starting Date"));
                    FieldsToExport.Add(CurrencyExchangeRate.FieldNo("Exchange Rate Amount"));
                    FieldsToExport.Add(CurrencyExchangeRate.FieldNo("Adjustment Exch. Rate Amount"));
                    FieldsToExport.Add(CurrencyExchangeRate.FieldNo("Relational Currency Code"));
                    FieldsToExport.Add(CurrencyExchangeRate.FieldNo("Relational Exch. Rate Amount"));
                    FieldsToExport.Add(CurrencyExchangeRate.FieldNo("Fix Exchange Rate Amount"));
                    FieldsToExport.Add(CurrencyExchangeRate.FieldNo("Relational Adjmt Exch Rate Amt"));
                end;
        end;
    end;

    local procedure UpdateTempFieldList(var TempFieldList: Record Field temporary; TableID: Integer; FieldID: Integer)
    begin
        TempFieldList.TableNo := TableID;
        TempFieldList."No." := FieldID;
        TempFieldList.Insert();
    end;

    local procedure SetLoadFieldForRecRef(var RecRef: RecordRef; var TempFieldList: Record Field temporary)
    var
    begin
        TempFieldList.SetRange(TableNo, RecRef.Number);
        if TempFieldList.FindSet() then
            repeat
                RecRef.SetLoadFields(TempFieldList."No.");
            until TempFieldList.Next() = 0;
    end;

    local procedure GetRecordChunkSize(): Integer
    begin
        exit(50050);
    end;

    local procedure GetMaxExportPeriodDays(): Integer
    begin
        exit(10);
    end;

    local procedure GetMaxRecordCount(): Integer
    begin
        exit(200000);
    end;
}