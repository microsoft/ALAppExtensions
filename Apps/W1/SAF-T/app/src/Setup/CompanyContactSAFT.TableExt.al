// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;

tableextension 5280 "Company Contact SAF-T" extends "Company Information"
{
    fields
    {
        field(5280; "Contact No. SAF-T"; Code[20])
        {
            TableRelation = Employee;
        }
    }
}
