// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.Worksheet;

using System.Security.User;

codeunit 31320 "Whse. Worksht.Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Whse. Worksheet Line", 'OnBeforeCheckTemplateName', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeCheckTemplateName(var WkshTemplateName: Code[10])
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
    begin
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"Whse. Worksheet";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, WkshTemplateName);
    end;
}
