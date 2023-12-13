pageextension 14609 "IS Posted Purchase Invoice" extends "Posted Purchase Invoice"
{
    trigger OnDeleteRecord(): Boolean;
    begin
        Error(DocumentDeletionErr);
    end;

    var
        DocumentDeletionErr: Label 'You cannot delete purchase documents that are posted';
}
