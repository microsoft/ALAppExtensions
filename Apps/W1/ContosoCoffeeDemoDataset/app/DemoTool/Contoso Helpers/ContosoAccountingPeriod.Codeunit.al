// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoTool.Helpers;

using Microsoft.Foundation.Period;

codeunit 5439 "Contoso Accounting Period"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Accounting Period" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertAccountingPeriod(StartingDate: Date; NewFiscalYear: Boolean)
    var
        AccountingPeriod: Record "Accounting Period";
        Exists: Boolean;
    begin
        if AccountingPeriod.Get(StartingDate) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AccountingPeriod.Validate("Starting Date", StartingDate);
        AccountingPeriod.Validate("New Fiscal Year", NewFiscalYear);

        if Exists then
            AccountingPeriod.Modify(true)
        else
            AccountingPeriod.Insert(true);
    end;
}
