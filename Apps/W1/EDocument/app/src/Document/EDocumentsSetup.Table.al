// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;
using System.Environment;

table 6107 "E-Documents Setup"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = R;

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
    begin
        Clear(Rec);
        if Rec.FindFirst() then
            if Rec."New E-Document Experience" then
                exit(true);
        if not EnvironmentInformation.IsSandbox() then
            exit(false);
        // exit(EnvironmentInformation.GetEnvironmentSetting('NewEDocumentExperience') <> '');
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