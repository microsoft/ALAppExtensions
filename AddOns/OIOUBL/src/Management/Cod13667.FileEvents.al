// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13667 "OIOUBL-File Events"
{
    procedure FileCreated(FilePath: Text)
    begin
        FileCreatedEvent(FilePath);
    end;

    [IntegrationEvent(false, false)]
    local procedure FileCreatedEvent(FilePath: Text)
    begin
    end;
}