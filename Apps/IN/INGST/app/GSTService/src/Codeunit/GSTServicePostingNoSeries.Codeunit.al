codeunit 18441 "GST Service Posting No. Series"
{

    procedure GetPostingNoSeriesforservice(var Rec: Record "Service Header")
    begin
        GetPostingNoSeries(Rec);
    end;

    local procedure GetPostingNoSeries(var Rec: Record "Service Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        Record: Variant;
    begin
        Record := Rec;
        PostingNoSeries.GetPostingNoSeriesCode(Record);
        Rec := Record;
    end;

    //No Series for Service 
    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEvent(var Rec: Record "Service Header")
    begin
        if not Rec.IsTemporary() then
            GetPostingNoSeries(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure SelltoCustomer(var Rec: Record "Service Header")
    begin
        GetPostingNoSeries(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Bill-to Customer no.', false, false)]
    local procedure BilltoCustomer(var Rec: Record "Service Header")
    begin
        GetPostingNoSeries(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Contact No.', false, false)]
    local procedure SelltoContact(var Rec: Record "Service Header")
    begin
        GetPostingNoSeries(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Bill-to Contact No.', false, false)]
    local procedure BilltoContact(var Rec: Record "Service Header")
    begin
        GetPostingNoSeries(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Trading', false, false)]
    local procedure Trading(var Rec: Record "Service Header")
    begin
        GetPostingNoSeries(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Location Code', false, false)]
    local procedure Location(var Rec: Record "Service Header")
    begin
        GetPostingNoSeries(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Invoice Type', false, false)]
    local procedure ServiceInvoiceType(var Rec: Record "Service Header")
    begin
        GetPostingNoSeries(Rec);
    end;

}