// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AA0235
codeunit 1596 "Email Installer"
#pragma warning restore AA0235
{
    Subtype = Install;
    Access = Internal;
    Permissions = tabledata Field = r;

    trigger OnInstallAppPerCompany()
    begin
        AddRetentionPolicyAllowedTables();
        SetDefaultEmailViewPolicy(Enum::"Email View Policy"::AllRelatedRecordsEmails);
    end;

    procedure AddRetentionPolicyAllowedTables()
    var
        Field: Record Field;
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetEmailTablesAddedToAllowedListUpgradeTag()) then
            exit;

        RetenPolAllowedTables.AddAllowedTable(Database::"Email Outbox", Field.FieldNo(SystemCreatedAt), 7);
        RetenPolAllowedTables.AddAllowedTable(Database::"Sent Email", Field.FieldNo(SystemCreatedAt), 7);

        UpgradeTag.SetUpgradeTag(GetEmailTablesAddedToAllowedListUpgradeTag());
    end;

    procedure SetDefaultEmailViewPolicy(DefaultEmailViewPolicy: Enum "Email View Policy")
    var
        EmailViewPolicy: Codeunit "Email View Policy";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetDefaultEmailViewPolicyUpgradeTag()) then
            exit;

        EmailViewPolicy.CheckForDefaultEntry(DefaultEmailViewPolicy);

        UpgradeTag.SetUpgradeTag(GetDefaultEmailViewPolicyUpgradeTag());
    end;

    local procedure GetEmailTablesAddedToAllowedListUpgradeTag(): Code[250]
    begin
        exit('MS-373161-EmailLogEntryAdded-20201005');
    end;

    local procedure GetDefaultEmailViewPolicyUpgradeTag(): Code[250]
    begin
        exit('MS-445654-DefaultEmailViewPolicyChanged-20221908');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterInitialization', '', false, false)]
    local procedure AddAllowedTablesOnAfterSystemInitialization()
    begin
        AddRetentionPolicyAllowedTables();
    end;
}