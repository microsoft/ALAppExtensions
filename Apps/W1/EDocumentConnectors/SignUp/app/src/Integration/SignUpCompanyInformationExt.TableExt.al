// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;
using Microsoft.Foundation.Company;

tableextension 6381 CompanyInformationExt extends "Company Information"
{
    fields
    {
        field(6381; "SignUp Service Participant Id"; Text[100])
        {
            Caption = 'Service Participant Id';
            ToolTip = 'ExFlow E-Invoicing Service Participant Id.';
        }
    }

}