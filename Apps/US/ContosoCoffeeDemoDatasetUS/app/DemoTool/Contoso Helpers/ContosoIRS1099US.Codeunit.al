#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.VAT.Reporting;

codeunit 11450 "Contoso IRS 1099 US"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteReason = 'Moved to IRS Forms App.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';
    Permissions = tabledata "IRS 1099 Form-Box" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertIRS1099FormBox(Code: Code[10]; Description: Text[100]; MinimumReportable: Decimal)
    var
        IRS1099FormBox: Record "IRS 1099 Form-Box";
        Exists: Boolean;
    begin
        if IRS1099FormBox.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        IRS1099FormBox.Validate(Code, Code);
        IRS1099FormBox.Validate(Description, Description);
        IRS1099FormBox.Validate("Minimum Reportable", MinimumReportable);

        if Exists then
            IRS1099FormBox.Modify(true)
        else
            IRS1099FormBox.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}
#endif