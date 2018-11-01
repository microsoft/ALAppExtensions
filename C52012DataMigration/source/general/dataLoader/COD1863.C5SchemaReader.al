// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1863 "C5 Schema Reader"
{
    var
        DefinitionFileMissingErr: Label 'Oops, it seems the definition file (exp00000.def) was missing from the zip file.';

    trigger OnRun()
    begin
        ProcessZipFile();
    end;

    local procedure ProcessZipFile()
    var
        NameValueBuffer: Record "Name/Value Buffer" temporary;
    begin

        Codeunit.Run(Codeunit::"C5 Unzip", NameValueBuffer);
        ReadDefinitionFile(NameValueBuffer);
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

    procedure GetDefinitionFileMissingErrorTxt(): Text[250]
    begin
        exit(CopyStr(DefinitionFileMissingErr, 1, 250));
    end;

    local procedure ReadDefinitionFile(var NameValueBuffer: Record "Name/Value Buffer")
    var
        C5SchemaParameters: Record "C5 Schema Parameters";
        Line: Text;
        TableName: Text;
        AccountsFound: Boolean;
        CustomersFound: Boolean;
        VendorsFound: Boolean;
        ItemsFound: Boolean;
        HistoryFound: Boolean;
        Number: Integer;
        StreamContent: InStream;
    begin
        C5SchemaParameters.GetSingleInstance();
        NameValueBuffer.SetFilter(Name, '*exp00000.def');
        if not NameValueBuffer.FindSet() then begin
            OnDefinitionFileMissing();
            Error(DefinitionFileMissingErr);
        end;
        NameValueBuffer.CalcFields("Value BLOB");
        NameValueBuffer."Value BLOB".CreateInStream(StreamContent);

        repeat
            StreamContent.ReadText(Line);
            if StrPos(Line, ',') > 0 then begin
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
        until (StreamContent.EOS()) Or (AccountsFound AND CustomersFound AND VendorsFound AND ItemsFound AND HistoryFound);
        C5SchemaParameters.Modify();
        Commit();

    end;

    [IntegrationEvent(false, false)]
    local procedure OnDefinitionFileMissing()
    begin
    end;

}

