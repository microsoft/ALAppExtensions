// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 4509 "Email - Outlook API Setup"
{
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; ClientId; guid)
        {
            Caption = 'Client Id';
            DataClassification = CustomerContent;
        }
        field(3; ClientSecret; guid)
        {
            Caption = 'Client Secret';
            DataClassification = CustomerContent;
        }
        field(4; RedirectURL; Text[1024])
        {
            Caption = 'Redirect URL';
            DataClassification = CustomerContent;
        }
        field(5; TenantID; Guid)
        {
            Caption = 'TenantID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    procedure GetNullGuidDefaultValue(): Text
    var
        DefaultTenantId: Label 'common', Locked = true;
    begin
        exit(DefaultTenantId);
    end;

    procedure GetTenantIDAsText(): Text
    var
        Setup: Record "Email - Outlook API Setup";
        DummyGuid: Guid;
        TExt2: Text;
    begin
        if Setup.Get() then
            if IsNullGuid(Setup.TenantID) or (DummyGuid = Setup.TenantID) then
                Setup.GetNullGuidDefaultValue()
            else
                // Remove braces
                exit(format(Setup.TenantID).Substring(2, StrLen(Setup.TenantID) - 2));
    end;
}
