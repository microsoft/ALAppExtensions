// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139536 "Test First Party Signals"
{
    Subtype = Test;
    TestPermissions = Restrictive;

    var
        Assert: Codeunit Assert;
        LibraryOnboardingSignal: Codeunit "Library - Onboarding Signal";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";

    [Test]
    procedure TestFirstPartyOnboardingSignals()
    var
        Company: Record Company;
        PostedPurchaseInvoice: Record "Purch. Inv. Header";
        PostedSalesInvoice: Record "Sales Invoice Header";
        OnboardingSignal: Codeunit "Onboarding Signal";
        RegisterFirstPartySignals: Codeunit "Register First Party Signals";
        OnboardingSignalType: Enum "Onboarding Signal Type";
        SignalEntryFalseErr: Label 'Onboarding Signal Entry should be False after initially inserted', Locked = true;
        SignalEntryTrueErr: Label 'Onboarding Signal Entry should be True after its criteria has been met', Locked = true;
        Counter: Integer;
    begin
        // [Scenario] After First party onboarding signal entries have been inserted, test if those signals are acting as expected
        Initialize();
        RegisterFirstPartySignals.RegisterFirstPartySignals();

        Company.Get(CompanyName());

        // [THEN] All of the entries should be set to False before the status check
        Assert.IsFalse(LibraryOnboardingSignal.IsOnboardingCompleted(Company.Name, OnboardingSignalType::"Purchase Invoice"), SignalEntryFalseErr);
        Assert.IsFalse(LibraryOnboardingSignal.IsOnboardingCompleted(Company.Name, OnboardingSignalType::"Sales Invoice"), SignalEntryFalseErr);
        Assert.IsFalse(LibraryOnboardingSignal.IsOnboardingCompleted(Company.Name, OnboardingSignalType::"Vendor Payments"), SignalEntryFalseErr);
        Assert.IsFalse(LibraryOnboardingSignal.IsOnboardingCompleted(Company.Name, OnboardingSignalType::"Customer Payments"), SignalEntryFalseErr);

        // [GIVEN] Populate some data to fulfill 2 criteria
        LibraryLowerPermissions.SetOutsideO365Scope();
        for Counter := 0 to 6 do begin
            PostedSalesInvoice.Init();
            PostedSalesInvoice."No." := Format(1000 + Counter);
            PostedSalesInvoice.Insert();

            PostedPurchaseInvoice.Init();
            PostedPurchaseInvoice."No." := Format(1000 + Counter);
            PostedPurchaseInvoice.Insert();
        end;
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] We check the status and set all entries to corresponding value
        OnboardingSignal.CheckAndEmitOnboardingSignals();

        // [THEN] Only the entries that their criteria have been met are set to True
        Assert.IsTrue(LibraryOnboardingSignal.IsOnboardingCompleted(Company.Name, OnboardingSignalType::"Purchase Invoice"), SignalEntryTrueErr);
        Assert.IsTrue(LibraryOnboardingSignal.IsOnboardingCompleted(Company.Name, OnboardingSignalType::"Sales Invoice"), SignalEntryTrueErr);
        Assert.IsFalse(LibraryOnboardingSignal.IsOnboardingCompleted(Company.Name, OnboardingSignalType::"Vendor Payments"), SignalEntryFalseErr);
        Assert.IsFalse(LibraryOnboardingSignal.IsOnboardingCompleted(Company.Name, OnboardingSignalType::"Customer Payments"), SignalEntryFalseErr);
    end;

    local procedure Initialize()
    begin
        LibraryOnboardingSignal.InitializeOnboardingSignalTestingEnv();

        CleanUpCorrespondingTables();
        LibraryLowerPermissions.SetO365BusFull();
    end;

    local procedure CleanUpCorrespondingTables()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PostedSalesInvoice: Record "Sales Invoice Header";
        PostedPurchaseInvoice: Record "Purch. Inv. Header";
    begin
        LibraryLowerPermissions.SetOutsideO365Scope();
        PostedSalesInvoice.DeleteAll();
        PostedPurchaseInvoice.DeleteAll();
        CustLedgerEntry.DeleteAll();
        VendorLedgerEntry.DeleteAll();
        LibraryLowerPermissions.SetO365BusFull();
    end;
}