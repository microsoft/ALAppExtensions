// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47091 "SL Post Migration Data Log"
{
    Caption = 'SL Post Migration Data Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Post Migration Type"; Code[30])
        {
            Caption = 'Post Migration Type';
            DataClassification = CustomerContent;
        }
        field(3; "Table Reference"; Text[30])
        {
            Caption = 'Table Reference';
        }
        field(4; "Error Code"; Text[100])
        {
            Caption = 'Error Code';
        }
        field(5; "Error Message"; Blob)
        {
            Caption = 'Error Message';
        }
        field(6; "Message Code"; Text[100])
        {
            Caption = 'Message Code';
        }
        field(7; "Message Text"; Text[250])
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
        ErrorMessageBuilder: TextBuilder;
        ErrorMessageInStream: InStream;
        ErrorMessageLine: Text;
    begin
        CalcFields(Rec."Error Message");
        Rec."Error Message".CreateInStream(ErrorMessageInStream);
        while not ErrorMessageInStream.EOS do begin
            ErrorMessageInStream.ReadText(ErrorMessageLine);
            ErrorMessageBuilder.AppendLine(ErrorMessageLine);
        end;
        exit(ErrorMessageBuilder.ToText().Trim())
    end;
}