// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

using Microsoft.HumanResources.Employee;

tableextension 10684 "SAF-T Company Contact" extends "Company Information"
{
    fields
    {
        field(10670; "SAF-T Contact No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'SAF-T Contact No.';
            TableRelation = Employee;
        }
    }
}
