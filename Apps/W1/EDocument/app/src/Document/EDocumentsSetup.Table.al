// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;
using System.Environment;
using System.Azure.Identity;

table 6107 "E-Documents Setup"
{
    Access = Internal;
#pragma warning disable AS0034
    InherentEntitlements = RIX;
    InherentPermissions = RX;
#pragma warning restore AS0034
    ReplicateData = false;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "New E-Document Experience"; Boolean)
        {
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

    procedure IsNewEDocumentExperienceActive(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        Clear(Rec);
        if Rec.FindFirst() then
            if Rec."New E-Document Experience" then
                exit(true);
        if AzureADTenant.GetAadTenantId() in [
            '7bfacc13-5977-43eb-ae75-63e4cbf78029',
            '5d02776e-8cf2-4fae-8cac-a52cfdfbe90f',
            'f0ac72d1-c1b3-4c2a-a196-8fb82cac5934',
            '4cde9473-edc6-464d-98c9-921bb36bab03',
            '1fe0f01e-1d4a-4e55-86d7-c45a5b9bf1a6',
            '62c3bd14-7298-4281-a12a-ec3a78c22957',
            'e5afa896-1f57-4c74-b9cd-65638c0f77da'
        ] then
            exit(true);
        if not EnvironmentInformation.IsSandbox() then
            exit(false);
        exit(EnvironmentInformation.GetEnvironmentSetting('EnableNewEDocumentExperience') <> '');
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"E-Documents Setup", 'I')]
    internal procedure InsertNewExperienceSetup()
    begin
        // Only to be used by tests.
        if Rec.FindFirst() then
            exit;
        Rec."New E-Document Experience" := true;
        Rec.Insert();
    end;

}