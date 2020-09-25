// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13621 PaymentApplication extends "Payment Application"
{
    layout
    {
        modify(Control2)
        {
            Visible = ShowMatchConfidence;
        }
    }
    procedure SetMatchConfidence(Value: Boolean);
    begin
        ShowMatchConfidence := Value;
    end;

    var
        ShowMatchConfidence: Boolean;
}