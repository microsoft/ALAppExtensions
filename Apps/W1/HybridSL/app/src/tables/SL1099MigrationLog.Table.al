// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47092 "SL 1099 Migration Log"
{
    Access = Internal;
    Caption = 'SL 1099 Migration Log';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
        }
        field(3; "SL Data Value"; Text[2])
        {
            Caption = 'SL Data Value';
        }
        field(4; "SL 1099 Box No."; Text[3])
        {
            Caption = 'SL 1099 Box No.';
        }
        field(5; "Form Type"; Text[4])
        {
            Caption = 'Form Type';
        }
        field(6; "BC IRS 1099 Code"; Code[10])
        {
            Caption = 'BC IRS 1099 Code';
        }
        field(7; IsError; Boolean)
        {
            Caption = 'Error';
        }
        field(8; WasSkipped; Boolean)
        {
            Caption = 'Skipped';
        }
        field(9; "Error Code"; Text[100])
        {
            Caption = 'Error Code';
        }
        field(10; "Error Message"; Blob)
        {
            Caption = 'Error Message';
        }
        field(11; "Message Code"; Text[100])
        {
            Caption = 'Message Code';
        }
        field(12; "Message Text"; Text[250])
        {
            Caption = 'Message Text';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure SetErrorMessage(ErrorMessageText: Text)
    var
        ErrorMessageOutStream: OutStream;
    begin
        Rec."Error Message".CreateOutStream(ErrorMessageOutStream);
        ErrorMessageOutStream.WriteText(ErrorMessageText);
    end;

    procedure GetErrorMessage(): Text
    var
        ErrorMessageInStream: InStream;
        ReturnText: Text;
    begin
        CalcFields(Rec."Error Message");
        if Rec."Error Message".HasValue() then begin
            Rec."Error Message".CreateInStream(ErrorMessageInStream);
            ErrorMessageInStream.ReadText(ReturnText);
        end;

        exit(ReturnText)
    end;
}