// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.ScriptHandler;

codeunit 20158 "Script Action Helper"
{
    procedure ExitLoopActionID(): Guid;
    begin
        exit('cf8ae582-9b5c-4cfc-aa25-e13df13b4f1b');
    end;

    procedure ContinueActionID(): Guid;
    begin
        exit('5dbf3042-9791-4165-931f-4e4424cd9e9a');
    end;
}
