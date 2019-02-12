// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 11026 "Elster VAT Statement Name" extends "VAT Statement Name"
{
    fields
    {
        field(11020; "Sales VAT Adv. Notif."; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales VAT Adv. Notification';

            trigger OnValidate()
            begin
                CheckSalesVATAdvNotif();
            end;

        }
    }

    trigger OnBeforeInsert()
    begin
        CheckSalesVATAdvNotif();
    end;

    var
        AlreadyExistsErr: Label 'There is already a %1 set up for %2.';

    local procedure CheckSalesVATAdvNotif()
    var
        VATStatementName: Record "VAT Statement Name";
    begin
        if "Sales VAT Adv. Notif." then begin
            VATStatementName.SetRange("Sales VAT Adv. Notif.", true);
            VATStatementName.SetFilter("Statement Template Name", '<>%1', "Statement Template Name");
            if not VATStatementName.IsEmpty() then
                Error(AlreadyExistsErr, TableCaption(), FieldCaption("Sales VAT Adv. Notif."));

            VATStatementName.SetFilter(Name, '<>%1', Name);
            VATStatementName.SetRange("Statement Template Name");
            if not VATStatementName.IsEmpty() then
                Error(AlreadyExistsErr, TableCaption(), FieldCaption("Sales VAT Adv. Notif."));
        end;
    end;

}