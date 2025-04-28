// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.CRM;

using System.Integration.Word;
using Microsoft.DemoData.Foundation;

codeunit 19060 "Create IN Word Template"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Word Template", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertWordTemplate(var Rec: Record "Word Template")
    var
        CreateWordTemplate: Codeunit "Create Word Template";
        CreateLanguage: Codeunit "Create Language";
    begin
        case Rec.Code of
            CreateWordTemplate.EventWordTemplate(),
            CreateWordTemplate.MemoWordTemplate(),
            CreateWordTemplate.ThanksNoteWordTemplate():
                Rec.Validate("Language Code", CreateLanguage.ENG());
        end;
    end;
}
