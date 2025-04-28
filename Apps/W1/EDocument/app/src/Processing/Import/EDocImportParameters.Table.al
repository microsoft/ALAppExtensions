// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.EServices.EDocument.Processing.Import;

table 6106 "E-Doc. Import Parameters"
{
    TableType = Temporary;

    fields
    {
        field(1; "Step to Run"; Enum "Import E-Document Steps")
        {
        }
        field(2; "Processing Customizations"; Enum "E-Doc. Proc. Customizations")
        {
        }
        field(3; "Purch. Journal V1 Behavior"; Option)
        {
            OptionMembers = "Inherit from service","Create purchase document","Create journal line";
        }
        field(4; "Create Document V1 Behavior"; Boolean)
        {
        }
    }
}