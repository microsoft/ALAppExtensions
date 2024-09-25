// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

table 6380 ConnectionAuth
{
    Access = Internal;

    fields
    {
        field(1; PK; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Access Token"; Guid)
        {
            Caption = 'Access Token';
            DataClassification = CustomerContent;
        }
        field(3; "Refresh Token"; Guid)
        {
            Caption = 'Refresh Token';
            DataClassification = CustomerContent;
        }
        field(30; "Token Timestamp"; DateTime)
        {
            Caption = 'Token Timestamp';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; PK)
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    procedure GetRecordOnce(): Boolean
    begin
        if RecordHasBeenRead then
            exit(RecordHasBeenRead);
        Clear(Rec);
        RecordHasBeenRead := Get();
        if not RecordHasBeenRead then begin
            Insert();
            RecordHasBeenRead := Get();
        end;
        exit(RecordHasBeenRead);
    end;
}