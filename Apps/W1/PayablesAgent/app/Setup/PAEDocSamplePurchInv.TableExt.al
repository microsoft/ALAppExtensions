// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument.Processing.Import.Purchase;

tableextension 3308 "PA E-Doc Sample Purch. Inv." extends "E-Doc Sample Purch. Inv File"
{
    fields
    {
        field(3308; "Send By Email"; Boolean)
        {
            Caption = 'Send By Email';
            ToolTip = 'Specifies whether the sample purchase invoice should be sent by email.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(SendByEmail; "Send By Email")
        {
        }
    }
}