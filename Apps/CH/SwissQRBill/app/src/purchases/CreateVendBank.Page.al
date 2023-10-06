// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Purchases.Vendor;

page 11502 "Swiss QR-Bill Create Vend Bank"
{
    Caption = 'Create a new vendor bank account';
    PageType = Card;
    SourceTable = "Vendor Bank Account";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            grid(GeneralGrid)
            {
                Caption = '';
                ShowCaption = false;
                GridLayout = Rows;

                group(GeneralGroup)
                {
                    Caption = '';
                    ShowCaption = false;

                    field(VendorNo; "Vendor No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the vendor number.';
                    }
                    field(BankAccountCodeField; BankAccountCode)
                    {
                        Caption = 'Code';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies a code to identify this vendor bank account.';

                        trigger OnValidate()
                        begin
                            Code := BankAccountCode;
                            CheckNotExists();
                        end;
                    }
                    field(IBAN; IBAN)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'IBAN/QR-IBAN';
                        ToolTip = 'Specifies the IBAN or QR-IBAN account of the vendor.';
                    }
                }
            }
        }
    }

    var
        BankAccountCode: Code[20];
        AlreadyExistsErr: Label 'Vendor bank account already exists.';

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::LookupOK then
            TestField(Code);
    end;

    internal procedure SetDetails(VendorBankAccount: Record "Vendor Bank Account")
    begin
        if Delete() then;
        TransferFields(VendorBankAccount);
        Insert();
    end;

    internal procedure GetDetails(var VendorBankAccount: Record "Vendor Bank Account")
    begin
        VendorBankAccount := Rec;
    end;

    local procedure CheckNotExists()
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        VendorBankAccount.SetRange("Vendor No.", "Vendor No.");
        VendorBankAccount.SetRange(Code, Code);
        if not VendorBankAccount.IsEmpty() then
            Error(AlreadyExistsErr);
    end;
}
