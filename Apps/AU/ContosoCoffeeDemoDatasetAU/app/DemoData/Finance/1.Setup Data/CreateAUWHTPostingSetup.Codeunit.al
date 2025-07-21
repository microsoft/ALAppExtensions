// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.WithholdingTax;
using Microsoft.DemoTool.Helpers;

codeunit 17151 "Create AU WHT Posting Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        WHTPostingSetup: Record "WHT Posting Setup";
        ContosoAUWHT: Codeunit "Contoso AU WHT";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
        CreateAUWHTRevenueType: Codeunit "Create AU WHT Revenue Type";
    begin
        ContosoAUWHT.SetOverwriteData(true);
        ContosoAUWHT.InsertWHTPostingSetup('', '', 46.5, CreateAUGLAccounts.WhtPrepaid(), CreateAUGLAccounts.WhtTaxPayable(), CreateAUWHTRevenueType.Wht(), CreateAUGLAccounts.PurchaseWhtAdjustments(), CreateAUGLAccounts.SalesWhtAdjustments(), WHTPostingSetup."Realized WHT Type"::Payment, 75);
        ContosoAUWHT.SetOverwriteData(false);
    end;
}
