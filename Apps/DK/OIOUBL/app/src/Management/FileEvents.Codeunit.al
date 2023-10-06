// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using System.Utilities;

codeunit 13667 "OIOUBL-File Events"
{
    procedure BlobCreated(var TempBlob: Codeunit "Temp Blob")
    begin
        OnBlobCreatedEvent(TempBlob);
    end;

    procedure FileCreated(FilePath: Text)
    begin
        FileCreatedEvent(FilePath);
    end;

    [IntegrationEvent(false, false)]
    local procedure FileCreatedEvent(FilePath: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBlobCreatedEvent(var TempBlob: Codeunit "Temp Blob")
    begin
    end;
}
