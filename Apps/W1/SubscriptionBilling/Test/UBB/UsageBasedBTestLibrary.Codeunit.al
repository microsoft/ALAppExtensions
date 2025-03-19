namespace Microsoft.SubscriptionBilling;

using System.IO;
using System.Globalization;
using Microsoft.Finance.Currency;
using Microsoft.Sales.Document;

codeunit 139892 "Usage Based B. Test Library"
{
    Access = Internal;

    var
        Currency: Record Currency;
        CultureInfo: Codeunit DotNet_CultureInfo;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        UsageBasedDocTypeConv: Codeunit "Usage Based Doc. Type Conv.";
        i: Integer;

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
        DataExchDef."Reading/Writing XMLport" := Xmlport::"Data Exch. Import - CSV";
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
        for i := 1 to RecordRef.FieldCount() do // Skip Entry No. = FieldNo = 1 and "Usage Data Import Entry No." = 2
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
        for i := 1 to RecordRef.FieldCount() do // Skip Entry No. = FieldNo = 1 and "Usage Data Import Entry No." = 2
            if RecordRef.FieldExist(i) then begin
                FieldRef := RecordRef.Field(i);
                if FieldRef.Type in [FieldRef.Type::Text, FieldRef.Type::Decimal, FieldRef.Type::Date, FieldRef.Type::Code] then
                    DataExchFieldMapping.InsertRec(DataExchDefCode, DataExchLineDefCode, RecordRef.Number, i, i, true, 1);
            end;
    end;

    procedure CreateGenericImportSettings(var GenericImportSettings: Record "Generic Import Settings"; SupplierNo: Code[20]; CreateUsageDataCustomer: Boolean; CreateUsageDataSubscription: Boolean)
    begin
        GenericImportSettings.Init();
        GenericImportSettings."Usage Data Supplier No." := SupplierNo;
        GenericImportSettings."Create Customers" := CreateUsageDataCustomer;
        GenericImportSettings."Create Supplier Subscriptions" := CreateUsageDataSubscription;
        GenericImportSettings.Insert(true);
    end;

    procedure CreateSimpleUsageDataGenericImport(var UsageDataGenericImport: Record "Usage Data Generic Import"; UsageDataImportEntryNo: Integer; ServiceObjectNo: Code[20]; CustomerNo: Code[20]; UnitCost: Decimal; BillingPeriodStartDate: Date; BillingPeriodEndDate: Date; SubscriptionStartDate: Date; SubscriptionEndDate: Date; Quantity: Decimal)
    begin
        UsageDataGenericImport.Init();
        UsageDataGenericImport."Usage Data Import Entry No." := UsageDataImportEntryNo;
        UsageDataGenericImport."Subscription Header No." := ServiceObjectNo;
        UsageDataGenericImport."Customer ID" := CustomerNo;
        UsageDataGenericImport."Supp. Subscription ID" := CopyStr(LibraryRandom.RandText(80), 1, MaxStrLen(UsageDataGenericImport."Supp. Subscription ID"));
        UsageDataGenericImport."Billing Period Start Date" := BillingPeriodStartDate;
        UsageDataGenericImport."Billing Period End Date" := BillingPeriodEndDate;
        UsageDataGenericImport."Supp. Subscription Start Date" := SubscriptionStartDate;
        UsageDataGenericImport."Supp. Subscription End Date" := SubscriptionEndDate;
        UsageDataGenericImport.Cost := UnitCost;
        UsageDataGenericImport.Quantity := Quantity;
        UsageDataGenericImport."Cost Amount" := UnitCost * UsageDataGenericImport.Quantity;
        UsageDataGenericImport."Entry No." := 0;
        UsageDataGenericImport.Insert(false);
    end;

    procedure CreateSalesInvoiceAndAssignToBillingLine(var BillingLine: Record "Billing Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        BillingLine."Document Type" := BillingLine."Document Type"::Invoice;
        BillingLine."Document No." := SalesHeader."No.";
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

    procedure CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(var UsageDataBlob: Record "Usage Data Blob"; var RecordRef: RecordRef;
                                                                          ServiceObjectNo: Code[20]; ServiceCommitmentEntryNo: Integer)
    begin
        CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(
            UsageDataBlob,
            RecordRef,
            CopyStr(LibraryRandom.RandText(80), 1, 80),
            CopyStr(LibraryRandom.RandText(80), 1, 80),
            ServiceObjectNo,
            ServiceCommitmentEntryNo,
            WorkDate(),
            WorkDate(),
            WorkDate(),
            WorkDate(),
            LibraryRandom.RandDec(10, 2));
    end;

    procedure CreateUsageDataCSVFileBasedOnRecordAndImportToUsageDataBlob(var UsageDataBlob: Record "Usage Data Blob"; var RecordRef: RecordRef; CustomerId: Text[80]; SubscriptionId: Text[80]; ServiceObjectNo: Code[20]; ServiceCommitmentEntryNo: Integer;
            BillingPeriodStartingDate: Date; BillingPeriodEndingDate: Date; SubscriptionStartingDate: Date; SubscriptionEndingDate: Date; Quantity: Decimal)
    var
        FieldCount: Integer;
        OutStr: OutStream;
    begin
        UsageDataBlob.Data.CreateOutStream(OutStr, TextEncoding::UTF8);
        FieldCount := RecordRef.FieldCount();
        CreateOutStreamHeaders(UsageDataBlob, OutStr, RecordRef, FieldCount);
        CreateOutStreamData(UsageDataBlob, OutStr, RecordRef, FieldCount, CustomerId, SubscriptionId, ServiceObjectNo, ServiceCommitmentEntryNo, BillingPeriodStartingDate, BillingPeriodEndingDate, SubscriptionStartingDate, SubscriptionEndingDate, Quantity);
        UsageDataBlob.ComputeHashValue();
        UsageDataBlob."Import Status" := Enum::"Processing Status"::Ok;
        UsageDataBlob.Modify(false);
    end;

    procedure CreateOutStreamData(var UsageDataBlob: Record "Usage Data Blob"; var OutStr: OutStream; var RecordRef: RecordRef; FieldCount: Integer;
                                                                              CustomerId: Text[80]; SubscriptionId: Text[80];
                                                                              ServiceObjectNo: Code[20]; ServiceCommitmentEntryNo: Integer;
                                                                              BillingPeriodStartingDate: Date; BillingPeriodEndingDate: Date; SubscriptionStartingDate: Date; SubscriptionEndingDate: Date; Quantity: Decimal)
    var
        FieldRef: FieldRef;
    begin
        for i := 1 to FieldCount do // Skip Entry No. = FieldNo = 1 and "Usage Data Import Entry No." = 2
            if RecordRef.FieldExist(i) then begin
                FieldRef := RecordRef.Field(i);
                case FieldRef.Type of
                    FieldType::Code, FieldType::Text:
                        case FieldRef.Number of
                            6:
                                OutStr.WriteText(ServiceObjectNo);
                            7:
                                OutStr.WriteText(CustomerId);
                            10:
                                OutStr.WriteText(SubscriptionId);
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

    procedure CreateOutStreamHeaders(var UsageDataBlob: Record "Usage Data Blob"; var OutStr: OutStream; var RecordRef: RecordRef; FieldCount: Integer)
    var
        FieldRef: FieldRef;
    begin
        for i := 1 to FieldCount do // Skip Entry No. = FieldNo = 1 and "Usage Data Import Entry No." = 2
            if RecordRef.FieldExist(i) then begin
                FieldRef := RecordRef.Field(i);
                OutStr.WriteText(FieldRef.Name);
                if i <> FieldCount then
                    OutStr.WriteText(';')
            end;
        OutStr.WriteText(); // New line
    end;

    procedure ConnectDataExchDefinitionToUsageDataGenericSettings(DataExchDefCode: Code[20]; var GenericImportSettings: Record "Generic Import Settings")
    begin
        GenericImportSettings."Data Exchange Definition" := DataExchDefCode;
        GenericImportSettings.Modify(false);
    end;

    procedure DeleteAllUsageBasedRecords()
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchDef: Record "Data Exch. Def";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        GenericImportSettings: Record "Generic Import Settings";
        UsageDataBilling: Record "Usage Data Billing";
        UsageDataBlob: Record "Usage Data Blob";
        UsageDataCustomer: Record "Usage Data Supp. Customer";
        UsageDataGenericImport: Record "Usage Data Generic Import";
        UsageDataImport: Record "Usage Data Import";
        UsageDataSubscription: Record "Usage Data Supp. Subscription";
        UsageDataSupplier: Record "Usage Data Supplier";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
    begin
        UsageDataBilling.DeleteAll(false);
        UsageDataGenericImport.DeleteAll(false);
        UsageDataBlob.DeleteAll(false);
        UsageDataImport.DeleteAll(false);

        UsageDataSubscription.DeleteAll(false);
        UsageDataCustomer.DeleteAll(false);
        UsageDataSupplierReference.DeleteAll(false);
        UsageDataSupplier.DeleteAll(false);

        GenericImportSettings.DeleteAll(false);

        DataExchDef.DeleteAll(false);
        DataExchColumnDef.DeleteAll(false);
        DataExchLineDef.DeleteAll(false);
        DataExchMapping.DeleteAll(false);
        DataExchFieldMapping.DeleteAll(false);
        GenericImportSettings.DeleteAll(false);
    end;

    procedure MockBillingLine(var BillingLine: Record "Billing Line")
    begin
        BillingLine.InitNewBillingLine();
        BillingLine.Insert(false);
    end;

    procedure MockBillingLineWithServObjectNo(var BillingLine: Record "Billing Line")
    begin
        BillingLine.InitNewBillingLine();
        BillingLine."Subscription Header No." := LibraryUtility.GenerateGUID();
        BillingLine."Subscription Line Entry No." := LibraryRandom.RandInt(10000);
        BillingLine.Insert(false);
    end;

    procedure MockCustomerContractLine(var CustomerContractLine: Record "Cust. Sub. Contract Line")
    var
        CustomerContract: Record "Customer Subscription Contract";
    begin
        CustomerContract.Init();
        CustomerContract.Insert(true);
        CustomerContractLine.Init();
        CustomerContractLine."Subscription Contract No." := CustomerContract."No.";
        CustomerContractLine."Contract Line Type" := CustomerContractLine."Contract Line Type"::Item;
        CustomerContractLine.Insert(false);
    end;

    procedure MockServiceCommitmentLine(var ServiceCommitment: Record "Subscription Line")
    var
        ServiceObject: Record "Subscription Header";
    begin
        ServiceObject.Init();
        ServiceObject.Insert(true);
        ServiceCommitment.Init();
        ServiceCommitment."Subscription Header No." := ServiceObject."No.";
        ServiceCommitment."Entry No." := 0;
        ServiceCommitment.Partner := ServiceCommitment.Partner::Customer;
        ServiceCommitment.Insert(false);
    end;

    procedure MockUsageDataBillingForContractLine(var UsageDataBilling: Record "Usage Data Billing"; ServicePartner: Enum "Service Partner"; ContractNo: Code[20]; ContractLine: Integer)
    begin
        UsageDataBilling.Init();
        UsageDataBilling.Partner := ServicePartner;
        UsageDataBilling."Subscription Contract No." := ContractNo;
        UsageDataBilling."Subscription Contract Line No." := ContractLine;
        UsageDataBilling.Insert(false);
    end;

    procedure MockUsageDataBillingForDocuments(var UsageDataBilling: Record "Usage Data Billing"; DocType: Enum "Sales Document Type"; DocNo: Code[20]; DocLineNo: Integer)
    begin
        UsageDataBilling.Init();
        UsageDataBilling.Partner := UsageDataBilling.Partner::Customer;
        UsageDataBilling."Document Type" := UsageBasedDocTypeConv.ConvertSalesDocTypeToUsageBasedBillingDocType(DocType);
        UsageDataBilling."Document No." := DocNo;
        UsageDataBilling."Document Line No." := DocLineNo;
        UsageDataBilling.Insert(false);
    end;

    procedure MockUsageDataBillingForServiceCommitmentLine(var UsageDataBilling: Record "Usage Data Billing"; ServCommPartner: Enum "Service Partner"; ServCommServiceObjectNo: Code[20]; ServCommLineNo: Integer)
    begin
        UsageDataBilling.Init();
        UsageDataBilling.Partner := ServCommPartner;
        UsageDataBilling."Subscription Header No." := ServCommServiceObjectNo;
        UsageDataBilling."Subscription Line Entry No." := ServCommLineNo;
        UsageDataBilling.Insert(false);
    end;

    procedure MockUsageDataForBillingLine(var UsageDataBilling: Record "Usage Data Billing"; BillingLine: Record "Billing Line")
    begin
        UsageDataBilling.Init();
        UsageDataBilling.Partner := UsageDataBilling.Partner::Customer;
        UsageDataBilling."Subscription Header No." := BillingLine."Subscription Header No.";
        UsageDataBilling."Subscription Line Entry No." := BillingLine."Subscription Line Entry No.";
        UsageDataBilling."Document Type" := UsageBasedDocTypeConv.ConvertRecurringBillingDocTypeToUsageBasedBillingDocType(BillingLine."Document Type");
        UsageDataBilling."Document No." := BillingLine."Document No.";
        UsageDataBilling."Billing Line Entry No." := BillingLine."Entry No.";
        UsageDataBilling."Billing Line Entry No." := BillingLine."Entry No.";
        UsageDataBilling.Insert(false);
    end;

}
