// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.ExternalFileStorage;

using System.ExternalFileStorage;

codeunit 144565 "Ext. Blob Account Mock"
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

    procedure StorageAccountName(): Text[250]
    begin
        exit(AccStorageAccountName);
    end;

    procedure StorageAccountName(Value: Text[250])
    begin
        AccStorageAccountName := Value;
    end;

    procedure ContainerName(): Text[250]
    begin
        exit(AccContainerName);
    end;

    procedure ContainerName(Value: Text[250])
    begin
        AccContainerName := Value;
    end;

    procedure Password(): Text
    begin
        exit(AccPassword);
    end;

    procedure Password(Value: Text)
    begin
        AccPassword := Value;
    end;

    procedure AuthorizationType(Value: Enum "Ext. Blob Storage Auth. Type")
    begin
        AccAuthorizationType := Value;
    end;

    procedure AuthorizationType(): Enum "Ext. Blob Storage Auth. Type"
    begin
        exit(AccAuthorizationType);
    end;

    var
        AccName: Text[250];
        AccStorageAccountName: Text[250];
        AccContainerName: Text[250];
        AccPassword: Text;
        AccAuthorizationType: Enum "Ext. Blob Storage Auth. Type";
}