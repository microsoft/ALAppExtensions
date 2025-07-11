namespace Microsoft.Bank.StatementImport.Yodlee;

using System.IO;
using Microsoft.Bank.Setup;

table 1452 "MS - Yodlee Data Exchange Def"
{
    ReplicateData = false;
    DataPerCompany = false;
    Permissions = TableData "Bank Export/Import Setup" = rimd;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(2; "Data Exchange Code"; Code[20])
        {
        }
        field(3; "Data Exchange Def"; BLOB)
        {
        }
        field(4; "Processing Codeunit ID"; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        YodleeTelemetryCategoryTok: Label 'AL Yodlee', Locked = true;
        UnsuccessfulDataExchSetupErr: Label 'Unable to set up data exchange definition. Unable to insert %1 for data exchange definition %2.', Locked = true;

    procedure ResetDataExchToDefault();
    begin
        ResetDataExchDefinitionToDefault();
        ResetYSL11DataExchDefinitionToDefault();
        ResetBankImportToDefault();
    end;

    local procedure ResetDataExchDefinitionToDefault();
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
    begin
        if DataExchDef.GET(GetYodleeLegacyAPIDataExchDefinitionCode()) then
            DataExchDef.DELETE(true);

        DataExchDef.Code := GetYodleeLegacyAPIDataExchDefinitionCode();
        DataExchDef.Name := 'Envestnet Yodlee - Bank Feeds Service';
        DataExchDef."Ext. Data Handling Codeunit" := 1413;
        DataExchDef."Reading/Writing Codeunit" := 1200;
        if not DataExchDef.INSERT() then begin
            Session.LogMessage('0000HBA', StrSubstNo(UnsuccessfulDataExchSetupErr, DataExchDef.TableCaption(), DataExchDef.Code), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            exit;
        end;
        DataExchLineDef."Data Exch. Def Code" := DataExchDef.Code;
        DataExchLineDef.Code := 'TRANSACTIONFEED';
        DataExchLineDef.Name := 'Definition';
        DataExchLineDef."Data Line Tag" := '/root/root/transaction';
        if not DataExchLineDef.INSERT() then begin
            Session.LogMessage('0000HBB', StrSubstNo(UnsuccessfulDataExchSetupErr, DataExchLineDef.TableCaption(), DataExchDef.Code), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            exit;
        end;
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 2, 'transactionId', '/root/root/transaction/id', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 3, 'description', '/root/root/transaction/description/original', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 5, 'postDate', '/root/root/transaction/date', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 7, 'amount', '/root/root/transaction/amount/amount', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 8, 'currencyCode', '/root/root/transaction/amount/currency', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 10, 'itemAccountId', '/root/root/transaction/accountId', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 21, 'balanceAmount', '/root/root/transaction/runningBalance/amount', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 22, 'balanceCurrencyCode', '/root/root/transaction/runningBalance/currency', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 23, 'transactionType', '/root/root/transaction/baseType', 'DEBIT');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 24, 'checkNumber', '/root/root/transaction/checkNumber', '');
        DataExchMapping."Data Exch. Def Code" := DataExchDef.Code;
        DataExchMapping."Data Exch. Line Def Code" := DataExchLineDef.Code;
        DataExchMapping."Table ID" := 274;
        DataExchMapping."Mapping Codeunit" := 1451;
        DataExchMapping."Data Exch. No. Field ID" := 17;
        DataExchMapping."Data Exch. Line Field ID" := 18;
        if not DataExchMapping.INSERT() then begin
            Session.LogMessage('0000HBC', StrSubstNo(UnsuccessfulDataExchSetupErr, DataExchMapping.TableCaption(), DataExchDef.Code), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            exit;
        end;
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 2, 70, false);
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 3, 23, false);
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 5, 5, false);
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 7, 7, false);
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 23, 7, false);
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 24, 14, true);
    end;

    [Scope('OnPrem')]
    procedure ResetYSL11DataExchDefinitionToDefault();
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
    begin
        if DataExchDef.GET(GetYodleeAPI11DataExchDefinitionCode()) then
            DataExchDef.DELETE(true);

        DataExchDef.Code := GetYodleeAPI11DataExchDefinitionCode();
        DataExchDef.Name := 'Envestnet Yodlee - Bank Feeds Service';
        DataExchDef."Ext. Data Handling Codeunit" := 1413;
        DataExchDef."Reading/Writing Codeunit" := 1200;
        if not DataExchDef.INSERT() then begin
            Session.LogMessage('0000HBD', StrSubstNo(UnsuccessfulDataExchSetupErr, DataExchDef.TableCaption(), DataExchDef.Code), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            exit;
        end;
        if DataExchLineDef.Get(DataExchDef.Code, 'TRANSACTIONFEED') then
            DataExchLineDef.Delete(true);
        DataExchLineDef."Data Exch. Def Code" := DataExchDef.Code;
        DataExchLineDef.Code := 'TRANSACTIONFEED';
        DataExchLineDef.Name := 'Definition';
        DataExchLineDef."Data Line Tag" := '/root/root/transaction';
        if not DataExchLineDef.INSERT() then begin
            Session.LogMessage('0000HBE', StrSubstNo(UnsuccessfulDataExchSetupErr, DataExchLineDef.TableCaption(), DataExchDef.Code), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            exit;
        end;

        DataExchColumnDef.SetRange("Data Exch. Def Code", DataExchDef.Code);
        if not DataExchColumnDef.IsEmpty() then
            DataExchColumnDef.DeleteAll();
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 2, 'transactionId', '/root/root/transaction/id', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 3, 'description', '/root/root/transaction/description/original', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 5, 'postDate', '/root/root/transaction/date', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 7, 'amount', '/root/root/transaction/amount/amount', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 8, 'currencyCode', '/root/root/transaction/amount/currency', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 10, 'itemAccountId', '/root/root/transaction/accountId', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 21, 'balanceAmount', '/root/root/transaction/runningBalance/amount', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 22, 'balanceCurrencyCode', '/root/root/transaction/runningBalance/currency', '');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 23, 'transactionType', '/root/root/transaction/baseType', 'DEBIT');
        InsertDataExchColumnDef(DataExchDef, DataExchLineDef, 24, 'checkNumber', '/root/root/transaction/checkNumber', '');

        DataExchMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchMapping.SetRange("Table ID", 274);
        DataExchMapping.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        if not DataExchMapping.IsEmpty() then
            DataExchMapping.DeleteAll();
        DataExchMapping."Data Exch. Def Code" := DataExchDef.Code;
        DataExchMapping."Data Exch. Line Def Code" := DataExchLineDef.Code;
        DataExchMapping."Table ID" := 274;
        DataExchMapping."Mapping Codeunit" := 1451;
        DataExchMapping."Data Exch. No. Field ID" := 17;
        DataExchMapping."Data Exch. Line Field ID" := 18;
        if not DataExchMapping.INSERT() then begin
            Session.LogMessage('0000HBF', StrSubstNo(UnsuccessfulDataExchSetupErr, DataExchMapping.TableCaption(), DataExchDef.Code), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            exit;
        end;

        DataExchFieldMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchFieldMapping.SetRange("Table ID", DataExchMapping."Table ID");
        DataExchFieldMapping.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        if not DataExchFieldMapping.IsEmpty() then
            DataExchFieldMapping.DeleteAll();
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 2, 70, false);
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 3, 23, false);
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 5, 5, false);
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 7, 7, false);
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 23, 7, false);
        InsertDataExchFieldMapping(DataExchDef, DataExchLineDef, DataExchMapping, 24, 14, true);
    end;

    local procedure InsertDataExchColumnDef(var DataExchDef: Record "Data Exch. Def"; var DataExchLineDef: Record "Data Exch. Line Def"; ColumnNo: Integer; Name: Text[250]; Path: Text[250]; NegativeSignIdentifier: Text[30])
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
    begin
        DataExchColumnDef."Data Exch. Def Code" := DataExchDef.Code;
        DataExchColumnDef."Data Exch. Line Def Code" := DataExchLineDef.Code;
        DataExchColumnDef."Column No." := ColumnNo;
        DataExchColumnDef.Name := Name;
        DataExchColumnDef.Path := Path;
        DataExchColumnDef."Negative-Sign Identifier" := NegativeSignIdentifier;
        if not DataExchColumnDef.INSERT() then begin
            Session.LogMessage('0000HBG', StrSubstNo(UnsuccessfulDataExchSetupErr, DataExchColumnDef.TableCaption(), DataExchColumnDef."Data Exch. Def Code"), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            exit;
        end;
    end;

    local procedure InsertDataExchFieldMapping(var DataExchDef: Record "Data Exch. Def"; var DataExchLineDef: Record "Data Exch. Line Def"; var DataExchMapping: Record "Data Exch. Mapping"; ColumnNo: Integer; FieldID: Integer; Optional: Boolean)
    var
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
    begin
        DataExchFieldMapping."Data Exch. Def Code" := DataExchDef.Code;
        DataExchFieldMapping."Data Exch. Line Def Code" := DataExchLineDef.Code;
        DataExchFieldMapping."Table ID" := DataExchMapping."Table ID";
        DataExchFieldMapping."Column No." := ColumnNo;
        DataExchFieldMapping."Field ID" := FieldID;
        DataExchFieldMapping.Optional := Optional;
        if not DataExchFieldMapping.INSERT() then begin
            Session.LogMessage('0000HBH', StrSubstNo(UnsuccessfulDataExchSetupErr, DataExchFieldMapping.TableCaption(), DataExchFieldMapping."Data Exch. Def Code"), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            exit;
        end;
    end;

    procedure ResetBankImportToDefault();
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        DataExchDef: Record "Data Exch. Def";
    begin
        if not DataExchDef.Get(GetYodleeAPI11DataExchDefinitionCode()) then
            exit;
        if BankExportImportSetup.GET(GetYodleeAPI11DataExchDefinitionCode()) then
            BankExportImportSetup.DELETE(true);
        if BankExportImportSetup.GET(GetYodleeLegacyAPIDataExchDefinitionCode()) then
            BankExportImportSetup.DELETE(true);

        BankExportImportSetup.INIT();
        BankExportImportSetup.Code := DataExchDef.Code;
        BankExportImportSetup.Name := DataExchDef.Name;
        BankExportImportSetup."Data Exch. Def. Code" := DataExchDef.Code;
        BankExportImportSetup.Direction := BankExportImportSetup.Direction::Import;
        BankExportImportSetup."Processing Codeunit ID" := 1270;
        if not BankExportImportSetup.INSERT() then begin
            Session.LogMessage('0000HBI', StrSubstNo(UnsuccessfulDataExchSetupErr, BankExportImportSetup.TableCaption(), BankExportImportSetup.Code), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            exit;
        end;
    end;

    procedure UpdateMSYodleeBankServiceSetupBankStmtImportFormat();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        if MSYodleeBankServiceSetup.Get() then begin
            MSYodleeBankServiceSetup.Validate("Bank Feed Import Format", GetYodleeAPI11DataExchDefinitionCode());
            MSYodleeBankServiceSetup.Modify(true);
        end;
    end;

    procedure ExportDataExchDefinition();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        DataExchDef: Record "Data Exch. Def";
    begin
        MSYodleeBankServiceSetup.Get();
        DataExchDef.GET(MSYodleeBankServiceSetup."Bank Feed Import Format");
        DataExchDef.SETRECFILTER();
        XMLPORT.RUN(XMLPORT::"Imp / Exp Data Exch Def & Map", false, false, DataExchDef);
    end;

    procedure GetYodleeAPI11DataExchDefinitionCode(): Code[20];
    begin
        exit('YODLEE11BANKFEED')
    end;

    procedure GetYodleeLegacyAPIDataExchDefinitionCode(): Code[20];
    begin
        exit('YODLEEBANKFEED')
    end;
}

