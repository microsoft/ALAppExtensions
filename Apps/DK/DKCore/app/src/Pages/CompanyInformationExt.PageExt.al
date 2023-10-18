// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.Foundation.Company;

pageextension 13601 CompanyInformationExt extends "Company Information"
{
    layout
    {

        modify("EORI Number")
        {
            Visible = true;
        }
    }
}
