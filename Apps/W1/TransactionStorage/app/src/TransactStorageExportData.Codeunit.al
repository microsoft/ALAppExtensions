namespace System.DataAdministration;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using System.Reflection;
using System.Telemetry;

codeunit 6202 "Transact. Storage Export Data"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Transact. Storage Table Entry" = rimd,
                  tabledata "Transact. Storage Task Entry" = rim,
                  tabledata "G/L Entry" = r,
                  tabledata "VAT Entry" = r,
                  tabledata "Cust. Ledger Entry" = r,
                  tabledata "Vendor Ledger Entry" = r,
                  tabledata "Item Ledger Entry" = r,
                  tabledata "Bank Account Ledger Entry" = r,
                  tabledata "Value Entry" = r,
                  tabledata "Sales Invoice Header" = r,
                  tabledata "Sales Invoice Line" = r,
                  tabledata "Sales Cr.Memo Header" = r,
                  tabledata "Sales Cr.Memo Line" = r,
                  tabledata "Purch. Inv. Header" = r,
                  tabledata "Purch. Inv. Line" = r,
                  tabledata "Purch. Cr. Memo Hdr." = r,
                  tabledata "Purch. Cr. Memo Line" = r,
                  tabledata Customer = r,
                  tabledata Vendor = r,
                  tabledata "Bank Account" = r,
                  tabledata "G/L Account" = r;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TransactionStorageImpl: Codeunit "Transaction Storage Impl.";
        TransactionStorageTok: Label 'Transaction Storage', Locked = true;
        ExportActionTok: Label 'Export of the table %1 %2', Comment = '%1 = table name; %2 = either ''starts'' or ''ends''';
        NoOfCollectedRecordsTxt: Label '%1 records collected from the table %2', Comment = '%1 = number; %2 = table name';

    procedure ExportData(TransactStorageTaskEntry: Record "Transact. Storage Task Entry")
    var
        TempFieldList: Record Field temporary;
        TransactionStorageABS: Codeunit "Transaction Storage ABS";
        HandledIncomingDocs: Dictionary of [Text, Integer];
        MasterData: Dictionary of [Integer, List of [Code[50]]];
        DataJsonArrays: Dictionary of [Integer, JsonArray];
        TablesToExport: List of [Integer];
        TableID: Integer;
    begin
        TablesToExport := GetTablesToExport();
        foreach TableID in TablesToExport do
            CollectDataFromTable(DataJsonArrays, HandledIncomingDocs, TempFieldList, MasterData, TransactStorageTaskEntry, TableID);
        CollectMasterData(DataJsonArrays, MasterData);
        TransactionStorageABS.ArchiveTransactionsToABS(DataJsonArrays, HandledIncomingDocs, TransactStorageTaskEntry);
        TransactStorageTaskEntry.Modify();
    end;

    local procedure CollectDataFromTable(var DataJsonArrays: Dictionary of [Integer, JsonArray]; var HandledIncomingDocs: Dictionary of [Text, Integer]; var TempFieldList: Record Field temporary; var MasterData: Dictionary of [Integer, List of [Code[50]]]; TransactStorageTaskEntry: Record "Transact. Storage Task Entry"; TableID: Integer)
    var
        TransactStorageTableEntry: Record "Transact. Storage Table Entry";
        RecRef: RecordRef;
        RecordJsonObject: JsonObject;
        TableJsonArray: JsonArray;
    begin
        RecRef.Open(TableID);
        SetFieldsToHandle(TempFieldList, RecRef.Number);
        SetLoadFieldForRecRef(RecRef, TempFieldList);
        TransactionStorageImpl.GetExportDataTrack(TransactStorageTableEntry, RecRef);
        SetRangeOnDataTable(RecRef, TransactStorageTableEntry, TransactStorageTaskEntry);
        TransactStorageTableEntry."No. Of Records Exported" := 0;
        FeatureTelemetry.LogUsage('0000LK5', TransactionStorageTok, StrSubstNo(ExportActionTok, RecRef.Name, 'started'));
        if RecRef.FindSet() then begin
            Clear(TableJsonArray);
            repeat
                TransactStorageTableEntry."No. Of Records Exported" += 1;
                HandleTableFieldSet(RecordJsonObject, MasterData, TempFieldList, RecRef, true);
                TableJsonArray.Add(RecordJsonObject);
                TransactionStorageImpl.HandleIncomingDocuments(HandledIncomingDocs, RecRef);
            until RecRef.Next() = 0;
            DataJsonArrays.Add(RecRef.Number, TableJsonArray);
        end;
        TransactionStorageImpl.CheckTimeDeadline(TransactStorageTaskEntry);
        FeatureTelemetry.LogUsage('0000LK6', TransactionStorageTok, StrSubstNo(ExportActionTok, RecRef.Name, 'ended'));
        FeatureTelemetry.LogUsage(
            '0000LK7', TransactionStorageTok, StrSubstNo(NoOfCollectedRecordsTxt, TransactStorageTableEntry."No. Of Records Exported", RecRef.Name));
        TransactStorageTableEntry."Record Filters" := CopyStr(RecRef.GetFilters(), 1, MaxStrLen(TransactStorageTableEntry."Record Filters"));
        TransactStorageTableEntry.Modify();
        RecRef.Close();
    end;

    local procedure CollectMasterData(var DataJsonArrays: Dictionary of [Integer, JsonArray]; var MasterData: Dictionary of [Integer, List of [Code[50]]])
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
    begin
        foreach MasterDataTableNo in MasterData.Keys() do begin
            MasterDataCodes := MasterData.Get(MasterDataTableNo);
            RecRef.Open(MasterDataTableNo);
            SetFieldsToHandle(TempFieldList, RecRef.Number);
            SetLoadFieldForRecRef(RecRef, TempFieldList);
            KeyRef := RecRef.KeyIndex(1);
            FieldRef := KeyRef.FieldIndex(1);
            if MasterDataCodes.Count <> 0 then begin
                Clear(TableJsonArray);
                foreach MasterDataCode in MasterDataCodes do begin
                    FieldRef.SetRange(MasterDataCode);
                    RecRef.FindFirst();
                    HandleTableFieldSet(RecordJsonObject, MasterData, TempFieldList, RecRef, false);
                    TableJsonArray.Add(RecordJsonObject);
                end;
                DataJsonArrays.Add(RecRef.Number, TableJsonArray);
            end;
            RecRef.Close();
            Commit();
        end;
    end;

    local procedure SetRangeOnDataTable(var RecRef: RecordRef; var TransactStorageTableEntry: Record "Transact. Storage Table Entry"; TransactStorageTaskEntry: Record "Transact. Storage Task Entry")
    var
        SystemCreateAtFieldRef: FieldRef;
        LastHandledDate: Date;
        LastHandledTime: Time;
    begin
        // select records modified from the last handled date/time to the task starting date/time
        LastHandledDate := DT2Date(TransactStorageTableEntry."Last Handled Date/Time");
        LastHandledTime := DT2Time(TransactStorageTableEntry."Last Handled Date/Time");
        SystemCreateAtFieldRef := RecRef.Field(RecRef.SystemModifiedAtNo());
        SystemCreateAtFieldRef.SetFilter(
            '%1..%2', CreateDateTime(LastHandledDate, LastHandledTime + 1), TransactStorageTaskEntry."Starting Date/Time");
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
                if FieldRef.Relation in [Database::"G/L Account", Database::Customer, Database::Vendor, Database::"Bank Account", Database::"Fixed Asset"] then
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

    local procedure GetTablesToExport() TablesToExport: List of [Integer]
    begin
        TablesToExport.Add(Database::"G/L Entry");
        TablesToExport.Add(Database::"VAT Entry");
        TablesToExport.Add(Database::"Cust. Ledger Entry");
        TablesToExport.Add(Database::"Vendor Ledger Entry");
        TablesToExport.Add(Database::"Item Ledger Entry");
        TablesToExport.Add(Database::"Bank Account Ledger Entry");
        TablesToExport.Add(Database::"Value Entry");
        TablesToExport.Add(Database::"Sales Invoice Header");
        TablesToExport.Add(Database::"Sales Invoice Line");
        TablesToExport.Add(Database::"Sales Cr.Memo Header");
        TablesToExport.Add(Database::"Sales Cr.Memo Line");
        TablesToExport.Add(Database::"Purch. Inv. Header");
        TablesToExport.Add(Database::"Purch. Inv. Line");
        TablesToExport.Add(Database::"Purch. Cr. Memo Hdr.");
        TablesToExport.Add(Database::"Purch. Cr. Memo Line");
    end;

    local procedure GetFieldsToExport(TableID: Integer) FieldsToExport: List of [Integer]
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VendLedgEntry: Record "Vendor Ledger Entry";
        VATEntry: Record "VAT Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
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
            Database::"G/L Entry":
                begin
                    FieldsToExport.Add(GLEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(GLEntry.FieldNo("G/L Account No."));
                    FieldsToExport.Add(GLEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(GLEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(GLEntry.FieldNo("Document No."));
                    FieldsToExport.Add(GLEntry.FieldNo(Description));
                    FieldsToExport.Add(GLEntry.FieldNo(Amount));
                    FieldsToExport.Add(GLEntry.FieldNo("User ID"));
                    FieldsToExport.Add(GLEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("Business Unit Code"));
                    FieldsToExport.Add(GLEntry.FieldNo("Transaction No."));
                    FieldsToExport.Add(GLEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(GLEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(GLEntry.FieldNo("Source Type"));
                    FieldsToExport.Add(GLEntry.FieldNo("Source No."));
                    FieldsToExport.Add(GLEntry.FieldNo("VAT Reporting Date"));
                end;
            Database::"Cust. Ledger Entry":
                begin
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Customer No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Document No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Customer Name"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Currency Code"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Global Dimension 1 Code"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Global Dimension 2 Code"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("User ID"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Due Date"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Transaction No."));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(CustLedgEntry.FieldNo("External Document No."));
                end;
            Database::"Vendor Ledger Entry":
                begin
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Entry No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Vendor No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Posting Date"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Document No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Vendor Name"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Currency Code"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Buy-from Vendor No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Global Dimension 1 Code"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Global Dimension 2 Code"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("User ID"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Due Date"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Transaction No."));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(VendLedgEntry.FieldNo("External Document No."));
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
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Country/Region Code"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(ItemLedgerEntry.FieldNo("Qty. per Unit of Measure"));
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
                    FieldsToExport.Add(VATEntry.FieldNo("User ID"));
                    FieldsToExport.Add(VATEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(VATEntry.FieldNo("Transaction No."));
                    FieldsToExport.Add(VATEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(VATEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(VATEntry.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(VATEntry.FieldNo("VAT Reporting Date"));
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
                    FieldsToExport.Add(ValueEntry.FieldNo("Cost per Unit"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Sales Amount (Actual)"));
                    FieldsToExport.Add(ValueEntry.FieldNo("User ID"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Source Code"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Source Type"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Document Date"));
                    FieldsToExport.Add(ValueEntry.FieldNo("External Document No."));
                    FieldsToExport.Add(ValueEntry.FieldNo("Document Type"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Entry Type"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Purchase Amount (Actual)"));
                    FieldsToExport.Add(ValueEntry.FieldNo("Cost Amount (Actual)"));
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
                    FieldsToExport.Add(SalesInvHeader.FieldNo("No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Bill-to Customer No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Bill-to Name"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Bill-to Address"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Bill-to City"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("External Document No."));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("User ID"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Sell-to Address"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Sell-to City"));
                    FieldsToExport.Add(SalesInvHeader.FieldNo("Sell-to Customer Name"));
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Bill-to Customer No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Bill-to Name"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Bill-to Address"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Bill-to City"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("External Document No."));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("User ID"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Sell-to Address"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Sell-to City"));
                    FieldsToExport.Add(SalesCrMemoHeader.FieldNo("Sell-to Customer Name"));
                end;
            Database::"Purch. Inv. Header":
                begin
                    FieldsToExport.Add(PurchInvHeader.FieldNo("No."));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Pay-To Vendor No."));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Pay-To Name"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Pay-To Address"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Pay-To City"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("User ID"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Buy-From Address"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Buy-From City"));
                    FieldsToExport.Add(PurchInvHeader.FieldNo("Buy-From Vendor Name"));
                end;
            Database::"Purch. Cr. Memo Hdr.":
                begin
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("No."));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Pay-To Vendor No."));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Pay-To Name"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Pay-To Address"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Pay-To City"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Posting Date"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Posting Description"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Due Date"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Currency Code"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("VAT Registration No."));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Document Date"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("User ID"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Buy-From Address"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Buy-From City"));
                    FieldsToExport.Add(PurchCrMemoHeader.FieldNo("Buy-From Vendor Name"));
                end;
            Database::"Sales Invoice Line":
                begin
                    FieldsToExport.Add(SalesInvLine.FieldNo("Document No."));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Line No."));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(SalesInvLine.FieldNo(Type));
                    FieldsToExport.Add(SalesInvLine.FieldNo("No."));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Location Code"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Shipment Date"));
                    FieldsToExport.Add(SalesInvLine.FieldNo(Description));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Unit of Measure"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Unit Price"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("VAT %"));
                    FieldsToExport.Add(SalesInvLine.FieldNo(Amount));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Amount Including VAT"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Bill-to Customer No."));
                    FieldsToExport.Add(SalesInvLine.FieldNo("VAT Base Amount"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Line Amount"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Qty. per Unit of Measure"));
                    FieldsToExport.Add(SalesInvLine.FieldNo("Unit of Measure Code"));
                end;
            Database::"Sales Cr.Memo Line":
                begin
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Document No."));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Line No."));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Sell-to Customer No."));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo(Type));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("No."));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Location Code"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Shipment Date"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo(Description));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Unit of Measure"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("Unit Price"));
                    FieldsToExport.Add(SalesCrMemoLine.FieldNo("VAT %"));
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
                    FieldsToExport.Add(PurchInvLine.FieldNo("Document No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Line No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Buy-From Vendor No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo(Type));
                    FieldsToExport.Add(PurchInvLine.FieldNo("No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Location Code"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Expected Receipt Date"));
                    FieldsToExport.Add(PurchInvLine.FieldNo(Description));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Unit of Measure"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Unit Cost"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("VAT %"));
                    FieldsToExport.Add(PurchInvLine.FieldNo(Amount));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Amount Including VAT"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Pay-To Vendor No."));
                    FieldsToExport.Add(PurchInvLine.FieldNo("VAT Base Amount"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Line Amount"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Qty. per Unit of Measure"));
                    FieldsToExport.Add(PurchInvLine.FieldNo("Unit of Measure Code"));
                end;
            Database::"Purch. Cr. Memo Line":
                begin
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Document No."));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Line No."));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Buy-From Vendor No."));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo(Type));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("No."));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Location Code"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Expected Receipt Date"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo(Description));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Unit of Measure"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Unit Cost"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("VAT %"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo(Amount));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Amount Including VAT"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Pay-To Vendor No."));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("VAT Base Amount"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Line Amount"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Qty. per Unit of Measure"));
                    FieldsToExport.Add(PurchCrMemoLine.FieldNo("Unit of Measure Code"));
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
}