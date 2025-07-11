// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148025 "FIK Event Subscribers"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: codeunit Assert;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    procedure VerifyFIKImportFormat()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        // [WHEN] Running company initialize
        // [THEN] FIK Import Format should be set correctly
        GeneralLedgerSetup.Get();
        Assert.AreEqual('FIK71', GeneralLedgerSetup."FIK Import Format",
            'The FIK Import Format should be set correctly during company initialize.');
    end;
}