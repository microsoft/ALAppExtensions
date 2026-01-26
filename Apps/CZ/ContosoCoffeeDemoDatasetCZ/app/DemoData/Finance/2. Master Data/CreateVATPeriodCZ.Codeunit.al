#if not CLEAN28
#pragma warning disable AL0432
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 31214 "Create VAT Period CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteState = Pending;
    ObsoleteReason = 'The VAT Period CZL table is replaced by VAT Return Period table. Use the Create VAT Return Period codeunit instead.';
    ObsoleteTag = '28.0';

    trigger OnRun()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        InsertData(ContosoUtilities.AdjustDate(19010101D), ContosoUtilities.AdjustDate(19040101D));
    end;

    procedure InsertData(StartingDate: Date; EndingDate: Date)
    var
        ContosoVATStatementCZ: Codeunit "Contoso VAT Statement CZ";
    begin
        while StartingDate <= EndingDate do begin
            ContosoVATStatementCZ.InsertVATPeriod(StartingDate);
            StartingDate := CalcDate('<1M>', StartingDate);
        end;
    end;
}
#pragma warning restore AL0432
#endif
