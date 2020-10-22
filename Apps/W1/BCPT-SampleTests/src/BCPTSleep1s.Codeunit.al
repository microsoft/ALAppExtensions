// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 149116 "BCPT Sleep 1s"
{
    trigger OnRun();
    begin
        Sleep(1000);
    end;
}