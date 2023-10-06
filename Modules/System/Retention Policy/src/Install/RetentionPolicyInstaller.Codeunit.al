// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

using System.Environment.Configuration;
using System.Upgrade;
using System.Environment;

#pragma warning disable AA0235
codeunit 3907 "Retention Policy Installer"
#pragma warning restore AA0235
{
    Subtype = Install;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Retention Period" = ri,
                  tabledata "Retention Policy Setup" = ri,
                  tabledata Company = r;

    var
        SixMonthsTok: Label 'Six Months', MaxLength = 20;
        RetenPolInstallerAbortLbl: Label 'Retention Policy Installer aborted due to missing table Retention Policy Log Entry on: %1', Locked = true;

    trigger OnInstallAppPerCompany()
    begin
        AddAllowedTables();
    end;

    procedure AddAllowedTables()
    begin
        AddAllowedTables(false);
    end;

    procedure AddAllowedTables(ForceUpdate: Boolean)
    var
        RetentionPolicyLogEntry: Record "Retention Policy Log Entry";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        UpgradeTag: Codeunit "Upgrade Tag";
        IsInitialSetup: Boolean;
    begin
        // if you add a new table here, also update codeunit 3913 "System Application Logs Delete"
        IsInitialSetup := not UpgradeTag.HasUpgradeTag(GetRetenPolLogEntryAddedUpgradeTag());
        if not (IsInitialSetup or ForceUpdate) then
            exit;

        if not RetenPolAllowedTables.IsAllowedTable(Database::"Retention Policy Log Entry") then
            if not RetenPolAllowedTables.AddAllowedTable(Database::"Retention Policy Log Entry", RetentionPolicyLogEntry.FieldNo(SystemCreatedAt), 28) then begin // minimum retention period of 28 days
                RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(RetenPolInstallerAbortLbl, CompanyName()));
                exit;
            end;

        if IsInitialSetup then begin
            CreateRetentionPolicySetup(Database::"Retention Policy Log Entry", CreateSixMonthRetentionPeriod());
            UpgradeTag.SetUpgradeTag(GetRetenPolLogEntryAddedUpgradeTag());
        end;
    end;

    local procedure CreateSixMonthRetentionPeriod(): Code[20]
    var
        RetentionPeriod: Record "Retention Period";
    begin
        if RetentionPeriod.Get(SixMonthsTok) then
            exit(RetentionPeriod.Code);

        RetentionPeriod.SetRange("Retention Period", RetentionPeriod."Retention Period"::"6 Months");
        if RetentionPeriod.FindFirst() then
            exit(RetentionPeriod.Code);

        RetentionPeriod.Code := CopyStr(UpperCase(SixMonthsTok), 1, MaxStrLen(RetentionPeriod.Code));
        RetentionPeriod.Description := SixMonthsTok;
        RetentionPeriod.Validate("Retention Period", RetentionPeriod."Retention Period"::"6 Months");
        RetentionPeriod.Insert(true);
        exit(RetentionPeriod.Code);
    end;

    local procedure CreateRetentionPolicySetup(TableId: Integer; RetentionPeriodCode: Code[20])
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if RetentionPolicySetup.Get(TableId) then
            exit;
        RetentionPolicySetup.Validate("Table Id", TableId);
        RetentionPolicySetup.Validate("Apply to all records", true);
        RetentionPolicySetup.Validate("Retention Period", RetentionPeriodCode);
        RetentionPolicySetup.Validate(Enabled, false);
        RetentionPolicySetup.Insert(true);
    end;

    local procedure GetRetenPolLogEntryAddedUpgradeTag(): Code[250]
    begin
        exit('MS-334067-RetenPolLogEntryAdded-20200731');
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Setup");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reten. Pol. Allowed Tables", OnRefreshAllowedTables, '', false, false)]
    local procedure AddAllowedTablesOnRefreshAllowedTables()
    begin
        AddAllowedTables(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterLogin, '', false, false)]
    local procedure AddAllowedTablesOnAfterLogin()
    begin
        AddAllowedTables();
    end;
}