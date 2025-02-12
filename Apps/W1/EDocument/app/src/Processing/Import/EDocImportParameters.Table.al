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
        field(2; "Prepare Draft Value Providers"; Enum "E-Doc Purchase Providers")
        {
        }
        field(3; "Finish Purchase Draft Impl."; Enum "E-Doc. Create Purchase Invoice")
        {
        }
    }
}