// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.GST.Base;

codeunit 19026 "Create IN HSN/SAC"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
        CreateINGSTGroup: Codeunit "Create IN GST Group";
        CreateINGLAccounts: Codeunit "Create IN GL Accounts";
    begin
        ContosoINTaxSetup.InsertHSNSAC(CreateINGSTGroup.GSTGroup0988(), HSNSACCode0988001(), HSNSACCode0988001Tok, Enum::"GST Goods And Services Type"::HSN);
        ContosoINTaxSetup.InsertHSNSAC(CreateINGSTGroup.GSTGroup0988(), HSNSACCode0988002(), HSNSACCode0988002Tok, Enum::"GST Goods And Services Type"::HSN);
        ContosoINTaxSetup.InsertHSNSAC(CreateINGSTGroup.GSTGroup0989(), HSNSACCode0989001(), HSNSACCode0989001Tok, Enum::"GST Goods And Services Type"::HSN);
        ContosoINTaxSetup.InsertHSNSAC(CreateINGSTGroup.GSTGroup0989(), HSNSACCode0989002(), HSNSACCode0989002Tok, Enum::"GST Goods And Services Type"::HSN);
        ContosoINTaxSetup.InsertHSNSAC(CreateINGSTGroup.GSTGroup2089(), HSNSACCode2089001(), HSNSACCode2089001Tok, Enum::"GST Goods And Services Type"::SAC);
        ContosoINTaxSetup.InsertHSNSAC(CreateINGSTGroup.GSTGroup2090(), HSNSACCode2090001(), HSNSACCode2090001Tok, Enum::"GST Goods And Services Type"::SAC);

        CreateINGLAccounts.UpdateGSTGroupOnGLAccounts(CreateINGLAccounts.ServiceContractSale(), CreateINGSTGroup.GSTGroup2089(), HSNSACCode2089001Tok);
        CreateINGLAccounts.UpdateGSTGroupOnGLAccounts(CreateINGLAccounts.Freight(), CreateINGSTGroup.GSTGroup2089(), HSNSACCode2089001Tok);
        CreateINGLAccounts.UpdateGSTGroupOnGLAccounts(CreateINGLAccounts.AuditFee(), CreateINGSTGroup.GSTGroup2089(), HSNSACCode2089001Tok);
        CreateINGLAccounts.UpdateGSTGroupOnGLAccounts(CreateINGLAccounts.ProfessionalCharges(), CreateINGSTGroup.GSTGroup2089(), HSNSACCode2089001Tok);
        CreateINGLAccounts.UpdateGSTGroupOnGLAccounts(CreateINGLAccounts.Insurance(), CreateINGSTGroup.GSTGroup2089(), HSNSACCode2089001Tok);
        CreateINGLAccounts.UpdateGSTGroupOnGLAccounts(CreateINGLAccounts.PenaltyCharges(), CreateINGSTGroup.GSTGroup2089(), HSNSACCode2089001Tok);
        CreateINGLAccounts.UpdateGSTGroupOnGLAccounts(CreateINGLAccounts.AdvocateFee(), CreateINGSTGroup.GSTGroup2089(), HSNSACCode2089001Tok);
        CreateINGLAccounts.UpdateGSTGroupOnGLAccounts(CreateINGLAccounts.OtherCharges(), CreateINGSTGroup.GSTGroup2089(), HSNSACCode2089001Tok);
    end;

    procedure HSNSACCode0988001(): Code[10]
    begin
        exit(HSNSACCode0988001Tok);
    end;

    procedure HSNSACCode0988002(): Code[10]
    begin
        exit(HSNSACCode0988002Tok);
    end;

    procedure HSNSACCode0989001(): Code[10]
    begin
        exit(HSNSACCode0989001Tok);
    end;

    procedure HSNSACCode0989002(): Code[10]
    begin
        exit(HSNSACCode0989002Tok);
    end;

    procedure HSNSACCode2089001(): Code[10]
    begin
        exit(HSNSACCode2089001Tok);
    end;

    procedure HSNSACCode2090001(): Code[10]
    begin
        exit(HSNSACCode2090001Tok);
    end;

    var
        HSNSACCode0988001Tok: Label '0988001', MaxLength = 10;
        HSNSACCode0988002Tok: Label '0988002', MaxLength = 10;
        HSNSACCode0989001Tok: Label '0989001', MaxLength = 10;
        HSNSACCode0989002Tok: Label '0989002', MaxLength = 10;
        HSNSACCode2090001Tok: Label '2090001', MaxLength = 10;
        HSNSACCode2089001Tok: Label '2089001', MaxLength = 10;
}
