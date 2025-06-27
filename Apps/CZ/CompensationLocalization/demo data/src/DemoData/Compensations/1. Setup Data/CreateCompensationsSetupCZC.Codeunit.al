// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Compensations;

using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Localization;

codeunit 31466 "Create Compensations Setup CZC"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCompensationsCZC: Codeunit "Contoso Compensations CZC";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
    begin
        ContosoCompensationsCZC.InsertCompensationsSetup(CreateGLAccountCZ.Internalsettlement(), CreateNoSeriesCZ.Compensation());
    end;
}
