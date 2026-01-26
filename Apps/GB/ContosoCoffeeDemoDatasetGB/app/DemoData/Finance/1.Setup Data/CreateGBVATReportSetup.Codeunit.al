#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

codeunit 10542 "Create GB VAT Report Setup"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;
    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to GovTalk app';
    ObsoleteTag = '27.0';

    trigger OnRun()
    begin
    end;

    [Obsolete('Moved to GovTalk app', '27.0')]
    procedure GovTalkVersion(): Code[10]
    begin
        exit(GovTalkVersionTok);
    end;

    var
        GovTalkVersionTok: Label 'GOVTALK', MaxLength = 10;
}
#endif
