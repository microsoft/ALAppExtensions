// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139756 "SMTP Account Mock"
{
    SingleInstance = true;

    procedure Name(): Text[250]
    begin
        exit(AccName);
    end;

    procedure Name(Value: Text[250])
    begin
        AccName := Value;
    end;

    procedure Server(): Text[250]
    begin
        exit(AccServer);
    end;

    procedure Server(Value: Text[250])
    begin
        AccServer := Value;
    end;

    procedure Authentication(): Enum "SMTP Authentication Types"
    begin
        exit(AccAuthentication);
    end;

    procedure Authentication(Value: Enum "SMTP Authentication Types")
    begin
        AccAuthentication := Value;
    end;

    procedure UserID(): Text[250]
    begin
        exit(AccUserID);
    end;

    procedure UserID(Value: Text[250])
    begin
        AccUserID := Value;
    end;

    procedure ServerPort(): Integer
    begin
        exit(AccServerPort);
    end;

    procedure ServerPort(Value: Integer)
    begin
        AccServerPort := Value;
    end;

    procedure SecureConnection(): Boolean
    begin
        exit(AccSecureConnection);
    end;

    procedure SecureConnection(Value: Boolean)
    begin
        AccSecureConnection := Value;
    end;

    procedure Password(): Text
    begin
        exit(AccPassword);
    end;

    procedure Password(Value: Text)
    begin
        AccPassword := Value;
    end;

    procedure EmailAddress(): Text[250]
    begin
        exit(AccEmailAddress);
    end;

    procedure EmailAddress(Value: Text[250])
    begin
        AccEmailAddress := Value;
    end;

    procedure SendAs(): Text[250]
    begin
        exit(AccSendAs);
    end;

    procedure SendAs(Value: Text[250])
    begin
        AccSendAs := Value;
    end;

    procedure AllowSenderSubstitution(): Boolean
    begin
        exit(AccAllowSenderSubstitution);
    end;

    procedure AllowSenderSubstitution(Value: Boolean)
    begin
        AccAllowSenderSubstitution := Value;
    end;

    var
        AccName: Text[250];
        AccServer: Text[250];
        AccAuthentication: Enum "SMTP Authentication Types";
        AccUserID: Text[250];
        AccServerPort: Integer;
        AccSecureConnection: Boolean;
        AccPassword: Text;
        AccSendAs: Text[250];
        AccEmailAddress: Text[250];
        AccAllowSenderSubstitution: Boolean;

}