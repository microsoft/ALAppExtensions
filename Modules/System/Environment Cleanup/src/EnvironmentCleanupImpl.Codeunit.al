// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1887 "Environment Cleanup Impl"
{
    Access = Internal;
    Permissions = tabledata Company = r;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentPerDatabase', '', false, false)]
    local procedure OnAfterCopyEnvironmentPerDatabase(SourceEnvironmentType: Option Production,Sandbox; SourceEnvironmentName: Text; DestinationEnvironmentType: Option Production,Sandbox; DestinationEnvironmentName: Text)
    var
        EnvironmentCleanup: Codeunit "Environment Cleanup";
        SourceType, DestinationType : Enum "Environment Type";
    begin
        SourceType := ConvertEnvironmentOptionToEnum(SourceEnvironmentType);
        DestinationType := ConvertEnvironmentOptionToEnum(DestinationEnvironmentType);
        EnvironmentCleanup.OnClearDatabaseConfig(SourceType, DestinationType);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", 'OnAfterCopyEnvironmentPerCompany', '', false, false)]
    local procedure OnAfterCopyEnvironmentPerCompany(SourceEnvironmentType: Option Production,Sandbox; SourceEnvironmentName: Text; DestinationEnvironmentType: Option Production,Sandbox; DestinationEnvironmentName: Text)
    var
        EnvironmentCleanup: Codeunit "Environment Cleanup";
        SourceType, DestinationType : Enum "Environment Type";
    begin
        SourceType := ConvertEnvironmentOptionToEnum(SourceEnvironmentType);
        DestinationType := ConvertEnvironmentOptionToEnum(DestinationEnvironmentType);
        EnvironmentCleanup.OnClearCompanyConfig(CompanyName(), SourceType, DestinationType);
    end;

    local procedure ConvertEnvironmentOptionToEnum(Option: Option Production,Sandbox): Enum "Environment Type"
    begin
        if Option = Option::Production then
            exit(Enum::"Environment Type"::Production)
        else
            exit(Enum::"Environment Type"::Sandbox)
    end;



}

