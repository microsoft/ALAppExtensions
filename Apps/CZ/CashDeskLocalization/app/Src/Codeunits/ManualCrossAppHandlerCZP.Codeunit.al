// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.ReceivablesPayables;

codeunit 31131 "Manual Cross App. Handler CZP"
{
    EventSubscriberInstance = Manual;

    var
        AppliesToIDCode: Code[50];

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnSetAppliesToID', '', false, false)]
    local procedure OnSetAppliesToIDCrossApplication(AppliesToID: Code[50])
    begin
        AppliesToIDCode := AppliesToID;
    end;

    procedure GetAppliesToID(): Code[50]
    begin
        exit(AppliesToIDCode);
    end;
}
