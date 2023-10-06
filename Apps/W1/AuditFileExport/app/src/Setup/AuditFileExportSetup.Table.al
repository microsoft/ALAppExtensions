// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

table 5264 "Audit File Export Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Audit File Export Setup';
    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; "Audit File Export Format"; enum "Audit File Export Format")
        {
            DataClassification = CustomerContent;
            Caption = 'Audit File Export Format Code';
        }
        field(3; "Standard Account Type"; enum "Standard Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Standard Account Type';
        }
        field(10; "Last Tax Code"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Tax Code';
        }
        field(11; "Default Post Code"; Code[20])
        {
            Caption = 'Default Post Code';
        }
        field(20; "Check Company Information"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Company Information';
        }
        field(21; "Check Customer"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Customer';
        }
        field(22; "Check Vendor"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Vendor';
        }
        field(23; "Check Bank Account"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Bank Account';
        }
        field(24; "Check Post Code"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Post Code';
        }
        field(25; "Check Address"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Address';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure InitSetup(AuditFileExportFormat: enum "Audit File Export Format")
    begin
        if not Rec.Get() then
            Rec.Insert();
        Rec."Audit File Export Format" := AuditFileExportFormat;
        Rec.Modify();
    end;

    procedure UpdateStandardAccountType(StandardAccountType: enum "Standard Account Type")
    begin
        if not Rec.Get() then
            Rec.Insert();
        Rec."Standard Account Type" := StandardAccountType;
        Rec.Modify();
    end;
}
