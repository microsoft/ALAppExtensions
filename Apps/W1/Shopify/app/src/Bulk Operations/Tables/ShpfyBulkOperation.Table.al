// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

table 30148 "Shpfy Bulk Operation"
{
    Caption = 'Shopify Bulk Operation';
    DataClassification = SystemMetadata;
    Access = Internal;

    fields
    {
        field(1; "Bulk Operation Id"; BigInteger)
        {
            Caption = 'Bulk Operation Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Shop".Code;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionMembers = mutation,query;
            OptionCaption = 'mutation,query';
        }
        field(4; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(5; Status; Enum "Shpfy Bulk Operation Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(6; "Completed At"; DateTime)
        {
            Caption = 'Completed At';
            DataClassification = SystemMetadata;
        }
        field(7; "Error Code"; Text[250])
        {
            Caption = 'Error Code';
            DataClassification = SystemMetadata;
        }
        field(8; "Bulk Operation Type"; Enum "Shpfy Bulk Operation Type")
        {
            Caption = 'Bulk Operation Type';
            DataClassification = SystemMetadata;
        }
        field(9; Url; Text[1024])
        {
            Caption = 'Url';
            DataClassification = SystemMetadata;
        }
        field(10; "Partial Data Url"; Text[1024])
        {
            Caption = 'Partial Data Url';
            DataClassification = SystemMetadata;
        }
        field(11; "Request Data"; Blob)
        {
            Caption = 'Request Data';
            DataClassification = SystemMetadata;
        }
        field(12; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Bulk Operation Id", "Shop Code", Type)
        {
            Clustered = true;
        }
        key(Key2; SystemCreatedAt)
        {
        }
    }

    trigger OnModify()
    var
        IBulkOperation: Interface "Shpfy IBulk Operation";
    begin
        if Processed then
            exit;

        IBulkOperation := "Bulk Operation Type";
        case Status of
            Status::Completed:
                IBulkOperation.RevertFailedRequests(Rec);
            Status::Canceled, Status::Failed:
                IBulkOperation.RevertAllRequests(Rec);
        end;
        Processed := true;
    end;

    internal procedure SetRequestData(RequestData: JsonArray)
    var
        OutStream: OutStream;
    begin
        Clear("Request Data");
        "Request Data".CreateOutStream(OutStream);
        if RequestData.WriteTo(OutStream) then
            Modify();
    end;

    internal procedure GetRequestData() RequestData: JsonArray
    var
        InStream: InStream;
        RequestText: Text;
    begin
        CalcFields("Request Data");
        if "Request Data".HasValue then begin
            "Request Data".CreateInStream(InStream);
            InStream.ReadText(RequestText);
            RequestData.ReadFrom(RequestText);
        end;
    end;
}