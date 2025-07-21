// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

table 11023 "Elec. VAT Decl. Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Sales VAT Adv. Notif. Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sales VAT Adv. Notif. Nos.';
            TableRelation = "No. Series";
        }

        field(3; "Sales VAT Adv. Notif. Path"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Sales VAT Adv. Notif. Path';
        }

        field(4; "XML File Default Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'XML File Default Name';
        }
    }

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ElecVATAdvanceNotTok: Label 'DE Elec. VAT Advance Notifications', Locked = true;
        ElecVATDeclSetupQst: Label 'Sales VAT Adv. Notif. Path of the XML file is missing. Do you want to update it now?';
        MissingSetupElsterErr: Label 'Sales VAT Adv. Notif Path of the XML file is missing. Please Correct it.';

    trigger OnInsert()
    begin
        FeatureTelemetry.LogUptake('0001Q0F', ElecVATAdvanceNotTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    procedure VerifyAndSetSalesVATAdvNotifPath()
    var
        ElectronicVATDeclSetup: Page "Electronic VAT Decl. Setup";
    begin
        Get();
        if IsSalesVATAdvNotifPathAvailable() then
            exit;
        if Confirm(ElecVATDeclSetupQst, true) then begin
            ElectronicVATDeclSetup.SetRecord(Rec);
            ElectronicVATDeclSetup.Editable(true);
            if ElectronicVATDeclSetup.RunModal() = Action::OK then
                ElectronicVATDeclSetup.GetRecord(Rec);
        end;
        if not IsSalesVATAdvNotifPathAvailable() then
            Error(MissingSetupElsterErr);
    end;

    local procedure IsSalesVATAdvNotifPathAvailable(): Boolean;
    begin
        exit(true);
    end;
}
