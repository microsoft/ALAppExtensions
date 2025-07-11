// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 19039 "Create IN TDS Posting Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
        CreateINTDSSection: Codeunit "Create IN TDS Section";
        CreateINGLAccounts: Codeunit "Create IN GL Accounts";
    begin
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.SectionS(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayableContractor194C(), CreateINGLAccounts.TDSRecContractor194C());
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.SectionC(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayableContractor194C(), CreateINGLAccounts.TDSRecContractor194C());
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.Section194JPF(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayableProfessional194J(), CreateINGLAccounts.TDSRecProfessional194J());
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.Section194JTF(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayableProfessional194J(), CreateINGLAccounts.TDSRecProfessional194J());
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.Section194JCC(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayableProfessional194J(), CreateINGLAccounts.TDSRecProfessional194J());
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.Section194JDF(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayableProfessional194J(), CreateINGLAccounts.TDSRecProfessional194J());
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.Section194IPM(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayableRent194I(), CreateINGLAccounts.TDSRecRent194I());
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.Section194ILB(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayableRent194I(), CreateINGLAccounts.TDSRecRent194I());
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.Section195(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayablePayabletoNonResidents195(), '');
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.Section194ABP(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayableInterest194A(), CreateINGLAccounts.TDSRecInterest194A());
        ContosoINTaxSetup.InsertTDSPostingSetup(CreateINTDSSection.Section194AOT(), DMY2Date(1, 1, 2010), CreateINGLAccounts.TDSPayableInterest194A(), CreateINGLAccounts.TDSRecInterest194A());
    end;
}
