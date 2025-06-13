// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.RoleCenters;

pageextension 6103 "E-Doc. A/P Admin RC" extends "Acc. Payable Administrator RC"
{
    layout
    {
        addafter(APAdministratorActivities)
        {
            part(EDocumentActivities; "E-Document Activities")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
