// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

table 10839 "Payment Status FR"
{
    Caption = 'Payment Status';
    LookupPageID = "Payment Status List FR";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Payment Class"; Text[30])
        {
            Caption = 'Payment Class';
            TableRelation = "Payment Class FR";
        }
        field(2; Line; Integer)
        {
            Caption = 'Line';
        }
        field(3; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(4; RIB; Boolean)
        {
            Caption = 'RIB';
        }
        field(5; Look; Boolean)
        {
            Caption = 'Look';
        }
        field(6; ReportMenu; Boolean)
        {
            Caption = 'ReportMenu';
        }
        field(7; "Acceptation Code"; Boolean)
        {
            Caption = 'Acceptation Code';
        }
        field(8; Amount; Boolean)
        {
            Caption = 'Amount';
        }
        field(9; Debit; Boolean)
        {
            Caption = 'Debit';
        }
        field(10; Credit; Boolean)
        {
            Caption = 'Credit';
        }
        field(11; "Bank Account"; Boolean)
        {
            Caption = 'Bank Account';
        }
        field(20; "Payment in Progress"; Boolean)
        {
            Caption = 'Payment in Progress';
        }
        field(21; "Archiving Authorized"; Boolean)
        {
            Caption = 'Archiving Authorized';
        }
    }

    keys
    {
        key(Key1; "Payment Class", Line)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PaymentStep: Record "Payment Step FR";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin
        if Line = 0 then
            Error(Text000Lbl);
        PaymentStep.SetRange("Payment Class", "Payment Class");
        PaymentStep.SetRange("Previous Status", Line);
        if PaymentStep.FindFirst() then
            Error(Text001Lbl);
        PaymentStep.SetRange("Previous Status");
        PaymentStep.SetRange("Next Status", Line);
        if not PaymentStep.IsEmpty() then
            Error(Text001Lbl);
        PaymentHeader.SetRange("Payment Class", "Payment Class");
        PaymentHeader.SetRange("Status No.", Line);
        if not PaymentHeader.IsEmpty() then
            Error(Text001Lbl);
        PaymentLine.SetRange("Payment Class", "Payment Class");
        PaymentLine.SetRange("Status No.", Line);
        if not PaymentLine.IsEmpty() then
            Error(Text001Lbl);
    end;

    trigger OnInsert()
    var
        PaymentStatus: Record "Payment Status FR";
    begin
        if not PaymentStatus.Get("Payment Class", 0) then
            Line := 0;
    end;

    var
        Text000Lbl: Label 'Deleting the first report is not allowed.';
        Text001Lbl: Label 'Deleting is not allowed because this Payment Status is already used.';
}

