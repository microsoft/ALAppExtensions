// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1863 "C5 Schema Reader"
{
    TableNo = "C5 Schema Parameters";
  
    var
        SomethingWentWrongErr: Label 'Oops, something went wrong.\Please try again later.';  
        DefinitionFileMissingErr: Label 'Oops, it seems the definition file (exp00000.def) was missing from the zip file.';
        CopyToDatabaseFailedErr: Label 'Something went wrong with copying the zip file to Database.';

    trigger OnRun()
    begin
        ProcessZipFile(Rec."Zip File");
    end;

    local procedure ProcessZipFile(FileName: Text)
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
        NameValueBuffer: Record "Name/Value Buffer" temporary;
        C5HelperFunctions: Codeunit "C5 Helper Functions";
    begin
        C5SchemaParameters.GetSingleInstance();
        C5SchemaParameters.Validate("Zip File", FileName);
        C5SchemaParameters.Modify();
        StoreFileOnBlob(FileName);
        Codeunit.Run(Codeunit::"C5 Unzip", NameValueBuffer);
        ReadDefinitionFile(NameValueBuffer);
        C5HelperFunctions.CleanupFiles();
    end;

    procedure GetNumberOfAccounts(): Integer
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
    begin
        C5SchemaParameters.GetSingleInstance();
        exit(C5SchemaParameters."Total Accounts");
    end;

    procedure GetNumberOfHistoricalEntries(): Integer
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
    begin
        C5SchemaParameters.GetSingleInstance();
        exit(C5SchemaParameters."Total Historical Entries");
    end;

    procedure GetNumberOfItems(): Integer
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
    begin
        C5SchemaParameters.GetSingleInstance();
        exit(C5SchemaParameters."Total Items");
    end;

    procedure GetNumberOfCustomers(): Integer
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
    begin
        C5SchemaParameters.GetSingleInstance();
        exit(C5SchemaParameters."Total Customers");
    end;

    procedure GetNumberOfVendors(): Integer
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
    begin
        C5SchemaParameters.GetSingleInstance();
        exit(C5SchemaParameters."Total Vendors");
    end;

    local procedure StoreFileOnBlob(Filename: Text)
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
        FileManagement: Codeunit "File Management";
        C5Unzip: Codeunit "C5 Unzip";
        ZipFile: File;
        ZipInStream: InStream;
        BlobOutStream: OutStream;   
    begin
        if not FileManagement.ServerFileExists(Filename) then begin
            C5Unzip.OnZipfileMissing();
            Error(SomethingWentWrongErr);
        end;
            
        ZipFile.Open(Filename);
        ZipFile.CreateInStream(ZipInStream);

        C5SchemaParameters.GetSingleInstance();
        C5SchemaParameters."Zip File Blob".CreateOutStream(BlobOutStream);
        if not CopyStream(BlobOutStream, ZipInStream) then begin
            OnCopyToDataBaseFailed();
            Error(SomethingWentWrongErr);
        end;
        
        C5SchemaParameters.Modify();
    end;

    local procedure ReadDefinitionFile(var NameValueBuffer: Record "Name/Value Buffer")
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
        DefinitionFilePath: Text;
        DefinitionFile: File;
        Line: Text;
        TableName: Text;
        AccountsFound: Boolean;
        CustomersFound: Boolean;
        VendorsFound: Boolean;
        ItemsFound: Boolean;
        HistoryFound: Boolean;
        Number: Integer;
    begin
        C5SchemaParameters.GetSingleInstance();
        NameValueBuffer.SetFilter(Name, '*exp00000.def');
        if not NameValueBuffer.FindSet() then begin
            OnDefinitionFileMissing();
            Error(DefinitionFileMissingErr);
        end;

        DefinitionFilePath := NameValueBuffer.Name;
        DefinitionFile.TextMode(true);
        DefinitionFile.WriteMode(false);
        DefinitionFile.Open(DefinitionFilePath);
        repeat
            DefinitionFile.Read(Line);
            if StrPos(Line,',') > 0 then begin
                TableName := SELECTSTR(2, Line);
                case TableName of
                    '"LedTable"':
                    begin
                        AccountsFound := true;
                        Evaluate(Number, SelectStr(3, Line));
                        C5SchemaParameters."Total Accounts" := Number;
                    end;
                    '"VendTable"':
                    begin
                        VendorsFound := true;
                        Evaluate(Number, SelectStr(3, Line));
                        C5SchemaParameters."Total Vendors" := Number;
                    end;
                    '"CustTable"':
                    begin
                        CustomersFound := true;
                        Evaluate(Number, SelectStr(3, Line));
                        C5SchemaParameters."Total Customers" := Number;
                    end;
                    '"InvenTable"':
                    begin
                        ItemsFound := true;
                        Evaluate(Number, SelectStr(3, Line));
                        C5SchemaParameters."Total Items" := Number;
                    end;
                    '"LedTrans"':
                    begin
                        HistoryFound := true;
                        Evaluate(Number, SelectStr(3, Line));
                        C5SchemaParameters."Total Historical Entries" := Number;
                    end;
                end;
            end;
        until (DefinitionFile.Pos() = DefinitionFile.Len()) Or (AccountsFound AND CustomersFound AND VendorsFound AND ItemsFound AND HistoryFound);
        C5SchemaParameters.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyToDataBaseFailed()
    begin
    end;
    
    [IntegrationEvent(false, false)]
    local procedure OnDefinitionFileMissing()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Schema Reader", 'OnDefinitionFileMissing', '', false, false)] 
    local procedure OnDefinitionFileMissinggSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001DG', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, DefinitionFileMissingErr, DataClassification::SystemMetadata);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"C5 Schema Reader", 'OnCopyToDataBaseFailed', '', false, false)] 
    local procedure OnCopyToDataBaseFailedSubscriber()
    var
        C5MigrationDashboardMgt: Codeunit "C5 Migr. Dashboard Mgt";
    begin
        SendTraceTag('00001IK', C5MigrationDashboardMgt.GetC5MigrationTypeTxt(), VERBOSITY::Error, CopyToDatabaseFailedErr, DataClassification::SystemMetadata);
    end;
}

