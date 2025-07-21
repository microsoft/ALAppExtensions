// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 14601 "IS Core Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        UpdateGeneralLedgserSetup();
    end;


    internal procedure UpdateGeneralLedgserSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DocsRetentionPeriodDef: Enum "Docs - Retention Period Def.";
    begin
        if GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup.Validate("Document Retention Period", DocsRetentionPeriodDef::"IS Docs Retention Period");
            GeneralLedgerSetup.Modify();
        end;
    end;
}