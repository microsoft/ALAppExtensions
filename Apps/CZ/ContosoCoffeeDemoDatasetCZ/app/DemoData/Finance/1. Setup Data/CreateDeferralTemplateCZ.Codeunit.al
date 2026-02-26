// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;
using Microsoft.Finance.Deferral;

codeunit 31220 "Create Deferral Template CZ"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        DeferralTemplate: Record "Deferral Template";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
    begin
        DeferralTemplate.DeleteAll(true); // "Create Deferral Template CZ" codeunit is triggered after "Create G/L Account CZ", so we need to clean up any existing deferral templates first.
        FinanceModuleSetup.Get();
        FinanceModuleSetup."Deferral Account No." := CreateGLAccountCZ.Deferredrevenues();
        FinanceModuleSetup.Modify();
        Codeunit.Run(Codeunit::"Create Deferral Template");
    end;
}
