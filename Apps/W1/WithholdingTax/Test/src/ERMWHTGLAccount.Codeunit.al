// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Tests.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.WithholdingTax;
using System.TestLibraries.Utilities;

codeunit 148325 "ERM WHT G/L Account"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = IntegrationTest;

    trigger OnRun()
    begin
        // [FEATURE] [G/L Account Where-Used]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryWithholdingTax: Codeunit "Library - Withholding Tax";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
        isInitialized: Boolean;
        InvalidTableCaptionErr: Label 'Invalid table caption.';
        InvalidFieldCaptionErr: Label 'Invalid field caption.';
        InvalidLineValueErr: Label 'Invalid Line value.';

    [Test]
    [HandlerFunctions('WhereUsedHandler')]
    [Scope('OnPrem')]
    procedure CheckWHTPostingSetup()
    var
        WHTBusinessPostingGroup: Record "Wthldg. Tax Bus. Post. Group";
        WHTProductPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        // [SCENARIO 285194] WHT Posting Setup should be shown on Where-Used page
        Initialize();

        // [GIVEN] WHT Posting Setup with "Sales Withholding Adj. Acc No" = "G"
        UpdateGeneralLedgerSetup(true, false);
        LibraryWithholdingTax.CreateWHTBusinessPostingGroup(WHTBusinessPostingGroup);
        LibraryWithholdingTax.CreateWHTProductPostingGroup(WHTProductPostingGroup);
        LibraryWithholdingTax.CreateWHTPostingSetup(WHTPostingSetup, WHTBusinessPostingGroup.Code, WHTProductPostingGroup.Code);
        WHTPostingSetup.Validate("Sales Wthldg. Tax Adj. Acc No", LibraryERM.CreateGLAccountNo());
        WHTPostingSetup.Modify();

        // [WHEN] Run Where-Used function for G/L Accoun "G"
        CalcGLAccWhereUsed.CheckGLAcc(WHTPostingSetup."Sales Wthldg. Tax Adj. Acc No");

        // [THEN] G/L Account "G" is shown on "G/L Account Where-Used List"
        ValidateWhereUsedRecord(
          WHTPostingSetup.TableCaption(),
          WHTPostingSetup.FieldCaption("Sales Wthldg. Tax Adj. Acc No"),
          StrSubstNo(
            '%1=%2, %3=%4',
            WHTPostingSetup.FieldCaption("Wthldg. Tax Bus. Post. Group"),
            WHTPostingSetup."Wthldg. Tax Bus. Post. Group",
            WHTPostingSetup.FieldCaption("Wthldg. Tax Prod. Post. Group"),
            WHTPostingSetup."Wthldg. Tax Prod. Post. Group"));
    end;

    [Test]
    [HandlerFunctions('WhereUsedShowDetailsHandler')]
    [Scope('OnPrem')]
    procedure ShowDetailsWhereUsedWHTPostingSetup()
    var
        WHTBusinessPostingGroup: Record "Wthldg. Tax Bus. Post. Group";
        WHTProductPostingGroup: Record "Wthldg. Tax Prod. Post. Group";
        WHTPostingSetup: Record "Withholding Tax Posting Setup";
        WHTPostingSetupPage: TestPage "Withholding Tax Posting Setup";
    begin
        // [SCENARIO 285194] WHT Posting Setup page should be open on Show Details action from Where-Used page
        Initialize();

        // [GIVEN] WHT Posting Setup "Wthldg. Tax Bus. Post. Group" = "BP", "Wthldg. Tax Prod. Post. Group" = "PP" with "Sales Withholding Adj. Acc No" = "G"
        UpdateGeneralLedgerSetup(true, false);
        LibraryWithholdingTax.CreateWHTBusinessPostingGroup(WHTBusinessPostingGroup);
        LibraryWithholdingTax.CreateWHTProductPostingGroup(WHTProductPostingGroup);
        LibraryWithholdingTax.CreateWHTPostingSetup(WHTPostingSetup, WHTBusinessPostingGroup.Code, WHTProductPostingGroup.Code);
        WHTPostingSetup.Validate("Sales Wthldg. Tax Adj. Acc No", LibraryERM.CreateGLAccountNo());
        WHTPostingSetup.Modify();

        // [WHEN] Run Where-Used function for G/L Accoun "G" and choose Show Details action
        WHTPostingSetupPage.Trap();
        CalcGLAccWhereUsed.CheckGLAcc(WHTPostingSetup."Sales Wthldg. Tax Adj. Acc No");

        // [THEN] WHT Posting Setup page opened with "Wthldg. Tax Bus. Post. Group" = "BP", "Wthldg. Tax Prod. Post. Group" = "PP"
        WHTPostingSetupPage."Wthldg. Tax Bus. Post. Group".AssertEquals(WHTBusinessPostingGroup.Code);
        WHTPostingSetupPage."Wthldg. Tax Prod. Post. Group".AssertEquals(WHTProductPostingGroup.Code);
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
        if isInitialized then
            exit;

        isInitialized := true;
    end;

    local procedure UpdateGeneralLedgerSetup(EnableWHT: Boolean; RoundAmountForWHTCalc: Boolean)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Enable Withholding Tax", EnableWHT);
        GeneralLedgerSetup.Validate("Round Amount Wthldg. Tax Calc", RoundAmountForWHTCalc);
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure ValidateWhereUsedRecord(ExpectedTableCaption: Text; ExpectedFieldCaption: Text; ExpectedLineValue: Text)
    begin
        Assert.AreEqual(ExpectedTableCaption, LibraryVariableStorage.DequeueText(), InvalidTableCaptionErr);
        Assert.AreEqual(ExpectedFieldCaption, LibraryVariableStorage.DequeueText(), InvalidFieldCaptionErr);
        Assert.AreEqual(ExpectedLineValue, LibraryVariableStorage.DequeueText(), InvalidLineValueErr);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure WhereUsedHandler(var GLAccountWhereUsedList: TestPage "G/L Account Where-Used List")
    begin
        GLAccountWhereUsedList.First();
        LibraryVariableStorage.Enqueue(GLAccountWhereUsedList."Table Name".Value);
        LibraryVariableStorage.Enqueue(GLAccountWhereUsedList."Field Name".Value);
        LibraryVariableStorage.Enqueue(GLAccountWhereUsedList.Line.Value);
        GLAccountWhereUsedList.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure WhereUsedShowDetailsHandler(var GLAccountWhereUsedList: TestPage "G/L Account Where-Used List")
    begin
        GLAccountWhereUsedList.First();
        GLAccountWhereUsedList.ShowDetails.Invoke();
    end;
}

