namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Archive;
using Microsoft.Sales.Document;

tableextension 8068 "Sales Line Archive" extends "Sales Line Archive"
{
    fields
    {
        field(8055; "Service Commitments"; Integer)
        {
            Caption = 'Service Commitments';
            FieldClass = FlowField;
            CalcFormula = count("Sales Service Comm. Archive" where("Document Type" = field("Document Type"), "Document No." = field("Document No."), "Document Line No." = field("Line No."), "Doc. No. Occurrence" = field("Doc. No. Occurrence"), "Version No." = field("Version No.")));
            Editable = false;
        }
        field(8059; "Exclude from Doc. Total"; Boolean)
        {
            Caption = 'Exclude from Document Total';
            DataClassification = CustomerContent;
        }
        modify("No.")
        {
            TableRelation = if (Type = const("Service Object")) "Service Object";

        }
    }

    trigger OnDelete()
    begin
        DeleteSalesServiceCommitmentArchive(Rec);
    end;

    local procedure DeleteSalesServiceCommitmentArchive(var SalesLineArchive: Record "Sales Line Archive")
    var
        SalesServiceCommArchive: Record "Sales Service Comm. Archive";
    begin
        if SalesLineArchive.IsTemporary() then
            exit;

        if not SalesLineArchive.IsSalesDocumentTypeWithServiceCommitments() then
            exit;

        SalesServiceCommArchive.SetRange("Document Type", SalesLineArchive."Document Type");
        SalesServiceCommArchive.SetRange("Document No.", SalesLineArchive."Document No.");
        SalesServiceCommArchive.SetRange("Document Line No.", SalesLineArchive."Line No.");
        SalesServiceCommArchive.SetRange("Doc. No. Occurrence", SalesLineArchive."Doc. No. Occurrence");
        SalesServiceCommArchive.SetRange("Version No.", SalesLineArchive."Version No.");
        if not SalesServiceCommArchive.IsEmpty() then
            SalesServiceCommArchive.DeleteAll(false);
    end;

    procedure IsSalesDocumentTypeWithServiceCommitments(): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine."Document Type" := Rec."Document Type";
        exit(SalesLine.IsSalesDocumentTypeWithServiceCommitments());
    end;
}