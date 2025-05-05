// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;
using Microsoft.Finance.VAT.Setup;

codeunit 31186 "Create General Ledger Setup CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGeneralLedgerSetup();
    end;

    local procedure UpdateGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateCurrency: Codeunit "Create Currency";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Local Currency Symbol", '');
        GeneralLedgerSetup.Validate("Local Currency Description", CzechCrownLbl);
        GeneralLedgerSetup.Validate("LCY Code", CreateCurrency.CZK());
        GeneralLedgerSetup.Validate("Acc. Schedule Results Nos. CZL", CreateNoSeriesCZ.AccountingScheduleResult());
        GeneralLedgerSetup."VAT Reporting Date Usage" := "VAT Reporting Date Usage"::"Enabled (Prevent modification)";
        GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL"::"Posting Date";
        GeneralLedgerSetup."Mark Cr. Memos as Corrections" := true;
        GeneralLedgerSetup."Mark Neg. Qty as Correct. CZL" := true;
        GeneralLedgerSetup."Max. VAT Difference Allowed" := 0.5;
        GeneralLedgerSetup."Check G/L Account Usage" := true;
        GeneralLedgerSetup."Print VAT specification in LCY" := true;
        GeneralLedgerSetup."Check Posting Debit/Credit CZL" := true;
        GeneralLedgerSetup."Do Not Check Dimensions CZL" := true;
        GeneralLedgerSetup."Closed Per. Entry Pos.Date CZL" := ContosoUtilities.AdjustDate(19020101D);
        GeneralLedgerSetup.Modify(true);
    end;

    var
        CzechCrownLbl: Label 'Czech Crown', MaxLength = 60;
}
