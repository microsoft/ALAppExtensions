﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

pageextension 13662 "OIOUBL-FinChrgMemoLines" extends "Finance Charge Memo Lines"
{
    layout
    {
        addafter(Amount)
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
        }
    }

    procedure UpdateLines(SetSaveRecord: Boolean);
    begin
        CurrPage.Update(SetSaveRecord);
    end;
}
