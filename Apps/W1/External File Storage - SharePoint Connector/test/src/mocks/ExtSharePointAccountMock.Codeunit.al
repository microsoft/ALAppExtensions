// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

codeunit 144580 "Ext. SharePoint Account Mock"
{
    Access = Internal;
    SingleInstance = true;

    procedure Name(): Text[250]
    begin
        exit(AccName);
    end;

    procedure Name(Value: Text[250])
    begin
        AccName := Value;
    end;

    procedure SharePointUrl(): Text[250]
    begin
        exit(AccSharePointUrl);
    end;

    procedure SharePointUrl(Value: Text[250])
    begin
        AccSharePointUrl := Value;
    end;


    procedure BaseRelativeFolderPath(): Text[250]
    begin
        exit(AccBaseRelativeFolderPath);
    end;

    procedure BaseRelativeFolderPath(Value: Text[250])
    begin
        AccBaseRelativeFolderPath := Value;
    end;

    procedure Password(): Text
    begin
        exit(AccPassword);
    end;

    procedure Password(Value: Text)
    begin
        AccPassword := Value;
    end;

    procedure ClientId(): Guid
    begin
        exit(AccClientId);
    end;

    procedure ClientId(Value: Guid)
    begin
        AccClientId := Value;
    end;

    procedure TenantId(): Guid
    begin
        exit(AccTenantId);
    end;

    procedure TenantId(Value: Guid)
    begin
        AccTenantId := Value;
    end;

    var
        AccName: Text[250];
        AccSharePointUrl: Text[250];
        AccBaseRelativeFolderPath: Text[250];
        AccPassword: Text;
        AccTenantId: Guid;
        AccClientId: Guid;
}