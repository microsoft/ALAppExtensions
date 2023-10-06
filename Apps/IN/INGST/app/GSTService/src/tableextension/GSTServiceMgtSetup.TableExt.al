// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Setup;

using Microsoft.Finance.GST.Base;

tableextension 18442 "GST Service Mgt Setup" extends "Service Mgt. Setup"
{
    fields
    {
        field(18440; "GST Dependency Type"; Enum "GST Dependency Type")
        {
            Caption = 'GST Dependency Type';
            DataClassification = CustomerContent;
        }
    }
}
