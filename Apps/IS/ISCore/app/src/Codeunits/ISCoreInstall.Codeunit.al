// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

#if not CLEAN24
using System.Upgrade;
#endif
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 14601 "IS Core Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
#if not CLEAN24
        InsertISCoreAppSetup();
#endif
        UpdateGeneralLedgserSetup();
    end;

#if not CLEAN24
    [Obsolete('Moved to Purchase Invoice Posting implementation. Replaced by local procedure CalcInvoiceDiscountPosting in codeunit Purch. Post Invoice', '20.0')]
    internal procedure InsertISCoreAppSetup()
    var
        ISCoreAppSetup: Record "IS Core App Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        EnableISCoreApp: Codeunit "Enable IS Core App";
    begin
        if UpgradeTag.HasUpgradeTag(EnableISCoreApp.GetISCoreAppUpdateTag()) then
            exit;

        if not ISCoreAppSetup.Get() then begin
            ISCoreAppSetup.Init();
            ISCoreAppSetup.Enabled := false;
            ISCoreAppSetup.Insert();
        end;
    end;
#endif

    internal procedure UpdateGeneralLedgserSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DocsRetentionPeriodDef: Enum "Docs - Retention Period Def.";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Document Retention Period", DocsRetentionPeriodDef::"IS Docs Retention Period");
        GeneralLedgerSetup.Modify();
    end;
}