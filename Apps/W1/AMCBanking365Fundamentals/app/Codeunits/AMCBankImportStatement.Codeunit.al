#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.IO;

codeunit 20125 "AMC Bank Import Statement"
{
    Permissions = TableData "Data Exch. Field" = rimd;
    TableNo = "Data Exch.";
    ObsoleteReason = 'AMC Banking 365 Fundamental extension is discontinued';
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';

    trigger OnRun()
    begin

    end;

    var

}
#endif
