// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Jobs;

using Microsoft.Projects.Project.Job;
using Microsoft.DemoData.Foundation;

codeunit 13724 "Create Job DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertJob(var Rec: Record Job)
    var
        CreateLanguage: Codeunit "Create Language";
    begin
        ValidateRecordFieldsJob(Rec, CreateLanguage.DAN());
    end;

    local procedure ValidateRecordFieldsJob(var Job: Record Job; LanguageCode: Code[10])
    begin
        Job.Validate("Language Code", LanguageCode);
    end;
}
