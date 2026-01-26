// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Tests.EServices.EDocument;

using Microsoft.EServices.EDocument;

codeunit 139518 "Dig. Vouchers Enable Enforce"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Digital Voucher Feature", 'OnBeforeEnforceDigitalVoucherFunctionality', '', false, false)]
    local procedure EnableOnBeforeEnforceDigitalVoucherFunctionality(var IsEnabled: Boolean; var IsHandled: Boolean)
    begin
        IsEnabled := true;
        IsHandled := true;
    end;

}
