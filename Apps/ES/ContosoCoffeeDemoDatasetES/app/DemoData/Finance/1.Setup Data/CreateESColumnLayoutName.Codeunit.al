// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 10795 "Create ES Column Layout Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.SetOverwriteData(true);
        ContosoAccountSchedule.InsertColumnLayoutName(Balance(), BalanceColumnLayoutLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CcPers(), ContStaffCostsLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CcProf(), BdInfPostingSummaryCostsForCcCoLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(CcTrans(), ContTransferCostsLbl);
        ContosoAccountSchedule.InsertColumnLayoutName(Pyg(), ProfitLossColumnLayoutLbl);
        ContosoAccountSchedule.SetOverwriteData(false);
    end;

    procedure Balance(): Code[10]
    begin
        exit(BalanceTok);
    end;

    procedure CcPers(): Code[10]
    begin
        exit(CcPersTok);
    end;

    procedure CcProf(): Code[10]
    begin
        exit(CcProfTok);
    end;

    procedure CcTrans(): Code[10]
    begin
        exit(CcTransTok);
    end;

    procedure Pyg(): Code[10]
    begin
        exit(PygTok);
    end;

    var
        CcPersTok: Label 'CC-PERS', MaxLength = 10;
        CcProfTok: Label 'CC-PROF', MaxLength = 10;
        CcTransTok: Label 'CC-TRANS', MaxLength = 10;
        PygTok: Label 'PYG', MaxLength = 10;
        BalanceTok: Label 'BALANCE', MaxLength = 10;
        BalanceColumnLayoutLbl: Label 'Balance Column Layout', MaxLength = 80;
        ContStaffCostsLbl: Label 'Cont. staff costs', MaxLength = 80;
        BdInfPostingSummaryCostsForCcCoLbl: Label 'BD inf.Posting summary costs for CC/CO', MaxLength = 80;
        ContTransferCostsLbl: Label 'Cont. transfer costs', MaxLength = 80;
        ProfitLossColumnLayoutLbl: Label 'Profit & Loss Column Layout', MaxLength = 80;
}
