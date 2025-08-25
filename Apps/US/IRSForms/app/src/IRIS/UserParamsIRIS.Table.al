// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10051 "User Params IRIS"
{
    Access = Internal;
    InherentEntitlements = rimdX;
    InherentPermissions = rimdX;
    DataPerCompany = false;

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(2; "IRIS User ID Key"; Guid)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(3; "Access Token Key"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Refresh Token Key"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Access Token Expires At"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Refresh Token Expires At"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(10; "Privacy Consent Given"; Boolean)
        {
            DataClassification = EndUserPseudonymousIdentifiers;
        }
    }

    keys
    {
        key(PK; "User Security ID")
        {
            Clustered = true;
        }
    }

    [InherentPermissions(PermissionObjectType::TableData, Database::"User Params IRIS", 'RI', InherentPermissionsScope::Both)]
    procedure GetRecord()
    begin
        if not Get(UserSecurityId()) then begin
            Rec."User Security ID" := UserSecurityId();
            Rec.Insert();
        end;
    end;

}