// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
tableextension 6806 WithholdingSourceCodeSetupExt extends "Source Code Setup"
{
    fields
    {
        field(6784; "Withholding Tax Settlement"; Code[10])
        {
            Caption = 'Withholding Tax Settlement';
            TableRelation = "Source Code";
        }
    }
}