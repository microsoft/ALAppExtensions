// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN25
namespace Microsoft.Finance.VAT.Reporting;

codeunit 148003 "IRS Forms Enable Feature"
{
    EventSubscriberInstance = Manual;
    ObsoleteReason = 'Moved to IRS Forms App.';
    ObsoleteState = Pending;
    ObsoleteTag = '25.0';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IRS Forms Feature", 'OnAfterCheckFeatureEnabled', '', false, false)]
    local procedure EnableIRSFormsOnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
}
#endif
