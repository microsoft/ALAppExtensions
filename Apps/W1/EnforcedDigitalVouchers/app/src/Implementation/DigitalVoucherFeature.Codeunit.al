// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Sales.History;
using System.Environment;
using System.Environment.Configuration;

codeunit 5585 "Digital Voucher Feature"
{
    var
        DKCountryCodeTxt: label 'DK', Locked = true;
        InstallFeatureNotificationMsg: Label 'Digital voucher feature is not enabled. Do you want to enable it by completing the guide?';
        CannotChangeEnforcedAppErr: Label 'You cannot perform this action because the Digital Voucher functionality is enforced in your application.';
        EnableTxt: Label 'Enable';

    procedure IsFeatureEnabled(): Boolean
    var
        DigitalVoucherSetup: Record "Digital Voucher Setup";
    begin
        if EnforceDigitalVoucherFunctionality() then
            exit(true);
        if not DigitalVoucherSetup.Get() then
            exit(false);
        exit(DigitalVoucherSetup.Enabled);
    end;

    procedure IsDigitalVoucherEnabledForTableNumber(TableNumber: Integer): Boolean
    begin
        exit(TableNumber in [Database::"Sales Invoice Header", Database::"Sales Cr.Memo Header", Database::"Purch. Inv. Header", Database::"Purch. Cr. Memo Hdr.", Database::"G/L Entry"]);
    end;

    procedure ThrowNotificationIfFeatureIsNotEnabled()
    var
        MyNotifications: Record "My Notifications";
        EnforceDigitalVoucherFeatureNotification: Notification;
    begin
        if IsFeatureEnabled() then
            exit;
        if not MyNotifications.IsEnabled(GetDigitalVoucherFeatureNotificationId()) then
            exit;
        EnforceDigitalVoucherFeatureNotification.Id := GetDigitalVoucherFeatureNotificationId();
        EnforceDigitalVoucherFeatureNotification.Recall();
        EnforceDigitalVoucherFeatureNotification.Message := InstallFeatureNotificationMsg;
        EnforceDigitalVoucherFeatureNotification.AddAction(EnableTxt, Codeunit::"Digital Voucher Feature", 'OpenDigitalVoucherGuide');
        EnforceDigitalVoucherFeatureNotification.Send();
    end;

    procedure OpenDigitalVoucherGuide(var Notification: Notification)
    begin
        Page.RunModal(Page::"Digital Voucher Guide");
    end;

    procedure CheckIfDigitalVoucherSetupChangeIsAllowed()
    begin
        if EnforceDigitalVoucherFunctionality() then
            Error(CannotChangeEnforcedAppErr);
    end;

    procedure EnforceDigitalVoucherFunctionality() IsEnabled: Boolean
    var
        Company: Record Company;
        EnvironmentInformation: Codeunit "Environment Information";
        IsHandled: Boolean;
    begin
        OnBeforeEnforceDigitalVoucherFunctionality(IsEnabled, IsHandled);
        if IsHandled then
            exit(IsEnabled);
        if (not EnvironmentInformation.IsSaaSInfrastructure()) or (EnvironmentInformation.IsSandbox()) then
            exit(false);
        Company.Get(CompanyName());
        if Company."Evaluation Company" then
            exit;
        if EnvironmentInformation.GetApplicationFamily() = DKCountryCodeTxt then
            exit(Today() >= 20240701D);
    end;

    local procedure GetDigitalVoucherFeatureNotificationId(): Guid
    begin
        exit('525ba5d9-efa3-4517-80c6-2de54f785f3b');
    end;

    [InternalEvent(false, false)]
    internal procedure OnBeforeEnforceDigitalVoucherFunctionality(var IsEnabled: Boolean; var IsHandled: Boolean)
    begin
    end;
}
