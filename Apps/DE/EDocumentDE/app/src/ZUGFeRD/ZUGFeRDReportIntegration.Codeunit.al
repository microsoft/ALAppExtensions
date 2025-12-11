// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

codeunit 11036 "ZUGFeRD Report Integration"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export ZUGFeRD Document", OnIsZUGFeRDPrintProcess, '', false, false)]
    local procedure EnableOnIsZUGFeRDPrintProcess(var Result: Boolean)
    begin
        Result := true;
    end;

}