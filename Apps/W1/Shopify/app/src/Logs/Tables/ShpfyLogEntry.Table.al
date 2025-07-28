// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using System.Security.AccessControl;
using System.Security.User;
using System.Reflection;

/// <summary>
/// Table Shpfy Log Entry (ID 30115).
/// </summary>
table 30115 "Shpfy Log Entry"
{
    Access = Internal;
    Caption = 'Shopify Log Entry';
    DataClassification = SystemMetadata;
    DrillDownPageID = "Shpfy Log Entries";
    LookupPageID = "Shpfy Log Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Date and Time"; DateTime)
        {
            Caption = 'Date and Time';
            DataClassification = SystemMetadata;
        }
        field(3; "Time"; Time)
        {
            Caption = 'Time';
            DataClassification = SystemMetadata;
        }
        field(4; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(6; Request; BLOB)
        {
            Caption = 'Request';
            DataClassification = SystemMetadata;
        }
        field(7; Response; BLOB)
        {
            Caption = 'Response';
            DataClassification = SystemMetadata;
        }
        field(8; "Status Code"; Code[10])
        {
            Caption = 'Status Code';
            DataClassification = SystemMetadata;
        }
        field(9; "Status Description"; Text[500])
        {
            Caption = 'Status Description';
            DataClassification = SystemMetadata;
        }
        field(10; URL; Text[500])
        {
            Caption = 'URL';
            DataClassification = SystemMetadata;
            ExtendedDatatype = URL;
        }
        field(11; Method; Text[30])
        {
            Caption = 'Method';
            DataClassification = SystemMetadata;
        }
        field(12; "Has Error"; Boolean)
        {
            Caption = 'Has Error';
            DataClassification = SystemMetadata;
        }
#if not CLEANSCHEMA28
        field(13; "Request Id"; Guid)
        {
            Caption = 'Request Id';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Replaced with "Shpfy Request Id" field';
#if not CLEAN25
            ObsoleteState = Pending;
            ObsoleteTag = '25.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '28.0';
#endif
        }
#endif
        field(14; "Request Preview"; Text[50])
        {
            Caption = 'Request Preview';
            DataClassification = SystemMetadata;
        }
        field(15; "Response Preview"; Text[50])
        {
            Caption = 'Response Preview';
            DataClassification = SystemMetadata;
        }
        field(16; "Retry Count"; Integer)
        {
            Caption = 'Retry Count';
            DataClassification = SystemMetadata;
        }
        field(17; "Query Cost"; Integer)
        {
            Caption = 'Query Cost';
            DataClassification = SystemMetadata;
        }
        field(18; "Shpfy Request Id"; Text[100])
        {
            Caption = 'Request Id';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        DeleteLogEntriesLbl: Label 'Are you sure that you want to delete Shopify log entries?';

    /// <summary> 
    /// Delete Entries.
    /// </summary>
    /// <param name="DaysOld">Parameter of type Integer.</param>
    internal procedure DeleteEntries(DaysOld: Integer);
    begin
        if not Confirm(DeleteLogEntriesLbl) then
            exit;

        if DaysOld > 0 then begin
            SetFilter("Date and Time", '<=%1', CreateDateTime(Today - DaysOld, Time));
            if not IsEmpty then
                DeleteAll(false);
            SetRange("Date and Time");
        end else
            if not IsEmpty then
                DeleteAll(false);
    end;

    /// <summary> 
    /// Get Request.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetRequest(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields(Request);
        if Request.HasValue then begin
            Request.CreateInStream(InStream, TextEncoding::UTF8);
            exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
        end;
    end;

    /// <summary> 
    /// Get Response.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetResponse(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields(Response);
        if Response.HasValue then begin
            Response.CreateInStream(InStream, TextEncoding::UTF8);
            exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
        end;
    end;

    /// <summary> 
    /// Set Request.
    /// </summary>
    /// <param name="Data">Parameter of type Text.</param>
    internal procedure SetRequest(Data: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Request);
        Request.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(Data);
        "Request Preview" := CopyStr(Data, 1, 50);
        if Modify() then;
    end;

    /// <summary> 
    /// Set Response.
    /// </summary>
    /// <param name="Data">Parameter of type Text.</param>
    internal procedure SetResponse(Data: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Response);
        Response.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(Data);
        "Response Preview" := CopyStr(Data, 1, 50);
        if Modify() then;
    end;
}

