table 1452 "MS - Yodlee Data Exchange Def"
{
    ReplicateData = false;
    DataPerCompany = false;
    Permissions = TableData 1200 = rimd;

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

    procedure ResetDataExchToDefault();
    begin
        ResetDataExchDefinitionToDefault();
        ResetYSL11DataExchDefinitionToDefault();
        ResetBankImportToDefault();
    end;

    local procedure ResetDataExchDefinitionToDefault();
    var
        DataExchDef: Record 1222;
        DataExchLineDef: Record 1227;
        DataExchMapping: Record 1224;
    begin
        IF DataExchDef.GET(GetYodleeLegacyAPIDataExchDefinitionCode()) THEN
            DataExchDef.DELETE(TRUE);

        DataExchDef.Code := GetYodleeLegacyAPIDataExchDefinitionCode();
        DataExchDef.Name := 'Envestnet Yodlee - Bank Feeds Service';
        DataExchDef."Ext. Data Handling Codeunit" := 1413;
        DataExchDef."Reading/Writing Codeunit" := 1200;
        DataExchDef.INSERT();
        DataExchLineDef."Data Exch. Def Code" := DataExchDef.Code;
        DataExchLineDef.Code := 'TRANSACTIONFEED';
        DataExchLineDef.Name := 'Definition';
        DataExchLineDef."Data Line Tag" := '/root/root/transaction';
        DataExchLineDef.INSERT();
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
        DataExchMapping.INSERT();
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
        DataExchDef: Record 1222;
        DataExchLineDef: Record 1227;
        DataExchMapping: Record 1224;
        DataExchColumnDef: Record 1223;
        DataExchFieldMapping: Record 1225;
    begin
        IF DataExchDef.GET(GetYodleeAPI11DataExchDefinitionCode()) THEN
            DataExchDef.DELETE(TRUE);

        DataExchDef.Code := GetYodleeAPI11DataExchDefinitionCode();
        DataExchDef.Name := 'Envestnet Yodlee - Bank Feeds Service';
        DataExchDef."Ext. Data Handling Codeunit" := 1413;
        DataExchDef."Reading/Writing Codeunit" := 1200;
        DataExchDef.INSERT();
        if DataExchLineDef.Get(DataExchDef.Code, 'TRANSACTIONFEED') then
            DataExchLineDef.Delete(true);
        DataExchLineDef."Data Exch. Def Code" := DataExchDef.Code;
        DataExchLineDef.Code := 'TRANSACTIONFEED';
        DataExchLineDef.Name := 'Definition';
        DataExchLineDef."Data Line Tag" := '/root/root/transaction';
        DataExchLineDef.INSERT();

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
        DataExchMapping.INSERT();

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

    local procedure InsertDataExchColumnDef(var DataExchDef: Record 1222; var DataExchLineDef: Record 1227; ColumnNo: Integer; Name: Text[250]; Path: Text[250]; NegativeSignIdentifier: Text[30])
    var
        DataExchColumnDef: Record 1223;
    begin
        DataExchColumnDef."Data Exch. Def Code" := DataExchDef.Code;
        DataExchColumnDef."Data Exch. Line Def Code" := DataExchLineDef.Code;
        DataExchColumnDef."Column No." := ColumnNo;
        DataExchColumnDef.Name := Name;
        DataExchColumnDef.Path := Path;
        DataExchColumnDef."Negative-Sign Identifier" := NegativeSignIdentifier;
        DataExchColumnDef.INSERT();
    end;

    local procedure InsertDataExchFieldMapping(var DataExchDef: Record 1222; var DataExchLineDef: Record 1227; var DataExchMapping: record 1224; ColumnNo: Integer; FieldID: Integer; Optional: Boolean)
    var
        DataExchFieldMapping: Record 1225;
    begin
        DataExchFieldMapping."Data Exch. Def Code" := DataExchDef.Code;
        DataExchFieldMapping."Data Exch. Line Def Code" := DataExchLineDef.Code;
        DataExchFieldMapping."Table ID" := DataExchMapping."Table ID";
        DataExchFieldMapping."Column No." := ColumnNo;
        DataExchFieldMapping."Field ID" := FieldID;
        DataExchFieldMapping.Optional := Optional;
        DataExchFieldMapping.INSERT();
    end;

    procedure ResetBankImportToDefault();
    var
        BankExportImportSetup: Record 1200;
        DataExchDef: Record 1222;
    begin
        DataExchDef.Get(GetYodleeAPI11DataExchDefinitionCode());
        IF BankExportImportSetup.GET(GetYodleeAPI11DataExchDefinitionCode()) THEN
            BankExportImportSetup.DELETE(TRUE);
        IF BankExportImportSetup.GET(GetYodleeLegacyAPIDataExchDefinitionCode()) THEN
            BankExportImportSetup.DELETE(TRUE);

        BankExportImportSetup.INIT();
        BankExportImportSetup.Code := DataExchDef.Code;
        BankExportImportSetup.Name := DataExchDef.Name;
        BankExportImportSetup."Data Exch. Def. Code" := DataExchDef.Code;
        BankExportImportSetup.Direction := BankExportImportSetup.Direction::Import;
        BankExportImportSetup."Processing Codeunit ID" := 1270;
        BankExportImportSetup.INSERT(TRUE);
    end;

    procedure UpdateMSYodleeBankServiceSetupBankStmtImportFormat();
    var
        MSYodleeBankServiceSetup: Record 1450;
    begin
        if MSYodleeBankServiceSetup.Get() then begin
            MSYodleeBankServiceSetup.Validate("Bank Feed Import Format", GetYodleeAPI11DataExchDefinitionCode());
            MSYodleeBankServiceSetup.Modify(true);
        end;
    end;

    procedure ExportDataExchDefinition();
    var
        MSYodleeBankServiceSetup: Record 1450;
        DataExchDef: Record 1222;
    begin
        MSYodleeBankServiceSetup.Get();
        DataExchDef.GET(MSYodleeBankServiceSetup."Bank Feed Import Format");
        DataExchDef.SETRECFILTER();
        XMLPORT.RUN(XMLPORT::"Imp / Exp Data Exch Def & Map", FALSE, FALSE, DataExchDef);
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

