// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.TestLibraries.DynamicsFieldService;

using Microsoft.Integration.DynamicsFieldService;

codeunit 139205 "FS Integration Test Library"
{
    procedure RegisterConnection(var FSConnectionSetup: Record "FS Connection Setup")
    begin
        FSConnectionSetup.RegisterConnection();
    end;

    procedure UnregisterConnection(var FSConnectionSetup: Record "FS Connection Setup")
    begin
        FSConnectionSetup.UnregisterConnection();
    end;

    procedure SetPassword(var FSConnectionSetup: Record "FS Connection Setup"; Password: SecretText)
    begin
        FSConnectionSetup.SetPassword(Password);
    end;

    procedure PerformTestConnection(var FSConnectionSetup: Record "FS Connection Setup")
    begin
        FSConnectionSetup.PerformTestConnection();
    end;
}