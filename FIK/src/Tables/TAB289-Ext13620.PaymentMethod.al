// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13620 PaymentMethod extends "Payment Method"
{
    fields
    {
        field(13652; PaymentTypeValidation; Option)
        {
            OptionMembers = " ","FIK 71","FIK 73","FIK 01","FIK 04",Domestic,International;
            Caption = 'Payment Type Validation';
        }
    }
}