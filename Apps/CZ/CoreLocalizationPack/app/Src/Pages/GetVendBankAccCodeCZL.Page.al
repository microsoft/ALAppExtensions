// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

page 11752 "Get Vend. Bank Acc. Code CZL"
{
    Caption = 'Get Vendor Bank Account Code';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(VendorNo; VendorNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor No.';
                    ToolTip = 'Specifies vendor for create bank account.';
                    Editable = false;
                }
                field(VendorBankAccCode; VendorBankAccCode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor Bank Account Code';
                    ToolTip = 'Specifies vendor bank account code.';
                }
                field(VendorBankAccName; VendorBankAccName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor Bank Account Name';
                    ToolTip = 'Specifies vendor bank account name.';
                }
            }
        }
    }
    var
        VendorNo: Code[20];
        VendorBankAccCode: Code[10];
        VendorBankAccName: Text[100];

    procedure SetValue(NewVendorNo: Code[20])
    begin
        VendorNo := NewVendorNo;
    end;

    procedure GetValue(var NewVendorBankAccCode: Code[10]; var NewVendorBankAccName: Text[100])
    begin
        NewVendorBankAccCode := VendorBankAccCode;
        NewVendorBankAccName := VendorBankAccName;
    end;
}
