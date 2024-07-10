// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Setup;

using Microsoft.Finance.VAT.Setup;
using System.Environment;

tableextension 11714 "Sales & Receivables Setup CZL" extends "Sales & Receivables Setup"
{
    fields
    {
#pragma warning disable AL0842
        field(11780; "Default VAT Date CZL"; Enum "Default VAT Date CZL")
#pragma warning restore AL0842
        {
            Caption = 'Default VAT Date';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Replaced by VAT Reporting Date in General Ledger Setup.';
        }
        field(11781; "Allow Alter Posting Groups CZL"; Boolean)
        {
            Caption = 'Allow Alter Posting Groups';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '23.0';
            ObsoleteReason = 'It will be replaced by "Allow Multiple Posting Groups" field.';

        }
        field(11782; "Print QR Payment CZL"; Boolean)
        {
            Caption = 'Print QR payment';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Print QR Payment CZL" then
                    CreatePrintQROnPremFontkNotification();
            end;
        }
    }
    local procedure CreatePrintQROnPremFontkNotification()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        PrintQROnPremFontkNotification: Notification;
        PrintQROnPremFontkNotificationLbl: Label 'To print the QR code for payments, it is necessary to have the IDAutomation2D font installed on the server.';
    begin
        if not EnvironmentInformation.IsOnPrem() then
            exit;
        PrintQROnPremFontkNotification.Message := PrintQROnPremFontkNotificationLbl;
        PrintQROnPremFontkNotification.Scope := NotificationScope::LocalScope;
        PrintQROnPremFontkNotification.Send();
    end;
}
