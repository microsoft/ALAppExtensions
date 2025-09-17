// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.VAT.Setup;

table 4772 "Finance Module Setup"
{
    DataClassification = CustomerContent;
    InherentEntitlements = RMX;
    InherentPermissions = RMX;
    Extensible = false;
    DataPerCompany = true;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }
        field(2; "VAT Prod. Post Grp. Standard"; Code[20])
        {
            Caption = 'Standard VAT Product Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(3; "VAT Prod. Post Grp. Reduced"; Code[20])
        {
            Caption = 'Reduced VAT Product Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(4; "VAT Prod. Post Grp. NO VAT"; Code[20])
        {
            Caption = 'No VAT Product Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    [InherentPermissions(PermissionObjectType::TableData, Database::"Finance Module Setup", 'I')]
    procedure InitRecord()
    begin
        if Rec.Get() then
            exit;

        Rec.Init();
        Rec.Insert();
    end;
}