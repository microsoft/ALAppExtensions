// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

tableextension 11514 "Swiss QR-Bill Gen Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(11500; "Swiss QR-Bill"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
