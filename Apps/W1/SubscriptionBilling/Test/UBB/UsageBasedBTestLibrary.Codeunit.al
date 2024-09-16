namespace Microsoft.SubscriptionBilling;

using System.IO;
using System.Globalization;
using Microsoft.Finance.Currency;

codeunit 139892 "Usage Based B. Test Library"
{
    Access = Internal;

    procedure ResetUsageBasedRecords()
    var
        UsageDataBilling: Record "Usage Data Billing";
        UsageDataGenericImport: Record "Usage Data Generic Import";
        UsageDataBlob: Record "Usage Data Blob";
        UsageDataImport: Record "Usage Data Import";
        UsageDataSubscription: Record "Usage Data Subscription";
        UsageDataCustomer: Record "Usage Data Customer";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        UsageDataSupplier: Record "Usage Data Supplier";
        GenericImportSettings: Record "Generic Import Settings";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchColumnDef: Record "Data Exch. Column Def";
    begin
        UsageDataBilling.Reset();
        UsageDataBilling.DeleteAll(false);
        UsageDataGenericImport.Reset();
        UsageDataGenericImport.DeleteAll(false);
        UsageDataBlob.Reset();
        UsageDataBlob.DeleteAll(false);
        UsageDataImport.Reset();
        UsageDataImport.DeleteAll(false);

        UsageDataSubscription.Reset();
        UsageDataSubscription.DeleteAll(false);
        UsageDataCustomer.Reset();
        UsageDataCustomer.DeleteAll(false);
        UsageDataSupplierReference.Reset();
        UsageDataSupplierReference.DeleteAll(false);
        UsageDataSupplier.Reset();
        UsageDataSupplier.DeleteAll(false);

        GenericImportSettings.Reset();
        GenericImportSettings.DeleteAll(false);

        DataExchDef.Reset();
        DataExchDef.DeleteAll(false);
        DataExchColumnDef.Reset();
        DataExchColumnDef.DeleteAll(false);
        DataExchLineDef.Reset();
        DataExchLineDef.DeleteAll(false);
        DataExchMapping.Reset();
        DataExchMapping.DeleteAll(false);
        DataExchFieldMapping.Reset();
        DataExchFieldMapping.DeleteAll(false);
        GenericImportSettings.Reset();
        GenericImportSettings.DeleteAll(false);
    end;

    procedure CreateUsageDataSupplier(var UsageDataSupplier: Record "Usage Data Supplier"; UsageDataSupplierType: Enum "Usage Data Supplier Type"; UnitPriceFromImport: Boolean; VendorInvoicePer: Enum "Vendor Invoice Per")
    begin
        UsageDataSupplier.Init();
        UsageDataSupplier."No." := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(UsageDataSupplier."No."));
        UsageDataSupplier.Description := CopyStr(LibraryRandom.RandText(80), 1, MaxStrLen(UsageDataSupplier.Description));
        UsageDataSupplier.Type := UsageDataSupplierType;
        UsageDataSupplier."Unit Price from Import" := UnitPriceFromImport;
        UsageDataSupplier."Vendor Invoice per" := VendorInvoicePer;
        UsageDataSupplier.Insert(false);
    end;

    procedure CreateUsageDataSupplierReference(var UsageDataSupplierReference: Record "Usage Data Supplier Reference"; SupplierNo: Code[20]; ReferenceType: Enum "Usage Data Reference Type")
    begin
        UsageDataSupplierReference.Init();
        UsageDataSupplierReference."Entry No." := 0;
        UsageDataSupplierReference."Supplier No." := SupplierNo;
        UsageDataSupplierReference.Type := ReferenceType;
        UsageDataSupplierReference.Insert(false);
    end;

    procedure CreateUsageDataImport(var UsageDataImport: Record "Usage Data Import"; SupplierNo: Code[20])
    begin
        UsageDataImport.Init();
        UsageDataImport."Entry No." := 0;
        UsageDataImport.Description := CopyStr(LibraryRandom.RandText(80), 1, MaxStrLen(UsageDataImport.Description));
        UsageDataImport."Supplier No." := SupplierNo;
        UsageDataImport.Insert(true);
    end;

    procedure CreateGenericImportSettings(var GenericImportSettings: Record "Generic Import Settings"; SupplierNo: Code[20]; CreateUsageDataCustomer: Boolean; CreateUsageDataSubscription: Boolean)
    begin
        GenericImportSettings.Init();
        GenericImportSettings."Usage Data Supplier No." := SupplierNo;
        GenericImportSettings."Create Customers" := CreateUsageDataCustomer;
        GenericImportSettings."Create Subscriptions" := CreateUsageDataSubscription;
        GenericImportSettings.Insert(true);
    end;

    procedure CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(var UsageDataBlob: Record "Usage Data Blob"; var RecordRef: RecordRef;
                                                                          ServiceObjectNo: Code[20]; ServiceCommitmentEntryNo: Integer)
    begin
        CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(UsageDataBlob, RecordRef, ServiceObjectNo, ServiceCommitmentEntryNo, WorkDate(), WorkDate(), WorkDate(), WorkDate(), LibraryRandom.RandDec(10, 2));
    end;

    procedure CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(var UsageDataBlob: Record "Usage Data Blob"; var RecordRef: RecordRef;
                                                                          ServiceObjectNo: Code[20]; ServiceCommitmentEntryNo: Integer;
                                                                          BillingPeriodStartingDate: Date; BillingPeriodEndingDate: Date; SubscriptionStartingDate: Date; SubscriptionEndingDate: Date; Quantity: Decimal)
    var
        OutStr: OutStream;
        FieldCount: Integer;
    begin
        UsageDataBlob.Data.CreateOutStream(OutStr, TextEncoding::UTF8);
        FieldCount := RecordRef.FieldCount();
        CreateOutStreamHeaders(OutStr, RecordRef, FieldCount);
        CreateOutStreamData(OutStr, RecordRef, FieldCount, ServiceObjectNo, BillingPeriodStartingDate, BillingPeriodEndingDate, SubscriptionStartingDate, SubscriptionEndingDate, Quantity);
        UsageDataBlob.ComputeHashValue();
        UsageDataBlob."Import Status" := Enum::"Processing Status"::Ok;
        UsageDataBlob.Modify(false);
    end;

    procedure CreateDataExchDefinition(var DataExchDef: Record "Data Exch. Def"; FileType: Option Xml,"Variable Text","Fixed Text",Json; DefinitionType: Enum "Data Exchange Definition Type";
                                                                                                                                                             FileEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS;
                                                                                                                                                             ColumnSeparator: Option " ",Tab,Semicolon,Comma,Space,Custom;
                                                                                                                                                             CustomColumnSeparator: Text[10];
                                                                                                                                                             HeaderLines: Integer)
    begin
        DataExchDef.Init();
        DataExchDef.Code := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(DataExchDef.Code));
        DataExchDef.Name := CopyStr(LibraryRandom.RandText(100), 1, MaxStrLen(DataExchDef.Name));
        DataExchDef."File Type" := FileType;
        DataExchDef.Type := DefinitionType;
        DataExchDef."Reading/Writing XMLport" := XmlPort::"Data Exch. Import - CSV";
        DataExchDef."File Encoding" := FileEncoding;
        DataExchDef."Column Separator" := ColumnSeparator;
        DataExchDef."Custom Column Separator" := CustomColumnSeparator;
        DataExchDef."Header Lines" := HeaderLines;
        DataExchDef.Insert(false);
    end;

    procedure CreateDataExchDefinitionLine(var DataExchLineDef: Record "Data Exch. Line Def"; DataExchDefCode: Code[20]; var RecordRef: RecordRef)
    begin
        DataExchLineDef.InsertRec(DataExchDefCode, CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(DataExchLineDef.Code)),
                                  CopyStr(LibraryRandom.RandText(100), 1, MaxStrLen(DataExchLineDef.Name)), RecordRef.FieldCount());
    end;

    procedure CreateDataExchColumnDefinition(var DataExchColumnDef: Record "Data Exch. Column Def"; DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20]; var RecordRef: RecordRef)
    var
        FieldRef: FieldRef;
        DataType: Option Text,Date,Decimal,DateTime;
    begin
        for i := 1 to RecordRef.FieldCount() do //Skip Entry No. = FieldNo = 1 and "Usage Data Import Entry No." = 2
            if RecordRef.FieldExist(i) then begin
                FieldRef := RecordRef.Field(i);
                if FieldRef.Type in [FieldRef.Type::Text, FieldRef.Type::Decimal, FieldRef.Type::Date, FieldRef.Type::Code] then begin
                    if FieldRef.Type <> FieldRef.Type::Code then
                        Evaluate(DataType, Format(FieldRef.Type))
                    else
                        Evaluate(DataType, Format(FieldRef.Type::Text));
                    DataExchColumnDef.InsertRecordForImport(DataExchDefCode, DataExchLineDefCode, i,
                                                         CopyStr(FieldRef.Name, 1, MaxStrLen(DataExchColumnDef.Name)), '', true, DataType, '',
                                                         CopyStr(CultureInfo.CurrentCultureName(), 1, MaxStrLen(DataExchColumnDef."Data Formatting Culture")));
                end;
            end;
    end;

    procedure CreateDataExchangeMapping(var DataExchMapping: Record "Data Exch. Mapping"; DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20]; var RecordRef: RecordRef)
    begin
        DataExchMapping.InsertRec(DataExchDefCode, DataExchLineDefCode, RecordRef.Number, CopyStr(LibraryRandom.RandText(250), 1, MaxStrLen(DataExchMapping.Name)),
                                    Codeunit::"Generic Import Mappings", 0, 0);
    end;

    procedure CreateDataExchangeFieldMapping(var DataExchFieldMapping: Record "Data Exch. Field Mapping"; DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20]; var RecordRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        for i := 1 to RecordRef.FieldCount() do //Skip Entry No. = FieldNo = 1 and "Usage Data Import Entry No." = 2
            if RecordRef.FieldExist(i) then begin
                FieldRef := RecordRef.Field(i);
                if FieldRef.Type in [FieldRef.Type::Text, FieldRef.Type::Decimal, FieldRef.Type::Date, FieldRef.Type::Code] then
                    DataExchFieldMapping.InsertRec(DataExchDefCode, DataExchLineDefCode, RecordRef.Number, i, i, true, 1);
            end;
    end;

    local procedure CreateOutStreamData(var OutStr: OutStream; var RecordRef: RecordRef; FieldCount: Integer;
                                                                          ServiceObjectNo: Code[20];
                                                                          BillingPeriodStartingDate: Date; BillingPeriodEndingDate: Date; SubscriptionStartingDate: Date; SubscriptionEndingDate: Date; Quantity: Decimal)
    var
        FieldRef: FieldRef;
    begin
        for i := 1 to FieldCount do //Skip Entry No. = FieldNo = 1 and "Usage Data Import Entry No." = 2
            if RecordRef.FieldExist(i) then begin
                FieldRef := RecordRef.Field(i);
                case FieldRef.Type of
                    FieldType::Code, FieldType::Text:
                        case FieldRef.Number of
                            6:
                                OutStr.WriteText(ServiceObjectNo);
                            25:
                                Currency.Get(LibraryERM.CreateCurrencyWithRandomExchRates());
                            else
                                OutStr.WriteText(CopyStr(LibraryRandom.RandText(100), 1, FieldRef.Length));
                        end;
                    FieldType::Decimal:
                        case FieldRef.Number of
                            21:
                                OutStr.WriteText(Format(Quantity));
                            else
                                OutStr.WriteText(Format(LibraryRandom.RandDec(100, 2)));
                        end;
                    FieldType::Date:
                        case FieldRef.Number of
                            13:
                                OutStr.WriteText(Format(SubscriptionStartingDate));
                            14:
                                OutStr.WriteText(Format(SubscriptionEndingDate));
                            15:
                                OutStr.WriteText(Format(BillingPeriodStartingDate));
                            16:
                                OutStr.WriteText(Format(BillingPeriodEndingDate));
                        end;
                end;
                if i <> FieldCount then
                    OutStr.WriteText(';');
            end;
        OutStr.WriteText();
    end;

    local procedure CreateOutStreamHeaders(var OutStr: OutStream; var RecordRef: RecordRef; FieldCount: Integer)
    var
        FieldRef: FieldRef;
    begin
        for i := 1 to FieldCount do //Skip Entry No. = FieldNo = 1 and "Usage Data Import Entry No." = 2
            if RecordRef.FieldExist(i) then begin
                FieldRef := RecordRef.Field(i);
                OutStr.WriteText(FieldRef.Name);
                if i <> FieldCount then
                    OutStr.WriteText(';')
            end;
        OutStr.WriteText(); //New line
    end;

    internal procedure ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDefCode: Code[20]; var GenericImportSettings: Record "Generic Import Settings")
    begin
        GenericImportSettings."Data Exchange Definition" := DataExchDefCode;
        GenericImportSettings.Modify(false);
    end;

    internal procedure CreateSimpleUsageDataGenericImport(var UsageDataGenericImport: Record "Usage Data Generic Import"; UsageDataImportEntryNo: Integer; ServiceObjectNo: Code[20]; CustomerNo: Code[20]; UnitCost: Decimal; BillingPeriodStartDate: Date; BillingPeriodEndDate: Date; SubscriptionStartDate: Date; SubscriptionEndDate: Date; Quantity: Integer)
    begin
        UsageDataGenericImport.Init();
        UsageDataGenericImport."Usage Data Import Entry No." := UsageDataImportEntryNo;
        UsageDataGenericImport."Service Object No." := ServiceObjectNo;
        UsageDataGenericImport."Customer ID" := CustomerNo;
        UsageDataGenericImport."Subscription ID" := CopyStr(LibraryRandom.RandText(80), 1, MaxStrLen(UsageDataGenericImport."Subscription ID"));
        UsageDataGenericImport."Billing Period Start Date" := BillingPeriodStartDate;
        UsageDataGenericImport."Billing Period End Date" := BillingPeriodEndDate;
        UsageDataGenericImport."Subscription Start Date" := SubscriptionStartDate;
        UsageDataGenericImport."Subscription End Date" := SubscriptionEndDate;
        UsageDataGenericImport.Cost := UnitCost;
        UsageDataGenericImport.Quantity := Quantity;
        UsageDataGenericImport."Cost Amount" := UnitCost * UsageDataGenericImport.Quantity;
        UsageDataGenericImport."Entry No." := 0;
        UsageDataGenericImport.Insert(false);
    end;

    var
        Currency: Record Currency;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        CultureInfo: Codeunit DotNet_CultureInfo;
        i: Integer;
}
