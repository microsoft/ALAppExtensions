pageextension 14604 "IS Posted Purch. Credit Memo" extends "Posted Purchase Credit Memo"
{
    trigger OnDeleteRecord(): Boolean
    begin
        Error(DocumentDeletionErr);
    end;

    var
        DocumentDeletionErr: Label 'You cannot delete purchase documents that are posted';
}
