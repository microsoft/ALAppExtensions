// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Registration;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using System.Diagnostics;
using System.Environment.Configuration;
using System.Telemetry;

codeunit 205 "Alt. Cust. VAT Reg. Doc. Impl." implements "Alt. Cust. VAT Reg. Doc."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;

    var
        AltCustVATRegFacade: Codeunit "Alt. Cust. VAT. Reg. Facade";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SalesLinesRecreated: Boolean;
        InstructionTxt: Label 'The following data is taken from the Alternative VAT Registration setup. It will override values in the document and affect the posting. Do you want to continue?';
        DocumentValueTxt: Label 'Document value';
        AlternativeValueTxt: Label 'Alternative value';
        CannotChangeVATDataWhenPrepmtErr: Label 'You cannot make this change because it leads to a different VAT Registration No., Gen. Bus. Posting Group or VAT Bus. Posting Group than in the sales document. Since you have posted a prepayment invoice, such a change will cause an inconsistency in the ledger entries.';
        CannotChangeVATDataWhenPartiallyPostedErr: Label 'You cannot make this change because it leads to a different VAT Registration No., Gen. Bus. Posting Group or VAT Bus. Posting Group than in the sales document. Since you have posted a partial shipment, such a change will cause an inconsistency in the ledger entries.';
        VATDataTakenFromCustomerMsg: Label 'The VAT Country/Region code has been changed to the value that does not have an alternative VAT registration.\\The following fields have been updated from the customer card: %1', Comment = '%1 = list of the fields';
        FeatureNameTxt: Label 'Alternative Customer VAT Registration', Locked = true;
        ConfirmAltCustVATRegNotificationNameTok: Label 'Confirm an alternative customer VAT registration.';
        ConfirmAltCustVATRegNotificationDescTok: Label 'Show the user the page to confirm an alternative customer VAT registration when choosing either ship-to address or the VAT country different from the customer''s';
        AddAlternativeCustVATRegQst: Label 'The VAT country is different than the customer''s. Do you want to add an alternative VAT registration for this VAT country?';
        AddAlternativeCustVATRegMsg: Label 'Add';
        DontShowMsg: Label 'Don''t show';
        AddAltCustVATRegNotificationNameTok: Label 'Suggest an alternative customer VAT registration from sales document';
        AddAltCustVATRegNotificationDescTok: Label 'Suggest the user to add an alternative customer VAT registration when choosing a VAT country different from the customer''s';

    procedure Init(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")
    begin
        if xSalesHeader."Bill-to Customer No." = '' then
            exit;
        SalesHeader.Validate("Alt. VAT Registration No.", false);
        SalesHeader.Validate("Alt. Gen. Bus Posting Group", false);
        SalesHeader.Validate("Alt. VAT Bus Posting Group", false);
    end;

    procedure CopyFromCustomer(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if not IsAltVATRegUsed(SalesHeader) then
            exit;
        RunChecks(SalesHeader);
        Customer.SetLoadFields("Country/Region Code", "VAT Registration No.", "Gen. Bus. Posting Group", "VAT Bus. Posting Group");
        if not GetCustVATCalc(Customer, SalesHeader) then
            exit;
        CopyFromCustomer(SalesHeader, xSalesHeader, Customer);
    end;

    local procedure CopyFromCustomer(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; Customer: Record Customer)
    var
        ChangedFieldsList: Text;
    begin
        if (SalesHeader."Alt. VAT Registration No." or SalesHeader."Alt. VAT Bus Posting Group") and
           (SalesHeader."VAT Country/Region Code" <> Customer."Country/Region Code") and
           (xSalesHeader."VAT Country/Region Code" = SalesHeader."VAT Country/Region Code")
        then begin
            SalesHeader."VAT Country/Region Code" := Customer."Country/Region Code";
            AddStringToCommaSeparatedList(ChangedFieldsList, SalesHeader.FieldCaption("VAT Country/Region Code"));
        end;
        if SalesHeader."Alt. VAT Registration No." then begin
            SalesHeader.Validate("Alt. VAT Registration No.", false);
            SalesHeader.Validate("VAT Registration No.", Customer."VAT Registration No.");
            AddStringToCommaSeparatedList(ChangedFieldsList, SalesHeader.FieldCaption("VAT Registration No."));
        end;
        if SalesHeader."Alt. Gen. Bus Posting Group" then begin
            SalesHeader.Validate("Alt. Gen. Bus Posting Group", false);
            SalesHeader.Validate("Gen. Bus. Posting Group", Customer."Gen. Bus. Posting Group");
            AddStringToCommaSeparatedList(ChangedFieldsList, SalesHeader.FieldCaption("Gen. Bus. Posting Group"));
        end;
        if SalesHeader."Alt. VAT Bus Posting Group" then begin
            SalesHeader.Validate("Alt. VAT Bus Posting Group", false);
            SalesHeader.Validate("VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
            AddStringToCommaSeparatedList(ChangedFieldsList, SalesHeader.FieldCaption("VAT Bus. Posting Group"));
        end;
        if GuiAllowed() then
            Message(VATDataTakenFromCustomerMsg, ChangedFieldsList);
    end;

    procedure UpdateSetupOnShipToCountryChangeInSalesHeader(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")
    var
        AltCustVATReg: Record "Alt. Cust. VAT Reg.";
        VATCustomer: Record Customer;
    begin
        GetCustVATCalc(VATCustomer, SalesHeader);
        if AltCustVATRegFacade.GetAlternativeCustVATReg(AltCustVATReg, VATCustomer."No.", SalesHeader."Ship-to Country/Region Code") then
            SalesHeader.Validate("VAT Country/Region Code", AltCustVATReg."VAT Country/Region Code")
        else
            CopyFromCustomer(SalesHeader, xSalesHeader);
    end;

    procedure UpdateSetupOnVATCountryChangeInSalesHeader(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        if AlternativeCustVATRegIsBlank(SalesHeader) then begin
            CopyFromCustomer(SalesHeader, xSalesHeader);
            if not GetCustVATCalc(Customer, SalesHeader) then
                exit;
            if Customer."Country/Region Code" = SalesHeader."VAT Country/Region Code" then
                exit;
            ThrowAddAltCustVATRegNotification(Customer."No.", SalesHeader."VAT Country/Region Code");
            exit;
        end;
        RunChecks(SalesHeader);
        if SalesHeader.SystemCreatedAt <> 0DT then
            if not ConfirmChanges(SalesHeader) then
                error('');
        UpdateAltCustVATRegInSalesHeader(SalesHeader);
    end;

    procedure UpdateSetupOnBillToCustomerChangeInSalesHeader(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; BillToCustomer: Record Customer)
    var
        GLSetup: Record "General Ledger Setup";
        AltCustVATReg: Record "Alt. Cust. VAT Reg.";
    begin
        GLSetup.Get();
        if GLSetup."Bill-to/Sell-to VAT Calc." <> GLSetup."Bill-to/Sell-to VAT Calc."::"Bill-to/Pay-to No." then
            exit;

        if IsAltVATRegUsed(SalesHeader) then begin
            if SalesHeader."Bill-to Customer No." = SalesHeader."Sell-to Customer No." then
                exit;
            CopyFromCustomer(SalesHeader, xSalesHeader, BillToCustomer);
            exit;
        end;
        if AltCustVATRegFacade.GetAlternativeCustVATReg(AltCustVATReg, BillToCustomer."No.", SalesHeader."Ship-to Country/Region Code") then begin
            SalesHeader.Validate("VAT Country/Region Code", AltCustVATReg."VAT Country/Region Code");
            exit;
        end;
        AltCustVATRegFacade.CopyBillToCustomerToSalesHeader(SalesHeader, BillToCustomer);
    end;

    local procedure IsAltVATRegUsed(SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(SalesHeader."Alt. VAT Registration No." or SalesHeader."Alt. Gen. Bus Posting Group" or SalesHeader."Alt. VAT Bus Posting Group");
    end;

    local procedure AlternativeCustVATRegIsBlank(SalesHeader: Record "Sales Header"): Boolean
    var
        AltCustVATReg: Record "Alt. Cust. VAT Reg.";
    begin
        exit(not GetAlternativeCustVATReg(AltCustVATReg, SalesHeader));
    end;

    local procedure GetAlternativeCustVATReg(var AltCustVATReg: Record "Alt. Cust. VAT Reg."; SalesHeader: Record "Sales Header"): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields("No.");
        GetCustVATCalc(Customer, SalesHeader);
        exit(AltCustVATRegFacade.GetAlternativeCustVATReg(AltCustVATReg, Customer."No.", SalesHeader."VAT Country/Region Code"));
    end;

    local procedure ConfirmChanges(var SalesHeader: Record "Sales Header") Confirmed: Boolean
    var
        TempChangeLogEntry: Record "Change Log Entry" temporary;
        ConfirmAltCustVATRegPage: Page "Confirm Alt. Cust. VAT Reg.";
    begin
        FeatureTelemetry.LogUsage('0000NHM', FeatureNameTxt, 'Confirm changes');
        if not BuildFieldChangeBuffer(TempChangeLogEntry, SalesHeader) then
            exit(true);
        if not GuiAllowed() then
            exit(true);
        if SalesHeader.GetHideValidationDialog() then
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

    local procedure UpdateAltCustVATRegInSalesHeader(var SalesHeader: Record "Sales Header")
    var
        AltCustVATReg: Record "Alt. Cust. VAT Reg.";
    begin
        GetAlternativeCustVATReg(AltCustVATReg, SalesHeader);
        BindSubscription(this);
        AltCustVATRegFacade.CopyAltCustVATRegToSalesHeader(SalesHeader, AltCustVATReg);
        UnbindSubscription(this);
        FeatureTelemetry.LogUptake('0000NHG', FeatureNameTxt, Enum::"Feature Uptake Status"::Used);
    end;

    local procedure BuildFieldChangeBuffer(var TempChangeLogEntry: Record "Change Log Entry" temporary; SalesHeader: Record "Sales Header"): Boolean
    var
        AltCustVATReg: Record "Alt. Cust. VAT Reg.";
    begin
        GetAlternativeCustVATReg(AltCustVATReg, SalesHeader);
        AltCustVATRegFacade.AddTempChangeLogEntryForAltCustVATRegChanges(TempChangeLogEntry, SalesHeader, AltCustVATReg);
        exit(not TempChangeLogEntry.IsEmpty());
    end;

    local procedure RunChecks(SalesHeader: Record "Sales Header")
    begin
        CheckPrepayment(SalesHeader);
        CheckPartialPosting(SalesHeader);
    end;

    local procedure CheckPrepayment(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Prepmt. Amt. Inv.", '<>%1', 0);
        if not SalesLine.IsEmpty() then
            error(CannotChangeVATDataWhenPrepmtErr);
    end;

    local procedure CheckPartialPosting(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Quantity Shipped", '<>%1', 0);
        if not SalesLine.IsEmpty() then
            error(CannotChangeVATDataWhenPartiallyPostedErr);
    end;

    local procedure GetCustVATCalc(var VATCustomer: Record Customer; SalesHeader: Record "Sales Header"): Boolean
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.GetRecordOnce();
        case GLSetup."Bill-to/Sell-to VAT Calc." of
            GLSetup."Bill-to/Sell-to VAT Calc."::"Bill-to/Pay-to No.":
                begin
                    if not VATCustomer.Get(SalesHeader."Bill-to Customer No.") then
                        exit(VATCustomer.Get(SalesHeader."Sell-to Customer No."));
                    exit(true);
                end;
            GLSetup."Bill-to/Sell-to VAT Calc."::"Sell-to/Buy-from No.":
                exit(VATCustomer.Get(SalesHeader."Sell-to Customer No."));
        end;
    end;

    local procedure GetConfirmChangesNotificationId(): Guid
    begin
        exit('5a911b76-547b-49f4-ba6f-ffc64d75077d');
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
        Notification.AddAction(AddAlternativeCustVATRegMsg, Codeunit::"Alt. Cust. VAT Reg. Doc. Impl.", 'AddAltCustVATRegFromNotification');
        Notification.AddAction(DontShowMsg, Codeunit::"Alt. Cust. VAT Reg. Doc. Impl.", 'DisableAddAltCustVATRegNotification');
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
        exit('44c9f482-ed1e-4882-9c96-3135915b566d')
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnRecreateSalesLinesOnBeforeConfirm', '', false, false)]
    local procedure AvoidDoubleConfirmationOnRecreateSalesLinesOnBeforeConfirm(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; var Confirmed: Boolean; var IsHandled: Boolean)
    begin
        if not SalesLinesRecreated then
            exit;
        Confirmed := true;
        IsHandled := true;
        SalesLinesRecreated := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterRecreateSalesLines', '', false, false)]
    local procedure SetSalesLineRecreatedOnAfterRecreateSalesLines()
    begin
        SalesLinesRecreated := true;
    end;
}