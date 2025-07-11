// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 31289 "Create VAT Return Period CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        InsertData(ContosoUtilities.AdjustDate(19030101D), ContosoUtilities.AdjustDate(19041231D));
    end;

    procedure InsertData(StartingDate: Date; EndingDate: Date)
    var
        ContosoVATStatementCZ: Codeunit "Contoso VAT Statement CZ";
    begin
        while StartingDate <= EndingDate do begin
            ContosoVATStatementCZ.InsertVATReturnPeriod(StartingDate, CalcDate('<1M-1D>', StartingDate), CalcDate('<1M+24D>', StartingDate));
            StartingDate := CalcDate('<1M>', StartingDate);
        end;
    end;
}

