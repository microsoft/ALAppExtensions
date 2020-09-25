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

    trigger OnInstallAppPerCompany()
    begin
        AddRetentionPolicyAllowedTables();
    end;

    procedure AddRetentionPolicyAllowedTables()
    var
        Field: Record Field;
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
    begin
        RetenPolAllowedTables.AddAllowedTable(Database::"Email Outbox", Field.FieldNo(SystemCreatedAt), 7);
        RetenPolAllowedTables.AddAllowedTable(Database::"Sent Email", Field.FieldNo(SystemCreatedAt), 7);
    end;
}