// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 10034 "IRS Forms Orchestrator"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetCreateFormDocsImplementation(): Interface "IRS 1099 Create Form Docs"
    begin
        exit(GetImplementation());
    end;

    procedure GetPrintingImplementation(): Interface "IRS 1099 Printing"
    begin
        exit(GetImplementation());
    end;

    procedure GetFormBoxCalcImplementation(): Interface "IRS 1099 Form Box Calc."
    begin
        exit(GetImplementation());
    end;

    local procedure GetImplementation(): Enum "IRS Forms Implementation"
    var
        IRSFormsSetup: Record "IRS Forms Setup";
    begin
        IRSFormsSetup.InitSetup();
        exit(IRSFormsSetup.Implementation);
    end;
}
