// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Registration;
using Microsoft.Sales.Customer;
using System.Telemetry;
using System.Diagnostics;
using System.Environment.Configuration;

codeunit 11732 "Alt. Cust. VAT Reg. Impl. CZZ" implements "Alt. Cust. VAT Reg. Adv. CZZ"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AltCustVATRegFacade: Codeunit "Alt. Cust. VAT. Reg. Facade";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        InstructionTxt: Label 'The following data is taken from the Alternative VAT Registration setup. It will override values in the document and affect the posting. Do you want to continue?';
        DocumentValueTxt: Label 'Document value';
        AlternativeValueTxt: Label 'Alternative value';
        CannotChangeVATDataWhenVATPaymentErr: Label 'You cannot make this change because it leads to a different VAT Registration No., Gen. Bus. Posting Group or VAT Bus. Posting Group than in the sales advance letter. Since you have posted a VAT payment, such a change will cause an inconsistency in the ledger entries.';
        VATDataTakenFromCustomerMsg: Label 'The VAT Country/Region code has been changed to the value that does not have an alternative VAT registration.\\The following fields have been updated from the customer card: %1', Comment = '%1 = list of the fields';
        FeatureNameTxt: Label 'Alternative Customer VAT Registration', Locked = true;
        ConfirmAltCustVATRegNotificationNameTok: Label 'Confirm an alternative customer VAT registration in advance letters';
        ConfirmAltCustVATRegNotificationDescTok: Label 'Show the user the page to confirm an alternative customer VAT registration when choosing the VAT country different from the customer''s';
        AddAlternativeCustVATRegQst: Label 'The VAT country is different than the customer''s. Do you want to add an alternative VAT registration for this VAT country?';
        AddAlternativeCustVATRegMsg: Label 'Add';
        DontShowMsg: Label 'Don''t show';
        AddAltCustVATRegNotificationNameTok: Label 'Suggest an alternative customer VAT registration from sales advance letter';
        AddAltCustVATRegNotificationDescTok: Label 'Suggest the user to add an alternative customer VAT registration when choosing a VAT country different from the customer''s';

    procedure Init(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        if xSalesAdvLetterHeaderCZZ."Bill-to Customer No." = '' then
            exit;
        SalesAdvLetterHeaderCZZ.Validate("Alt. VAT Registration No.", false);
        SalesAdvLetterHeaderCZZ.Validate("Alt. VAT Bus Posting Group", false);
    end;

    procedure CopyFromCustomer(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        Customer: Record Customer;
    begin
        if not IsAltVATRegUsed(SalesAdvLetterHeaderCZZ) then
            exit;
        RunChecks(SalesAdvLetterHeaderCZZ);
        Customer.SetLoadFields("Country/Region Code", "VAT Registration No.", "VAT Bus. Posting Group");
        if not Customer.Get(SalesAdvLetterHeaderCZZ."Bill-to Customer No.") then
            exit;
        CopyFromCustomer(SalesAdvLetterHeaderCZZ, xSalesAdvLetterHeaderCZZ, Customer);
    end;

    local procedure CopyFromCustomer(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; Customer: Record Customer)
    var
        ChangedFieldsList: Text;
    begin
        if (SalesAdvLetterHeaderCZZ."Alt. VAT Registration No." or SalesAdvLetterHeaderCZZ."Alt. VAT Bus Posting Group") and
           (SalesAdvLetterHeaderCZZ."VAT Country/Region Code" <> Customer."Country/Region Code") and
           (xSalesAdvLetterHeaderCZZ."VAT Country/Region Code" = SalesAdvLetterHeaderCZZ."VAT Country/Region Code")
        then begin
            SalesAdvLetterHeaderCZZ."VAT Country/Region Code" := Customer."Country/Region Code";
            AddStringToCommaSeparatedList(ChangedFieldsList, SalesAdvLetterHeaderCZZ.FieldCaption("VAT Country/Region Code"));
        end;
        if SalesAdvLetterHeaderCZZ."Alt. VAT Registration No." then begin
            SalesAdvLetterHeaderCZZ.Validate("Alt. VAT Registration No.", false);
            SalesAdvLetterHeaderCZZ.Validate("VAT Registration No.", Customer."VAT Registration No.");
            AddStringToCommaSeparatedList(ChangedFieldsList, SalesAdvLetterHeaderCZZ.FieldCaption("VAT Registration No."));
        end;
        if SalesAdvLetterHeaderCZZ."Alt. VAT Bus Posting Group" then begin
            SalesAdvLetterHeaderCZZ.Validate("Alt. VAT Bus Posting Group", false);
            SalesAdvLetterHeaderCZZ.Validate("VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
            AddStringToCommaSeparatedList(ChangedFieldsList, SalesAdvLetterHeaderCZZ.FieldCaption("VAT Bus. Posting Group"));
        end;
        if GuiAllowed() then
            Message(VATDataTakenFromCustomerMsg, ChangedFieldsList);
    end;

    procedure UpdateSetupOnVATCountryChangeInSalesAdvLetterHeader(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; xSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        Customer: Record Customer;
    begin
        if AlternativeCustVATRegIsBlank(SalesAdvLetterHeaderCZZ) then begin
            CopyFromCustomer(SalesAdvLetterHeaderCZZ, xSalesAdvLetterHeaderCZZ);
            if not Customer.Get(SalesAdvLetterHeaderCZZ."Bill-to Customer No.") then
                exit;
            if Customer."Country/Region Code" = SalesAdvLetterHeaderCZZ."VAT Country/Region Code" then
                exit;
            ThrowAddAltCustVATRegNotification(Customer."No.", SalesAdvLetterHeaderCZZ."VAT Country/Region Code");
            exit;
        end;
        RunChecks(SalesAdvLetterHeaderCZZ);
        if SalesAdvLetterHeaderCZZ.SystemCreatedAt <> 0DT then
            if not ConfirmChanges(SalesAdvLetterHeaderCZZ) then
                error('');
        UpdateAltCustVATRegInSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ);
    end;

    local procedure IsAltVATRegUsed(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"): Boolean
    begin
        exit(SalesAdvLetterHeaderCZZ."Alt. VAT Registration No." or SalesAdvLetterHeaderCZZ."Alt. VAT Bus Posting Group");
    end;

    local procedure AlternativeCustVATRegIsBlank(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"): Boolean
    var
        AltCustVATReg: Record "Alt. Cust. VAT Reg.";
    begin
        exit(not GetAlternativeCustVATReg(AltCustVATReg, SalesAdvLetterHeaderCZZ));
    end;

    local procedure GetAlternativeCustVATReg(var AltCustVATReg: Record "Alt. Cust. VAT Reg."; SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields("No.");
        Customer.Get(SalesAdvLetterHeaderCZZ."Bill-to Customer No.");
        exit(AltCustVATRegFacade.GetAlternativeCustVATReg(AltCustVATReg, Customer."No.", SalesAdvLetterHeaderCZZ."VAT Country/Region Code"));
    end;

    local procedure ConfirmChanges(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ") Confirmed: Boolean
    var
        TempChangeLogEntry: Record "Change Log Entry" temporary;
        ConfirmAltCustVATRegPage: Page "Confirm Alt. Cust. VAT Reg.";
    begin
        FeatureTelemetry.LogUsage('0000QRW', FeatureNameTxt, 'Confirm changes');
        if not BuildFieldChangeBuffer(TempChangeLogEntry, SalesAdvLetterHeaderCZZ) then
            exit(true);
        if not GuiAllowed() then
            exit(true);
        if SalesAdvLetterHeaderCZZ.GetHideValidationDialog() then
            exit(true);
        if not ShowConfirmation() then
            exit(true);
        ConfirmAltCustVATRegPage.SetUIControls(InstructionTxt, DocumentValueTxt, AlternativeValueTxt);
        ConfirmAltCustVATRegPage.SetSource(TempChangeLogEntry);
        Confirmed := ConfirmAltCustVATRegPage.RunModal() = Action::Ok;
        if ConfirmAltCustVATRegPage.DontShowAgainOptionSelected() then
            DisableConfirmation();
        exit(Confirmed);
    end;

    local procedure ShowConfirmation(): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        if Database.IsInWriteTransaction() then
            exit(false);
        exit(MyNotifications.IsEnabled(GetConfirmChangesNotificationId()));
    end;

    local procedure DisableConfirmation()
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(GetConfirmChangesNotificationId()) then
            MyNotifications.InsertDefault(GetConfirmChangesNotificationId(), ConfirmAltCustVATRegNotificationNameTok, ConfirmAltCustVATRegNotificationDescTok, false);
    end;

    local procedure UpdateAltCustVATRegInSalesAdvLetterHeader(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        AltCustVATReg: Record "Alt. Cust. VAT Reg.";
    begin
        GetAlternativeCustVATReg(AltCustVATReg, SalesAdvLetterHeaderCZZ);
        if AltCustVATReg."VAT Registration No." <> '' then begin
            SalesAdvLetterHeaderCZZ.Validate("Alt. VAT Registration No.", true);
            SalesAdvLetterHeaderCZZ.Validate("VAT Registration No.", AltCustVATReg."VAT Registration No.");
        end;
        if AltCustVATReg."VAT Bus. Posting Group" <> '' then begin
            SalesAdvLetterHeaderCZZ.Validate("Alt. VAT Bus Posting Group", true);
            SalesAdvLetterHeaderCZZ.Validate("VAT Bus. Posting Group", AltCustVATReg."VAT Bus. Posting Group");
        end;
        OnAfterUpdateAltCustVATRegInSalesAdvLetterHeader(SalesAdvLetterHeaderCZZ, AltCustVATReg);
        FeatureTelemetry.LogUptake('0000QRV', FeatureNameTxt, Enum::"Feature Uptake Status"::Used);
    end;

    local procedure BuildFieldChangeBuffer(var TempChangeLogEntry: Record "Change Log Entry" temporary; SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"): Boolean
    var
        AltCustVATReg: Record "Alt. Cust. VAT Reg.";
    begin
        GetAlternativeCustVATReg(AltCustVATReg, SalesAdvLetterHeaderCZZ);
        if (AltCustVATReg."VAT Registration No." <> '') and (SalesAdvLetterHeaderCZZ."VAT Registration No." <> AltCustVATReg."VAT Registration No.") then
            AddFieldChangeBuffer(TempChangeLogEntry, SalesAdvLetterHeaderCZZ.FieldNo("VAT Registration No."), SalesAdvLetterHeaderCZZ."VAT Registration No.", AltCustVATReg."VAT Registration No.");
        if (AltCustVATReg."VAT Bus. Posting Group" <> '') and (SalesAdvLetterHeaderCZZ."VAT Bus. Posting Group" <> AltCustVATReg."VAT Bus. Posting Group") then
            AddFieldChangeBuffer(TempChangeLogEntry, SalesAdvLetterHeaderCZZ.FieldNo("VAT Bus. Posting Group"), SalesAdvLetterHeaderCZZ."VAT Bus. Posting Group", AltCustVATReg."VAT Bus. Posting Group");
        OnAfterBuildFieldChangeBuffer(TempChangeLogEntry, SalesAdvLetterHeaderCZZ);
        exit(not TempChangeLogEntry.IsEmpty());
    end;

    local procedure AddFieldChangeBuffer(var TempChangeLogEntry: Record "Change Log Entry" temporary; DocFieldNo: Integer; OldValue: Text[2048]; NewValue: Text[2048])
    begin
        TempChangeLogEntry."Entry No." += 1;
        TempChangeLogEntry."Table No." := Database::"Sales Adv. Letter Header CZZ";
        TempChangeLogEntry."Field No." := DocFieldNo;
        TempChangeLogEntry."Old Value" := OldValue;
        TempChangeLogEntry."New Value" := NewValue;
        TempChangeLogEntry.Insert();
    end;

    local procedure RunChecks(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        CheckVATPayment(SalesAdvLetterHeaderCZZ);
    end;

    local procedure CheckVATPayment(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if not SalesAdvLetterEntryCZZ.IsEmpty() then
            error(CannotChangeVATDataWhenVATPaymentErr);
    end;

    local procedure GetConfirmChangesNotificationId(): Guid
    begin
        exit('e564eb18-2c72-4d30-be8d-2050e084f9c2');
    end;

    local procedure AddStringToCommaSeparatedList(var List: Text; Value: Text)
    begin
        if List <> '' then
            List += ', ';
        List += Value;
    end;

    local procedure ThrowAddAltCustVATRegNotification(CustNo: Code[20]; VATCountryRegionCode: Code[10])
    var
        MyNotifications: Record "My Notifications";
        AltCustVATReg: Record "Alt. Cust. VAT Reg.";
        Notification: Notification;
    begin
        if not MyNotifications.IsEnabled(AddAltCustVATRegNotificationId()) then
            exit;
        Notification.Id(AddAltCustVATRegNotificationId());
        Notification.Message(AddAlternativeCustVATRegQst);
        Notification.SetData(AltCustVATReg.FieldName("Customer No."), CustNo);
        Notification.SetData(AltCustVATReg.FieldName("VAT Country/Region Code"), VATCountryRegionCode);
        Notification.AddAction(AddAlternativeCustVATRegMsg, Codeunit::"Alt. Cust. VAT Reg. Impl. CZZ", 'AddAltCustVATRegFromNotification');
        Notification.AddAction(DontShowMsg, Codeunit::"Alt. Cust. VAT Reg. Impl. CZZ", 'DisableAddAltCustVATRegNotification');
        Notification.Send();
    end;

    procedure AddAltCustVATRegFromNotification(Notification: Notification)
    var
        AltCustVATReg: Record "Alt. Cust. VAT Reg.";
        NewId: Integer;
    begin
        if AltCustVATReg.FindLast() then
            NewId := AltCustVATReg.Id;
        NewId += 1;
        AltCustVATReg.Init();
        AltCustVATReg.Validate(Id, NewId);
        AltCustVATReg.Validate("Customer No.",
            CopyStr(Notification.GetData(AltCustVATReg.FieldName("Customer No.")), 1, MaxStrLen(AltCustVATReg."Customer No.")));
        AltCustVATReg.Validate("VAT Country/Region Code",
            CopyStr(Notification.GetData(AltCustVATReg.FieldName("VAT Country/Region Code")), 1, MaxStrLen(AltCustVATReg."VAT Country/Region Code")));
        AltCustVATReg.Insert(true);
        Commit();
        Page.RunModal(0, AltCustVATReg);
    end;

    procedure DisableAddAltCustVATRegNotification(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.Disable(Notification.Id()) then
            MyNotifications.InsertDefault(Notification.Id(), AddAltCustVATRegNotificationNameTok, AddAltCustVATRegNotificationDescTok, false);
    end;

    local procedure AddAltCustVATRegNotificationId(): Text
    begin
        exit('34c4fa1d-07b6-450b-b524-0d367b1e6221')
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildFieldChangeBuffer(var TempChangeLogEntry: Record "Change Log Entry" temporary; SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateAltCustVATRegInSalesAdvLetterHeader(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var AltCustVATReg: Record "Alt. Cust. VAT Reg.")
    begin
    end;
}