// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148169 "Elster VAT Adv. Notification"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURES] [Elster] [VAT Advance Notification]
    end;

    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        IsInitialized: Boolean;
        RollBackChangesErr: Label 'Roll-back the changes done by this test case.';

    [Test]
    procedure CheckFieldValuesOnSalesVATAdvanceNotification()
    var
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
        SalesVATAdvanceNotif2: Record "Sales VAT Advance Notif.";
    begin
        // [SCENARIO 283574] Verify Default field Values on New Sales VAT Advance Notification Record after creating First record.

        // Setup: Create and Update Sales VAT Advance Notification Record for the first time.
        Initialize();
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif);
        UpdateSalesVATAdvanceNotif(SalesVATAdvanceNotif);

        // Exercise: Create new Sales VAT Advance Notification record.
        CreateSalesVATAdvanceNotif(SalesVATAdvanceNotif2);

        // Verify: Verify that New record will take values from previous record.
        SalesVATAdvanceNotif2.TestField(Period, SalesVATAdvanceNotif.Period);
        SalesVATAdvanceNotif2.TestField("XSL-Filename", SalesVATAdvanceNotif."XSL-Filename");
        SalesVATAdvanceNotif2.TestField("Contact for Tax Office", SalesVATAdvanceNotif."Contact for Tax Office");

        // Tear-Down
        asserterror Error(RollBackChangesErr);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Elster VAT Adv. Notification");
        // Lazy Setup.
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Elster VAT Adv. Notification");

        LibraryERMCountryData.CreateVATData();
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Elster VAT Adv. Notification");
    end;

    local procedure UpdateSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.");
    begin
        SalesVATAdvanceNotif.Validate("XSL-Filename", TemporaryPath() + SalesVATAdvanceNotif.Description + SalesVATAdvanceNotif."No." + '.xsl');
        SalesVATAdvanceNotif.Validate(Period, SalesVATAdvanceNotif.Period::Quarter);
        SalesVATAdvanceNotif.Validate("Contact for Tax Office", LibraryUtility.GenerateGUID());
        SalesVATAdvanceNotif.Modify(true);
    END;

    local procedure CreateSalesVATAdvanceNotif(var SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.");
    begin
        SalesVATAdvanceNotif.Init();
        SalesVATAdvanceNotif.Validate("No.",
          CopyStr(LibraryUtility.GenerateRandomCode(SalesVATAdvanceNotif.FieldNo("No."), Database::"Sales VAT Advance Notif."),
            1, LibraryUtility.GetFieldLength(Database::"Sales VAT Advance Notif.", SalesVATAdvanceNotif.FieldNo("No."))));
        SalesVATAdvanceNotif.Insert(true);
    end;
}