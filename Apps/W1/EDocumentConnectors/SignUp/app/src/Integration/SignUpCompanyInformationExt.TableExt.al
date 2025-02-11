// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;
using Microsoft.Foundation.Company;

tableextension 6381 SignUpCompanyInformationExt extends "Company Information"
{
    fields
    {
        field(6381; "SignUp Service Participant Id"; Text[100])
        {
            Caption = 'Service Participant Id';
            ToolTip = 'Specifies the PEPPOL participant identifier registered for your company in the ExFlow E-Invoicing subscription. This identifier is used when you are sending/receiving documents via the PEPPOL network.';
        }
    }

}