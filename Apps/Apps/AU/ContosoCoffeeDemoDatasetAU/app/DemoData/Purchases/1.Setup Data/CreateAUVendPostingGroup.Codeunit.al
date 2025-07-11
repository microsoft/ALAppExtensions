// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.DemoData.Finance;
using Microsoft.DemoTool.Helpers;

codeunit 17145 "Create AU Vend Posting Group"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVendorPostingGroup(Intercomp(), CreateAUGLAccounts.VendorsIntercompany(), CreateGLAccount.OtherCostsOfOperations(), CreateGLAccount.PmtdiscReceivedDecreases(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PaymentToleranceReceived(), IntercompanyLbl, false);
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure Intercomp(): Code[20]
    begin
        exit(IntercompTok);
    end;

    var
        IntercompTok: Label 'INTERCOMP', MaxLength = 20;
        IntercompanyLbl: Label 'Intercompany', MaxLength = 100;
}
