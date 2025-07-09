// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;

codeunit 19025 "Create IN GST Posting Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
        CreateINState: Codeunit "Create IN State";
        CreateINGLAccounts: Codeunit "Create IN GL Accounts";
    begin
        ContosoINTaxSetup.InsertGSTPostingSetup(CreateINState.Delhi(), 2, CreateINGLAccounts.CGSTRcvbleAcc(), CreateINGLAccounts.CGSTPayableAcc(), CreateINGLAccounts.CGSTRcvbleAccInterim(), CreateINGLAccounts.CGSTPayableAccInterim(), CreateINGLAccounts.GSTExpenseAcc(), CreateINGLAccounts.GSTRefundAcc(), CreateINGLAccounts.CGSTRcvblAccInterimDist(), CreateINGLAccounts.CGSTRcvblAccDist(), CreateINGLAccounts.CGSTCrMismatchAcc(), CreateINGLAccounts.GSTTDSReceivableAccount(), CreateINGLAccounts.GSTTCSReceivableAccount(), CreateINGLAccounts.GSTTCSPayableAccount(), '');
        ContosoINTaxSetup.InsertGSTPostingSetup(CreateINState.Delhi(), 3, CreateINGLAccounts.IGSTRcvbleAcc(), CreateINGLAccounts.IGSTPayableAcc(), CreateINGLAccounts.IGSTRcvbleAccInterim(), CreateINGLAccounts.IGSTPayableAccInterim(), CreateINGLAccounts.GSTExpenseAcc(), CreateINGLAccounts.GSTRefundAcc(), CreateINGLAccounts.IGSTRcvblAccInterimDist(), CreateINGLAccounts.IGSTRcvblAccDist(), CreateINGLAccounts.IGSTCrMismatchAcc(), CreateINGLAccounts.GSTTDSReceivableAccount(), CreateINGLAccounts.GSTTCSReceivableAccount(), CreateINGLAccounts.GSTTCSPayableAccount(), CreateINGLAccounts.CustomHouse());
        ContosoINTaxSetup.InsertGSTPostingSetup(CreateINState.Delhi(), 6, CreateINGLAccounts.SGSTRcvbleAcc(), CreateINGLAccounts.SGSTPayableAcc(), CreateINGLAccounts.SGSTRcvbleAccInterim(), CreateINGLAccounts.SGSTPayableAccInterim(), CreateINGLAccounts.GSTExpenseAcc(), CreateINGLAccounts.GSTRefundAcc(), CreateINGLAccounts.SGSTRcvblAccInterimDist(), CreateINGLAccounts.SGSTRcvblAccDist(), CreateINGLAccounts.SGSTCrMismatchAcc(), CreateINGLAccounts.GSTTDSReceivableAccount(), CreateINGLAccounts.GSTTCSReceivableAccount(), CreateINGLAccounts.GSTTCSPayableAccount(), '');
        ContosoINTaxSetup.InsertGSTPostingSetup(CreateINState.Haryana(), 2, CreateINGLAccounts.CGSTRcvbleAcc(), CreateINGLAccounts.CGSTPayableAcc(), CreateINGLAccounts.CGSTRcvbleAccInterim(), CreateINGLAccounts.CGSTPayableAccInterim(), CreateINGLAccounts.GSTExpenseAcc(), CreateINGLAccounts.GSTRefundAcc(), CreateINGLAccounts.CGSTRcvblAccInterimDist(), CreateINGLAccounts.CGSTRcvblAccDist(), CreateINGLAccounts.CGSTCrMismatchAcc(), CreateINGLAccounts.GSTTDSReceivableAccount(), CreateINGLAccounts.GSTTCSReceivableAccount(), CreateINGLAccounts.GSTTCSPayableAccount(), '');
        ContosoINTaxSetup.InsertGSTPostingSetup(CreateINState.Haryana(), 3, CreateINGLAccounts.IGSTRcvbleAcc(), CreateINGLAccounts.IGSTPayableAcc(), CreateINGLAccounts.IGSTRcvbleAccInterim(), CreateINGLAccounts.IGSTPayableAccInterim(), CreateINGLAccounts.GSTExpenseAcc(), CreateINGLAccounts.GSTRefundAcc(), CreateINGLAccounts.IGSTRcvblAccInterimDist(), CreateINGLAccounts.IGSTRcvblAccDist(), CreateINGLAccounts.IGSTCrMismatchAcc(), CreateINGLAccounts.GSTTDSReceivableAccount(), CreateINGLAccounts.GSTTCSReceivableAccount(), CreateINGLAccounts.GSTTCSPayableAccount(), CreateINGLAccounts.CustomHouse());
        ContosoINTaxSetup.InsertGSTPostingSetup(CreateINState.Haryana(), 6, CreateINGLAccounts.SGSTRcvbleAcc(), CreateINGLAccounts.SGSTPayableAcc(), CreateINGLAccounts.SGSTRcvbleAccInterim(), CreateINGLAccounts.SGSTPayableAccInterim(), CreateINGLAccounts.GSTExpenseAcc(), CreateINGLAccounts.GSTRefundAcc(), CreateINGLAccounts.SGSTRcvblAccInterimDist(), CreateINGLAccounts.SGSTRcvblAccDist(), CreateINGLAccounts.SGSTCrMismatchAcc(), CreateINGLAccounts.GSTTDSReceivableAccount(), CreateINGLAccounts.GSTTCSReceivableAccount(), CreateINGLAccounts.GSTTCSPayableAccount(), '');

        ContosoINTaxSetup.CreateGSTCompReconMapping(CGSTComponentCode(), 17, Component2AmountLbl, 9, DistributedasComponent2Lbl);
        ContosoINTaxSetup.CreateGSTCompReconMapping(IGSTComponentCode(), 19, Component3AmountLbl, 10, DistributedasComponent3Lbl);
        ContosoINTaxSetup.CreateGSTCompReconMapping(SGSTComponentCode(), 15, Component1AmountLbl, 8, DistributedasComponent1Lbl);
    end;

    procedure CGSTComponentCode(): Code[10]
    begin
        exit(CGSTComponentCodeTok);
    end;

    procedure SGSTComponentCode(): Code[10]
    begin
        exit(SGSTComponentCodeTok);
    end;

    procedure IGSTComponentCode(): Code[10]
    begin
        exit(IGSTComponentCodeTok);
    end;

    var
        CGSTComponentCodeTok: Label 'CGST', MaxLength = 10;
        SGSTComponentCodeTok: Label 'SGST', MaxLength = 10;
        IGSTComponentCodeTok: Label 'IGST', MaxLength = 10;
        DistributedasComponent2Lbl: Label 'Distributed as Component 2', MaxLength = 30;
        DistributedasComponent1Lbl: Label 'Distributed as Component 1', MaxLength = 30;
        DistributedasComponent3Lbl: Label 'Distributed as Component 3', MaxLength = 30;
        Component1AmountLbl: Label 'Component 1 Amount', MaxLength = 30;
        Component2AmountLbl: Label 'Component 2 Amount', MaxLength = 30;
        Component3AmountLbl: Label 'Component 3 Amount', MaxLength = 30;
}
