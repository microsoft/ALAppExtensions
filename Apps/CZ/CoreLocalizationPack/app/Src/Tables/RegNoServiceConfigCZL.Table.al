// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

table 11755 "Reg. No. Service Config CZL"
{
    Caption = 'Registration No. Service Config';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Enabled then
                    TestField("Service Endpoint");
            end;
        }
        field(3; "Service Endpoint"; Text[250])
        {
            Caption = 'Service Endpoint';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        if not IsEmpty() then
            Error(CannotInsertMultipleSettingsErr);
    end;

    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        RegNoSettingIsNotEnabledErr: Label 'Registration Service Setting is not enabled.';
        CannotInsertMultipleSettingsErr: Label 'You cannot insert multiple settings.';

    procedure RegNoSrvIsEnabled(): Boolean
    begin
        RegNoServiceConfigCZL.SetRange(Enabled, true);
        exit(RegNoServiceConfigCZL.FindFirst() and RegNoServiceConfigCZL.Enabled);
    end;

    procedure GetRegNoURL(): Text
    begin
        RegNoServiceConfigCZL.SetRange(Enabled, true);
        if not RegNoServiceConfigCZL.FindFirst() then
            Error(RegNoSettingIsNotEnabledErr);
        RegNoServiceConfigCZL.TestField("Service Endpoint");
        exit(RegNoServiceConfigCZL."Service Endpoint");
    end;
}
