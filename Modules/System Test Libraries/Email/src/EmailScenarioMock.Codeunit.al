// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134694 "Email Scenario Mock"
{
    Permissions = tabledata "Email Scenario" = rid;

    procedure AddMapping(EmailScenario: Enum "Email Scenario"; AccountId: Guid; Connector: Enum "Email Connector")
    var
        Scenario: Record "Email Scenario";
    begin
        Scenario.Scenario := EmailScenario;
        Scenario."Account Id" := AccountId;
        Scenario.Connector := Connector;

        Scenario.Insert();
    end;

    procedure DeleteAllMappings()
    var
        Scenario: Record "Email Scenario";
    begin
        Scenario.DeleteAll();
    end;

}