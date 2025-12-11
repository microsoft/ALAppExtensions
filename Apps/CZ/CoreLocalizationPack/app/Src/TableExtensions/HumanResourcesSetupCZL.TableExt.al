// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.HumanResources.Setup;

using Microsoft.HumanResources.Employee;
using System.Utilities;

tableextension 31075 "Human Resources Setup CZL" extends "Human Resources Setup"
{
    fields
    {
        modify("Allow Multiple Posting Groups")
        {
            trigger OnAfterValidate()
            var
                Employee: Record Employee;
                ConfirmManagement: Codeunit "Confirm Management";
                IsConfirmed: Boolean;
            begin
                if "Allow Multiple Posting Groups" and ("Allow Multiple Posting Groups" <> xRec."Allow Multiple Posting Groups") then begin
                    Employee.SetRange("Allow Multiple Posting Groups", false);
                    if not Employee.IsEmpty() then
                        IsConfirmed := ConfirmManagement.GetResponse(EmployeeUpdateQst, false);
                    if IsConfirmed then
                        Employee.ModifyAll("Allow Multiple Posting Groups", true);
                end;
            end;
        }
    }

    var
        EmployeeUpdateQst: Label 'There are employees that do not allow multiple posting groups. Do you want to update these employees to allow multiple posting groups?';
}