#if not CLEAN21
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 148089 "MTD Test Fraud Prevention Hdrs"
{
    Subtype = Test;
    TestPermissions = Disabled;
    ObsoleteReason = 'Not used anymore.';
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '21.0';
#pragma warning restore AS0072

    trigger OnRun()
    begin
        // [FEATURE] [Making Tax Digital] [Fraud Prevention]
    end;

    var
        Assert: Codeunit Assert;
        LibraryMakingTaxDigital: Codeunit "Library - Making Tax Digital";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        IsInitialized: Boolean;

    [Test]
    procedure SampleValuesAreHiddenByDefault()
    var
        MTDFraudPreventionHeaders: TestPage "MTD Fraud Prevention Headers";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 349684] "Sample Value" column is hidden by default and becomes visible after "Get Current Headers" action
        Initialize();
        LibraryApplicationArea.EnableFoundationSetup();

        MTDFraudPreventionHeaders.OpenEdit();
        Assert.IsFalse(MTDFraudPreventionHeaders.SampleValue.Visible(), '');
        MTDFraudPreventionHeaders."Get Current Headers".Invoke();
        Assert.IsTrue(MTDFraudPreventionHeaders.SampleValue.Visible(), '');
        MTDFraudPreventionHeaders.Close();
    end;

    local procedure Initialize()
    var
        MTDMissingFraudPrevHdr: Record "MTD Missing Fraud Prev. Hdr";
        MTDDefaultFraudPrevHdr: Record "MTD Default Fraud Prev. Hdr";
        MTDSessionFraudPrevHdr: Record "MTD Session Fraud Prev. Hdr";
    begin
        MTDMissingFraudPrevHdr.DeleteAll();
        MTDDefaultFraudPrevHdr.DeleteAll();
        MTDSessionFraudPrevHdr.DeleteAll();

        if IsInitialized then
            exit;

        LibraryMakingTaxDigital.SetOAuthSetupSandbox(true);
        LibraryMakingTaxDigital.SetupOAuthAndVATRegNo(true, '', '');
        IsInitialized := true;
        Commit();
    end;
}
#endif