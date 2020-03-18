// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13620 PaymentMethod extends "Payment Method"
{
    fields
    {
        field(13652; PaymentTypeValidation; Enum "Payment Type Validation")
        {
            Caption = 'Payment Type Validation';
        }
    }
}