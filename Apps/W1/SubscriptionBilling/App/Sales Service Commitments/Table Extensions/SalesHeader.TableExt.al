namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

tableextension 8053 "Sales Header" extends "Sales Header"
{
    fields
    {
        field(8051; "Recurring Billing"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Recurring Billing';
        }
        field(8052; "Contract Detail Overview"; Enum "Contract Detail Overview")
        {
            Caption = 'Contract Detail Overview';
            DataClassification = CustomerContent;
        }
    }
    internal procedure GetLastLineNo(): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", "Document Type");
        SalesLine.SetRange("Document No.", "No.");
        if SalesLine.FindLast() then
            exit(SalesLine."Line No.");
    end;

    internal procedure GetNextLineNo(): Integer
    begin
        exit(GetLastLineNo() + 10000);
    end;

    internal procedure HasOnlyContractRenewalLines(): Boolean
    var
        SalesLine: Record "Sales Line";
        HasContractRenewalLines: Boolean;
    begin
        SalesLine.SetRange("Document Type", Rec."Document Type");
        SalesLine.SetRange("Document No.", Rec."No.");
        SalesLine.SetFilter(Type, '<>%1', "Sales Line Type"::" ");
        if SalesLine.FindSet() then begin
            HasContractRenewalLines := true;
            repeat
                if not SalesLine.IsContractRenewal() then
                    HasContractRenewalLines := false;
            until (SalesLine.Next() = 0) or (HasContractRenewalLines = false);
        end;
        exit(HasContractRenewalLines);
    end;
}