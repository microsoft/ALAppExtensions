// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13610 CompanyInformation extends "Company Information"
{
    layout
    {
        addafter(IBAN)
        {
            field("Bank Creditor No."; BankCreditorNo)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the FIK reference that will be inserted on sales invoice documents to domestic customers.';
            }
        }
    }
}