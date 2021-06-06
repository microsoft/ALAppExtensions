codeunit 18150 "Fin Ch. Memo UseCase Dataset"
{
    procedure GetText(): Text
    begin
        exit(GSTOnFinChMemoUseCasesLbl);
    end;

    var
        GSTOnFinChMemoUseCasesLbl: Label 'GST On Finance Charge Memo Use Cases';
}