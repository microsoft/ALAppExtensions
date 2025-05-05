// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.HumanResources.Employee;
using Microsoft.DemoData.HumanResources;

codeunit 11155 "CreateEmployee Template AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Employee Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertEmployeeTemplate(var Rec: Record "Employee Templ.")
    var
        CreateEmployeeTemplate: Codeunit "Create Employee Template";
    begin
        case Rec.Code of
            CreateEmployeeTemplate.AdminCode(), CreateEmployeeTemplate.ITCode():
                Rec.Validate("Employee Posting Group", '');
        end;
    end;
}
