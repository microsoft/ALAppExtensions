// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 144758 "BCPT Codeunit With Error"
{
    TableNo = "BCPT Line";

    trigger OnRun()
    begin
        Error('Throw Error');
    end;
}